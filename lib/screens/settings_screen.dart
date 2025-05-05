import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore

import '../core/settings/app_settings.dart';
import '../core/utils/sound_service.dart';
import '../core/utils/permission_handler.dart';
import '../settings.dart';
import '../widgets/theme_provider.dart'; // Theme provider
import 'feedback_screen.dart'; // Import Feedback Screen
import 'help_support_screen.dart'; // Import Help & Support Screen
import '../user_data_provider.dart'; // Import User Data Provider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();

  bool _isDarkMode = false;
  bool _areNotificationsEnabled = true;
  bool _isLocationEnabled = true;
  double _brightness = 1.0;
  double _soundVolume = 1.0;
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _settings.loadSettings();
    final soundVol = await SoundService().getVolume();
    final locGranted = await Permission.location.isGranted;
    final notifGranted = await Permission.notification.isGranted;
    final brightness = await _getBrightness(); // Get system brightness

    setState(() {
      _isDarkMode = _settings.isDarkMode;
      _brightness = brightness;
      _soundVolume = soundVol;
      _isLocationEnabled = locGranted;
      _areNotificationsEnabled = notifGranted;
      _isLoading = false;
    });
  }

  Future<double> _getBrightness() async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      debugPrint("Error getting brightness: $e");
      return 1.0;
    }
  }

  Future<void> _setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
      await _settings.setBrightness(value);
      setState(() => _brightness = value);
    } catch (e) {
      debugPrint("Error setting brightness: $e");
      // Handle error, maybe show a snackbar
    }
  }

  Future<void> _giveFeedbackHaptic() async {
    HapticFeedback.lightImpact();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    await SoundService().playClickSound();
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _settings.toggleDarkMode();
    setState(() => _isDarkMode = value);
    await _giveFeedbackHaptic();
    context.read<ThemeProvider>().toggleTheme(); // Update global theme
  }

  Future<void> _changeSoundVolume(double value) async {
    await SoundService().setVolume(value);
    setState(() => _soundVolume = value);
    await _giveFeedbackHaptic();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() => _isLocationEnabled = status.isGranted);
    await _giveFeedbackHaptic();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() => _areNotificationsEnabled = status.isGranted);
    await _giveFeedbackHaptic();
  }

  void _resetSettings() {
    setState(() {
      _isDarkMode = false;
      _brightness = 1.0;
      _soundVolume = 1.0;
      _areNotificationsEnabled = true;
      _isLocationEnabled = true;
      _selectedLanguage = 'English';
    });
    _giveFeedbackHaptic();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> _navigateToFeedbackScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
    );
  }

  Future<void> _navigateToHelpSupportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
    );
  }

  Future<void> _showReportDialog() async {
    final userData = Provider.of<UserData>(context, listen: false);
    final TextEditingController reportController = TextEditingController();
    double rating = 0.0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report a Problem'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Please describe the problem you are experiencing:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reportController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue in detail...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Optional: Rate the severity of the problem:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.warning,
                    color: Colors.orange,
                  ),
                  onRatingUpdate: (newRating) {
                    rating = newRating;
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Information (for better assistance):',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text('Name: ${userData.name}'),
                Text('Email: ${userData.email ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final report = reportController.text.trim();
                if (report.isNotEmpty) {
                  // Advanced reporting: Save to Firebase with severity, user info, etc.
                  try {
                    await FirebaseFirestore.instance
                        .collection('reports')
                        .add({
                      'userId': userData.uid,
                      'name': userData.name,
                      'email': userData.email ?? 'N/A',
                      'report': report,
                      'severityRating': rating,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    reportController.clear();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Problem reported. Thank you!')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error reporting problem: $error')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please describe the problem.')),
                  );
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About Navedge"),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Navedge is a cutting-edge navigation application designed to provide users with seamless and intuitive navigation experiences...", textAlign: TextAlign.justify),
              SizedBox(height: 20),
              Text("Key Features:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("- Real-time traffic updates"),
              Text("- Turn-by-turn voice navigation"),
              Text("- Offline map support"),
              Text("- Point of Interest (POI) search"),
              // Add more documentation here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSwitchTile("Dark Mode", Icons.dark_mode, _isDarkMode, _toggleDarkMode),
                const SizedBox(height: 16),
                _buildSliderTile("Brightness", Icons.brightness_6, _brightness, _setBrightness),
                const SizedBox(height: 16),
                _buildSliderTile("Sound Volume", Icons.volume_up, _soundVolume, _changeSoundVolume),
                const SizedBox(height: 16),
                _buildSwitchTile("Notifications", Icons.notifications, _areNotificationsEnabled, (_) {
                  _requestNotificationPermission();
                }),
                const SizedBox(height: 16),
                _buildSwitchTile("Location Services", Icons.location_on, _isLocationEnabled, (_) {
                  _requestLocationPermission();
                }),
                const SizedBox(height: 16),
                Text("Language", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: "English", child: Text("English")),
                    DropdownMenuItem(value: "Spanish", child: Text("Spanish")),
                    DropdownMenuItem(value: "Hindi", child: Text("Hindi")),
                    DropdownMenuItem(value: "French", child: Text("French")),
                    DropdownMenuItem(value: "German", child: Text("German")),
                    DropdownMenuItem(value: "Japanese", child: Text("Japanese")),
                  ],
                  onChanged: (val) async {
                    setState(() => _selectedLanguage = val!);
                    await _giveFeedbackHaptic();
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Reset to Default"),
                  onPressed: _resetSettings,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.feedback_outlined),
                  label: const Text("Give Feedback"),
                  onPressed: _navigateToFeedbackScreen,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline),
                  label: const Text("Help & Support"),
                  onPressed: _navigateToHelpSupportScreen,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.report_problem),
                  label: const Text("Report a Problem"),
                  onPressed: _showReportDialog,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text("About App"),
                  onPressed: _showAboutDialog,
                ),
                const SizedBox(height: 30),
                Text("Advanced Features", style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Share App"),
                  onPressed: () {
                    _launchURL('https://drive.google.com/your_app_link_here'); // Replace with your actual Google Drive link
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.privacy_tip),
                  label: const Text("Privacy Policy"),
                  onPressed: () async {
                    const url = 'https://your-privacy-policy-url.com'; // Replace with your actual privacy policy URL
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch privacy policy URL.')),
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(String title, IconData icon, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 16)),
        ]),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
