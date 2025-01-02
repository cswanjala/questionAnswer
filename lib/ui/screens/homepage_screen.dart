import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/ask_now_screen.dart';
import 'package:question_nswer/ui/screens/experts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';
import 'account_screen.dart';

class HomepageScreen extends StatefulWidget {
  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  int _currentIndex = 0;

  // List of pages for the bottom navigation bar
  final List<Widget> _pages = [
    HomeScreen(),
    MessageScreen(),
    AskNowScreen(),
    ExpertsListScreen(),
    AccountPage(),
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
              style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "answer",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _pages[_currentIndex], // Display the selected page
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
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.add), label: "Ask Now"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.group), label: "Experts"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: "Account"),
        ],
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Questions Section
          Text(
            "Active Questions (1)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              title: Text("Dr. Joe"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Board Certified MD | Yesterday at 01:12"),
                  SizedBox(height: 5),
                  Text(
                    "What is the best method to reduce microalbumin in urine using medicine and diet?",
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
          ),
          SizedBox(height: 20),
          // Favorite Experts Section
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildExpertCard("Dr. Dan", "Board Certified MD"),
              _buildAddMoreExpertsCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(String name, String title) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Container(
          height: 180,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                radius: 30,
              ),
              SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(CupertinoIcons.chat_bubble_2_fill, size: 16),
                label: Text("Ask", style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreExpertsCard() {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Container(
          height: 180,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.person_crop_circle_badge_plus, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                "Add more Experts",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


