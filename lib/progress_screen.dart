import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF3F51B5);

    return Scaffold(
      appBar: AppBar(title: const Text("My Preparation Progress"), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 🎯 Circular Progress Chart
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 0.65, // 65% progress
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const Column(
                    children: [
                      Text("65%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("Completed", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildProgressRow("Python Basics", 0.9, Colors.orange),
            _buildProgressRow("Object Oriented (OOPs)", 0.4, Colors.blue),
            _buildProgressRow("Data Structures", 0.2, Colors.green),
            _buildProgressRow("Interview Readiness", 0.5, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${(value * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}