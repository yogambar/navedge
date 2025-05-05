import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import for LatLng
import 'dart:async'; // Import for Timer
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges; // Import the badges package

import '../core/utils/sound_service.dart';
import '../core/utils/permission_handler.dart';
import '../widgets/theme_provider.dart';
import '../settings.dart';

import '../widgets/login_button.dart';
import '../widgets/chatbot_button.dart';
import '../widgets/map_button.dart';
import '../widgets/route_planner_button.dart';
import '../widgets/settings_button.dart';
import '../widgets/home_button.dart';
import '../widgets/profile_button.dart';
import '../widgets/help_button.dart';
import '../widgets/about_button.dart';

import 'profile_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import 'chatbot_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'route_planner_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

import '../user_data_provider.dart';

class AllButtonsScreen extends StatefulWidget {
  const AllButtonsScreen({super.key});

  @override
  State<AllButtonsScreen> createState() => _AllButtonsScreenState();
}

class _AllButtonsScreenState extends State<AllButtonsScreen> {
  bool _loading = true;
  Timer? _hoverSoundTimer; // Timer for debouncing hover sound

  @override
  void initState() {
    super.initState();
    // Simulate loading delay for shimmer effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hoverSoundTimer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final userData = context.watch<UserData>();
    final soundService = Provider.of<SoundService>(context, listen: false);

    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _loading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const Text(
                  'Explore Navedge',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              )
            : const Text(
                'Explore Navedge',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.black, Colors.deepPurple.shade900]
                      : [Colors.lightBlue.shade100, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: _loading
                  ? GridView.builder(
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 25,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 25,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final button = _getButtonWithSize(context, index, 36); // Adjusted iconSize
                        final label = _getLabel(index);
                        final screen = _getScreen(index);

                        return _animatedButton(
                          context,
                          button,
                          label,
                          screen,
                          userData,
                          index,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedButton(
    BuildContext context,
    Widget button,
    String label,
    Widget screen,
    UserData userData,
    int index,
  ) {
    final showBadge =
        userData.hasSpecialBadge && (index == 0 || index == 3 || index == 6);
    final animated = _getAnimation(index);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.lightBlue.shade100;
    final soundService = Provider.of<SoundService>(context, listen: false);

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) async {
            if (kIsWeb ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows) {
              if (_hoverSoundTimer?.isActive ?? false) {
                _hoverSoundTimer!.cancel();
              }
              _hoverSoundTimer = Timer(const Duration(milliseconds: 100), () async {
                await soundService.playHoverSound();
              });
            }
          },
          onExit: (_) {
            _hoverSoundTimer?.cancel();
          },
          child: GestureDetector(
            onTap: () async {
              await soundService.playButtonClickSound();
              await PermissionHandlerService.checkAndRequestPermissions();

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => screen,
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.4), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: animation, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 700),
                ),
              );
            },
            child: animated(
              badges.Badge(
                showBadge: showBadge,
                badgeContent: const Text('★', style: TextStyle(color: Colors.white)),
                badgeStyle: badges.BadgeStyle(badgeColor: Colors.deepPurple),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerSize = constraints.maxWidth;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1, // Creates a square
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.95), // Match background
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  blurRadius: 14,
                                  offset: const Offset(4, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0), // Ensure logo is fully visible
                                child: _getButtonWithSize(context, index, containerSize * 0.6), // Adjust size as needed
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                            shadows: const [
                              Shadow(
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget Function(Widget) _getAnimation(int index) {
    final delay = Duration(milliseconds: 100 * index);

    switch (index % 4) {
      case 0:
        return (child) => FlipInY(
            child: child, duration: const Duration(milliseconds: 600), delay: delay);
      case 1:
        return (child) => ZoomIn(
            child: child, duration: const Duration(milliseconds: 500), delay: delay);
      case 2:
        return (child) => BounceInDown(
            child: child, duration: const Duration(milliseconds: 500), delay: delay);
      case 3:
      default:
        return (child) => FadeInUp(
            child: child, duration: const Duration(milliseconds: 500), delay: delay);
    }
  }

  Widget _getButtonWithSize(BuildContext context, int index, double size) {
    final exampleGraph = {
      LatLng(37.7749, -122.4194): {LatLng(34.0522, -118.2437): 380.0},
    };
    final soundService = Provider.of<SoundService>(context, listen: false);

    switch (index) {
      case 0:
        return LoginButton(iconSize: size);
      case 1:
        return ChatbotButton(iconSize: size);
      case 2:
        return MapButton(iconSize: size, initialGraph: exampleGraph); // Corrected parameter name
      case 3:
        return RoutePlannerButton(
          onPressed: () {
            soundService.playNavigationTapSound(); // Example of another sound
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const RoutePlannerScreen(), // Removed incorrect parameters
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.4), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 700),
              ),
            );
          },
          size: size, // Using size parameter
        );
      case 4:
        return SettingsButton(iconSize: size);
      case 5:
        return HomeButton(iconSize: size);
      case 6:
        return ProfileButton(iconSize: size);
      case 7:
        return HelpButton(iconSize: size);
      case 8:
        return AboutButton(iconSize: size); // Removed the incorrect parameter
      default:
        return const SizedBox();
    }
  }

  String _getLabel(int index) {
    const labels = [
      'Login',
      'Chatbot',
      'Map',
      'Route',
      'Settings',
      'Home',
      'Profile',
      'Help',
      'About',
    ];
    return labels[index];
  }

  Widget _getScreen(int index) {
    final exampleGraph = {
      LatLng(37.7749, -122.4194): {LatLng(34.0522, -118.2437): 380.0},
    };

    switch (index) {
      case 0:
        return const LoginScreen();
      case 1:
        return const ChatbotScreen();
      case 2:
        return MapScreen(initialGraph: exampleGraph); // Corrected parameter name
      case 3:
        return const RoutePlannerScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return const HomeScreen();
      case 6:
        return const ProfileScreen();
      case 7:
        return const HelpScreen();
      case 8:
        return const AboutScreen();
      default:
        return const SizedBox();
    }
  }
}
