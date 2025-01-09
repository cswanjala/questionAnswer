import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/experts/controllers/experts_provider.dart';
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/ui/screens/ask_now_screen.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';
import 'package:question_nswer/ui/screens/experts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';
import 'account_screen.dart';
import 'package:intl/intl.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    MessageScreen(),
    const AskNowScreen(),
    const ExpertsListScreen(),
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
                fontWeight: FontWeight.bold,
              ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  // void initState() {
  //   super.initState();

  //   // Defer state update to after the first frame is rendered
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final questionsProvider =
  //         Provider.of<QuestionsProvider>(context, listen: false);
  //     questionsProvider
  //         .fetchQuestions(); // Fetch questions after the build process
  //   });
  // }
  void initState() {
    super.initState();

    // Fetch data once during initialization
    final questionsProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final expertsProvider =
        Provider.of<ExpertsProvider>(context, listen: false);
    questionsProvider.fetchQuestions();
    expertsProvider.fetchExperts();
  }

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsProvider>(context);
    final expertsProvider = Provider.of<ExpertsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Questions Section
          if (questionsProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (questionsProvider.questions.isEmpty)
            const Text("No active questions")
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Questions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questionsProvider.questions.length,
                  itemBuilder: (context, index) {
                    final question = questionsProvider.questions[index];
                    final assignedExpert = question['assigned_expert'];

                    // Parse created_at
                    final createdAt = question['created_at'] != null
                        ? DateTime.parse(question['created_at'])
                        : null;

                    // Format date
                    final formattedDate = createdAt != null
                        ? DateFormat('MMM d, yyyy h:mm a')
                            .format(createdAt) // Example: Jan 8, 2025 1:12 PM
                        : "Unknown time";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/150'),
                        ),
                        title: Text(
                          assignedExpert != null
                              ? assignedExpert['user']['username']
                              : 'Unassigned',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignedExpert != null
                                  ? "${assignedExpert['title']} | $formattedDate"
                                  : "Waiting for an expert to be assigned | $formattedDate",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              question['content'],
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              assignedExpert != null
                                  ? "Expert ${assignedExpert['user']['username']} is responding"
                                  : "Waiting for an expert to respond",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          const SizedBox(height: 20),

          // Favorite Experts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
          const SizedBox(height: 10),
          if (expertsProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (expertsProvider.experts.isEmpty)
            const Text("No experts found")
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: expertsProvider.experts.take(2).map((expert) {
                return Expanded(
                  child: Card(
                    elevation: 2,
                    child: Container(
                      height: 180,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                NetworkImage('https://via.placeholder.com/150'),
                            radius: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            expert['user']['username'] ?? "Expert",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            expert['categories'] != null &&
                                    expert['categories'] is List &&
                                    expert['categories'].isNotEmpty
                                ? expert['categories'].join(
                                    ', ') // Convert list to a comma-separated string
                                : "No category", // Fallback if categories is empty or null
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final authToken = Provider.of<ExpertsProvider>(
                                      context,
                                      listen: false)
                                  .authToken;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    expertName: expert['user']['username'],
                                    expertImage: "",
                                    expertCategory: expert['categories'] !=
                                                null &&
                                            expert['categories'] is List
                                        ? expert['categories'].join(
                                            ', ') // Convert list to a string
                                        : "No category",
                                    recipientId: expert['id'],
                                    authToken: authToken,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(CupertinoIcons.chat_bubble_2_fill,
                                size: 16),
                            label: const Text("Ask",
                                style: TextStyle(fontSize: 14)),
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
            ),
        ],
      ),
    );
  }
}
