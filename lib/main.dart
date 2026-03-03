// ignore_for_file: uri_does_not_exist, unused_import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'login_screen.dart'; 
import 'package:python_interview_app_frontend/app_data.dart';
import 'package:python_interview_app_frontend/python_roadmap_screen.dart';
import 'dart:async'; 

// ✅ Groq API Config
const String groqKey = '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';
const String groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  runApp(const MyApp());
}

// --- 📖 1. AI Lesson Screen ---
class LessonScreen extends StatefulWidget {
  final String topicName;
  const LessonScreen({super.key, required this.topicName});
  @override
  State<LessonScreen> createState() => LessonScreenState();
}

class LessonScreenState extends State<LessonScreen> {
  String aiContent = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAILesson();
  }

  Future<void> _fetchAILesson() async {
    print("LOG: Initiating AI fetch request for: ${widget.topicName}");
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Authorization': 'Bearer $groqKey', 
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "model": "llama3-8b-8192",
          "messages": [
            {
              "role": "user", 
              "content": "Provide a very detailed professional interview summary for Python topic: ${widget.topicName}. Include: 1. Deep Concept 2. Code Example 3. Interview Questions."
            }
          ]
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          aiContent = data['choices'][0]['message']['content'];
          isLoading = false;
        });
      } else {
        setState(() {
          aiContent = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        aiContent = "Connection Error.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName), backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Text(aiContent, style: const TextStyle(fontSize: 16, height: 1.6)))),
          if (!isLoading) SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () { myAppData.incrementTopics(); Navigator.pop(context); }, child: const Text("MARK AS LEARNT"))),
        ]),
      ),
    );
  }
}

// --- 🎯 2. AI Mock Interview ---
class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});
  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  int _currentIndex = 0;
  bool _isFinished = false;
  bool _isLoading = true;
  final TextEditingController _ansController = TextEditingController();
  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestionsFromAI();
  }

  Future<void> _fetchQuestionsFromAI() async {
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {'Authorization': 'Bearer $groqKey', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "llama3-8b-8192",
          "messages": [
            {"role": "system", "content": "Return ONLY a JSON list of 5 Python interview questions strings."}
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _questions = jsonDecode(data['choices'][0]['message']['content']);
          _isLoading = false;
        });
      }
    } catch (e) { print(e); }
  }

  void _next() {
    if (_ansController.text.isEmpty) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() { _currentIndex++; _ansController.clear(); });
    } else {
      setState(() { _isFinished = true; });
      myAppData.addInterviewToHistory("AI Python Assessment", "Excellent");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_isFinished) return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.stars, size: 80, color: Colors.orange), const Text("Assessment Done!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))])));

    return Scaffold(
      appBar: AppBar(title: const Text("AI Assessment"), backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length, color: Colors.orange),
          const SizedBox(height: 30),
          Text(_questions[_currentIndex], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _ansController, maxLines: 4, decoration: const InputDecoration(hintText: "Type answer...", border: OutlineInputBorder())),
          const Spacer(),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _next, child: const Text("NEXT")))
        ]),
      ),
    );
  }
}

// --- 📝 3. Python Quiz Screen ---
class PythonQuizScreen extends StatelessWidget {
  const PythonQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Python AI Quiz"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            const Text("AI Quiz coming soon!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Back"))
          ],
        ),
      ),
    );
  }
}

// --- 💬 4. AI Chat & Resume Screen ---
class ChatScreen extends StatefulWidget {
  final bool autoOpenPicker;
  const ChatScreen({super.key, this.autoOpenPicker = false});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickFile());
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() => _messages.add({"role": "bot", "content": "📄 Resume received: ${result.files.first.name}. Analyzing..."}));
      _chatWithAI("Analyze this resume for a Python role.");
    }
  }

  Future<void> _chatWithAI(String text) async {
    setState(() => _messages.add({"role": "user", "content": text}));
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {'Authorization': 'Bearer $groqKey', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "llama3-8b-8192",
          "messages": [{"role": "user", "content": text}]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _messages.add({"role": "bot", "content": data['choices'][0]['message']['content']}));
      }
    } catch (e) { print(e); }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant"), backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemCount: _messages.length, itemBuilder: (context, index) {
            final m = _messages[index];
            return ListTile(title: Align(alignment: m['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: m['role'] == 'user' ? Colors.blue[100] : Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Text(m['content']!))));
          })),
          Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile), Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ask AI..."))), IconButton(icon: const Icon(Icons.send), onPressed: () => _chatWithAI(_controller.text))])),
        ],
      ),
    );
  }
}

// --- 👤 Profile, History & MyApp ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Profile"), backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white), body: const Center(child: Text("Misbah Tanwar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History"), backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
      body: ListenableBuilder(listenable: myAppData, builder: (context, child) {
        if (myAppData.history.isEmpty) return const Center(child: Text("No History Yet"));
        return ListView.builder(itemCount: myAppData.history.length, itemBuilder: (context, index) => ListTile(title: Text(myAppData.history[index].title), subtitle: Text("Score: ${myAppData.history[index].score}")));
      }),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, textTheme: GoogleFonts.poppinsTextTheme()), home: const LoginScreen());
  }
}