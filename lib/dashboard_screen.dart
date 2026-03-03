import 'package:flutter/material.dart';
import 'main.dart' as main_app;
import 'login_screen.dart';
import 'python_tips_screen.dart';
import 'progress_screen.dart';
import 'package:python_interview_app_frontend/python_roadmap_screen.dart';
import 'app_data.dart';
import 'python_quiz_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "AI Mentor Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              onDetailsPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => main_app.ProfileScreen()));
              },
              decoration: BoxDecoration(color: primaryColor),
              accountName: const Text("Misbah Tanwar",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("misbah@example.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.person, size: 50, color: Color(0xFF3F51B5)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: primaryColor),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: const Text("Interview History"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => main_app.HistoryScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Misbah!",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
            const Text("What would you like to do today?",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 25),

            /// Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListenableBuilder(
                  listenable: myAppData,
                  builder: (context, child) => _buildStatBox(
                      context,
                      "Topics",
                      "${myAppData.completedTopicsCount}/10",
                      Colors.orange),
                ),
                ListenableBuilder(
                  listenable: myAppData,
                  builder: (context, child) => _buildStatBox(
                      context,
                      "Score",
                      "${myAppData.progressPercentage}%",
                      Colors.blue),
                ),
                ListenableBuilder(
                  listenable: myAppData,
                  builder: (context, child) => _buildStatBox(
                      context,
                      "Mocks",
                      "${myAppData.mockInterviewsCount}",
                      Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Grid Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [

                  _buildMenuCard(
                    context,
                    "Mock Interview",
                    Icons.assignment_turned_in_rounded,
                    Colors.orange,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                main_app.MockInterviewScreen())),
                  ),

                  _buildMenuCard(
                    context,
                    "AI MCQ Quiz",
                    Icons.quiz_outlined,
                    Colors.teal,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PythonQuizScreen())),
                  ),

                  _buildMenuCard(
                    context,
                    "Analyze Resume",
                    Icons.description_outlined,
                    Colors.blue,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                main_app.ChatScreen(
                                    autoOpenPicker: true))),
                  ),

                  /// ✅ Added Roadmap Card
                  _buildMenuCard(
                    context,
                    "Python Roadmap",
                    Icons.map_outlined,
                    Colors.indigo,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PythonRoadmapScreen())),
                  ),

                  _buildMenuCard(
                    context,
                    "Python Tips",
                    Icons.lightbulb_outline_rounded,
                    Colors.green,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PythonTipsScreen())),
                  ),

                  _buildMenuCard(
                    context,
                    "My Progress",
                    Icons.analytics_outlined,
                    Colors.purple,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ProgressScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(
      BuildContext context, String title, String value, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 15),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}