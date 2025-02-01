import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/experts/controllers/experts_provider.dart';
import 'package:question_nswer/core/features/experts/controllers/favourite_expert_provider.dart';
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/ui/screens/ask_now_screen.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';
import 'package:question_nswer/ui/screens/experts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';
import 'package:question_nswer/ui/screens/payments_screen.dart';
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
              "expert ",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "ask&more",
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
  final String baseUrl = 'http://192.168.1.127:8000';
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_loadMoreData);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final questionsProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final expertsProvider =
        Provider.of<ExpertsProvider>(context, listen: false);
    final favoriteExpertsProvider =
        Provider.of<FavoriteExpertsProvider>(context, listen: false);

    questionsProvider.fetchQuestions();
    expertsProvider.fetchExperts();
    _initializeUser(favoriteExpertsProvider);
  }

  Future<void> _initializeUser(FavoriteExpertsProvider favoriteExpertsProvider) async {
    final secureStorage = FlutterSecureStorage();
    final userId = await secureStorage.read(key: 'user_id');
    if (userId != null) {
      favoriteExpertsProvider.fetchFavoriteExperts(userId);
    }
  }

  void _loadMoreData() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isLoadingMore = true;
      });

      final questionsProvider =
          Provider.of<QuestionsProvider>(context, listen: false);
      questionsProvider.fetchMoreQuestions().then((_) {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  Future<void> _refreshData() async {
    final questionsProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final favoriteExpertsProvider =
        Provider.of<FavoriteExpertsProvider>(context, listen: false);

    await questionsProvider.refreshQuestions();
    await favoriteExpertsProvider.refreshFavoriteExperts();
  }

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsProvider>(context);
    final favoriteExpertsProvider = Provider.of<FavoriteExpertsProvider>(context);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveQuestionsSection(questionsProvider),
            const SizedBox(height: 20),
            _buildFavoriteExpertsSection(favoriteExpertsProvider),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQuestionsSection(QuestionsProvider questionsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Active Questions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (questionsProvider.isLoading && !_isLoadingMore)
          const Center(child: CircularProgressIndicator())
        else if (questionsProvider.questions.isEmpty)
          const Text("No active questions")
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questionsProvider.questions.length,
            itemBuilder: (context, index) {
              final question = questionsProvider.questions[index];
              final assignedExpert = question['assigned_expert'];
              final createdAt = question['created_at'] != null
                  ? DateTime.parse(question['created_at'])
                  : null;
              final formattedDate = createdAt != null
                  ? DateFormat('MMM d, yyyy h:mm a').format(createdAt)
                  : "Unknown time";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: assignedExpert != null &&
                            assignedExpert['user'] != null &&
                            assignedExpert['user']['profile_picture'] != null
                        ? NetworkImage('$baseUrl${assignedExpert['user']['profile_picture']}')
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          ),
      ],
    );
  }

  Widget _buildFavoriteExpertsSection(FavoriteExpertsProvider favoriteExpertsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (favoriteExpertsProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (favoriteExpertsProvider.favoriteExperts.isEmpty)
          const Text("No favorite experts found")
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: favoriteExpertsProvider.favoriteExperts.take(2).map((expert) {
              final profilePicture = expert['expert']['user']['profile_picture'];
              return Expanded(
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: 180,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                              ? NetworkImage('$baseUrl$profilePicture')
                              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          radius: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          expert['expert']['user']['username'] ?? "Expert",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          expert['expert']['categories'] != null &&
                                  expert['expert']['categories'] is List &&
                                  expert['expert']['categories'].isNotEmpty
                              ? expert['expert']['categories'].join(', ')
                              : "No category",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final authToken = Provider.of<ExpertsProvider>(context, listen: false).authToken;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  expertName: expert['expert']['user']['username'],
                                  expertImage: profilePicture != null ? '$baseUrl$profilePicture' : "",
                                  expertCategory: expert['expert']['categories'] != null &&
                                          expert['expert']['categories'] is List
                                      ? expert['expert']['categories'].join(', ')
                                      : "No category",
                                  authToken: authToken,
                                  senderUsername: 'salama',
                                  recipientUsername: 'makena',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.chat_bubble_2_fill, size: 16),
                          label: const Text("Ask", style: TextStyle(fontSize: 14)),
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
    );
  }
}