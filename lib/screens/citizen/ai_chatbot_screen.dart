import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';

class AIChatbotScreen extends StatefulWidget {
  final bool isAdmin; // Pass this to change the AI's context
  const AIChatbotScreen({super.key, this.isAdmin = false});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final List<String> _suggestions;
  late final String _systemPrompt;

  @override
  void initState() {
    super.initState();
    // Contextual setup based on role
    if (widget.isAdmin) {
      _suggestions = ["Show pending complaints", "Top performing contractors", "Analyze zone health"];
      _systemPrompt = "You are CivicAI Admin Copilot, an AI assistant for city authorities. Provide concise, professional analytics and advice regarding urban management, contractor efficiency, and complaint resolution.";
      _messages.add({"role": "assistant", "content": "Welcome to the Admin Copilot. How can I assist you with city management today?"});
    } else {
      _suggestions = ["How to report a pothole?", "What is my Civic Score?", "Nearest garbage van?"];
      _systemPrompt = "You are CivicAI, a friendly and helpful assistant for citizens. Guide them on how to report civic issues, explain gamification (Civic Points), and help them improve their city. Keep answers concise.";
      _messages.add({"role": "assistant", "content": "Hello! I'm your CivicAI Assistant. How can we improve your neighborhood today?"});
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['GROQ_API_KEY']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama3-8b-8192", // Fast and capable Groq model
          "messages": [
            {"role": "system", "content": _systemPrompt},
            ..._messages
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['choices'][0]['message']['content'];
        setState(() => _messages.add({"role": "assistant", "content": aiText}));
      } else {
        setState(() => _messages.add({"role": "assistant", "content": "Error: Unable to connect to CivicAI servers. (${response.statusCode})"}));
      }
    } catch (e) {
      setState(() => _messages.add({"role": "assistant", "content": "Network error. Please check your internet connection."}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.isAdmin ? LucideIcons.sparkles : LucideIcons.bot, color: AppTheme.primaryTeal),
            const SizedBox(width: 10),
            Text(widget.isAdmin ? "AI Insights Copilot" : "CivicAI Assistant", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggested Prompts Area
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ActionChip(
                    backgroundColor: isDark ? Colors.grey.shade900 : Colors.teal.shade50,
                    side: BorderSide(color: AppTheme.primaryTeal.withOpacity(0.3)),
                    label: Text(_suggestions[index], style: TextStyle(color: isDark ? Colors.white : AppTheme.darkTeal)),
                    onPressed: () => _sendMessage(_suggestions[index]),
                  ),
                );
              },
            ),
          ),
          
          const Divider(),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (c, i) {
                bool isUser = _messages[i]['role'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryTeal : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Text(
                      _messages[i]['content']!, 
                      style: TextStyle(color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)
                    ),
                  ),
                );
              }
            )
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(color: AppTheme.primaryTeal),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}