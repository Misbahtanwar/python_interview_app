// ignore_for_file: uri_does_not_exist, unused_import
import 'package:flutter/material.dart';
import 'app_data.dart'; 
import 'package:python_interview_app_frontend/main.dart' as main_app;

class PythonRoadmapScreen extends StatefulWidget {
  const PythonRoadmapScreen({super.key});

  @override
  State<PythonRoadmapScreen> createState() => _PythonRoadmapScreenState();
}

class _PythonRoadmapScreenState extends State<PythonRoadmapScreen> {
  final List<Map<String, dynamic>> levels = [
    {
      "level": "Level 1: Basic Structures",
      "topics": [{"title": "Lists vs Tuples vs Sets"}, {"title": "Mutable vs Immutable"}]
    },
    {
      "level": "Level 2: Efficient Coding",
      "topics": [{"title": "List Comprehensions"}, {"title": "Lambda Functions"}]
    },
    {
      "level": "Level 3: Logic & Memory",
      "topics": [{"title": "Deep Copy vs Shallow Copy"}, {"title": "Memory Management in Python"}]
    },
    {
      "level": "Level 4: Error & Flow",
      "topics": [{"title": "Decorators & Generators"}, {"title": "Exception Handling (Try-Except)"}]
    },
    {
      "level": "Level 5: Master OOPS",
      "topics": [{"title": "Classes and Objects (OOPS)"}, {"title": "Inheritance & Polymorphism"}]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Python Roadmap"),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3F51B5),
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
              ),
              title: Text(
                levels[index]['level'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              // ✅ children logic ko clean kiya taaki casting error na aaye
              children: (levels[index]['topics'] as List).map((topicData) {
                final Map<String, dynamic> topic = topicData;
                return ListTile(
                  title: Text(topic['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_circle_right_outlined, color: Colors.orange),
                  onTap: () {
                    // ✅ main_app lagaya kyunki LessonScreen main.dart mein hai
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => main_app.LessonScreen(topicName: topic['title']!),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}