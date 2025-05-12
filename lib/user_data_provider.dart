import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends ChangeNotifier {
  String? _uid;
  String _name = '';
  String? _email;
  String? _age;
  String? _gender;
  String? _dob;
  String? _profileImagePath;
  String _badgeType = '';
  String? _role;
  int _loginStreak = 0;
  String _animationType = 'bounceIn';
  String? _soundPath;
  Position? _currentLocation;
  DateTime? _lastActive;
  bool _isOnline = false;
  bool _hasLoggedInBefore = false;
  bool _isEmailPasswordEnabled = false;
  bool _isGoogleEnabled = false;
  bool _isGitHubEnabled = false;
  bool _isMicrosoftEnabled = false;
  bool _isAppleEnabled = false;
  String _selectedVehicle = 'driving';

  // Social connection status
  bool _isFacebookConnected = false;
  bool _isTwitterConnected = false;
  bool _isLinkedInConnected = false;
  bool _isGitHubConnected = false;

  // Facebook
  String? _facebookName;
  String? _facebookEmail;
  String? _facebookProfileUrl;

  // Twitter
  String? _twitterName;
  String? _twitterEmail;
  String? _twitterProfileUrl;

  // LinkedIn
  String? _linkedInName;
  String? _linkedInEmail;
  String? _linkedInProfileUrl;

  // GitHub
  String? _githubName;
  String? _githubEmail;
  String? _githubProfileUrl;

  UserData() {
    _loadUserData();
  }

  // Getters
  String? get uid => _uid;
  String get name => _name;
  String? get email => _email;
  String? get age => _age;
  String? get gender => _gender;
  String? get dob => _dob;
  String? get profileImagePath => _profileImagePath;
  String get badgeType => _badgeType;
  String? get role => _role;
  int get loginStreak => _loginStreak;
  String get animationType => _animationType;
  String? get soundPath => _soundPath;
  Position? get currentLocation => _currentLocation;
  DateTime? get lastActive => _lastActive;
  bool get isOnline => _isOnline;
  bool get hasLoggedInBefore => _hasLoggedInBefore;
  bool get isEmailPasswordEnabled => _isEmailPasswordEnabled;
  bool get isGoogleEnabled => _isGoogleEnabled;
  bool get isGitHubEnabled => _isGitHubEnabled;
  bool get isMicrosoftEnabled => _isMicrosoftEnabled;
  bool get isAppleEnabled => _isAppleEnabled;
  String get selectedVehicle => _selectedVehicle;

  bool get isFacebookConnected => _isFacebookConnected;
  bool get isTwitterConnected => _isTwitterConnected;
  bool get isLinkedInConnected => _isLinkedInConnected;
  bool get isGitHubConnected => _isGitHubConnected;
  
  UserData.withSocialData({
    String? facebookProfileUrl,
    String? twitterProfileUrl,
    String? linkedInProfileUrl,
    String? githubProfileUrl,
    bool isFacebookConnected = false,
    bool isTwitterConnected = false,
    bool isLinkedInConnected = false,
    bool isGitHubConnected = false,
  }) {
    _facebookProfileUrl = facebookProfileUrl;
    _twitterProfileUrl = twitterProfileUrl;
    _linkedInProfileUrl = linkedInProfileUrl;
    _githubProfileUrl = githubProfileUrl;

    _isFacebookConnected = isFacebookConnected;
    _isTwitterConnected = isTwitterConnected;
    _isLinkedInConnected = isLinkedInConnected;
    _isGitHubConnected = isGitHubConnected;
  }

  Future<void> saveToDatabase() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update(toMap());
  }
  
  Map<String, dynamic> toMap() {
    return {
      'facebookProfileUrl': facebookProfileUrl,
      'twitterProfileUrl': twitterProfileUrl,
      'linkedInProfileUrl': linkedInProfileUrl,
      'githubProfileUrl': githubProfileUrl,
      'isFacebookConnected': isFacebookConnected,
      'isTwitterConnected': isTwitterConnected,
      'isLinkedInConnected': isLinkedInConnected,
      'isGitHubConnected': isGitHubConnected,
    };
  }
  
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData.withSocialData(
      facebookProfileUrl: map['facebookProfileUrl'],
      twitterProfileUrl: map['twitterProfileUrl'],
      linkedInProfileUrl: map['linkedInProfileUrl'],
      githubProfileUrl: map['githubProfileUrl'],
      isFacebookConnected: map['isFacebookConnected'] ?? false,
      isTwitterConnected: map['isTwitterConnected'] ?? false,
      isLinkedInConnected: map['isLinkedInConnected'] ?? false,
      isGitHubConnected: map['isGitHubConnected'] ?? false,
    );
  }

  String? get facebookName => _facebookName;
  set facebookName(String? value) {
    _facebookName = value;
    notifyListeners();
  }

  String? get facebookEmail => _facebookEmail;
  set facebookEmail(String? value) {
    _facebookEmail = value;
    notifyListeners();
  }

  String? get facebookProfileUrl => _facebookProfileUrl;
  set facebookProfileUrl(String? value) {
    _facebookProfileUrl = value;
    notifyListeners();
  }

  String? get twitterName => _twitterName;
  set twitterName(String? value) {
    _twitterName = value;
    notifyListeners();
  }

  String? get twitterEmail => _twitterEmail;
  set twitterEmail(String? value) {
    _twitterEmail = value;
    notifyListeners();
  }

  String? get twitterProfileUrl => _twitterProfileUrl;
  set twitterProfileUrl(String? value) {
    _twitterProfileUrl = value;
    notifyListeners();
  }

  String? get linkedInName => _linkedInName;
  set linkedInName(String? value) {
    _linkedInName = value;
    notifyListeners();
  }

  String? get linkedInEmail => _linkedInEmail;
  set linkedInEmail(String? value) {
    _linkedInEmail = value;
    notifyListeners();
  }

  String? get linkedInProfileUrl => _linkedInProfileUrl;
  set linkedInProfileUrl(String? value) {
    _linkedInProfileUrl = value;
    notifyListeners();
  }

  String? get githubName => _githubName;
  set githubName(String? value) {
    _githubName = value;
    notifyListeners();
  }

  String? get githubEmail => _githubEmail;
  set githubEmail(String? value) {
    _githubEmail = value;
    notifyListeners();
  }

  String? get githubProfileUrl => _githubProfileUrl;
  set githubProfileUrl(String? value) {
    _githubProfileUrl = value;
    notifyListeners();
  }

  // Special Badge Checker
  bool get hasSpecialBadge => _badgeType != 'newbie' && _badgeType.isNotEmpty;

  // Individual setters
  set selectedVehicle(String mode) {
    if (_selectedVehicle != mode) {
      _selectedVehicle = mode;
      notifyListeners();
    }
  }
  
  set isFacebookConnected(bool value) {
    _isFacebookConnected = value;
    notifyListeners();
  }

  set isTwitterConnected(bool value) {
    _isTwitterConnected = value;
    notifyListeners();
  }

  set isLinkedInConnected(bool value) {
    _isLinkedInConnected = value;
    notifyListeners();
  }

  set isGitHubConnected(bool value) {
    _isGitHubConnected = value;
    notifyListeners();
  }
  
  void updateFacebookConnection(bool connected, String name, String email, String profileUrl) {
    isFacebookConnected = connected;
    facebookName = name;
    facebookEmail = email;
    facebookProfileUrl = profileUrl;
    notifyListeners();
  }

  void updateTwitterConnection(bool connected, String name, String email, String profileUrl) {
    isTwitterConnected = connected;
    twitterName = name;
    twitterEmail = email;
    twitterProfileUrl = profileUrl;
    notifyListeners();
  }

  void updateLinkedInConnection(bool connected, String name, String email, String profileUrl) {
    isLinkedInConnected = connected;
    linkedInName = name;
    linkedInEmail = email;
    linkedInProfileUrl = profileUrl;
    notifyListeners();
  }

  void updateGitHubConnection(bool connected, String name, String email, String profileUrl) {
    isGitHubConnected = connected;
    githubName = name;
    githubEmail = email;
    githubProfileUrl = profileUrl;
    notifyListeners();
  }
  
  void updateUid(String? newUid) {
    if (_uid != newUid) {
      _uid = newUid;
      _saveUserData('uid', _uid);
      notifyListeners();
    }
  }

  void updateName(String newName) {
    if (_name != newName) {
      _name = newName;
      _saveUserData('name', _name);
      notifyListeners();
    }
  }

  void updateEmail(String newEmail) {
    if (_email != newEmail) {
      _email = newEmail;
      _saveUserData('email', _email);
      notifyListeners();
    }
  }

  // void updatePhoneNumber(String? newPhoneNumber) { // Removed setter
  //   if (_phoneNumber != newPhoneNumber) {
  //     _phoneNumber = newPhoneNumber;
  //     _saveUserData('phoneNumber', _phoneNumber);
  //     notifyListeners();
  //   }
  // }

  void updateAge(String? newAge) {
    if (_age != newAge) {
      _age = newAge;
      _saveUserData('age', _age);
      notifyListeners();
    }
  }

  void updateGender(String? newGender) {
    if (_gender != newGender) {
      _gender = newGender;
      _saveUserData('gender', _gender);
      notifyListeners();
    }
  }

  void updateDob(String? newDob) {
    if (_dob != newDob) {
      _dob = newDob;
      _saveUserData('dob', _dob);
      notifyListeners();
    }
  }

  void updateProfileImagePath(String? newPath) {
    if (_profileImagePath != newPath) {
      _profileImagePath = newPath;
      _saveUserData('profileImagePath', _profileImagePath);
      notifyListeners();
    }
  }
  
  void updateSelectedVehicle(String newVehicle) {
    if (_selectedVehicle != newVehicle) {
      _selectedVehicle = newVehicle;
      _saveUserData('selectedVehicle', _selectedVehicle);
      notifyListeners();
    }
  }

  Future<void> updateProfileImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _profileImagePath = image.path;
      _saveUserData('profileImagePath', _profileImagePath);
      notifyListeners();
    }
  }

  Future<void> updateProfileImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _profileImagePath = image.path;
      _saveUserData('profileImagePath', _profileImagePath);
      notifyListeners();
    }
  }

  void updateRole(String? newRole) {
    if (_role != newRole) {
      _role = newRole;
      _saveUserData('role', _role);
      notifyListeners();
    }
  }

  void updateBadgeType(String newBadge) {
    if (_badgeType != newBadge) {
      _badgeType = newBadge;
      _saveUserData('badgeType', _badgeType);
      notifyListeners();
    }
  }

  void updateLoginStreak(int newStreak) {
    if (_loginStreak != newStreak) {
      _loginStreak = newStreak;
      _saveUserData('loginStreak', _loginStreak);
      _updateBadgeFromStreak();
      notifyListeners();
    }
  }

  void updateAnimationType(String animation) {
    if (_animationType != animation) {
      _animationType = animation;
      _saveUserData('animationType', _animationType);
      notifyListeners();
    }
  }

  void updateSoundPath(String? newSoundPath) {
    if (_soundPath != newSoundPath) {
      _soundPath = newSoundPath;
      _saveUserData('soundPath', _soundPath);
      notifyListeners();
    }
  }

  void updateCurrentLocation(Position? newLocation) {
    if (_currentLocation != newLocation) {
      _currentLocation = newLocation;
      _saveUserData('latitude', _currentLocation?.latitude);
      _saveUserData('longitude', _currentLocation?.longitude);
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you won't be able to
        // request permissions again (unless the user re-enables it
        // in the app settings).
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      debugPrint(
          'Location permissions are permanently denied, we cannot request them.');
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      _currentLocation = await Geolocator.getCurrentPosition();
      updateCurrentLocation(_currentLocation);
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  void updateLastActive(DateTime? newLastActive) {
    if (_lastActive != newLastActive) {
      _lastActive = newLastActive;
      _saveUserData('lastActive', _lastActive?.toIso8601String());
      notifyListeners();
    }
  }

  void updateIsOnline(bool newIsOnline) {
    if (_isOnline != newIsOnline) {
      _isOnline = newIsOnline;
      _saveUserData('isOnline', _isOnline);
      notifyListeners();
    }
  }

  void setHasLoggedInBefore(bool value) {
    if (_hasLoggedInBefore != value) {
      _hasLoggedInBefore = value;
      _saveUserData('hasLoggedInBefore', _hasLoggedInBefore);
      notifyListeners();
    }
  }

  void updateIsEmailPasswordEnabled(bool value) {
    if (_isEmailPasswordEnabled != value) {
      _isEmailPasswordEnabled = value;
      _saveUserData('isEmailPasswordEnabled', _isEmailPasswordEnabled);
      notifyListeners();
    }
  }

  void updateIsGoogleEnabled(bool value) {
    if (_isGoogleEnabled != value) {
      _isGoogleEnabled = value;
      _saveUserData('isGoogleEnabled', _isGoogleEnabled);
      notifyListeners();
    }
  }

  void updateIsGitHubEnabled(bool value) {
    if (_isGitHubEnabled != value) {
      _isGitHubEnabled = value;
      _saveUserData('isGitHubEnabled', _isGitHubEnabled);
      notifyListeners();
    }
  }

  void updateIsMicrosoftEnabled(bool value) {
    if (_isMicrosoftEnabled != value) {
      _isMicrosoftEnabled = value;
      _saveUserData('isMicrosoftEnabled', _isMicrosoftEnabled);
      notifyListeners();
    }
  }

  void updateIsAppleEnabled(bool value) {
    if (_isAppleEnabled != value) {
      _isAppleEnabled = value;
      _saveUserData('isAppleEnabled', _isAppleEnabled);
      notifyListeners();
    }
  }

  void _updateBadgeFromStreak() {
    if (_role == 'admin') {
      _badgeType = 'admin';
    } else if (_loginStreak >= 30) {
      _badgeType = 'platinum';
    } else if (_loginStreak >= 15) {
      _badgeType = 'gold';
    } else if (_loginStreak >= 7) {
      _badgeType = 'silver';
    } else if (_loginStreak >= 3) {
      _badgeType = 'bronze';
    } else {
      _badgeType = 'newbie';
    }
  }

  /// Batch update
  void updateUserDetails({
    String? uid, // Include UID in the batch update
    String? name,
    String? email,
    // String? phoneNumber, // Removed from batch update
    String? age,
    String? gender,
    String? dob,
    String? profileImagePath,
    String? badgeType,
    String? role,
    int? loginStreak,
    String? animationType,
    String? soundPath,
    Position? currentLocation,
    DateTime? lastActive,
    bool? isOnline,
    bool? isEmailPasswordEnabled, // New field in batch update
    bool? isGoogleEnabled, // New field in batch update
    bool? isGitHubEnabled, // New field in batch update
    bool? isMicrosoftEnabled, // New field in batch update
    bool? isAppleEnabled, // New field in batch update
    String? selectedVehicle,
  }) {
    bool updated = false;

    if (uid != null && uid != _uid) {
      _uid = uid;
      _saveUserData('uid', _uid);
      updated = true;
    }
    if (name != null && name != _name) {
      _name = name;
      _saveUserData('name', _name);
      updated = true;
    }
    if (email != null && email != _email) {
      _email = email;
      _saveUserData('email', _email);
      updated = true;
    }
    // if (phoneNumber != null && phoneNumber != _phoneNumber) { // Removed from batch update
    //   _phoneNumber = phoneNumber;
    //   _saveUserData('phoneNumber', _phoneNumber);
    //   updated = true;
    // }
    if (age != null && age != _age) {
      _age = age;
      _saveUserData('age', _age);
      updated = true;
    }
    if (gender != null && gender != _gender) {
      _gender = gender;
      _saveUserData('gender', _gender);
      updated = true;
    }
    if (dob != null && dob != _dob) {
      _dob = dob;
      _saveUserData('dob', _dob);
      updated = true;
    }
    if (profileImagePath != null && profileImagePath != _profileImagePath) {
      _profileImagePath = profileImagePath;
      _saveUserData('profileImagePath', _profileImagePath);
      updated = true;
    }
    if (role != null && role != _role) {
      _role = role;
      _saveUserData('role', _role);
      updated = true;
    }
    if (loginStreak != null && loginStreak != _loginStreak) {
      _loginStreak = loginStreak;
      _saveUserData('loginStreak', _loginStreak);
      _updateBadgeFromStreak();
      updated = true;
    }
    if (badgeType != null && badgeType != _badgeType) {
      _badgeType = badgeType!;
      _saveUserData('badgeType', _badgeType);
      updated = true;
    }
    if (animationType != null && animationType != _animationType) {
      _animationType = animationType;
      _saveUserData('animationType', _animationType);
      updated = true;
    }
    if (soundPath != null && soundPath != _soundPath) {
      _soundPath = soundPath;
      _saveUserData('soundPath', _soundPath);
      updated = true;
    }
    if (currentLocation != null && currentLocation != _currentLocation) {
      _currentLocation = currentLocation;
      _saveUserData('latitude', _currentLocation?.latitude);
      _saveUserData('longitude', _currentLocation?.longitude);
      updated = true;
    }
    if (lastActive != null && lastActive != _lastActive) {
      _lastActive = lastActive;
      _saveUserData('lastActive', _lastActive?.toIso8601String());
      updated = true;
    }
    if (isOnline != null && isOnline != _isOnline) {
      _isOnline = isOnline;
      _saveUserData('isOnline', _isOnline);
      updated = true;
    }
    if (isEmailPasswordEnabled != null && isEmailPasswordEnabled != _isEmailPasswordEnabled) {
      _isEmailPasswordEnabled = isEmailPasswordEnabled;
      _saveUserData('isEmailPasswordEnabled', _isEmailPasswordEnabled);
      updated = true;
    }
    if (isGoogleEnabled != null && isGoogleEnabled != _isGoogleEnabled) {
      _isGoogleEnabled = isGoogleEnabled;
      _saveUserData('isGoogleEnabled', _isGoogleEnabled);
      updated = true;
    }
    if (isGitHubEnabled != null && isGitHubEnabled != _isGitHubEnabled) {
      _isGitHubEnabled = isGitHubEnabled;
      _saveUserData('isGitHubEnabled', _isGitHubEnabled);
      updated = true;
    }
    if (isMicrosoftEnabled != null && isMicrosoftEnabled != _isMicrosoftEnabled) {
      _isMicrosoftEnabled = isMicrosoftEnabled;
      _saveUserData('isMicrosoftEnabled', _isMicrosoftEnabled);
      updated = true;
    }
    if (isAppleEnabled != null && isAppleEnabled != _isAppleEnabled) {
      _isAppleEnabled = isAppleEnabled;
      _saveUserData('isAppleEnabled', _isAppleEnabled);
      updated = true;
    }
    if (selectedVehicle != null && selectedVehicle != _selectedVehicle) {
      _selectedVehicle = selectedVehicle;
      _saveUserData('selectedVehicle', _selectedVehicle);
      updated = true;
    }

    if (updated) notifyListeners();
  }

  /// Update profile fields from UI
  void updateProfile({
    required String name,
    String? age,
    String? gender,
    String? dob,
  }) {
    updateUserDetails(
      name: name,
      age: age,
      gender: gender,
      dob: dob,
    );
  }

  /// Update a single field dynamically
  void updateField(String field, dynamic value) {
    switch (field) {
      case 'uid':
        updateUid(value as String?);
        break;
      case 'name':
        updateName(value as String);
        break;
      case 'email':
        updateEmail(value as String);
        break;
      // case 'phoneNumber': // Removed case
      //   updatePhoneNumber(value as String?);
      //   break;
      case 'age':
        updateAge(value as String?);
        break;
      case 'gender':
        updateGender(value as String?);
        break;
      case 'dob':
        updateDob(value as String?);
        break;
      case 'profileImagePath':
        updateProfileImagePath(value as String?);
        break;
      case 'role':
        updateRole(value as String?);
        break;
      case 'badgeType':
        updateBadgeType(value as String);
        break;
      case 'loginStreak':
        updateLoginStreak(value as int);
        break;
      case 'animationType':
        updateAnimationType(value as String);
        break;
      case 'soundPath':
        updateSoundPath(value as String?);
        break;
      case 'currentLocation':
        updateCurrentLocation(value as Position?);
        break;
      case 'lastActive':
        updateLastActive(value as DateTime?);
        break;
      case 'isOnline':
        updateIsOnline(value as bool);
        break;
      case 'isEmailPasswordEnabled':
        updateIsEmailPasswordEnabled(value as bool);
        break;
      case 'isGoogleEnabled':
        updateIsGoogleEnabled(value as bool);
        break;
      case 'isGitHubEnabled':
        updateIsGitHubEnabled(value as bool);
        break;
      case 'isMicrosoftEnabled':
        updateIsMicrosoftEnabled(value as bool);
        break;
      case 'isAppleEnabled':
        updateIsAppleEnabled(value as bool);
        break;
      case 'selectedVehicle':
        updateSelectedVehicle(value as String);
        break;
      default:
        throw ArgumentError('Unknown field: $field');
    }
  }

  void clearUserData() async {
    _uid = null;
    _name = '';
    _email = '';
    // _phoneNumber = null; // Removed
    _age = null;
    _gender = null;
    _dob = null;
    _profileImagePath = null;
    _badgeType = '';
    _role = null;
    _loginStreak = 0;
    _animationType = 'bounceIn';
    _soundPath = null;
    _currentLocation = null;
    _lastActive = null;
    _isOnline = false;
    _hasLoggedInBefore = false;
    _isEmailPasswordEnabled = false; // Clear new fields
    _isGoogleEnabled = false;
    _isGitHubEnabled = false;
    _isMicrosoftEnabled = false;
    _isAppleEnabled = false;
    _selectedVehicle = 'driving';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    // await prefs.remove('phoneNumber'); // Removed
    await prefs.remove('age');
    await prefs.remove('gender');
    await prefs.remove('dob');
    await prefs.remove('profileImagePath');
    await prefs.remove('badgeType');
    await prefs.remove('role');
    await prefs.remove('loginStreak');
    await prefs.remove('animationType');
    await prefs.remove('soundPath');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.remove('lastActive');
    await prefs.remove('isOnline');
    await prefs.remove('hasLoggedInBefore');
    await prefs.remove('isEmailPasswordEnabled'); // Remove new fields
    await prefs.remove('isGoogleEnabled');
    await prefs.remove('isGitHubEnabled');
    await prefs.remove('isMicrosoftEnabled');
    await prefs.remove('isAppleEnabled');
    await prefs.remove('selectedVehicle');

    notifyListeners();
  }

  // Helper method to save user data to SharedPreferences
  Future<void> _saveUserData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else if (value is DateTime) {
      await prefs.setString(key, value.toIso8601String());
    } else if (value == null) {
      await prefs.remove(key);
    }
  }

  // Helper method to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid');
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email');
    // _phoneNumber = prefs.getString('phoneNumber'); // Removed
    _age = prefs.getString('age');
    _gender = prefs.getString('gender');
    _dob = prefs.getString('dob');
    _profileImagePath = prefs.getString('profileImagePath');
    _badgeType = prefs.getString('badgeType') ?? 'newbie';
    _role = prefs.getString('role');
    _loginStreak = prefs.getInt('loginStreak') ?? 0;
    _animationType = prefs.getString('animationType') ?? 'bounceIn';
    _soundPath = prefs.getString('soundPath');
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');
    if (latitude != null && longitude != null) {
      _currentLocation = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(), // Timestamp might be outdated
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0, // Added altitudeAccuracy
        headingAccuracy: 0.0, // Added headingAccuracy
      );
    }
    final lastActiveString = prefs.getString('lastActive');
    _lastActive = lastActiveString != null ? DateTime.parse(lastActiveString) : null;
    _isOnline = prefs.getBool('isOnline') ?? false;
    _hasLoggedInBefore = prefs.getBool('hasLoggedInBefore') ?? false;
    _isEmailPasswordEnabled = prefs.getBool('isEmailPasswordEnabled') ?? false; // Load new fields
    _isGoogleEnabled = prefs.getBool('isGoogleEnabled') ?? false;
    _isGitHubEnabled = prefs.getBool('isGitHubEnabled') ?? false;
    _isMicrosoftEnabled = prefs.getBool('isMicrosoftEnabled') ?? false;
    _isAppleEnabled = prefs.getBool('isAppleEnabled') ?? false;
    _updateBadgeFromStreak(); // Ensure badge is updated on load
    _selectedVehicle = prefs.getString('selectedVehicle') ?? 'driving';
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'uid': _uid,
        'name': _name,
        'email': _email,
        // 'phoneNumber': _phoneNumber, // Removed
        'age': _age,
        'gender': _gender,
        'dob': _dob,
        'profileImagePath': _profileImagePath,
        'badgeType': _badgeType,
        'role': _role,
        'loginStreak': _loginStreak,
        'animationType': _animationType,
        'soundPath': _soundPath,
        'currentLocation': _currentLocation?.toJson(),
        'lastActive': _lastActive?.toIso8601String(),
        'isOnline': _isOnline,
        'hasLoggedInBefore': _hasLoggedInBefore,
        'isEmailPasswordEnabled': _isEmailPasswordEnabled, // Add new fields to JSON
        'isGoogleEnabled': _isGoogleEnabled,
        'isGitHubEnabled': _isGitHubEnabled,
        'isMicrosoftEnabled': _isMicrosoftEnabled,
        'isAppleEnabled': _isAppleEnabled,
        'selectedVehicle': _selectedVehicle,
      };

  void fromJson(Map<String, dynamic> json) {
    updateUserDetails(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      // phoneNumber: json['phoneNumber'], // Removed
      age: json['age'],
      gender: json['gender'],
      dob: json['dob'],
      profileImagePath: json['profileImagePath'],
      badgeType: json['badgeType'],
      role: json['role'],
      loginStreak: json['loginStreak'],
      animationType: json['animationType'],
      soundPath: json['soundPath'],
      currentLocation: json['currentLocation'] != null
          ? Position.fromMap(json['currentLocation'])
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isOnline: json['isOnline'],
      isEmailPasswordEnabled: json['isEmailPasswordEnabled'], // Load new fields from JSON
      isGoogleEnabled: json['isGoogleEnabled'],
      isGitHubEnabled: json['isGitHubEnabled'],
      isMicrosoftEnabled: json['isMicrosoftEnabled'],
      isAppleEnabled: json['isAppleEnabled'],
    );
    setHasLoggedInBefore(json['hasLoggedInBefore'] ?? false);
  }

  UserData copyWith({
    String? uid,
    String? name,
    String? email,
    // String? phoneNumber, // Removed
    String? age,
    String? gender,
    String? dob,
    String? profileImagePath,
    String? badgeType,
    String? role,
    int? loginStreak,
    String? animationType,
    String? soundPath,
    Position? currentLocation,
    DateTime? lastActive,
    bool? isOnline,
    bool? hasLoggedInBefore,
    bool? isEmailPasswordEnabled, // Add new fields to copyWith
    bool? isGoogleEnabled,
    bool? isGitHubEnabled,
    bool? isMicrosoftEnabled,
    bool? isAppleEnabled,
    String? selectedVehicle,
  }) {
    return UserData()
      .._uid = uid ?? _uid
      ..updateUserDetails(
        name: name ?? _name,
        email: email ?? _email,
        // phoneNumber: phoneNumber ?? _phoneNumber, // Removed
        age: age ?? _age,
        gender: gender ?? _gender,
        dob: dob ?? _dob,
        profileImagePath: profileImagePath ?? _profileImagePath,
        badgeType: badgeType ?? _badgeType,
        role: role ?? _role,
        loginStreak: loginStreak ?? _loginStreak,
        animationType: animationType ?? _animationType,
        soundPath: soundPath ?? _soundPath,
        currentLocation: currentLocation ?? _currentLocation,
        lastActive: lastActive ?? _lastActive,
        isOnline: isOnline ?? _isOnline,
        isEmailPasswordEnabled: isEmailPasswordEnabled ?? _isEmailPasswordEnabled, // Copy new fields
        isGoogleEnabled: isGoogleEnabled ?? _isGoogleEnabled,
        isGitHubEnabled: isGitHubEnabled ?? _isGitHubEnabled,
        isMicrosoftEnabled: isMicrosoftEnabled ?? _isMicrosoftEnabled,
        isAppleEnabled: isAppleEnabled ?? _isAppleEnabled,
        selectedVehicle: selectedVehicle ?? _selectedVehicle,
      )
      .._hasLoggedInBefore = hasLoggedInBefore ?? _hasLoggedInBefore;
  }

  @override
  String toString() {
    return 'UserData(uid: $_uid, name: $_name, email: $_email, age: $_age, gender: $_gender, dob: $_dob, '
        'profileImagePath: $_profileImagePath, badgeType: $_badgeType, role: $_role, '
        'loginStreak: $_loginStreak, animationType: $_animationType, soundPath: $_soundPath, '
        'currentLocation: $_currentLocation, lastActive: $_lastActive, isOnline: $_isOnline, hasLoggedInBefore: $_hasLoggedInBefore, '
        'isEmailPasswordEnabled: $_isEmailPasswordEnabled, isGoogleEnabled: $_isGoogleEnabled, isGitHubEnabled: $_isGitHubEnabled, '
        'isMicrosoftEnabled: $_isMicrosoftEnabled, isAppleEnabled: $_isAppleEnabled)';
  }
}
