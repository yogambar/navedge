import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navedge/core/utils/sound_service.dart';
import 'screens/home_screen.dart'; // Corrected import path

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _hasInteracted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sound on first interaction (optional, initialization is in main.dart)
  }

  void _userInteracted() {
    if (!_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
      final soundService = Provider.of<SoundService>(context, listen: false);
      soundService.playClickSound(); // Play a sound on the first interaction
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _userInteracted,
      child: MaterialApp(
        title: 'Navedge',
        theme: Theme.of(context), // Use the theme provided by ThemeProvider in main.dart
        home: const HomeScreen(), // Navigate to your main application screen
      ),
    );
  }
}
