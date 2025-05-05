import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'package:flutter/src/painting/gradient.dart' as flutter_gradient;
import 'package:rive/src/rive_core/shapes/paint/linear_gradient.dart' as rive_gradient;
import 'package:shimmer/shimmer.dart'; // Import Shimmer

import '../core/utils/sound_service.dart';
import '../core/utils/permission_handler.dart';
import '../settings.dart';
import '../widgets/theme_provider.dart';
import '../widgets/chatbot_button.dart';
import '../widgets/profile_button.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAsyncTasks();
    // Simulate loading delay for shimmer effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _initAsyncTasks() async {
    await PermissionHandlerService.requestInitialPermissions();
    await SoundService().initialize();
  }

  Widget _buildLoadingSkeleton(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 200, height: 30, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 80, color: Colors.white),
          const SizedBox(height: 20),
          Container(width: 150, height: 30, color: Colors.white),
          const SizedBox(height: 10),
          ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(height: 60, color: Colors.white),
              )),
          const SizedBox(height: 20),
          Container(width: 180, height: 30, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 80, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final soundService = Provider.of<SoundService>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: _isLoading
            ? Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: const Text("About Navedge"),
              )
            : const Text("About Navedge"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          _animatedBackground(isDarkMode),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: _isLoading
                  ? _buildLoadingSkeleton(isDarkMode)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(context, "About Navedge", 600, isDarkMode),
                          const SizedBox(height: 12),
                          _animatedText(
                            context,
                            "Navedge is an innovative and intelligent navigation platform offering AI-powered routes, chatbot assistance, and offline-first maps. Explore your journey smarter with us.",
                            700,
                            isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _sectionHeader(context, "Core Features:", 750, isDarkMode),
                          const SizedBox(height: 10),
                          ..._buildFeatureTiles(context, isDarkMode),
                          const SizedBox(height: 24),
                          _sectionHeader(context, "Our Mission:", 800, isDarkMode),
                          const SizedBox(height: 10),
                          _animatedText(
                            context,
                            "We aim to revolutionize navigation by integrating real-time intelligence, open data, and elegant design. With Navedge, the journey is just as smart as the destination.",
                            850,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          _buildAnimatedButtons(context),
        ],
      ),
    );
  }

  Widget _animatedBackground(bool isDarkMode) {
    return ShaderMask(
      shaderCallback: (bounds) => flutter_gradient.LinearGradient(
        colors: isDarkMode
            ? [Colors.deepPurple.shade900, Colors.black]
            : [Colors.blue.shade100, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcOver,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/gradient_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int delay, bool isDarkMode) {
    return FadeInUp(
      duration: Duration(milliseconds: delay),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _animatedText(BuildContext context, String text, int delay, bool isDarkMode) {
    return FadeIn(
      duration: Duration(milliseconds: delay),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
      ),
    );
  }

  List<Widget> _buildFeatureTiles(BuildContext context, bool isDarkMode) {
    final features = [
      ["🗺️ Google Maps Integration", "Navigate anywhere using Google Maps with live location and routes."],
      ["🔍 Smart Search", "Find any location by name, landmark, or coordinates with autocomplete."],
      ["👤 Firebase Login System", "Securely log in using Google, Apple, or guest mode via Firebase Auth."],
      ["🗣️ Chatbot Assistant (No ML)", "In-app chatbot helps with routing and queries using rule-based logic."],
      ["🚀 Routing Algorithms", "Choose between Dijkstra, Bellman-Ford, A*, and Floyd-Warshall algorithms."],
      ["💬 Voice Assistant", "Use speech to search, get directions, or interact hands-free with the app."],
      ["🌐 Open Data Support", "Download OpenStreetMap data for offline navigation and open-source flexibility."],
      ["🧠 AI-Enhanced Routing", "Smarter routing with future AI features like preferences and traffic-aware paths."],
      ["📱 Cross-Platform Support", "Runs seamlessly on Android, iOS, and Web using a single Flutter codebase."]
    ];
    final soundService = Provider.of<SoundService>(context, listen: false);

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final title = entry.value[0];
      final description = entry.value[1];

      return GestureDetector(
        onTap: () async {
          HapticFeedback.mediumImpact();
          await soundService.playClickSound();
          _showFeaturePopup(context, title, description);
        },
        child: FadeInRight(
          duration: Duration(milliseconds: 600 + index * 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showFeaturePopup(BuildContext context, String title, String description) {
    final detailedDescriptions = {
      "🗺️ Google Maps Integration":
          "Our app integrates Google Maps to deliver high-quality, interactive mapping experiences. It supports dynamic markers, live location tracking, polylines for route rendering, and turn-by-turn navigation. The integration leverages Google's Directions, Geocoding, and Places APIs, enabling real-time route suggestions, location searches, and reverse geocoding. It supports hybrid, terrain, and satellite views. Whether you're navigating busy city roads or rural paths, Google Maps ensures detailed coverage and precise route plotting. This feature empowers users with accurate, up-to-date mapping data and a globally recognized interface optimized for both Android and iOS through Flutter's cross-platform capabilities.",
      "🔍 Smart Search":
          "Smart Search allows users to look up any place using names, coordinates, or keywords. Powered by Google's Places API, it delivers lightning-fast, location-aware autocomplete suggestions while typing. Users can search for landmarks, restaurants, addresses, or even raw coordinates like '28.6139, 77.2090'. The system automatically ranks relevant results by proximity and popularity. For areas with no internet, the app can fall back to a locally stored index of saved locations or favorites. This feature eliminates the guesswork and makes navigation easy, whether you're in an unfamiliar neighborhood or revisiting your favorite destination.",
      "👤 Firebase Login System":
          "The app supports secure login using Firebase Authentication, enabling multiple sign-in options such as Google, Apple, and anonymous guest mode. Users can create a profile that stores personal preferences including selected map themes, favorite routes, and accessibility settings. Firebase ensures safe, encrypted identity management while allowing for easy syncing across multiple devices. Logged-in users also benefit from profile image uploads, saved chatbot history, and persistent login sessions. With Firebase's reliability and ease of integration with Flutter, authentication becomes seamless, fast, and user-friendly—no additional server-side setup required.",
      "🗣️ Chatbot Assistant (No ML)":
          "The in-app chatbot assistant works completely offline using rule-based logic without requiring machine learning. It identifies specific keywords like 'route', 'offline', 'help', or 'hi' and responds with predefined, context-sensitive replies. This design ensures consistent performance even without an internet connection. The chatbot acts as a user guide, helping users understand the app features, suggest nearby places, or initiate route planning. Built with simple, extensible logic, new phrases and responses can easily be added to expand its conversational range. This lightweight approach ensures accessibility while maintaining conversational interaction throughout the app.",
      "🚀 Routing Algorithms":
          "The app includes multiple routing algorithms for both online and offline scenarios. Users can choose between Dijkstra, Bellman-Ford, Floyd-Warshall, or A* algorithms based on their preferences. Each algorithm is implemented in Dart for performance and flexibility. Offline routing uses preloaded maps or custom graphs for computing paths. Online users can rely on Google’s Directions API. The algorithm selector is available in the settings, allowing users to prioritize fastest, shortest, or most scenic routes. This gives full control over route planning, ideal for power users or technical users seeking transparency in navigation logic.",
      "💬 Voice Assistant":
          "Voice Assistant enhances hands-free navigation by converting spoken queries into actionable app commands. Users can search for places, request directions, or interact with the chatbot using natural voice input. The app uses speech-to-text plugins to capture and process speech, triggering actions such as opening routes or displaying results. With animated waveforms and real-time transcription, it creates an interactive and engaging experience. Especially useful for driving scenarios, this feature promotes safety, accessibility, and convenience. All voice interactions are processed locally where possible, ensuring user privacy while reducing reliance on constant connectivity.",
      "🌐 Open Data Support":
          "We proudly support open data standards by incorporating OpenStreetMap (OSM) datasets for offline and community-driven mapping. Users can download `.osm.pbf` files to enable offline map usage in remote areas. This ensures reliable navigation even without internet access. Using open data promotes transparency, scalability, and contributes to global coverage. Our implementation supports map rendering using OSM tiles and allows users to switch between OSM and Google Maps based on preference. This dual-layered support gives users flexibility while empowering open-source communities to continuously update and improve mapping accuracy.",
      "🧠 AI-Enhanced Routing (Optional/Future)":
          "AI-Enhanced Routing (optional feature) will use contextual data such as user preferences, traffic patterns, and behavior history to suggest smarter, adaptive routes. While not ML-based yet, future updates may include reinforcement learning models to dynamically learn and optimize based on past user journeys. For now, the app allows partial customization like avoiding tolls, preferring scenic paths, or choosing efficiency. As the app evolves, AI will help recommend ideal departure times, suggest reroutes during congestion, and even propose pitstops. This feature aims to deliver deeply personalized navigation for every journey.",
      "📱 Cross-Platform Support":
          "Built with Flutter, the app runs seamlessly on Android, iOS, and even Web platforms using a single codebase. All native functionalities—GPS, maps, authentication, and voice input—are abstracted using well-maintained Flutter plugins. This enables faster development and ensures UI/UX consistency across devices. Firebase handles the backend integration, while platform-specific tweaks like Apple Sign-In or Android permissions are fully supported. Whether you're testing on an emulator or deploying to a real device, Flutter ensures optimized performance and native feel without compromising on design or functionality. Deploy once, run everywhere—simple and efficient.",
    };
    final soundService = Provider.of<SoundService>(context, listen: false);
    final detailedText = detailedDescriptions[title] ?? description;

    showDialog(
      context: context,
      builder: (context) {
        return ElasticIn(
          duration: const Duration(milliseconds: 500),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Theme.of(context).cardColor,
            title: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.deepPurpleAccent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Text(
              detailedText,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await soundService.playPopSound();
                  Navigator.pop(context);
                },
                child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButtons(BuildContext context) {
    final soundService = Provider.of<SoundService>(context, listen: false);
    return Stack(
      children: [
        Positioned(
          bottom: 20,
          right: 20,
          child: _navButton(context, ChatbotButton(onPressed: () async {
            await soundService.playConfirmSound();
            Navigator.push(context, _animatedRoute(const ChatbotScreen()));
          })),
        ),
        Positioned(
          top: 30, // Adjusted top position to be a bit lower
          right: 20,
          child: _navButton(context, ProfileButton(onPressed: () async {
            await soundService.playClickSound();
            Navigator.push(context, _animatedRoute(const ProfileScreen()));
          })),
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, Widget button) {
    return ElasticIn(
      duration: const Duration(milliseconds: 600),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: button,
      ),
    );
  }

  PageRouteBuilder _animatedRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }
}
