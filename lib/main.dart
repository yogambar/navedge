import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:navedge/app.dart';
import 'package:navedge/core/settings/app_settings.dart' as settings;
import 'package:navedge/core/utils/permission_handler.dart';
import 'package:navedge/user_data_provider.dart';
import 'package:navedge/widgets/theme_provider.dart';
import 'package:navedge/settings.dart';
import 'package:navedge/core/utils/sound_service.dart';
import 'package:navedge/core/authentication/auth_service.dart';
import 'package:navedge/core/services/device_info_service.dart'; // Import DeviceInfoService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  settings.AppSettings? appSettings;
  SoundService? soundService;

  // 🔥 Firebase Initialization
  try {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.linux)) {
      debugPrint("🔥 Initializing Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase initialized.");
    } else {
      debugPrint("🚫 Skipping Firebase initialization on Linux.");
    }
  } catch (e, stackTrace) {
    debugPrint('⚠️ Firebase initialization failed: $e\n$stackTrace');
  }

  // 🎵 Sound Service Initialization
  try {
    debugPrint("🎵 Initializing sound service...");
    soundService = SoundService();
    await soundService.initialize();
    debugPrint("✅ Sound service initialized.");
  } catch (e, stackTrace) {
    debugPrint('⚠️ Sound service initialization failed: $e\n$stackTrace');
    soundService = null;
  }

  // 🛠️ App Settings Initialization
  try {
    debugPrint("🛠️ Initializing app settings...");
    appSettings = settings.AppSettings();
    await appSettings.loadSettings();
    debugPrint("✅ App settings loaded.");
  } catch (e, stackTrace) {
    debugPrint('⚠️ App settings initialization failed: $e\n$stackTrace');
    appSettings = null;
  }

  debugPrint("🚀 Launching app...");
  _runAppSafely(appSettings, soundService);
}

void _runAppSafely(settings.AppSettings? appSettings, SoundService? soundService) {
  final fallbackSettings = appSettings ?? settings.AppSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: fallbackSettings),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserData()),
        ChangeNotifierProxyProvider<UserData, AuthService>(
          create: (context) =>
              AuthService(userData: Provider.of<UserData>(context, listen: false)),
          update: (context, userData, previous) =>
              previous!,
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider<PermissionHandlerService>(create: (_) => PermissionHandlerService()),
        Provider<DeviceInfoService>(create: (_) => DeviceInfoService()), // Provide DeviceInfoService
        if (soundService != null)
          ChangeNotifierProvider.value(value: soundService),
      ],
      child: const MyAppWrapper(),
    ),
  );
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navedge',
      theme: themeProvider.themeData,
      home: const App(),
    );
  }
}
