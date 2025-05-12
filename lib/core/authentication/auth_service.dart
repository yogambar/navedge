import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier; // Import ChangeNotifier
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
// If using Apple sign-in, uncomment the below line and add the dependency
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple_sign_in;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show AppleIDAuthorizationScope; // Explicit import
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore (if used in getUserDetails)
import 'package:firebase_core/firebase_core.dart'; // Make sure Firebase core is imported
import '../../user_data_provider.dart'; // Import UserData

class AuthService extends ChangeNotifier { // Extend ChangeNotifier here
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserData userData; // Instance of UserData

  AuthService({required this.userData}); // Constructor to receive UserData

  /// ✅ Get the current logged-in user.
  User? get currentUser => _auth.currentUser;

  /// ✅ Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ✅ Login with Google
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      User? user;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        user = userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (user != null) {
        _updateUserDataFromUser(user); // Update UserData
        notifyListeners(); // Notify listeners after login state changes
        return _buildUserMap(user);
      }
      return null;
    } catch (e, stack) {
      debugPrint("Google sign-in error: $e\n$stack");
      return null;
    }
  }

  /// ✅ Login with Email & Password
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners(); // Notify listeners after login
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Email login error: ${e.message}");
      throw e; // Re-throw the exception for UI handling
    } catch (e) {
      debugPrint("Unexpected email login error: $e");
      throw e;
    }
  }

  /// ✅ Register with Email & Password
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners(); // Notify listeners after registration
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Email registration error: ${e.message}");
      throw e; // Re-throw the exception for UI handling
    } catch (e) {
      debugPrint("Unexpected email registration error: $e");
      throw e;
    }
  }

  /// ✅ Sign in with GitHub
  Future<Map<String, dynamic>?> loginWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithPopup(githubProvider);
      final User? user = userCredential.user;
      if (user != null) {
        _updateUserDataFromUser(user); // Update UserData
        notifyListeners(); // Notify listeners
        return _buildUserMap(user);
      }
      return null;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint("GitHub sign-in error: ${e.message}\n$stack");
      return null;
    } catch (e, stack) {
      debugPrint("Unexpected GitHub sign-in error: $e\n$stack");
      return null;
    }
  }

  /// ✅ Sign in with Microsoft
  Future<Map<String, dynamic>?> loginWithMicrosoft() async {
    try {
      final microsoftProvider = MicrosoftAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithPopup(microsoftProvider);
      final User? user = userCredential.user;
      if (user != null) {
        _updateUserDataFromUser(user); // Update UserData
        notifyListeners(); // Notify listeners
        return _buildUserMap(user);
      }
      return null;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint("Microsoft sign-in error: ${e.message}\n$stack");
      return null;
    } catch (e, stack) {
      debugPrint("Unexpected Microsoft sign-in error: $e\n$stack");
      return null;
    }
  }

  /// ✅ Sign in with Apple (Firebase)
  Future<Map<String, dynamic>?> loginWithApple() async {
    try {
      User? user;
      if (kIsWeb) {
        final appleProvider = OAuthProvider('apple.com');
        final UserCredential userCredential =
            await _auth.signInWithPopup(appleProvider);
        user = userCredential.user;
      } else {
        final appleCredential =
            await apple_sign_in.SignInWithApple.getAppleIDCredential(
          scopes: [
            //AppleIDAuthorizationScope.email,
            //AppleIDAuthorizationScope.fullName,
          ],
        );

        if (appleCredential.identityToken != null) {
          final OAuthCredential credential =
              OAuthProvider('apple.com').credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode, // Might be null
          );

          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          user = userCredential.user;
        }
      }
      if (user != null) {
        _updateUserDataFromUser(user); // Update UserData
        notifyListeners(); // Notify listeners
        return _buildUserMap(user);
      }
      return null;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint("Apple sign-in error (Firebase): ${e.message}\n$stack");
      throw e; // Re-throw for UI handling
    } catch (e, stack) {
      debugPrint("Unexpected Apple sign-in error: $e\n$stack");
      throw e;
    }
  }

  /// ✅ Link Google Account
  Future<UserCredential?> linkWithGoogle() async {
    if (_auth.currentUser == null) return null;
    try {
      UserCredential? userCredential;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.currentUser?.linkWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.currentUser?.linkWithCredential(credential);
      }
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error linking with Google: ${e.message}");
      throw e; // Re-throw for UI handling
    } catch (e) {
      debugPrint("Unexpected error linking with Google: $e");
      throw e;
    }
  }

  /// ✅ Link GitHub Account
  Future<UserCredential?> linkWithGitHub() async {
    if (_auth.currentUser == null) return null;
    try {
      final githubProvider = GithubAuthProvider();
      final UserCredential? userCredential =
          await _auth.currentUser?.linkWithPopup(githubProvider);
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error linking with GitHub: ${e.message}");
      throw e;
    } catch (e) {
      debugPrint("Unexpected error linking with GitHub: $e");
      throw e;
    }
  }

  /// ✅ Link Microsoft Account
  Future<UserCredential?> linkWithMicrosoft() async {
    if (_auth.currentUser == null) return null;
    try {
      final microsoftProvider = MicrosoftAuthProvider();
      final UserCredential? userCredential =
          await _auth.currentUser?.linkWithPopup(microsoftProvider);
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error linking with Microsoft: ${e.message}");
      throw e;
    } catch (e) {
      debugPrint("Unexpected error linking with Microsoft: $e");
      throw e;
    }
  }

  /// ✅ Link Apple Account
  Future<UserCredential?> linkWithApple() async {
    if (_auth.currentUser == null) return null;
    try {
      UserCredential? userCredential;
      if (kIsWeb) {
        final appleProvider = OAuthProvider('apple.com');
        userCredential = await _auth.currentUser?.linkWithPopup(appleProvider);
      } else {
        final appleCredential =
            await apple_sign_in.SignInWithApple.getAppleIDCredential(
          scopes: [
            //AppleIDAuthorizationScope.email,
            //AppleIDAuthorizationScope.fullName,
          ],
        );

        if (appleCredential.identityToken != null) {
          final OAuthCredential credential =
              OAuthProvider('apple.com').credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode, // Might be null
          );
          userCredential = await _auth.currentUser?.linkWithCredential(credential);
        }
      }
      if (userCredential?.user != null) {
        _updateUserDataFromUser(userCredential!.user!); // Update UserData
        notifyListeners();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error linking with Apple: ${e.message}");
      throw e; // Re-throw for UI handling
    } catch (e) {
      debugPrint("Unexpected error linking with Apple: $e");
      throw e;
    }
  }

  /// ✅ Unlink Provider
  Future<User?> unlinkProvider(String providerId) async {
    if (_auth.currentUser == null) {
      debugPrint("No user signed in to unlink provider.");
      return null;
    }
    try {
      await _auth.currentUser!.unlink(providerId);
      notifyListeners();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error unlinking provider ($providerId): ${e.message}");
      throw e; // Re-throw for UI handling
    } catch (e) {
      debugPrint("Unexpected error unlinking provider ($providerId): $e");
      throw e;
    }
  }

  /// ✅ Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      debugPrint("Error sending password reset email: ${e.message}");
      throw e; // Re-throw the error for the UI to handle
    } catch (e) {
      debugPrint("Unexpected error sending password reset email: $e");
      throw e;
    }
  }

  /// ✅ Update user's display name
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(displayName);
        _updateUserDataFromUser(user); // Update local data
        notifyListeners();
        debugPrint("Display name updated to: $displayName");
      } on FirebaseAuthException catch (e) {
        debugPrint("Error updating display name: ${e.message}");
        throw e;
      } catch (e) {
        debugPrint("Unexpected error updating display name: $e");
        throw e;
      }
    }
  }

  /// ✅ Update user's email
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
        _updateUserDataFromUser(user);
        notifyListeners();
        debugPrint("Email updated to: $newEmail");
      } on FirebaseAuthException catch (e) {
        debugPrint("Error updating email: ${e.message}");
        throw e;
      } catch (e) {
        debugPrint("Unexpected error updating email: $e");
        throw e;
      }
    }
  }

  /// ✅ Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        debugPrint("Email verification sent to: ${user.email}");
      } on FirebaseAuthException catch (e) {
        debugPrint("Error sending email verification: ${e.message}");
        throw e;
      } catch (e) {
        debugPrint("Unexpected error sending email verification: $e");
        throw e;
      }
    } else if (user?.emailVerified == true) {
      debugPrint("Email is already verified.");
    } else {
      debugPrint("No user signed in to send email verification.");
    }
  }

  /// ✅ Update user's password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        notifyListeners();
        debugPrint("Password updated.");
      } on FirebaseAuthException catch (e) {
        debugPrint("Error updating password: ${e.message}");
        throw e;
      } catch (e) {
        debugPrint("Unexpected error updating password: $e");
        throw e;
      }
    }
  }

  /// ✅ Delete current user account
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
        debugPrint("User account deleted.");
      } on FirebaseAuthException catch (e) {
        debugPrint("Error deleting user account: ${e.message}");
        throw e;
      } catch (e) {
        debugPrint("Unexpected error deleting user account: $e");
        throw e;
      }
    } else {
      debugPrint("No user signed in to delete.");
    }
  }

  /// ✅ Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      userData.clearUserData(); // Clear local user data on logout
      notifyListeners(); // Notify listeners after logout
      debugPrint("Logged out successfully.");
    } catch (e) {
      debugPrint("Logout error: $e");
      throw e;
    }
  }

  /// ✅ Fetch user details by UID (Replace with your backend logic)
  /// ✅ Fetch user details by UID (Replace with your backend logic)
  /// ✅ Fetch user details by UID (Replace with your backend logic)
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      // Placeholder: Replace this with your actual database or API call
      // For example, if you are using Firestore:
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Optionally update UserData with Firestore details here if needed
        userData.updateUserDetails(
          uid: uid,
          name: userDoc.data()?['name'],
          email: userDoc.data()?['email'],
          age: userDoc.data()?['age'],
          gender: userDoc.data()?['gender'],
          dob: userDoc.data()?['dob'] != null ? (userDoc.data()?['dob'] as Timestamp).toDate().toString() : null,
          profileImagePath: userDoc.data()?['profileImage'],
          badgeType: userDoc.data()?['badgeType'],
          role: userDoc.data()?['role'],
          loginStreak: userDoc.data()?['loginStreak'],
          animationType: userDoc.data()?['animationType'],
          soundPath: userDoc.data()?['soundPath'],
          lastActive: userDoc.data()?['lastActive'] != null ? (userDoc.data()?['lastActive'] as Timestamp).toDate() : null,
          isOnline: userDoc.data()?['isOnline'] ?? false,
          isEmailPasswordEnabled: userDoc.data()?['isEmailPasswordEnabled'] ?? false,
          isGoogleEnabled: userDoc.data()?['isGoogleEnabled'] ?? false,
          isGitHubEnabled: userDoc.data()?['isGitHubEnabled'] ?? false,
          isMicrosoftEnabled: userDoc.data()?['isMicrosoftEnabled'] ?? false,
          isAppleEnabled: userDoc.data()?['isAppleEnabled'] ?? false,
        );
        notifyListeners();
        return userDoc.data();
      }
      // For now, let's return null or some default data
      return null;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Firestore error fetching user details: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  /// 🔧 Utility: build user info map from Firebase User
  Map<String, dynamic> _buildUserMap(User user) {
    return {
      'uid': user.uid,
      'name': user.displayName ?? 'Anonymous',
      'email': user.email ?? 'No email',
      'photoUrl': user.photoURL ?? 'assets/images/default_profile.png',
    };
  }

  /// 🔧 Utility: update UserData provider with Firebase User details
  void _updateUserDataFromUser(User? user) {
    if (user != null) {
      userData.updateUid(user.uid);
      userData.updateName(user.displayName ?? '');
      if (user.email != null) {
        userData.updateEmail(user.email!); // Use the null-aware operator (!) after checking for null
      } else {
        // Handle the case where the email is null (e.g., set a default value or don't update)
        userData.updateEmail(''); // Example: set to an empty string
        print("Warning: User email is null.");
      }
      userData.updateProfileImagePath(user.photoURL);

      // Determine the sign-in method and update the corresponding enabled flag
      userData.updateIsGoogleEnabled(user.providerData.any((info) => info.providerId == 'google.com'));
      userData.updateIsGitHubEnabled(user.providerData.any((info) => info.providerId == 'github.com'));
      userData.updateIsMicrosoftEnabled(user.providerData.any((info) => info.providerId == 'microsoft.com'));
      userData.updateIsAppleEnabled(user.providerData.any((info) => info.providerId == 'apple.com'));
      userData.updateIsEmailPasswordEnabled(user.email != null && user.providerData.any((info) => info.providerId == 'password'));

      notifyListeners();
      // You might need to fetch additional profile information from your database
      // and update UserData accordingly.
    }
  }
}
