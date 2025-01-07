import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:question_nswer/ui/screens/ask_now_screen.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';
import 'package:question_nswer/ui/screens/experts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';
import 'account_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    MessageScreen(),
    AskNowScreen(),
    ExpertsListScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "just",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "answer",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble), label: "Inbox"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add), label: "Ask Now"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group), label: "Experts"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: "Account"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<dynamic>> fetchQuestions() async {
    final String? token = await _secureStorage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse("http://192.168.220.229:8000/api/questions"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch questions");
    }
  }

  Future<List<dynamic>> fetchExperts() async {
    final response =
        await http.get(Uri.parse("http://192.168.220.229:8000/api/experts"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final random = Random();
      return List.generate(
        2,
        (_) => data[random.nextInt(data.length)],
      );
    } else {
      throw Exception("Failed to fetch experts");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<dynamic>>(
            future: fetchQuestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text("No active questions");
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Active Questions",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final question = snapshot.data![index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150'),
                            ),
                            title: Text("Dr. Joe"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Board Certified MD | Yesterday at 01:12"),
                                SizedBox(height: 5),
                                Text(
                                  question['content'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Waiting for the Board Certified MD",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Favorite Experts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "All Experts",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchExperts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                final experts = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: experts.map((expert) {
                    return Expanded(
                      child: Card(
                        elevation: 2,
                        child: Container(
                          height: 180,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/150'),
                                radius: 30,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "User ID ${expert['user']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Text(
                                expert['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Retrieve the auth token from secure storage
                                  final String? authToken = await _secureStorage
                                      .read(key: 'auth_token');

                                  if (authToken != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          expertName: "sample name",// Replace with the actual field for expert's name
                                          expertImage: "", // Replace with the actual field for expert's image
                                          expertCategory: expert[
                                              'categories'][0].toString(), // Replace with the actual field for expert's category
                                          recipientId: expert[
                                              'user'], // Replace with the field containing recipient ID
                                          authToken: authToken,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Handle the case where authToken is null
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Authentication token not found')),
                                    );
                                  }
                                },
                                icon: Icon(CupertinoIcons.chat_bubble_2_fill,
                                    size: 16),
                                label:
                                    Text("Ask", style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
