import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/chatbot_button.dart';
import '../core/authentication/auth_service.dart';
import '../core/utils/permission_handler.dart';
import '../core/utils/sound_service.dart';
import '../widgets/theme_provider.dart';
import '../user_data_provider.dart';
import 'login_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final picker = ImagePicker();
  File? _customProfileImage;
  bool showAnimation = false;
  bool loginSuccess = false;
  bool loading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // bool _notificationsEnabled = true; // Example notification state - moved to settings

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    PermissionHandlerService.requestPermissions();
    Provider.of<UserData>(context, listen: false).getCurrentLocation();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => loading = false);
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _triggerLoginAnimation(bool success) async {
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(success ? FeedbackType.success : FeedbackType.error);
    }
    await SoundService().playFeedback(success ? 'success.wav' : 'error.wav');

    setState(() {
      loginSuccess = success;
      showAnimation = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showAnimation = false);
      }
    });
  }

  Future<void> _pickCustomImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _customProfileImage = File(picked.path));
      Provider.of<UserData>(context, listen: false)
          .updateProfileImagePath(picked.path);
    }
  }

  String _getBadgeFromStreak(int streak) {
    if (streak >= 100) return 'gold';
    if (streak >= 50) return 'silver';
    if (streak >= 20) return 'bronze';
    return 'basic'; // You might not have a 'basic' badge asset now
  }

  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) {
      return null;
    }
    try {
      final birthDate = DateFormat('yyyy-MM-dd').parse(dob);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      final monthDiff = currentDate.month - birthDate.month;
      if (monthDiff < 0 ||
          (monthDiff == 0 && currentDate.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      debugPrint("Error parsing DOB: $e");
      return null;
    }
  }

  Future<void> _logoutUser() async {
    final userData = Provider.of<UserData>(context, listen: false);
    await AuthService(userData: userData).logout();
    userData.clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void showFeatureComingSoon() {
    Flushbar(
      message: 'This feature is coming soon!',
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.construction_outlined, color: Colors.yellowAccent),
      shouldIconPulse: true,
      backgroundColor: Theme.of(context).snackBarTheme.backgroundColor ?? Colors.grey[800]!,
    ).show(context);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      Flushbar(
        message: 'Could not launch $url',
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.redAccent),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor ?? Colors.grey[800]!,
      ).show(context);
    }
  }

  Future<void> _shareProfile(UserData userData) async {
    String profileText = 'Check out my profile!\n';
    if (userData.name.isNotEmpty) profileText += 'Name: ${userData.name}\n';
    if (userData.email != null) profileText += 'Email: ${userData.email}\n';
    if (userData.age != null) profileText += 'Age: ${userData.age}\n';
    if (userData.gender != null) profileText += 'Gender: ${userData.gender}\n';
    if (userData.dob != null) profileText += 'Date of Birth: ${userData.dob}\n';
    if (userData.loginStreak > 0) profileText += 'Login Streak: ${userData.loginStreak} days\n';
    if (userData.currentLocation != null) {
      profileText += 'Location: <span class="math-inline">\{userData\.currentLocation\!\.latitude\.toStringAsFixed\(2\)\}, '
'</span>{userData.currentLocation!.longitude.toStringAsFixed(2)}\n';
    }
    if (userData.isFacebookConnected) profileText += 'Connected to Facebook\n';
    if (userData.isTwitterConnected) profileText += 'Connected to Twitter\n';
    if (userData.isLinkedInConnected) profileText += 'Connected to LinkedIn\n';
    if (userData.isGitHubConnected) profileText += 'Connected to GitHub\n';
    Share.share(profileText, subject: 'My Profile Information');
  }

  Widget _buildLoginLogoutButton(bool isLoggedIn) {
    return _stylishButton(
      icon: isLoggedIn ? Icons.logout_outlined : Icons.login_outlined,
      label: isLoggedIn ? 'Logout' : 'Login',
      onPressed: () {
        if (isLoggedIn) {
          _logoutUser();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      color: isLoggedIn ? Colors.redAccent : Colors.green,
    );
  }

  Future<void> _connectToFacebook(UserData userData) async {
    showFeatureComingSoon(); // Placeholder for Facebook login
    userData.updateFacebookConnection(true, 'Facebook User', 'facebook@example.com', 'https://facebook.com/exampleuser'); // Dummy data
    _triggerLoginAnimation(true); // Dummy success
  }

  Future<void> _connectToTwitter(UserData userData) async {
    showFeatureComingSoon(); // Placeholder for Twitter login
    userData.updateTwitterConnection(true, 'Twitter User', 'twitter@example.com', 'https://twitter.com/exampleuser'); // Dummy data
    _triggerLoginAnimation(true); // Dummy success
  }

  Future<void> _connectToLinkedIn(UserData userData) async {
    showFeatureComingSoon(); // Placeholder for LinkedIn login
    userData.updateLinkedInConnection(true, 'LinkedIn User', 'linkedin@example.com', 'https://linkedin.com/in/exampleuser'); // Dummy data
    _triggerLoginAnimation(true); // Dummy success
  }

  Future<void> _connectToGitHub(UserData userData) async {
    showFeatureComingSoon(); // Placeholder for GitHub login
    userData.updateGitHubConnection(true, 'GitHub User', 'github@example.com', 'https://github.com/exampleuser'); // Dummy data
    _triggerLoginAnimation(true); // Dummy success
  }

  void _connectToSocial(String socialMedia, UserData userData) {
    switch (socialMedia) {
      case 'facebook':
        _connectToFacebook(userData);
        break;
      case 'twitter':
        _connectToTwitter(userData);
        break;
      case 'linkedin':
        _connectToLinkedIn(userData);
        break;
      case 'github':
        _connectToGitHub(userData);
        break;
    }
  }

  Widget _buildSocialMediaLink(String socialMedia, UserData userData) {
    IconData? icon;
    VoidCallback? onTap;

    switch (socialMedia) {
      case 'facebook':
        icon = Icons.facebook;
        onTap = () => _connectToSocial('facebook', userData);
        break;
      case 'twitter':
        icon = Icons.android; // Replace with actual Twitter icon if available
        onTap = () => _connectToSocial('twitter', userData);
        break;
      case 'linkedin':
        icon = FontAwesomeIcons.linkedin;
        onTap = () => _connectToSocial('linkedin', userData);
        break;
      case 'github':
        icon = Icons.code;
        onTap = () => _connectToSocial('github', userData);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                'Connect to ${socialMedia.capitalize()}',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(title: Text('No new notifications.')),
                // Add actual notifications here
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AlertDialog(
          title: const Text('About App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('App Name: Your Awesome App'),
              const Text('Version: 1.0.0'),
              const Text('Developed by: Your Name/Organization'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode'),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
              // Add other relevant info or settings here if needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickCustomImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  _pickCustomImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Profile Photo'),
                onTap: () {
                  Provider.of<UserData>(context, listen: false)
                      .updateProfileImagePath(null);
                  setState(() => _customProfileImage = null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableSocialLink(String label, String platform, String? url, IconData icon, Function(String) onSave) {
    final controller = TextEditingController(text: url);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your $platform link',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () => onSave(controller.text.trim()),
                    ),
                  ),
                  onSubmitted: onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSocialMediaLink(String platform, String newUrl) async {
    final userData = Provider.of<UserData>(context, listen: false);

    switch (platform) {
      case 'facebook':
        userData.facebookProfileUrl = newUrl;
        userData.isFacebookConnected = newUrl.isNotEmpty;
        break;
      case 'twitter':
        userData.twitterProfileUrl = newUrl;
        userData.isTwitterConnected = newUrl.isNotEmpty;
        break;
      case 'linkedin':
        userData.linkedInProfileUrl = newUrl;
        userData.isLinkedInConnected = newUrl.isNotEmpty;
        break;
      case 'github':
        userData.githubProfileUrl = newUrl;
        userData.isGitHubConnected = newUrl.isNotEmpty;
        break;
    }

    await userData.saveToDatabase();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final badge = _getBadgeFromStreak(userData.loginStreak);
    final calculatedAge = _calculateAge(userData.dob);
    final isLoggedIn = userData.uid != null && userData.uid!.isNotEmpty;

    ImageProvider profileImg;
    if (_customProfileImage != null) {
      profileImg = FileImage(_customProfileImage!);
    } else if (userData.profileImagePath != null &&
        userData.profileImagePath!.startsWith('http')) {
      profileImg = CachedNetworkImageProvider(userData.profileImagePath!);
    } else if (userData.profileImagePath != null) {
      profileImg = FileImage(File(userData.profileImagePath!));
    } else {
      profileImg = AssetImage(
        (userData.gender?.toLowerCase() == 'female')
            ? 'assets/images/user_profiles/default_female.png'
            : 'assets/images/user_profiles/default_male.png',
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Your Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        automaticallyImplyLeading: false, // To remove the back button if any
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [Colors.black87, Colors.grey.shade900] : [Colors.grey.shade200, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: loading
                ? Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: const CircleAvatar(radius: 70),
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _animationController.forward();
                                    _showProfileImageOptions(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundImage: profileImg,
                                    onBackgroundImageError: (exception, stackTrace) {
                                      debugPrint('Error loading image: $exception');
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(Icons.edit, size: 20, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            userData.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Image.asset('assets/images/badges/${badge}_badge.png', height: 50),
                          const SizedBox(height: 30),

                          // Main profile details
                          if (userData.email != null)
                            _buildProfileDetail("Email", userData.email!, Icons.email_outlined),
                          if (userData.gender != null)
                            _buildProfileDetail("Gender", userData.gender!, Icons.person_outline),
                          if (userData.dob != null)
                            _buildProfileDetail("Date of Birth", userData.dob!, Icons.calendar_today_outlined),
                          if (calculatedAge != null)
                            _buildProfileDetail("Age", calculatedAge.toString(), Icons.cake_outlined),
                          _buildProfileDetail("Login Streak", "${userData.loginStreak} days", Icons.timeline_outlined),
                          if (userData.currentLocation != null)
                            _buildProfileDetail(
                              "Location",
                              "${userData.currentLocation!.latitude.toStringAsFixed(2)}, ${userData.currentLocation!.longitude.toStringAsFixed(2)}",
                              Icons.location_on_outlined,
                            ),
                          if (userData.lastActive != null)
                            _buildProfileDetail(
                              "Last Active",
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(userData.lastActive!),
                              Icons.access_time_outlined,
                            ),
                          _buildProfileDetail("Online Status", userData.isOnline ? "Online" : "Offline",
                              userData.isOnline ? Icons.wifi : Icons.wifi_off),
                          if (userData.role != null)
                            _buildProfileDetail("Role", userData.role!, Icons.shield_outlined),
                          if (userData.badgeType.isNotEmpty)
                            _buildProfileDetail("Badge", userData.badgeType, Icons.card_membership_outlined),
                          _buildProfileDetail(
                            "Preferred Vehicle",
                            userData.selectedVehicle.isNotEmpty ? userData.selectedVehicle : 'Not set',
                            Icons.directions_car_outlined,
                          ),
                          if (userData.soundPath != null)
                            _buildProfileDetail("Custom Sound", userData.soundPath!.split('/').last, Icons.music_note_outlined),

                          const SizedBox(height: 20),

                          if (userData.facebookProfileUrl != null && userData.facebookProfileUrl!.isNotEmpty)
                            _buildProfileDetail("Facebook", userData.facebookProfileUrl!, Icons.facebook, url: userData.facebookProfileUrl),
                          if (userData.twitterProfileUrl != null && userData.twitterProfileUrl!.isNotEmpty)
                            _buildProfileDetail("Twitter", userData.twitterProfileUrl!, Icons.android, url: userData.twitterProfileUrl), // Replace Icons.android with actual Twitter icon
                          if (userData.linkedInProfileUrl != null && userData.linkedInProfileUrl!.isNotEmpty)
                            _buildProfileDetail("LinkedIn", userData.linkedInProfileUrl!, FontAwesomeIcons.linkedin, url: userData.linkedInProfileUrl),
                          if (userData.githubProfileUrl != null && userData.githubProfileUrl!.isNotEmpty)
                            _buildProfileDetail("GitHub", userData.githubProfileUrl!, Icons.code, url: userData.githubProfileUrl),

                          const SizedBox(height: 20),

                          ListTile(
                            leading: const Icon(Icons.directions_car_outlined),
                            title: const Text('Change Transport Mode'),
                            subtitle: Text(userData.selectedVehicle.isNotEmpty ? userData.selectedVehicle : 'Not set'),
                            onTap: () => _showChangeTransportModeDialog(context, userData),
                          ),
                          const Divider(),

                          const SizedBox(height: 20),

                          // Action buttons
                          _stylishButton(
                            icon: Icons.settings_outlined,
                            label: 'More Settings',
                            onPressed: _showAdvancedSettings,
                            color: Colors.deepPurpleAccent,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _stylishButton(
                                icon: Icons.edit_outlined,
                                label: 'Edit Profile',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return ChangeNotifierProvider.value(
                                        value: userData,
                                        child: Builder(
                                          builder: (context) => _buildEditDialog(context),
                                        ),
                                      );
                                    },
                                  );
                                },
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              _buildLoginLogoutButton(isLoggedIn),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
          const Positioned(bottom: 30, right: 20, child: ChatbotButton()),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value, IconData icon, {String? url}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                InkWell(
                  onTap: url != null && url.isNotEmpty ? () => _launchURL(url) : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: url != null && url.isNotEmpty ? Colors.blueAccent : (isDark ? Colors.white : Colors.black87),
                      decoration: url != null && url.isNotEmpty ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stylishButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
    );
  }

  Widget _buildEditDialog(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    final nameController = TextEditingController(text: userData.name);
    DateTime? selectedDOB;
    try {
      selectedDOB = DateFormat('yyyy-MM-dd').parse(userData.dob ?? '');
    } catch (e) {
      selectedDOB = DateTime(DateTime.now().year - 20, 1, 1);
    }

    final genderOptions = [null, 'Male', 'Female', 'Other'];
    String? selectedGender = userData.gender;
    final ageController =
        TextEditingController(text: _calculateAge(userData.dob)?.toString());

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("Edit Your Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  onChanged: (value) => userData.updateField('name', value),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String?>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: genderOptions
                      .map((g) => DropdownMenuItem(
                          value: g, child: Text(g ?? 'Not Specified')))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedGender = value);
                    userData.updateField('gender', value);
                  },
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          selectedDOB ?? DateTime(DateTime.now().year - 20),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      final formattedDate =
                          DateFormat('yyyy-MM-dd').format(picked);
                      setState(() => selectedDOB = picked);
                      userData.updateField('dob', formattedDate);
                      final newAge = _calculateAge(formattedDate);
                      userData.updateField('age', newAge?.toString());
                      ageController.text = newAge?.toString() ?? '';
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userData.dob ?? 'Not Specified'),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age (Automatic)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Add more edit fields as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                userData.updateUserDetails(
                  name: nameController.text.trim(),
                  gender: selectedGender,
                  dob: userData.dob,
                  age: _calculateAge(userData.dob)?.toString(),
                  // Update other fields if you add more to the dialog
                );
                Navigator.pop(context);
                _triggerLoginAnimation(true);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final userData = Provider.of<UserData>(context, listen: false);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Advanced Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  onTap: () => _showNotificationsDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: const Text('Change Transport Mode'),
                  subtitle: Text(userData.selectedVehicle.isNotEmpty ? userData.selectedVehicle : 'Not set'),
                  onTap: () => _showChangeTransportModeDialog(context, userData),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme Settings'),
                  onTap: () => _showThemeSettingsDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language Preferences'),
                  onTap: () => _showLanguagePreferencesDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share Profile'),
                  onTap: () => _shareProfile(userData),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About App'),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(),
                const SizedBox(height: 20),
                const Text("Connected Social Accounts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildEditableSocialLink(
                  'Facebook',
                  'facebook',
                  userData.facebookProfileUrl,
                  Icons.facebook,
                  (newUrl) => _updateSocialMediaLink('facebook', newUrl), // Corrected
                ),
                _buildEditableSocialLink(
                  'Twitter',
                  'twitter',
                  userData.twitterProfileUrl,
                  Icons.android, // Replace with actual Twitter icon
                  (newUrl) => _updateSocialMediaLink('twitter', newUrl), // Corrected
                ),
                _buildEditableSocialLink(
                  'LinkedIn',
                  'linkedin',
                  userData.linkedInProfileUrl,
                  FontAwesomeIcons.linkedin,
                  (newUrl) => _updateSocialMediaLink('linkedin', newUrl), // Corrected
                ),
                _buildEditableSocialLink(
                  'GitHub',
                  'github',
                  userData.githubProfileUrl,
                  Icons.code,
                  (newUrl) => _updateSocialMediaLink('github', newUrl), // Corrected
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Settings', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modeButton(BuildContext context, String iconPath, String mode) {
    final selectedVehicle = Provider.of<UserData>(context).selectedVehicle;
    final isSelected = selectedVehicle == mode;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.15;
    final borderRadius = BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: buttonSize,
      height: buttonSize * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.white,
        borderRadius: borderRadius,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Provider.of<UserData>(context, listen: false).updateField('transportMode', mode); // Update transportMode
            Navigator.pop(context);
          },
          borderRadius: borderRadius,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icons/$iconPath',
                fit: BoxFit.contain,
                width: buttonSize * 0.5,
                height: buttonSize * 0.5,
              ),
              const SizedBox(height: 8),
              Text(
                mode.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: buttonSize * 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeTransportModeDialog(BuildContext context, UserData userData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final popupWidth = screenWidth * 0.7;
    final popupHeight = screenHeight * 0.4;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(scale: Tween<double>(begin: 0.5, end: 1.0).animate(anim1), child: FadeTransition(opacity: anim1, child: child));
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            width: popupWidth,
            height: popupHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Choose Transport Mode",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _modeButton(buildContext, 'car.png', 'Car'),
                    _modeButton(buildContext, 'bike.png', 'Bike'),
                    _modeButton(buildContext, 'bus.png', 'Bus'),
                    _modeButton(buildContext, 'train.png', 'Train'),
                    _modeButton(buildContext, 'walk.png', 'Walk'),
                    _modeButton(buildContext, 'other.png', 'Other'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(buildContext),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeSettingsDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Theme Settings'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (bool value) {
                        setState(() {
                          isDark = value;
                          themeProvider.toggleTheme();
                        });
                      },
                    ),
                  ),
                  // Add more theme options if needed
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePreferencesDialog(BuildContext context) {
    // Implement language selection logic here
    showFeatureComingSoon();
  }
}

extension StringCasing on String {
  String capitalize() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
