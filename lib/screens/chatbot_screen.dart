import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:navedge/core/settings/app_settings.dart';
import 'package:navedge/core/utils/sound_service.dart';
import 'package:navedge/settings.dart';
import 'package:navedge/models/chatbot_model.dart';
import 'package:navedge/core/chatbot/chatbot_service.dart';
import 'package:navedge/user_data_provider.dart'; // Import UserData

import '../widgets/profile_button.dart';

class ChatbotScreen extends StatefulWidget {
  final String? prefillMessage;

  const ChatbotScreen({Key? key, this.prefillMessage}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<ChatbotMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isBotTyping = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    // Initialize ChatbotService with the BuildContext to access UserData
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = Provider.of<UserData>(context, listen: false);
      ChatbotService.initialize(userData);
    });
    _speech = stt.SpeechToText();
    _addMessage(ChatbotMessage(
      message: "Hi! How can I assist you today?",
      isUserMessage: false,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _playStartupSound());
  }

  Future<void> _playStartupSound() async {
    final settingsProvider = context.read<SettingsProvider>();
    if (settingsProvider.soundEnabled) {
      await SoundService().playClickSound();
    }
  }

  void _addMessage(ChatbotMessage message) {
    _messages.insert(0, message);
    _listKey.currentState?.insertItem(0);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final userMessage = ChatbotMessage(message: text, isUserMessage: true);
    _addMessage(userMessage);
    await SoundService().playUserMessageSound();
    _replyToUserMessage(text);
  }

  Future<void> _replyToUserMessage(String message) async {
    setState(() => _isBotTyping = true);
    await SoundService().playChatbotTypingSound();
    await Future.delayed(const Duration(milliseconds: 1500));

    final response = ChatbotService.getResponse(message);
    final botMessage = ChatbotMessage(message: response, isUserMessage: false);

    setState(() {
      _isBotTyping = false;
      _addMessage(botMessage);
    });

    await SoundService().playChatbotResponseSound();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _listKey.currentState?.setState(() {});
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            _speech.stop();
            if (_controller.text.isNotEmpty) {
              _sendMessage(); // Auto-send
            }
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Widget _buildSuggestions() {
    const suggestions = ['Hi', 'Hello', 'Help', 'Route Info', 'About App'];
    return AnimatedOpacity(
      opacity: _controller.text.toLowerCase().trim() == 'hi' ||
              _controller.text.toLowerCase().trim() == 'hello'
          ? 1
          : 0,
      duration: const Duration(milliseconds: 300),
      child: Wrap(
        spacing: 8,
        children: suggestions
            .map(
              (text) => ActionChip(
                label: Text(text),
                onPressed: () {
                  _controller.text = text;
                  _sendMessage();
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMessage(ChatbotMessage message, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: message.isUserMessage
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUserMessage)
              const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/chatbot/chatbot_avatar.png'),
                radius: 24,
              ),
            const SizedBox(width: 10),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: message.isUserMessage
                      ? const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue])
                      : const LinearGradient(
                          colors: [Colors.white, Colors.grey]),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: message.isUserMessage
                        ? const Radius.circular(18)
                        : const Radius.circular(0),
                    bottomRight: message.isUserMessage
                        ? const Radius.circular(0)
                        : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: message.isUserMessage ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 85.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundImage:
                AssetImage('assets/images/chatbot/chatbot_avatar.png'),
            radius: 24,
          ),
          const SizedBox(width: 8),
          FadeInLeft(
            child: Image.asset(
              'assets/images/chatbot/chatbot_typing.gif',
              width: 60,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          FadeInUp(
            child: SizedBox(
              width: 90,
              height: 40,
              child: Lottie.asset(
                'assets/images/animations/chatbot_typing.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Offstage(
      offstage: !_showEmojiPicker,
      child: SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (Category? category, Emoji emoji) {
            _controller.text += emoji.emoji;
          },
          config: const Config(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettings>().isDarkMode;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: AppBar(
                    title: const Text('Chatbot'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.delete_forever_rounded),
                        onPressed: _clearChat,
                        tooltip: "Clear Chat",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: FadeInRight(
                          duration: const Duration(milliseconds: 600),
                          child: const ProfileButton(
                            iconSize: 70,
                            buttonColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSuggestions(),
                Expanded(
                  child: Stack(
                    children: [
                      AnimatedList(
                        key: _listKey,
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 80),
                        initialItemCount: _messages.length,
                        itemBuilder: (context, index, animation) =>
                            _buildMessage(_messages[index], animation),
                      ),
                      if (_isBotTyping)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _buildTypingIndicator(),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color:
                      isDark ? Colors.black26 : Colors.white.withOpacity(0.9),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmojiPicker = !_showEmojiPicker);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Type your message...',
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening)
                            Lottie.asset(
                              'assets/images/animations/mic_wave.json',
                              width: 50,
                              height: 50,
                            ),
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : Colors.grey,
                            ),
                            onPressed: _listen,
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      BounceInRight(
                        duration: const Duration(milliseconds: 400),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, size: 30),
                          color: Colors.blueAccent,
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEmojiPicker(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
