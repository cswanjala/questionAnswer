# core/serializers.py
from rest_framework import serializers
from .models import ChatMessage, FavoriteExpert, Notification, Ratings, User, Expert, Question, Answer, MembershipPlan,Category
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import authenticate

class UserSerializer(serializers.ModelSerializer):
    categories = serializers.ListField(
        child=serializers.CharField(max_length=100),
        write_only=True,
        required=False
    )
    title = serializers.CharField(max_length=30, required=False)
    profile_picture = serializers.ImageField(max_length=100, required=False, allow_empty_file=True, use_url=True)  # Ensure profile_picture can handle image uploads

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'is_expert', 'profile_picture', 'categories', 'title']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        categories_data = validated_data.pop('categories', [])
        title = validated_data.pop('title', None)
        profile_picture = validated_data.pop('profile_picture', None)
        user = User.objects.create_user(**validated_data)
        
        if profile_picture:
            user.profile_picture = profile_picture
            user.save()

        if validated_data.get('is_expert', False):
            expert = Expert.objects.create(user=user, title=title)
            for category_name in categories_data:
                category, created = Category.objects.get_or_create(name=category_name)
                expert.categories.add(category)
        
        return user
    

class ExpertAverageRatingSerializer(serializers.Serializer):
    expert_id = serializers.IntegerField()
    average_rating = serializers.FloatField()


class ExpertSerializer(serializers.ModelSerializer):
    user = UserSerializer()  # Nested serializer to include user details
    average_rating = serializers.SerializerMethodField()
    categories = serializers.SerializerMethodField()

    class Meta:
        model = Expert
        fields = ['id', 'user', 'categories', 'average_rating', 'title']

    def get_average_rating(self, obj):
        """Return the calculated average rating of the expert."""
        return obj.average_rating

    def get_categories(self, obj):
        """Return a list of category names instead of IDs."""
        return obj.categories.values_list('name', flat=True)

    def create(self, validated_data):
        # Extract user data from validated_data
        user_data = validated_data.pop('user')
        
        # Create the user object
        user = User.objects.create_user(
            username=user_data['username'],
            email=user_data['email'],
            password=user_data['password'],
            profile_picture=user_data.get('profile_picture'),
        )
        
        # Create the expert object
        expert = Expert.objects.create(user=user, **validated_data)

        # Add categories to the expert
        categories = self.initial_data.get('categories', "").split(',')
        for category_name in categories:
            category = Category.objects.get(name=category_name)
            expert.categories.add(category)

        # Return the created expert
        return expert


class MembershipSerializer(serializers.ModelSerializer):
   user = UserSerializer(read_only=True)
   class Meta:
       model = MembershipPlan 
       fields = ['user','name','price','duration days','can_ask_unlimited','can_chat_with expert']
class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ratings
        fields = '__all__'

class QuestionSerializer(serializers.ModelSerializer):
    assigned_expert = ExpertSerializer(read_only=True)  # Assigned by the backend
    client = UserSerializer(read_only=True)  # Assigned by the backend

    class Meta:
        model = Question
        fields = ['id', 'client','content', 'created_at', 'category', 'is_active', 'assigned_expert','image']
        read_only_fields = ['assigned_expert']  # Explicitly read-only

    def create(self, validated_data):
        # Remove 'client' from validated_data if it exists
        validated_data.pop('client', None)  
        
        # Create a new question with the explicitly provided client
        return Question.objects.create(client=self.context['request'].user, **validated_data)



class AnswerSerializer(serializers.ModelSerializer):
    rating_value = serializers.SerializerMethodField()

    class Meta:
        model = Answer
        fields = ['id', 'question', 'expert', 'content', 'created_at', 'rating_value']

    # def validate(self, data):
    #     question = data.get('question')
    #     if question.assigned_expert != self.context['request'].user:
    #         raise serializers.ValidationError("You are not the assigned expert for this question.")
    #     return data
    def validate(self, data):
        if not data['question'].is_active:
            raise serializers.ValidationError("This question is no longer active.")
        return data

    def get_rating_value(self, obj):
        # If the Answer has a related Rating, return the star value, else return None or a default value
        return obj.ratings.stars if obj.ratings else None

class MembershipPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = MembershipPlan
        fields = '__all__'

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'


# from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
# from rest_framework.exceptions import AuthenticationFailed
# from django.contrib.auth import authenticate

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username_or_email = attrs.get('username')
        password = attrs.get('password')

        # Attempt to authenticate using email
        user = authenticate(request=self.context.get('request'), username=username_or_email, password=password)
        if not user:
            try:
                from django.contrib.auth import get_user_model
                User = get_user_model()
                user = User.objects.get(email=username_or_email)
                if not user.check_password(password):
                    raise User.DoesNotExist
            except User.DoesNotExist:
                raise AuthenticationFailed('Invalid credentials')

        if user and not user.is_active:
            raise AuthenticationFailed('User account is disabled')

        # Create tokens if authentication is successful
        refresh = self.get_token(user)
        data = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'id': user.id,
            'username': user.username,  # Add the username to the response data
            'is_expert': user.is_expert,  # Add the is_expert flag to the response data
        }
        return data

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = "__all__"

class ChatMessageSerializer(serializers.ModelSerializer):
    question = QuestionSerializer(read_only=True)
    sender_username = serializers.CharField(source="sender.username", read_only=True)
    recipient_username = serializers.CharField(source="receiver.username", read_only=True)
    sender_profile_picture = serializers.ImageField(source="sender.profile_picture", read_only=True)
    recipient_profile_picture = serializers.ImageField(source="receiver.profile_picture", read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'sender', 'receiver','question', 'sender_username', 'recipient_username', 'sender_profile_picture', 'recipient_profile_picture', 'message', 'timestamp']



class FavoriteExpertSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    expert = ExpertSerializer(read_only=True)
    class Meta:
        model = FavoriteExpert
        fields = ['user', 'expert']
        read_only_fields = ['user']

class RatingsSerializer(serializers.ModelSerializer):
    # question = QuestionSerializer(read_only=True)
    class Meta:
        model = Ratings
        fields = ['id', 'stars', 'question']