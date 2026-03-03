import 'package:flutter/material.dart';

// ✅ Interview Record ke liye ek choti class
class InterviewRecord {
  final String title;
  final String score;
  final String date;

  InterviewRecord({required this.title, required this.score, required this.date});
}

class AppData extends ChangeNotifier {
  int completedTopicsCount = 0;
  int totalTopics = 50;
  int mockInterviewsCount = 0; 

  // ✅ Yeh list aapki asli history save karegi
  List<InterviewRecord> history = [];

  // Ye line apne aap calculation karegi
  int get progressPercentage => totalTopics > 0 
      ? ((completedTopicsCount / totalTopics) * 100).toInt() 
      : 0;

  // Topics badhane ke liye
  void incrementTopics() {
    if (completedTopicsCount < totalTopics) {
      completedTopicsCount++;
      notifyListeners(); 
    }
  }

  // ✅ Updated Function: Jo history mein record bhi add karega
  void addInterviewToHistory(String title, String score) {
    history.insert(0, InterviewRecord(
      title: title,
      score: score,
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    ));
    mockInterviewsCount = history.length; // Count apne aap list se update hoga
    notifyListeners(); 
  }

  // Purana function compatibility ke liye (optional)
  void incrementMockCount() {
    mockInterviewsCount++;
    notifyListeners();
  }
}

final AppData myAppData = AppData();