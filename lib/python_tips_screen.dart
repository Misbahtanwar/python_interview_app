import 'package:flutter/material.dart';

class PythonTipsScreen extends StatelessWidget {
  const PythonTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Professional Interview Tips Data
    final List<Map<String, String>> tips = [
      {
        "title": "List Comprehension",
        "desc": "Use [x for x in data] instead of long loops for cleaner code.",
        "tag": "Coding Style"
      },
      {
        "title": "Memory Management",
        "desc": "Python uses Garbage Collection. Use 'del' for large objects to free space.",
        "tag": "Performance"
      },
      {
        "title": "Decorators",
        "desc": "Understand @wraps to modify function behavior without changing code.",
        "tag": "Advanced"
      },
      {
        "title": "Global Interpreter Lock (GIL)",
        "desc": "Must-know for interviews! It allows only one thread to execute at a time.",
        "tag": "Interview Hot"
      },
      {
        "title": "Generators vs Lists",
        "desc": "Use 'yield' for large datasets to save RAM instead of returning a full list.",
        "tag": "Efficiency"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Python Interview Tips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tip["title"]!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tip["tag"]!,
                          style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tip["desc"]!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  TextButton.icon(
                    onPressed: () {}, // Future: Link to a detailed blog or AI explanation
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text("Read More"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}