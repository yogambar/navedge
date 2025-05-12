import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../core/authentication/auth_service.dart';
import '../core/utils/permission_handler.dart';
import '../core/utils/sound_service.dart';
import '../user_data_provider.dart';
import '../widgets/chatbot_button.dart';
import '../screens/chatbot_screen.dart';
import '../widgets/theme_provider.dart';
import 'home_screen.dart'; // Import HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Access the AuthService using Provider
  AuthService get _authService => Provider.of<AuthService>(context, listen: false);
  bool _showAnimation = false;
  bool _loginSuccess = false;
  bool _isLoading = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await SoundService().initialize();
    await PermissionHandlerService.checkAndRequestAllPermissionsOnce();

    if (_authService.currentUser != null) {
      await _fetchUserDataAndNavigate(); // Call combined fetch and navigate
      return; // Prevent the delayed loading screen
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() => _dataLoaded = true);
  }

  Future<void> _fetchUserDataAndNavigate() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = Provider.of<UserData>(context, listen: false);
      final fetchedUserData = await _authService.getUserDetails(user.uid);
      if (fetchedUserData != null) {
        userData.updateUserDetails(
          uid: user.uid,
          name: fetchedUserData['name'] ?? '',
          email: fetchedUserData['email'] ?? '',
          age: fetchedUserData['age'],
          gender: fetchedUserData['gender'],
          dob: fetchedUserData['dob'],
          profileImagePath: fetchedUserData['profileImagePath'],
          badgeType: fetchedUserData['badgeType'] ?? '',
          role: fetchedUserData['role'],
          loginStreak: fetchedUserData['loginStreak'] ?? 0,
          animationType: fetchedUserData['animationType'] ?? 'bounceIn',
          soundPath: fetchedUserData['soundPath'],
          lastActive: fetchedUserData['lastActive'] != null
              ? DateTime.tryParse(fetchedUserData['lastActive'])
              : null,
          isOnline: fetchedUserData['isOnline'] ?? false,
          isEmailPasswordEnabled:
              fetchedUserData['isEmailPasswordEnabled'] ?? false,
          isGoogleEnabled: fetchedUserData['isGoogleEnabled'] ?? false,
          isGitHubEnabled: fetchedUserData['isGitHubEnabled'] ?? false,
          isMicrosoftEnabled: fetchedUserData['isMicrosoftEnabled'] ?? false,
          isAppleEnabled: fetchedUserData['isAppleEnabled'] ?? false,
        );
        // Navigate to the home screen after fetching data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // If user data fetch fails, still show the login screen
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _dataLoaded = true);
      }
    } else {
      // If no current user, show the login screen
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _dataLoaded = true);
    }
  }

  void _triggerSound(String path) {
    SoundService().playSound(path);
  }

  Future<void> _showLoginAnimation(bool success) async {
    final soundService = Provider.of<SoundService>(context, listen: false);
    await soundService.playFeedback(success ? 'success.wav' : 'error.wav');

    setState(() {
      _showAnimation = true;
      _loginSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _showAnimation = false);
    });
  }

  Future<void> _handleLogin(String provider) async {
    setState(() => _isLoading = true);
    final soundService = Provider.of<SoundService>(context, listen: false);
    await soundService.playClickSound();
    try {
      Map<String, dynamic>? userDetails;
      if (provider == 'google') {
        userDetails = await _authService.loginWithGoogle();
      } else if (provider == 'apple') {
        userDetails = await _authService.loginWithApple();
      } else if (provider == 'github') {
        userDetails = await _authService.loginWithGitHub();
      } else if (provider == 'microsoft') {
        userDetails = await _authService.loginWithMicrosoft();
      }

      final success = userDetails != null && userDetails['uid'] != null;
      _showLoginAnimation(success);

      if (success) {
        final userData = Provider.of<UserData>(context, listen: false);
        userData.updateUserDetails(
          uid: userDetails['uid'],
          name: userDetails['name'] ?? '',
          email: userDetails['email'] ?? '',
          profileImagePath: userDetails['photoUrl'],
        );
        // Navigate to the home screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      _showLoginAnimation(false);
      await soundService.playErrorSound();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _customLoginButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconLoginButton('assets/images/icons/google_logo.jpeg', 'Google',
                Colors.white, () => _handleLogin('google')),
            _iconLoginButton('assets/images/icons/github_logo.png', 'GitHub',
                Colors.black87, () => _handleLogin('github')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconLoginButton('assets/images/icons/microsoft_logo.png', 'Microsoft',
                Colors.white, () => _handleLogin('microsoft')),
            _iconLoginButton(null, 'Apple', Colors.black,
                () => _handleLogin('apple'),
                icon: Icons.apple),
          ],
        ),
      ],
    );
  }

  Widget _iconLoginButton(String? imagePath, String label, Color color,
      VoidCallback onTap,
      {IconData? icon}) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final soundService = Provider.of<SoundService>(context, listen: false);
    final size = MediaQuery.of(context).size.width * 0.25; // Adjust for desired size

    return GestureDetector(
      onTap: () async {
        await soundService.playClickSound();
        onTap();
      },
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: size / 2.5,
              child: imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(imagePath),
                    )
                  : Icon(icon, color: Colors.white, size: size / 2),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_qp1q7mct.json',
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Fetching your data.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserData>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.deepPurple.shade900, Colors.black]
                    : [Colors.lightBlue.shade100, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            foregroundDecoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: Center(
              child: !_dataLoaded
                  ? _buildLoadingSkeleton(isDarkMode)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            child: Lottie.network(
                              'https://assets10.lottiefiles.com/packages/lf20_qp1q7mct.json',
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              userData.name.isNotEmpty
                                  ? "Hello, ${userData.name}!"
                                  : "Welcome to NavEdge!",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 800),
                            child: const Text(
                              "Sign in to continue your journey.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          FadeIn(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 800),
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white))
                                : Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    color: isDarkMode
                                        ? Colors.grey[900]
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Sign in with:",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 30),
                                          _customLoginButtons(),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: IconButton(
                              icon: Icon(
                                isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Colors.white70,
                                size: 30,
                              ),
                              onPressed: themeProvider.toggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (_showAnimation)
            Center(
              child: Lottie.asset(
                _loginSuccess
                    ? 'assets/images/animations/login_success.json'
                    : 'assets/images/animations/login_failed.json',
                width: 180,
                repeat: false,
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ChatbotButton(
              onPressed: () async {
                final soundService =
                    Provider.of<SoundService>(context, listen: false);
                await soundService.playClickSound();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatbotScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
