import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cached_network_image/cached_network_image.dart'; // For efficient image loading

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = Provider.of<UserData>(context, listen: false);
      ChatbotService.initialize(userData);
      if (widget.prefillMessage != null && widget.prefillMessage!.isNotEmpty) {
        _controller.text = widget.prefillMessage!;
        Future.delayed(const Duration(milliseconds: 500), _sendMessage);
      }
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
          curve: Curves.easeInOut, // More natural scrolling curve
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
    await Future.delayed(const Duration(milliseconds: 1200)); // Slightly faster bot response

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat history cleared')), // User feedback
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            _speech.stop();
            if (_controller.text.isNotEmpty) {
              _sendMessage(); // Auto-send after listening
            }
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occurred during speech recognition: $val')),
          );
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
    const suggestions = ['Quick Help', 'Navigation Tips', 'App Features'];
    return FadeIn( // Subtle animation for suggestions
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.start,
          children: suggestions
              .map(
                (text) => Chip(
                  label: Text(text, style: const TextStyle(color: Colors.blueAccent)),
                  backgroundColor: Colors.blueAccent.shade100, // Using shade100 instead of shade50
                  onDeleted: () {
                    _controller.text = text;
                    _sendMessage();
                  },
                  deleteIcon: const Icon(Icons.send_rounded, size: 18, color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatbotMessage message, Animation<double> animation) {
    final userData = Provider.of<UserData>(context, listen: false);
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0, // Messages grow from the bottom
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment:
              message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, // Align avatars to the top
          children: [
            if (!message.isUserMessage)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/chatbot/chatbot_avatar.png'),
                  radius: 20, // Slightly smaller avatar
                ),
              ),
            Expanded(
              child: Align(
                alignment: message.isUserMessage
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: message.isUserMessage
                        ? const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue])
                        : LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.surface,
                              Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1)
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUserMessage
                          ? const Radius.circular(18)
                          : const Radius.circular(5),
                      bottomRight: message.isUserMessage
                          ? const Radius.circular(5)
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: message.isUserMessage
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            if (message.isUserMessage)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: userData.profileImagePath != null && userData.profileImagePath!.isNotEmpty
                      ? CachedNetworkImageProvider(userData.profileImagePath!) as ImageProvider<Object>?
                      : const AssetImage('assets/images/default_profile.png'),
                  onBackgroundImageError: (_, __) =>
                      const AssetImage('assets/images/default_profile.png'),
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
            radius: 20,
          ),
          const SizedBox(width: 8),
          FadeInLeft(
            child: Image.asset(
              'assets/images/chatbot/chatbot_typing.gif',
              width: 50,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          FadeInUp(
            child: SizedBox(
              width: 70,
              height: 35,
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
        config: const Config(
          height: 256,
          locale: Locale('en'),
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28.0,
          ),
          viewOrderConfig: ViewOrderConfig(), // uses default order
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blueAccent,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blueAccent,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: Color(0xFFF2F2F2),
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: Color(0xFFF2F2F2),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettings>().isDarkMode;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
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
                iconSize: 60, // Slightly smaller profile button
                buttonColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSuggestions(),
                Expanded(
                  child: Stack(
                    children: [
                      AnimatedList(
                        key: _listKey,
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 80), // Reduced top padding
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
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black26
                        : Theme.of(context).colorScheme.background.withOpacity(0.9),
                    border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)), // Subtle top border
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_outlined,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmojiPicker = !_showEmojiPicker);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                              width: 45,
                              height: 45,
                            ),
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Colors.redAccent
                                  : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            ),
                            onPressed: _listen,
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      BounceInRight(
                        duration: const Duration(milliseconds: 400),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, size: 28),
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
