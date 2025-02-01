from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

class User(AbstractUser):
    is_expert = models.BooleanField(default=False)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)

    groups = models.ManyToManyField(
        Group,
        related_name="custom_user_set",  # Change related_name to avoid clashes
        blank=True,
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name="custom_user_permissions_set",  # Change related_name to avoid clashes
        blank=True,
    )

class Ratings(models.Model):
    stars = models.FloatField(validators=[MinValueValidator(0.0), MaxValueValidator(5.0)], default=0.0)

    def __str__(self):
        return f"{self.stars} stars"

class Category(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Expert(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    rating = models.FloatField(default=0.0)
    categories = models.ManyToManyField(Category)
    title = models.CharField(max_length = 30,default="Expert")

    def __str__(self):
        return self.user.username

    @property
    def average_rating(self):
        # Get all answers for this expert where they have been assigned to the question
        answers = Answer.objects.filter(expert=self)
        total_ratings = sum(answer.ratings.stars for answer in answers if answer.ratings)
        total_answers = answers.count()

        # Calculate the average rating if there are any answers
        if total_answers > 0:
            return total_ratings / total_answers
        return 0.0  # Return 0.0 if no ratings exist for this expert
    
class FavoriteExpert(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="favorite_experts")
    expert = models.ForeignKey(Expert, on_delete=models.CASCADE, related_name="favorited_by")

    class Meta:
        unique_together = ('user', 'expert')  # Prevent duplicates

    def __str__(self):
        return f"{self.user.username} favorited {self.expert.user.username}"


class MembershipPlan(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    duration_days = models.IntegerField()
    can_ask_unlimited = models.BooleanField(default=False)
    can_chat_with_expert = models.BooleanField(default=False)

    def __str__(self):
        return self.name

# class Payment(models.Model):
#     user = models.ForeignKey(User, on_delete=models.CASCADE)
#     amount = models.DecimalField(max_digits=10, decimal_places=2)
#     date = models.DateTimeField(auto_now_add=True)
#     membership_plan = models.ForeignKey(MembershipPlan, null=True, blank=True, on_delete=models.SET_NULL)

#     def __str__(self):
#         return f"{self.user.username} paid {self.amount} for {self.membership_plan}"

class Question(models.Model):
    client = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    assigned_expert = models.ForeignKey(Expert, null=True, blank=True, on_delete=models.SET_NULL,related_name='assigned_questions')
    is_active = models.BooleanField(default=True)
    image = models.ImageField(upload_to='question_images/', null=True, blank=True)

    def __str__(self):
        return self.content[:50]

class Answer(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    ratings = models.ForeignKey(Ratings, on_delete=models.CASCADE, null=True, blank=True)  # Optional ratings
    expert = models.ForeignKey(Expert, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.content[:50]

    def update_rating(self, user, new_rating):
        """
        Method to update the rating, ensuring only the question owner can update.
        """
        if self.question.user == user:  # Ensure only the user who owns the question can update the rating
            self.ratings.stars = new_rating
            self.ratings.save()
        else:
            raise PermissionError("You are not authorized to update the rating.")
        

class Notification(models.Model):
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notifications")
    sender = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="sent_notifications")
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"Notification for {self.recipient.username} - {self.message[:20]}"
    

class ChatMessage(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    message = models.TextField()
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='chat_messages') 
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.sender} -> {self.receiver}: {self.message[:50]}"
    

class Payment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=15.00)
    status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ], default='pending')  # Add default value for status
    created_at = models.DateTimeField(auto_now_add=True)

class PaymentDetail(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    stripe_payment_method_id = models.CharField(max_length=255, unique=True)
    card_brand = models.CharField(max_length=50)
    card_last4 = models.CharField(max_length=4)
    payment_status = models.CharField(max_length=50, default='pending')

    def __str__(self):
        return f"{self.card_brand} ending in {self.card_last4}"

class FavoriteExpert(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="favorite_experts")
    expert = models.ForeignKey(Expert, on_delete=models.CASCADE, related_name="favorited_by")

    class Meta:
        unique_together = ('user', 'expert')  # Prevent duplicates

    def __str__(self):
        return f"{self.user.username} favorited {self.expert.user.username}"