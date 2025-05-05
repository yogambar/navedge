import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/chatbot_button.dart';
import '../core/authentication/auth_service.dart';
import '../core/utils/permission_handler.dart';
import '../core/utils/sound_service.dart';
import '../widgets/theme_provider.dart';
import '../user_data_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final picker = ImagePicker();
  File? _customProfileImage;
  bool showAnimation = false;
  bool loginSuccess = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    PermissionHandlerService.requestPermissions();
    Provider.of<UserData>(context, listen: false).getCurrentLocation();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => loading = false);
    });
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
      setState(() => showAnimation = false);
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
    if (streak >= 30) return 'gold';
    if (streak >= 15) return 'silver';
    if (streak >= 7) return 'bronze';
    return 'basic'; // More professional default badge name
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
    await AuthService(userData: userData).logout(); // Pass userData here
    userData.clearUserData(); // Clear all user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final badge = _getBadgeFromStreak(userData.loginStreak);
    final profileImg = _customProfileImage != null
        ? FileImage(_customProfileImage!)
        : userData.profileImagePath != null
            ? FileImage(File(userData.profileImagePath!))
            : AssetImage(
                (userData.gender?.toLowerCase() == 'female')
                    ? 'assets/images/user_profiles/default_female.png'
                    : 'assets/images/user_profiles/default_male.png',
              ) as ImageProvider;

    final calculatedAge = _calculateAge(userData.dob);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Your Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.black87, Colors.grey.shade900]
                    : [Colors.grey.shade200, Colors.white],
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
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
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
                                                Provider.of<UserData>(context,
                                                        listen: false)
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
                                },
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: profileImg,
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
                          Image.asset('assets/images/badges/${badge}_badge.png',
                              height: 50),
                          const SizedBox(height: 30),
                          _buildProfileDetail(
                              "Email", userData.email ?? "Not provided", Icons.email_outlined),
                          if (userData.gender != null)
                            _buildProfileDetail("Gender", userData.gender!, Icons.person_outline),
                          if (userData.dob != null)
                            _buildProfileDetail("Date of Birth", userData.dob!, Icons.calendar_today_outlined),
                          if (calculatedAge != null)
                            _buildProfileDetail("Age", calculatedAge.toString(), Icons.cake_outlined),
                          _buildProfileDetail(
                              "Login Streak", "${userData.loginStreak} days", Icons.timeline_outlined),
                          if (userData.currentLocation != null)
                            _buildProfileDetail(
                              "Location",
                              "${userData.currentLocation!.latitude.toStringAsFixed(2)}, "
                              "${userData.currentLocation!.longitude.toStringAsFixed(2)}",
                              Icons.location_on_outlined,
                            ),
                          if (userData.lastActive != null)
                            _buildProfileDetail(
                              "Last Active",
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(userData.lastActive!),
                              Icons.access_time_outlined,
                            ),
                          _buildProfileDetail(
                              "Online Status", userData.isOnline ? "Online" : "Offline", userData.isOnline ? Icons.wifi : Icons.wifi_off),
                          if (userData.role != null)
                            _buildProfileDetail("Role", userData.role!, Icons.shield_outlined),
                          if (userData.badgeType.isNotEmpty)
                            _buildProfileDetail("Badge", userData.badgeType, Icons.card_membership_outlined),
                          const SizedBox(height: 40),
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
                                          builder: (context) =>
                                              _buildEditDialog(context),
                                        ),
                                      );
                                    },
                                  );
                                },
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              _stylishButton(
                                icon: Icons.logout_outlined,
                                label: 'Logout',
                                onPressed: _logoutUser,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
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

  Widget _buildProfileDetail(String label, String value, IconData icon) {
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
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
}
