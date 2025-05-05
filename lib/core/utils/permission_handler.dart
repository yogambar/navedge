import 'dart:io'; // Import dart:io for platform checks

import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  // Static methods for direct access
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.operatingSystem == 'web') {
      print('Storage permission is not supported on web.');
      return true; // Assume granted or handle differently on web
    }
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> isPermissionGranted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking permission status: $e');
      return false;
    }
  }

  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      print('Error checking permission status: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    try {
      if (Platform.operatingSystem == 'web') {
        // Filter out unsupported permissions on web
        permissions = permissions.where((p) => p != Permission.storage).toList();
      }
      if (permissions.isEmpty) {
        return {};
      }
      return await permissions.request();
    } catch (e) {
      print('Error requesting multiple permissions: $e');
      return {};
    }
  }

  static Future<bool> areAllPermissionsGranted(List<Permission> permissions) async {
    try {
      for (var permission in permissions) {
        if (!await isPermissionGranted(permission)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking all permissions: $e');
      return false;
    }
  }

  static Future<String> requestPermissionWithMessage(Permission permission) async {
    if (Platform.operatingSystem == 'web' && permission == Permission.storage) {
      return 'Storage permission is not supported on web.';
    }
    try {
      final status = await permission.request();
      if (status.isGranted) {
        return '${permission.toString()} permission granted';
      } else if (status.isDenied) {
        return '${permission.toString()} permission denied';
      } else if (status.isPermanentlyDenied) {
        return '${permission.toString()} permission permanently denied, please enable it in app settings';
      } else {
        return 'Permission status unknown for ${permission.toString()}';
      }
    } catch (e) {
      return 'Error requesting permission: $e';
    }
  }

  // New methods added
  static Future<void> requestInitialPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.microphone,
        Permission.notification,
        Permission.storage
      ];
      await requestMultiplePermissions(permissions);
    } catch (e) {
      print('Error requesting initial permissions: $e');
    }
  }

  static Future<void> checkAndRequestAllPermissionsOnce() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.microphone,
        Permission.notification,
        Permission.storage
      ];
      await requestMultiplePermissions(permissions);
    } catch (e) {
      print('Error checking and requesting all permissions: $e');
    }
  }

  static Future<void> checkAndRequestPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.microphone,
        Permission.notification,
        Permission.storage
      ];
      await requestMultiplePermissions(permissions);
    } catch (e) {
      print('Error checking and requesting permissions: $e');
    }
  }

  // New method added for requestPermissions
  static Future<void> requestPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.microphone,
        Permission.notification,
        Permission.storage
      ];
      await requestMultiplePermissions(permissions);
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  // Non-static instance methods (for Provider use)
  Future<bool> requestLocation() => requestLocationPermission();
  Future<bool> requestCamera() => requestCameraPermission();
  Future<bool> requestMicrophone() => requestMicrophonePermission();
  Future<bool> requestNotification() => requestNotificationPermission();
  Future<bool> requestStorage() => requestStoragePermission();

  Future<bool> checkPermission(Permission permission) => isPermissionGranted(permission);
  Future<bool> isPermanentlyDenied(Permission permission) => isPermissionPermanentlyDenied(permission);
  Future<void> openSettings() => openAppSettings();
  Future<Map<Permission, PermissionStatus>> requestMultiple(List<Permission> permissions) =>
      requestMultiplePermissions(permissions);
  Future<bool> areAllGranted(List<Permission> permissions) => areAllPermissionsGranted(permissions);
  Future<String> requestWithMessage(Permission permission) => requestPermissionWithMessage(permission);
}
