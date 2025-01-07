import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';

class ExpertsListScreen extends StatefulWidget {
  const ExpertsListScreen({super.key});

  @override
  _ExpertsListScreenState createState() => _ExpertsListScreenState();
}

class _ExpertsListScreenState extends State<ExpertsListScreen> {
  late Future<List<Map<String, dynamic>>> _expertsFuture;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _expertsFuture = ApiService().fetchExperts();
    _loadAuthToken(); // Load auth token on initialization
  }

  // Function to retrieve the authToken from secure storage
  Future<void> _loadAuthToken() async {
    _authToken = await _secureStorage.read(key: ApiConstants.authTokenKey);
    setState(() {}); // Rebuild the widget after fetching the authToken
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(ApiConstants.expertsListTitle),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,  // No back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ApiConstants.expertsListSubtitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _expertsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Failed to load experts: ${snapshot.error}",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ApiConstants.noExpertsMessage,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else {
                    final experts = snapshot.data!;
                    return ListView.builder(
                      itemCount: experts.length,
                      itemBuilder: (context, index) {
                        final expert = experts[index];
                        return _buildExpertCard(
                          context: context,
                          id: expert['id'],
                          userId: expert['user'],
                          title: expert['title'] ?? ApiConstants.defaultTitle,
                          rating: expert['average_rating']?.toDouble() ?? 0.0,
                          categories: expert['categories'],
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
    required int id,
    required int userId,
    required String title,
    required double rating,
    required List<dynamic> categories,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
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
                  child: Text(
                    title.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${ApiConstants.userIdLabel} $userId",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${ApiConstants.titleLabel} $title",
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(CupertinoIcons.heart, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ApiConstants.addedToFavouritesMessage)),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildStarRating(rating),
                SizedBox(width: 8),
                Text(
                  "$rating/5",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "${ApiConstants.categoriesLabel}: ${categories.join(", ")}",
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_authToken != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          expertName: "${ApiConstants.userIdLabel} $userId",
                          expertImage: "", // Placeholder, no image provided in API
                          expertCategory: title,
                          authToken: _authToken!,
                          recipientId: userId,
                        ),
                      ),
                    );
                  } else {
                    print(ApiConstants.authTokenMissingMessage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(60, 30),
                ),
                child: Text(
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
          Icon(Icons.star, color: Colors.amber, size: 16),
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber, size: 16),
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, color: Colors.amber, size: 16),
      ],
    );
  }
}
