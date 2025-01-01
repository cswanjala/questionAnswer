import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/profile_screen.dart';
import 'package:question_nswer/ui/screens/questions_details_screen.dart';
import 'package:question_nswer/ui/screens/post_questions_screen.dart';
import 'package:question_nswer/ui/screens/proposals_screen.dart';
import 'package:question_nswer/ui/screens/contracts_screen.dart';
import 'package:question_nswer/ui/screens/alerts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';

void main() => runApp(AnswersApp());

class AnswersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Answers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JustAnswerClone(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    ProposalsScreen(),
    ContractsScreen(),
    MessagesScreen(),
    AlertsScreen(),
  ];

  // Handle BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.question_answer,
                color: Colors.white), // Icon next to the title
            SizedBox(width: 8),
            Text(
              'Answers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4, // Slight shadow for a modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16), // Rounded bottom edge
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              // Placeholder for notifications functionality
            },
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/profile_picture.jpg'), // Replace with a real image
              radius: 16,
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),

      body: _screens[_selectedIndex], // Display the selected screen
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostQuestionScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null, // Show FloatingActionButton only on Questions tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Proposals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Contracts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Update the selected index
      ),
    );
  }
}

class JustAnswerClone extends StatelessWidget {
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
      body: SingleChildScrollView(
        child: Padding(
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
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual image URL
                  ),
                  title: Text("Dr. Joe"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Board Certified MD | Yesterday at 01:12"),
                      SizedBox(height: 5),
                      Text(
                        "What is the best method to reduce microalbumin in urine using medicine and diet and other methods",
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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Ask now"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Experts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

  // Helper method to create an expert card
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
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual image URL
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
              SizedBox(
                width: double.infinity, // Ensures the button takes up the card's width
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.question_answer, size: 16),
                  label: Text("Ask", style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create the "Add More Experts" card
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
              Icon(Icons.person, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Icon(Icons.add, size: 24, color: Colors.blue),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            ],
          ),
        ),
      ),
    );
  }
}