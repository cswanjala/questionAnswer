import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatelessWidget {
  final int questionIndex;

  const QuestionDetailScreen({super.key, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Title
              Text(
                'Question Title $questionIndex',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Question Description
              Text(
                'This is a detailed description of the question. Here you can provide more context, background information, and additional details that might help users understand the question better.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),

              // Question Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid: \$${(questionIndex + 1) * 5}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Answered in: ${questionIndex + 2} hours',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Tags
              Wrap(
                spacing: 10,
                children: [
                  Chip(
                    label: Text('Flutter'),
                    backgroundColor: Colors.blue[50],
                  ),
                  Chip(
                    label: Text('Dart'),
                    backgroundColor: Colors.blue[50],
                  ),
                  Chip(
                    label: Text('Mobile Development'),
                    backgroundColor: Colors.blue[50],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Answers Section
              Text(
                'Answers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Answer List
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  'U${index + 1}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'User ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'This is the content of the answer provided by User ${index + 1}. It contains insights and possible solutions to the question.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up, color: Colors.green),
                                onPressed: () {},
                              ),
                              Text('${(index + 1) * 5} Likes'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // Add a New Answer Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle add answer action
                },
                icon: Icon(Icons.add),
                label: Text('Add Your Answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
