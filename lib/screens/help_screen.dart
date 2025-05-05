import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:rive/rive.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer

import '../widgets/chatbot_button.dart';
import '../widgets/profile_button.dart';

import 'chatbot_screen.dart';
import 'profile_screen.dart';

import '../core/utils/sound_service.dart';
import '../core/utils/permission_handler.dart';
import '../widgets/theme_provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late SoundService soundService;
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionHandlerService.checkAndRequestAllPermissionsOnce();
      soundService = Provider.of<SoundService>(context, listen: false);
      // Simulate loading delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  Widget _buildLoadingSkeleton(Color textColor, Color subTextColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(width: 200, height: 30, color: Colors.white),
          const SizedBox(height: 12),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(height: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 25),
          Container(width: 150, height: 30, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 20, color: Colors.white),
          const SizedBox(height: 10),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(height: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final soundService = Provider.of<SoundService>(context, listen: false);

    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.lightBlue.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Text("Help & Support", style: TextStyle(color: textColor)),
                )
              : Text("Help & Support", style: TextStyle(color: textColor)),
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              color: backgroundColor,
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? _buildLoadingSkeleton(textColor, subTextColor)
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          FadeInDown(
                            child: Text(
                              "Frequently Asked Questions",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _faqCard("❓ How do I plan a route?", [
                            "You can enter source and destination manually.",
                            "You may enter coordinates directly.",
                            "Or pin 📌 locations on the map.",
                          ], textColor, subTextColor, soundService),
                          _faqCard("📍 How does location permission affect the app?", [
                            "Sets your current location as the default source.",
                            "Zooms into your location for better accuracy.",
                          ], textColor, subTextColor, soundService),
                          _faqCard("🗺️ Can I use the app offline?", [
                            "Yes! Navedge uses offline OpenStreetMap data.",
                            "No internet required for navigation.",
                          ], textColor, subTextColor, soundService),
                          _faqCard("🔐 Do I need to log in?", [
                            "All features work without login.",
                            "Logging in enables profile customization.",
                          ], textColor, subTextColor, soundService),
                          _faqCard("💬 How does the chatbot work?", [
                            "It’s built-in and doesn’t rely on APIs.",
                            "Typing 'hi' or 'hello' gives quick options.",
                          ], textColor, subTextColor, soundService),
                          _faqCard("🎨 How do I enable dark mode?", [
                            "Go to profile > settings.",
                            "Toggle Dark Mode switch.",
                          ], textColor, subTextColor, soundService),
                          const SizedBox(height: 25),
                          FadeInUp(
                            child: Text(
                              "Need More Help?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "For additional support, contact us at:",
                            style: TextStyle(fontSize: 16, color: subTextColor),
                          ),
                          const SizedBox(height: 10),
                          _buildContactInfo(
                            context,
                            Icons.email,
                            "yogambarsingh@gmail.com",
                            "mailto:yogambarsingh2480@gmail.com",
                            textColor,
                            soundService,
                          ),
                          _buildContactInfo(
                            context,
                            Icons.language,
                            "LinkedIn",
                            "https://www.linkedin.com/in/yogambar-singh-b42b5927a",
                            textColor,
                            soundService,
                          ),
                          _buildContactInfo(
                            context,
                            Icons.code,
                            "GitHub",
                            "https://github.com/yogambar",
                            textColor,
                            soundService,
                          ),
                        ],
                      ),
              ),
            ),

            // Chatbot button
            Positioned(
              bottom: 16,
              right: 16,
              child: _animatedButton(
                ChatbotButton(
                  onPressed: () async {
                    if (mounted) {
                      await soundService.playClickSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            // Profile button
            Positioned(
              top: 26, // Adjusted top position
              right: 16,
              child: _animatedButton(
                ProfileButton(
                  onPressed: () async {
                    if (mounted) {
                      await soundService.playClickSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            // Rive animation
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: const SizedBox(
                height: 110,
                child: RiveAnimation.network(
                  'https://public.rive.app/community/runtime-files/2099-3226-rocket-demo.riv',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqCard(String title, List<String> bulletPoints, Color textColor,
      Color subTextColor, SoundService soundService) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          await soundService.playClickSound();
          await _showFAQDialog(title, bulletPoints, textColor, subTextColor, soundService);
        },
        child: Card(
          color: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                const Icon(Icons.question_answer_rounded,
                    color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFAQDialog(String title, List<String> bulletPoints,
      Color textColor, Color subTextColor, SoundService soundService) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "FAQ Popup",
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutBack),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(title, style: TextStyle(color: textColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 100,
                  child: RiveAnimation.network(
                    'https://public.rive.app/community/runtime-files/2106-3730-question-animation.riv',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                ...bulletPoints.map(
                  (point) => ListTile(
                    leading: const Icon(Icons.brightness_1, size: 8),
                    title: Text(point, style: TextStyle(color: subTextColor)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await soundService.playConfirmSound();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatbotScreen(prefillMessage: title),
                      ),
                    );
                  }
                },
                child: const Text("Ask Chatbot"),
              ),
              TextButton(
                onPressed: () async {
                  await soundService.playPopSound();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String text,
      String url, Color textColor, SoundService soundService) {
    return InkWell(
      onTap: () async {
        await soundService.playClickSound();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open $url')),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.lightBlueAccent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedButton(Widget button) {
    return ElasticIn(
      duration: const Duration(milliseconds: 700),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: button,
      ),
    );
  }
}
