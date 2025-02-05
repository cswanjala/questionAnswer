# core/views.py
import json
from django.forms import ValidationError
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from rest_framework import viewsets
from .models import ChatMessage, FavoriteExpert, Notification, PaymentDetail, User, Expert, Question, Answer, MembershipPlan,Category,Ratings
from .serializers import ChatMessageSerializer, CustomTokenObtainPairSerializer, ExpertAverageRatingSerializer, FavoriteExpertSerializer, NotificationSerializer, RatingSerializer, RatingsSerializer, UserSerializer, ExpertSerializer, QuestionSerializer, AnswerSerializer, MembershipPlanSerializer,CategorySerializer
from django.core.exceptions import PermissionDenied

from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.permissions import IsAuthenticated
from .utils import assign_expert_to_question, notify_expert
from .permissions import IsAssignedExpert, IsQuestionOwner
from rest_framework.viewsets import ReadOnlyModelViewSet
from rest_framework.decorators import api_view,permission_classes
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt

import stripe

stripe.api_key = settings.STRIPE_SECRET_KEY

class CreatePaymentIntentView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            data = request.data
            amount = 500  # Amount in cents
            currency = 'usd'

            if amount <= 0:
                return Response({"error": "Invalid amount"}, status=status.HTTP_400_BAD_REQUEST)

            # Create a PaymentIntent
            intent = stripe.PaymentIntent.create(
                amount=amount,
                currency=currency,
                metadata={'integration_check': 'accept_a_payment'}
            )
            print("payment made")

            return Response({
                "clientSecret": intent['client_secret']
            }, status=status.HTTP_200_OK)
        except stripe.error.StripeError as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"error": "Something went wrong"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class MembershipViewSet(viewsets.ModelViewSet):
    queryset = MembershipPlan.objects.all()
    serializer_class = MembershipPlanSerializer()


def index(request):
    return render(request, "chat/index.html")

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class ExpertViewSet(viewsets.ModelViewSet):
    queryset = Expert.objects.all()
    serializer_class = ExpertSerializer

