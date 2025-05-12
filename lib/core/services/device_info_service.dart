import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Returns the platform name as a string
  Future<String> getPlatform() async {
    if (kIsWeb) return 'Web';

    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
      return 'Unknown';
    } catch (e) {
      debugPrint('Error getting platform: $e');
      return 'Unknown';
    }
  }

  /// Returns the app version from package_info_plus
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      debugPrint('Error getting app version: $e');
      return 'Unknown';
    }
  }

  /// Returns the unique device ID (Android ID or iOS identifierForVendor)
  Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        return 'Web';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id ?? 'Unknown Android ID';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'Unknown iOS ID';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return windowsInfo.deviceId ?? 'Unknown Windows ID';
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        return macInfo.systemGUID ?? 'Unknown macOS ID';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        return linuxInfo.machineId ?? 'Unknown Linux ID';
      } else {
        return 'Unsupported Platform';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'Error';
    }
  }

  /// Returns the model of the device
  Future<String> getDeviceModel() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return '${webInfo.browserName.name} on ${webInfo.userAgent ?? "Unknown"}';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model ?? 'Unknown Android Device';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.utsname.machine ?? 'Unknown iOS Device';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return windowsInfo.computerName ?? 'Windows PC';
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        return macInfo.model ?? 'Mac';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        return linuxInfo.name ?? 'Linux Machine';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      debugPrint('Error getting device model: $e');
      return 'Unknown';
    }
  }
}
