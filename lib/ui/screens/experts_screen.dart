import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';

class ExpertsListScreen extends StatelessWidget {
  const ExpertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Live Experts in 150+ categories",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Favourite Experts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 7, // Replace with actual data length
                itemBuilder: (context, index) {
                  return _buildExpertCard(
                    context: context, // Pass the context here
                    name: "Dr. David, MD",
                    title: "General Practitioner",
                    rating: 4.4,
                    imageUrl: "https://via.placeholder.com/150",
                    buttonLabel: index % 2 == 0 ? "Ask" : "Add",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard({
    required BuildContext context, // Accept context as a parameter
    required String name,
    required String title,
    required double rating,
    required String imageUrl,
    required String buttonLabel,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 30,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            SizedBox(height: 5),
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
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context, // Use the context here
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  expertName: name,
                  expertImage: imageUrl,
                  expertCategory: title,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                buttonLabel == "Ask" ? Colors.blue : Colors.grey[200],
            minimumSize: Size(60, 30),
          ),
          child: Text(
            buttonLabel,
            style: TextStyle(
              color: buttonLabel == "Ask" ? Colors.white : Colors.black,
            ),
          ),
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
