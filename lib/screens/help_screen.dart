import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:rive/rive.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

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
  bool _isLoading = true;

  // Lottie animation paths for each FAQ
  final Map<String, String> _faqAnimationPaths = {
    "❓ How do I plan a route?": "assets/lottie/route_planning.json",
    "📍 How does location permission affect the app?":
        "assets/lottie/location_permission.json",
    "🗺️ Can I use the app offline?": "assets/lottie/offline_map.json",
    "🔐 Do I need to log in?": "assets/lottie/login_security.json",
    "💬 How does the chatbot work?": "assets/lottie/chatbot_interaction.json",
    "🎨 How do I enable dark mode?": "assets/lottie/dark_mode.json",
  };

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
                  child:
                      Text("Help & Support", style: TextStyle(color: textColor)),
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
                                fontSize: 24, // Increased font size for emphasis
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._faqAnimationPaths.keys.map((title) {
                            final bulletPoints = _getBulletPoints(title);
                            return _faqCard(
                              title,
                              bulletPoints,
                              textColor,
                              subTextColor,
                              soundService,
                              _faqAnimationPaths[title]!,
                            );
                          }).toList(),
                          const SizedBox(height: 32),
                          FadeInUp(
                            child: Text(
                              "Need More Assistance?",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Contact us through the following channels:",
                            style: TextStyle(fontSize: 16, color: subTextColor),
                          ),
                          const SizedBox(height: 12),
                          _buildContactInfo(
                            context,
                            Icons.email,
                            "Email Support",
                            "mailto:yogambarsingh2480@gmail.com",
                            textColor,
                            soundService,
                          ),
                          _buildContactInfo(
                            context,
                            Icons.language,
                            "LinkedIn Profile",
                            "https://www.linkedin.com/in/yogambar-singh-b42b5927a",
                            textColor,
                            soundService,
                          ),
                          _buildContactInfo(
                            context,
                            Icons.code,
                            "GitHub Repository",
                            "https://github.com/yogambar",
                            textColor,
                            soundService,
                          ),
                          const SizedBox(height: 80), // Space for floating buttons
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
              top: 26,
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

            // Rive animation (moved higher and adjusted size)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100, // Slightly reduced height
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

  // Helper function to get bullet points for each FAQ
  List<String> _getBulletPoints(String title) {
    switch (title) {
      case "❓ How do I plan a route?":
        return [
          "Enter source and destination manually.",
          "Enter coordinates directly.",
          "Pin 📌 locations on the map.",
        ];
      case "📍 How does location permission affect the app?":
        return [
          "Sets your current location as the default source.",
          "Zooms into your location for better accuracy.",
        ];
      case "🗺️ Can I use the app offline?":
        return [
          "Yes! Navedge uses offline OpenStreetMap data.",
          "No internet required for navigation.",
        ];
      case "🔐 Do I need to log in?":
        return [
          "All features work without login.",
          "Logging in enables profile customization.",
        ];
      case "💬 How does the chatbot work?":
        return [
          "It’s built-in and doesn’t rely on APIs.",
          "Typing 'hi' or 'hello' gives quick options.",
        ];
      case "🎨 How do I enable dark mode?":
        return ["Go to profile > settings.", "Toggle Dark Mode switch."];
      default:
        return [];
    }
  }

  Widget _faqCard(
    String title,
    List<String> bulletPoints,
    Color textColor,
    Color subTextColor,
    SoundService soundService,
    String lottiePath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          await soundService.playClickSound();
          await _showFAQDialog(
              title, bulletPoints, textColor, subTextColor, soundService, lottiePath);
        },
        child: Card(
          color: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Slightly more rounded
          elevation: 5, // Slightly more shadow
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Slightly more padding
            child: Row(
              children: [
                Icon(Icons.question_mark_rounded, // More modern question mark icon
                    color: Colors.blueAccent, size: 28), // Slightly larger icon
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17, // Slightly larger font
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey), // Indicating interaction
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFAQDialog(
    String title,
    List<String> bulletPoints,
    Color textColor,
    Color subTextColor,
    SoundService soundService,
    String lottiePath,
  ) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "FAQ Popup",
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale:
              CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart), // More refined animation
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // More rounded dialog
            title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)), // Bold title
            content: SingleChildScrollView( // Added SingleChildScrollView for longer content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120, // Adjusted Lottie size
                    width: 120,
                    child: Lottie.asset(
                      lottiePath,
                      fit: BoxFit.contain,
                      repeat: true, // Keep the animation looping
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...bulletPoints.map(
                    (point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(point, style: TextStyle(color: subTextColor, fontSize: 16)), // Slightly larger text
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Would you like to ask the chatbot about this?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor.withOpacity(0.8), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await soundService.playPopSound();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey, // Muted "Close" button
                ),
                child: const Text("Close"),
              ),
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // More prominent action button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Ask Chatbot"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(
      BuildContext context, IconData icon, String text, String url, Color textColor, SoundService soundService) {
    return InkWell(
      onTap: () async {
        await soundService.playClickSound();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open $text')), // More user-friendly message
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0), // Slightly more vertical padding
        child: Row(
          children: [
            Icon(icon, color: Colors.lightBlueAccent, size: 26), // Slightly larger icon
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 17, color: textColor), // Slightly larger text
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.launch_rounded, color: Colors.grey, size: 20), // Indicating external link
          ],
        ),
      ),
    );
  }

  Widget _animatedButton(Widget button) {
    return ElasticIn(
      duration: const Duration(milliseconds: 700),
      child: Material( // Use Material for inkwell effect if needed
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        elevation: 6, // Slightly more elevation
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // Slightly more opaque
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3), // Subtler shadow color
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: button,
        ),
      ),
    );
  }
}
