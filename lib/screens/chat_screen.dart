import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  final String role; // Accepts Citizen or Admin
  
  const ChatScreen({super.key, required this.role});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  late final String systemPrompt;
  late final List<Map<String, String>> _chatHistory;
  late final List<Map<String, String>> _displayMessages;

  @override
  void initState() {
    super.initState();
    
    // Updated identity to CivicAI ChatBot
    systemPrompt = """
    # SYSTEM PROMPT: CIVIC AI CHATBOT
    You are the CivicAI ChatBot, the official digital assistant for the municipal reporting and analytics platform. You must never introduce yourself as a generic AI, a large language model, or a dummy chatbot. You must never break character.
    The user you are currently speaking to has logged in as a: **${widget.role.toUpperCase()}**.
    
    If CITIZEN: Guide them through issue intake (Location, Description, Urgency, Photos) and confirm routing.
    If ADMIN: Provide analytical, data-driven operational support (trend analysis, ticket prioritization).
    """;

    _chatHistory = [
      {"role": "system", "content": systemPrompt}
    ];

    // Updated initial greetings
    _displayMessages = [
      {
        "role": "assistant",
        "content": widget.role == 'Citizen' 
            ? "Hello. I am the CivicAI ChatBot. How can I assist you with municipal services today?"
            : "CivicAI System Online. Ready to assist with operational analytics and ticket management, Administrator."
      }
    ];
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _displayMessages.add({"role": "user", "content": text});
      _chatHistory.add({"role": "user", "content": text});
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      setState(() {
        _displayMessages.add({"role": "assistant", "content": "System Error: API key is missing. Please check .env.local file."});
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant", 
          "messages": _chatHistory,
          "temperature": 0.2, 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];

        setState(() {
          _displayMessages.add({"role": "assistant", "content": botResponse});
          _chatHistory.add({"role": "assistant", "content": botResponse});
        });
      } else {
        final errorData = jsonDecode(response.body);
        final realError = errorData['error']['message'] ?? 'Unknown API Error';
        
        setState(() {
          _displayMessages.add({"role": "assistant", "content": "API Error (${response.statusCode}): $realError"});
        });
      }
    } catch (e) {
      setState(() {
        _displayMessages.add({"role": "assistant", "content": "Connection error: ${e.toString()}"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define the unique suggestions based on the user's role
    final List<String> suggestions = widget.role == 'Citizen'
        ? ['Report a massive pothole', 'Garbage collection issue', 'Check complaint status']
        : ['Show active complaints', 'Identify high priority issues', 'Zone cleanliness analytics'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Portal - CivicAI'), // Updated AppBar title
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayMessages.length,
              itemBuilder: (context, index) {
                final msg = _displayMessages[index];
                final isUser = msg['role'] == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isUser ? theme.primaryColor : theme.cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            
          // QUICK SUGGESTIONS BLOCK
          // This only shows up if the Chatbot has just sent its first greeting
          if (_displayMessages.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: suggestions.map((text) => InkWell(
                  onTap: () {
                    // Populate the text box and send the message instantly
                    _controller.text = text;
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: theme.primaryColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      text, 
                      style: TextStyle(
                        color: theme.primaryColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0
                      )
                    ),
                  ),
                )).toList(),
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  CircleAvatar(
                    backgroundColor: theme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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