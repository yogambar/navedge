import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../core/utils/permission_handler.dart';
import '../core/utils/sound_service.dart'; 
import '../widgets/theme_provider.dart';
import '../widgets/all_buttons_button.dart';
import '../widgets/chatbot_button.dart';
import '../widgets/profile_button.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'all_buttons_screen.dart';
import '../user_data_provider.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showTermsPopup = false;
  bool _termsAccepted = false;
  bool _showWelcomeAnimation = false;
  bool _isScreenLoading = true;
  bool _hasUserInteracted = false; // Track if user has interacted
  LatLng? _currentLocation;
  String _locationText = 'Locating...';
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));
    await _requestPermissions();
    _checkFirstLogin();
    setState(() => _isScreenLoading = false);
  }

  Future<void> _requestPermissions() async {
    await PermissionHandlerService.requestLocationPermission();
    await PermissionHandlerService.requestCameraPermission();
    await PermissionHandlerService.requestMicrophonePermission();
    await PermissionHandlerService.requestNotificationPermission();
  }

  Future<void> _checkFirstLogin() async {
    final userProvider = Provider.of<UserData>(context, listen: false);
    if (!userProvider.hasLoggedInBefore) {
      setState(() => _showTermsPopup = true);
    } else {
      setState(() => _termsAccepted = true);
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
      _locationText = 'Locating...';
    });

    bool locationGranted =
        await PermissionHandlerService.isPermissionGranted(Permission.location);

    if (locationGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateLocationText(position.latitude, position.longitude);
      } catch (e) {
        _locationText = 'Error fetching location.';
      }
    } else {
      _locationText = 'Location permission denied.';
    }

    setState(() => _locationLoading = false);
  }

  Future<void> _updateLocationText(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() => _locationText = '${place.locality}, ${place.country}');
      } else {
        setState(() => _locationText = 'Coordinates: ($lat, $lon)');
      }
    } catch (e) {
      setState(() => _locationText = 'Coordinates: ($lat, $lon)');
    }
  }

  Widget _buildTermsPopup() {
    final userProvider = Provider.of<UserData>(context, listen: false);
    final soundService = Provider.of<SoundService>(context, listen: false);

    return AlertDialog(
      title: const Text('📜 Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👋 Welcome!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('📄 Please read and accept the following terms and conditions:',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text(
                '1. 📖 Acceptance of Terms: By using this application, you agree to be bound by these Terms and Conditions and our Privacy Policy.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '2. 🚦 User Conduct: You agree to use the application only for lawful purposes and in a manner that does not infringe the rights of, restrict, or inhibit anyone else\'s use and enjoyment of the application.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '3. 🔒 Privacy: Your privacy is important to us. Please refer to our Privacy Policy for details on how we collect, use, and protect your personal information.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '4. ⚖ Intellectual Property: The application and its original content, features, and functionality are owned by [Your Company Name] and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '5. ❗ Disclaimer of Warranties: The application is provided on an "AS IS" and "AS AVAILABLE" basis without any warranties of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, and course of performance.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '6. ⚠ Limitation of Liability: In no event shall [Your Company Name] be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or in connection with your use of the application.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '7. 🌍 Governing Law: These Terms and Conditions shall be governed by and construed in accordance with the laws of [Your Country/State], without regard to its conflict of law provisions.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '8. 🔄 Changes to Terms: We reserve the right to modify or replace these Terms and Conditions at any time. Your continued use of the application after any such changes constitutes your acceptance of the new Terms and Conditions.',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
                '9. 📬 Contact Us: If you have any questions about these Terms and Conditions, please contact us at [Your Contact Information].',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text('🎉 Enjoy a smooth and secure experience!',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await soundService.playConfirmSound();
            userProvider.setHasLoggedInBefore(true);
            setState(() {
              _showTermsPopup = false;
              _termsAccepted = true;
              _showWelcomeAnimation = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              soundService.playSuccessSound(); // Play a sound after accepting
            });
            Future.delayed(const Duration(seconds: 4), () {
              setState(() => _showWelcomeAnimation = false);
              _fetchLocation();
            });
          },
          child: const Text('Accept', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildWelcomeAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          'assets/animations/fireworks.json',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Lottie.asset(
          'assets/animations/welcome.json',
          width: 400,
          height: 400,
        ),
      ],
    );
  }

  Widget _buildCoordinateBar() {
    return ZoomIn(
      delay: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_pin, color: Colors.red),
            const SizedBox(width: 8),
            _locationLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(_locationText,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return BounceInUp(
      delay: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton(AllButtonsButton(onPressed: () {
              _handleButtonPress(() {
                Navigator.push(
                    context, _animatedRoute(const AllButtonsScreen()));
              });
            })),
            _navButton(ProfileButton(onPressed: () {
              _handleButtonPress(() {
                Navigator.push(
                    context, _animatedRoute(const ProfileScreen()));
              });
            })),
            _navButton(ChatbotButton(onPressed: () {
              _handleButtonPress(() {
                Navigator.push(
                    context, _animatedRoute(const ChatbotScreen()));
              });
            })),
          ],
        ),
      ),
    );
  }

  void _handleButtonPress(VoidCallback navigationCallback) {
    final soundService = Provider.of<SoundService>(context, listen: false);
    // Play hover sound only if the user hasn't interacted yet
    if (!_hasUserInteracted) {
      soundService.playHoverSound();
      setState(() => _hasUserInteracted = true);
    }
    navigationCallback();
  }

  Widget _navButton(Widget button) {
    return Pulse(
      duration: const Duration(seconds: 2),
      child: SizedBox(
        width: 100,
        height: 100,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: button,
        ),
      ),
    );
  }

  PageRouteBuilder<dynamic> _animatedRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return SizedBox.expand(
      child: Lottie.asset(
        'assets/animations/world.json',
        fit: BoxFit.cover,
        repeat: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserData>(context);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.deepPurple[900] : Colors.blue[100],
      body: _isScreenLoading
          ? Stack( // Use Stack to position the full-screen image
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/app_logo/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error_outline,
                            size: 200, color: Colors.red),
                      );
                    },
                  ),
                ),
                Center( // Center the shimmer loading indicator on top of the image
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 136), // Adjust spacing if needed
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                _buildAnimatedBackground(),
                if (_showWelcomeAnimation) _buildWelcomeAnimation(),
                if (!_showWelcomeAnimation) ...[
                  Positioned(
                      top: 80, left: 0, right: 0, child: _buildCoordinateBar()),
                  Positioned(
                      bottom: 100, left: 0, right: 0, child: _buildButtons()),
                ],
                if (_showTermsPopup) Center(child: _buildTermsPopup()),
              ],
            ),
    );
  }
}
