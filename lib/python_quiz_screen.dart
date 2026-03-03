import 'package:flutter/material.dart';

// ✅ Is file mein sirf Quiz ki class honi chahiye, baaki sab main.dart se aayega
class PythonQuizScreen extends StatefulWidget {
  const PythonQuizScreen({super.key});

  @override
  State<PythonQuizScreen> createState() => _PythonQuizScreenState();
}

class _PythonQuizScreenState extends State<PythonQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Python AI Quiz"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_rounded, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              "AI Quiz is coming soon!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}