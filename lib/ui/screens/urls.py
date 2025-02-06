# core/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    AllMessagesView,
    AssignedQuestionsView,
    ChatMessageView,
    CreatePaymentIntentView,
    ExpertAverageRatingView,
    FavoriteExpertView,
    NotificationViewSet,
    RatingsViewSet,
    UserViewSet,
    ExpertViewSet,
    QuestionViewSet,
    AnswerViewSet,
    MembershipPlanViewSet,
    CategoryViewSet,
    RegisterUserView,
    LoginView,
    CurrentUserView,
    add_card,
    add_favorite_expert,
    create_chat_message,
    get_favorite_experts,
    index, # Import the chat message viewset
    get_chat_messages,
    store_payment_details,
    CreateInfuraPaymentView,
    CompleteExpertRegistrationView
)
from rest_framework_simplejwt.views import TokenObtainPairView


# Define and register routes using DefaultRouter
router = DefaultRouter()
router.register('users', UserViewSet, basename='user')
router.register('experts', ExpertViewSet, basename='expert')
router.register('questions', QuestionViewSet, basename='question')
router.register('answers', AnswerViewSet, basename='answer')
router.register('membership-plans', MembershipPlanViewSet, basename='membershipplan')
router.register('categories', CategoryViewSet, basename='category')
router.register('notifications', NotificationViewSet, basename='notification')
# router.register('ratings', NotificationViewSet, basename='ratings')
router.register('ratings', RatingsViewSet,basename='ratings')

# Combine router URLs with custom paths
urlpatterns = [
    path('', include(router.urls)),  # Include all router-generated URLs
    path('register/', RegisterUserView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('chat-messages/<int:recipient>/', ChatMessageView.as_view(), name='chat-messages'),
    path("chat/", index, name="index"),
    path('user/', CurrentUserView.as_view(), name='current_user'),
    path('get_chat_messages/<str:room_name>/', get_chat_messages, name='get_chat_messages'),
    path('favorites/', FavoriteExpertView.as_view(), name='favorite_experts'),
    path('messages/', AllMessagesView.as_view(), name='all-messages'),
    path('payments/create-intent/', CreatePaymentIntentView.as_view(), name='create-payment-intent'),
    path('add_card/', add_card, name='add_card'),
    path('addfavexpert',add_favorite_expert,name='add_favourite_expert'),
    path('get_favorite_experts/', get_favorite_experts, name='get_favorite_experts'),
    path('create_chat_message/', create_chat_message, name='create_chat_message'),
    path('user/', CurrentUserView.as_view(), name='current_user'), 
    path('store-payment-details/', store_payment_details, name='store_payment_details'),
    path('assigned-questions/', AssignedQuestionsView.as_view(), name='assigned-questions'),
    path('expert_average_rating/<int:expert_id>/', ExpertAverageRatingView.as_view(), name='expert_average_rating'),
    path('infura/create-payment/', CreateInfuraPaymentView.as_view(), name='create-infura-payment'),
    path('complete-expert-registration/', CompleteExpertRegistrationView.as_view(), name='complete_expert_registration'),
]


