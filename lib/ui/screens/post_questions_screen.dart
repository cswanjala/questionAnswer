import 'package:flutter/material.dart';

class PostQuestionScreen extends StatefulWidget {
  const PostQuestionScreen({super.key});

  @override
  _PostQuestionScreenState createState() => _PostQuestionScreenState();
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {
  bool _isRecording = false;
  String? _attachmentName;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _addAttachment() {
    // Mock functionality for attachment
    setState(() {
      _attachmentName = "mock_attachment.png"; // Mock attachment name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Question'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ask a Question',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Question Title',
                  hintText: 'Enter a concise title for your question',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Question Description',
                  hintText: 'Provide more details about your question',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    onPressed: _toggleRecording,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _isRecording ? 'Recording...' : 'Record Your Question',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
              if (!_isRecording)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Recording saved (mocked)', style: TextStyle(color: Colors.grey)),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAttachment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Add Attachment'),
              ),
              if (_attachmentName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Attachment: $_attachmentName'),
                ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Offer Payment in Bitcoin',
                  hintText: 'Enter the amount in BTC',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle question posting logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Post Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