class ExpertAverageRatingView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, expert_id):
        try:
            expert = Expert.objects.get(id=expert_id)
        except Expert.DoesNotExist:
            return Response({"error": "Expert not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get all questions assigned to the expert that have ratings
        questions_with_ratings = Question.objects.filter(assigned_expert=expert, ratings__isnull=False)
        
        # Compute the total and average rating
        total_ratings = sum(rating.stars for question in questions_with_ratings for rating in question.ratings.all())
        total_questions = questions_with_ratings.count()
        average_rating = total_ratings / total_questions if total_questions > 0 else 0.0

        # Prepare the response data
        response_data = {
            "expert_id": expert.id,
            "average_rating": average_rating
        }

        serializer = ExpertAverageRatingSerializer(response_data)
        return Response(serializer.data, status=status.HTTP_200_OK)

class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class RatingsViewSet(viewsets.ModelViewSet):
    queryset = Ratings.objects.all()
    serializer_class = RatingsSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        rating = serializer.save()
        question = rating.question

        # Deactivate the question
        question.is_active = False
        question.save()
    

class QuestionViewSet(viewsets.ModelViewSet):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Question.objects.filter(is_active=True)
        elif user.is_expert:
            return Question.objects.filter(assigned_expert__user=user, is_active=True)
        return Question.objects.filter(client=user, is_active=True)

    def perform_create(self, serializer):
        question = serializer.save(client=self.request.user, is_active=True)
        expert = assign_expert_to_question(question, client=self.request.user)
        if expert:
            notify_expert(expert, question)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        question = Question.objects.get(pk=response.data['id'])
        assigned_expert = question.assigned_expert

        # Include payment status in the response
        response.data.update({
            "assigned_expert": assigned_expert.user.username if assigned_expert else "No expert available",
        })

        return response

    def store_payment_details(self, payment_method_id):
        """ Store the payment method details securely (only tokenized data) """
        try:
            # Retrieve the payment method details using the ID
            payment_method = stripe.PaymentMethod.retrieve(payment_method_id)
            
            # You can store the card details in your database (but only store the token)
            # Example: Store the card brand and last 4 digits for display purposes.
            PaymentDetail.objects.create(
                user=self.request.user,
                stripe_payment_method_id=payment_method.id,
                card_brand=payment_method.card['brand'],
                card_last4=payment_method.card['last4'],
                payment_status='succeeded'  # Mark payment as succeeded
            )
        except stripe.error.StripeError as e:
            raise Exception("Failed to store payment method: " + str(e))


class AnswerViewSet(viewsets.ModelViewSet):
    queryset = Answer.objects.all()
    serializer_class = AnswerSerializer
    permission_classes = [IsAuthenticated, IsAssignedExpert,IsQuestionOwner]

    def get_queryset(self):
        
        user = self.request.user
        if user.is_staff:
            return Answer.objects.all()
        return Answer.objects.filter(question__client=user)

    def perform_create(self, serializer):
        question = serializer.validated_data.get('question')

        # Check to ensure there was an expert for that question
        if question.assigned_expert:
            if question.assigned_expert.user != self.request.user:
                raise PermissionDenied("Hey "+self.request.user.username + " this question was assigned to "+question.assigned_expert.user.username)
            serializer.save()
        else:
            #assign the current user to handle that question
            #check if the current user is an expert
            if self.request.user.is_expert:
                print("The user is an expert : ",self.request.user.is_expert)
                question.assigned_expert = Expert.objects.get(user=self.request.user)
                serializer.save()
            else:
                raise PermissionDenied("Hey "+self.request.user.username + " only experts can answer this question...")


        

class MembershipPlanViewSet(viewsets.ModelViewSet):
    queryset = MembershipPlan.objects.all()
    serializer_class = MembershipPlanSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


class RegisterUserView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Generate JWT token
            refresh = RefreshToken.for_user(user)
            return Response({
                "user": UserSerializer(user).data,
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class AssignedQuestionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Get all questions assigned to the current authenticated expert.
        """
        user = request.user

        # Ensure the user is an expert
        if not hasattr(user, 'expert'):
            return Response({"error": "You are not an expert."}, status=status.HTTP_403_FORBIDDEN)

        # Retrieve questions assigned to the expert
        questions = Question.objects.filter(assigned_expert=user.expert)

        serializer = QuestionSerializer(questions, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class LoginView(TokenObtainPairView):
    """
    This view handles JWT login.
    """
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        # Call the parent class's post method to get the JWT tokens
        response = super().post(request, *args, **kwargs)
        
        # The username and id are already added in the serializer
        return response


class NotificationViewSet(ReadOnlyModelViewSet):
    """
    View to list and retrieve notifications for the logged-in user.
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Only return notifications for the logged-in user
        return Notification.objects.filter(recipient=self.request.user).order_by("-created_at")


class AssignExpertView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, question_id):
        question = get_object_or_404(Question, id=question_id)
        expert = get_object_or_404(User, id=request.data.get('expert_id'))

        if not request.user.is_authenticated or not request.user.is_staff:
            return Response({"error": "You do not have permission to assign experts."}, status=403)

        assign_expert_to_question(question, expert, request.user)
        return Response({"message": "Expert assigned successfully."})

class ChatMessageView(APIView):
    """
    View to retrieve chat messages for a specific recipient.
    """
    def get(self, request, recipient, format=None):
        # Filter chat messages based on recipient id
        try:
            chat_messages = ChatMessage.objects.filter(recipient_id=recipient)  # Adjust the filter based on your model
            if not chat_messages:
                return Response({"detail": "No messages found for this recipient."}, status=status.HTTP_404_NOT_FOUND)
            serializer = ChatMessageSerializer(chat_messages, many=True)
            return Response(serializer.data)
        except ChatMessage.DoesNotExist:
            return Response({"detail": "Messages not found."}, status=status.HTTP_404_NOT_FOUND)
        
    def post(self, request, recipient, format=None):
        """
        Allows sending a new chat message to a recipient.
        """
        # Add the recipient to the incoming data
        data = request.data
        
        data['recipient'] = recipient  # Set the recipient to the one specified in the URL
        data['sender'] = request.user.id

        

        # Serialize the data
        serializer = ChatMessageSerializer(data=data)
        
        if serializer.is_valid():
            # Save the new message to the database
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Return the current authenticated user's details.
        """
        user = request.user  # Get the currently authenticated user
        serializer = UserSerializer(user)  # Serialize the user data
        return Response(serializer.data, status=status.HTTP_200_OK)
    

@api_view(['GET'])
def get_chat_messages(request, room_name):
    # Extract participants from room_name
    participants = room_name.split('_')
    if len(participants) != 2:
        return Response({"error": "Invalid room name format."}, status=400)

    sender_username, receiver_username = participants

    # Query for messages sent between the two users
    messages = ChatMessage.objects.filter(
        sender__username=sender_username, receiver__username=receiver_username
    ) | ChatMessage.objects.filter(
        sender__username=receiver_username, receiver__username=sender_username
    )
    messages = messages.order_by('timestamp')

    serialized_messages = [
        {
            "message": msg.message,
            "sender": msg.sender.username,
            "receiver": msg.receiver.username,
            "timestamp": msg.timestamp,
            "content":msg.question.content,
            "question_id":msg.question.id
        }
        for msg in messages
    ]
    return Response(serialized_messages)

class FavoriteExpertView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """
        Add an expert to the user's favorites.
        """
        expert_id = request.data.get('expert_id')
        if not expert_id:
            return Response({"error": "Expert ID is required."}, status=status.HTTP_400_BAD_REQUEST)

        expert = Expert.objects.filter(id=expert_id).first()
        if not expert:
            return Response({"error": "Expert not found."}, status=status.HTTP_404_NOT_FOUND)

        # Add the favorite expert
        favorite, created = FavoriteExpert.objects.get_or_create(user=request.user, expert=expert)
        if not created:
            return Response({"message": "Expert is already in your favorites."}, status=status.HTTP_200_OK)

        serializer = FavoriteExpertSerializer(favorite)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def get(self, request):
        """
        Retrieve all favorite experts for the logged-in user.
        """
        favorites = FavoriteExpert.objects.filter(user=request.user)
        serializer = FavoriteExpertSerializer(favorites, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AllMessagesView(APIView):
    """
    API view to retrieve all messages between different senders and receivers.
    """

    def get(self, request, *args, **kwargs):
        # Retrieve all ChatMessages from the database
        messages = ChatMessage.objects.all()

        # Serialize the data
        serializer = ChatMessageSerializer(messages, many=True)

        # Return the serialized data in API response
        return Response(serializer.data, status=status.HTTP_200_OK)
    

import stripe
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import PaymentDetail

stripe.api_key = settings.STRIPE_SECRET_KEY

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_card(request):
    user = request.user
    card_data = request.data

    try:
        # Get the token from the request data
        token = card_data.get('token')
        if not token:
            return Response({"success": False, "error": "Token is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Create a PaymentMethod with Stripe using the token
        payment_method = stripe.PaymentMethod.create(
            type="card",
            card={
                "token": token,
            },
            billing_details={
                "name": card_data['cardholder_name'],
            },
        )

        # Attach the PaymentMethod to the customer
        stripe.PaymentMethod.attach(
            payment_method.id,
            customer=user.stripe_customer_id,
        )

        # Save the card details in the database
        PaymentDetail.objects.create(
            user=user,
            stripe_payment_method_id=payment_method.id,
            card_brand=payment_method.card['brand'],
            card_last4=payment_method.card['last4'],
        )

        return Response({"success": True, "message": "Card added successfully!"}, status=status.HTTP_200_OK)
    except stripe.error.CardError as e:
        return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"error": "An error occurred"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_favorite_expert(request):
    user = request.user
    print(request.data)
    expert_id = request.data.get('expert_id')
    

    if not expert_id:
        return Response({"error": "Expert ID is required."}, status=status.HTTP_400_BAD_REQUEST)
    
    print("past expert id")

    try:
        expert = Expert.objects.get(id=expert_id)
    except Expert.DoesNotExist:
        return Response({"error": "Expert not found."}, status=status.HTTP_404_NOT_FOUND)

    favorite_expert, created = FavoriteExpert.objects.get_or_create(user=user, expert=expert)
    print(favorite_expert)

    if not created:
        return Response({"error": "Expert is already in your favorites."}, status=status.HTTP_400_BAD_REQUEST)

    serializer = FavoriteExpertSerializer(favorite_expert)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_favorite_experts(request):
    user = request.user
    favorite_experts = FavoriteExpert.objects.filter(user=user)
    serializer = FavoriteExpertSerializer(favorite_experts, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

class FavoriteExpertViewSet(viewsets.ModelViewSet):
        queryset = FavoriteExpert.objects.all()
        serializer_class = FavoriteExpertSerializer
        permission_classes = [IsAuthenticated]

        def get_queryset(self):
            return FavoriteExpert.objects.filter(user=self.request.user)

        def create(self, request, *args, **kwargs):
            expert_id = request.data.get('expert_id')
            if not expert_id:
                return Response({"error": "Expert ID is required."}, status=status.HTTP_400_BAD_REQUEST)

            try:
                expert = Expert.objects.get(id=expert_id)
            except Expert.DoesNotExist:
                return Response({"error": "Expert not found."}, status=status.HTTP_404_NOT_FOUND)

            favorite_expert, created = FavoriteExpert.objects.get_or_create(user=request.user, expert=expert)

            if not created:
                return Response({"error": "Expert is already in your favorites."}, status=status.HTTP_400_BAD_REQUEST)

            serializer = self.get_serializer(favorite_expert)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        

#chat message viewsets
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_chat_message(request):
    sender = request.user
    receiver_id = request.data.get('receiver_id')
    question_id = request.data.get('question_id')
    message = request.data.get('message')

    if not receiver_id or not question_id or not message:
        return Response({"error": "receiver_id, question_id, and message are required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        question = Question.objects.get(id=question_id)
    except Question.DoesNotExist:
        return Response({"error": "Question not found."}, status=status.HTTP_404_NOT_FOUND)

    chat_message = ChatMessage.objects.create(
        sender=sender,
        receiver_id=receiver_id,
        question=question,
        message=message
    )

    serializer = ChatMessageSerializer(chat_message)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
        

@api_view(['POST'])
def store_payment_details(request):
    """
    View to store payment details after a successful payment
    """
    print("store payment triggered...");
    if request.method == 'POST':
        try:
            # Assuming the data comes as JSON
            user_id = request.data.get('user_id')
            stripe_payment_method_id = request.data.get('stripe_payment_method_id')
            card_brand = request.data.get('card_brand')
            card_last4 = request.data.get('card_last4')

            print(request.data);

            # Find the user who made the payment
            user = User.objects.get(id=user_id)
            print(user)

            # Save payment details in the database
            payment_detail = PaymentDetail.objects.create(
                user=user,
                stripe_payment_method_id=stripe_payment_method_id,
                card_brand=card_brand,
                card_last4=card_last4
            )
            print(payment_detail);

            return Response({
                'message': 'Payment details stored successfully.',
                'payment_detail': {
                    'id': payment_detail.id,
                    'user': payment_detail.user.username,
                    'card_brand': payment_detail.card_brand,
                    'card_last4': payment_detail.card_last4,
                }
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

from web3 import Web3

# Infura project ID
INFURA_PROJECT_ID = 'db89f5628f214355971a7a2c3a4d3395'
INFURA_URL = f'https://mainnet.infura.io/v3/{INFURA_PROJECT_ID}'

# Connect to Infura
web3 = Web3(Web3.HTTPProvider(INFURA_URL))

class CreateInfuraPaymentView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            data = request.data
            amount = data.get('amount', 0)
            api_key = data.get('api_key')
            user_address = data.get('user_address')  # Ethereum address of the user
            private_key = data.get('private_key')  # Private key of the user's Ethereum wallet

            if amount <= 0:
                return Response({"error": "Invalid amount"}, status=status.HTTP_400_BAD_REQUEST)

            if not web3.isConnected():
                return Response({"error": "Failed to connect to Infura"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            # Convert amount to Wei (1 Ether = 10^18 Wei)
            amount_in_wei = web3.toWei(amount, 'ether')

            # Create a transaction
            transaction = {
                'to': 'recipient_ethereum_address',  # Replace with your recipient address
                'value': amount_in_wei,
                'gas': 2000000,
                'gasPrice': web3.toWei('50', 'gwei'),
                'nonce': web3.eth.getTransactionCount(user_address),
                'chainId': 1  # Mainnet chain ID
            }

            # Sign the transaction
            signed_txn = web3.eth.account.signTransaction(transaction, private_key)

            # Send the transaction
            txn_hash = web3.eth.sendRawTransaction(signed_txn.rawTransaction)

            # Wait for the transaction receipt
            txn_receipt = web3.eth.waitForTransactionReceipt(txn_hash)

            if txn_receipt.status == 1:
                return Response({
                    "message": "Infura payment processed successfully.",
                    "transaction_hash": txn_hash.hex()
                }, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Transaction failed"}, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)