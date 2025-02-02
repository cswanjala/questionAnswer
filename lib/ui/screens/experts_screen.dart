import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/features/experts/controllers/experts_provider.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';

class ExpertsListScreen extends StatelessWidget {
  const ExpertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expertsProvider = Provider.of<ExpertsProvider>(context, listen: false);

    // Fetch current user data when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await expertsProvider.fetchCurrentUser();
      expertsProvider.fetchExperts();
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(ApiConstants.expertsListTitle),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ApiConstants.expertsListSubtitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Consumer<ExpertsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (provider.experts.isEmpty) {
                    return Center(
                      child: Text(
                        ApiConstants.noExpertsMessage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: provider.experts.length,
                      itemBuilder: (context, index) {
                        final expert = provider.experts[index];
                        final currentUser = provider.currentUser;

                        return _buildExpertCard(
                          context: context,
                          expertName: expert['user']['username'],
                          id: expert['id'],
                          userId: expert['user']['id'],
                          title: expert['title'] ?? ApiConstants.defaultTitle,
                          rating: expert['average_rating']?.toDouble() ?? 0.0,
                          categories: expert['categories'],
                          profilePicture: expert['user']['profile_picture'],
                          senderUsername: currentUser['username'] ?? 'Unknown',
                          recipientUsername: expert['user']['username'],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard({
    required BuildContext context,
    required String expertName,
    required int id,
    required int userId,
    required String title,
    required double rating,
    required List<dynamic> categories,
    required String senderUsername,
    required String recipientUsername,
    String? profilePicture,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 30,
                  backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                    ? NetworkImage(profilePicture)
                    : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expertName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    final user = await Provider.of<ExpertsProvider>(context, listen: false).currentUser;
                    if (userId != null) {
                      try {
                        // Add the selected expert to favorites
                        final response = await Provider.of<ExpertsProvider>(context, listen: false)
                            .addFavoriteExpert(userId);

                        // Handle the response as needed (e.g., show success message)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Expert added to favorites!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add expert to favorites: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not logged in')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStarRating(rating),
                const SizedBox(width: 8),
                Text(
                  "$rating/5",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${ApiConstants.categoriesLabel}: ${categories.join(", ")}",
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  final authToken = Provider.of<ExpertsProvider>(context, listen: false).authToken;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        senderUsername: senderUsername,
                        recipientUsername: recipientUsername,
                        expertName: expertName,
                        expertImage: profilePicture ?? "",
                        expertCategory: title,
                        authToken: authToken,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(60, 30),
                ),
                child: const Text(
                  ApiConstants.askButtonLabel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 16),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 16),
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 16),
      ],
    );
  }
}
