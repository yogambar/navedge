import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding

import '../user_data_provider.dart';
import 'package:navedge/core/services/device_info_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with TickerProviderStateMixin {
  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String _errorMessage = '';
  UserData? _userData;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  String _platform = 'Unknown';
  String _appVersion = 'Unknown';
  List<Map<String, dynamic>> _otherFeedback = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  /// Instead of initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userData == null) {
      _loadInitialData(); // Now safe to use context
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final deviceInfoService = Provider.of<DeviceInfoService>(context, listen: false);
      final userData = Provider.of<UserData>(context, listen: false);

      String platform = await deviceInfoService.getPlatform();
      String appVersion = await deviceInfoService.getAppVersion();

      await _loadOtherFeedback(); // Load feedback from other users

      if (mounted) {
        setState(() {
          _userData = userData;
          _platform = platform;
          _appVersion = appVersion;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Error in _loadInitialData: $e\n$stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data. Please check your connection and restart.';
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar(_errorMessage);
        });
      }
    }
  }

  Future<void> _loadOtherFeedback() async {
    try {
      final currentUserUid = Provider.of<UserData>(context, listen: false).uid;
      final feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _otherFeedback = feedbackSnapshot.docs
              .where((doc) => doc['userId'] != currentUserUid)
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (error) {
      debugPrint("Error loading other feedback: $error");
      _showSnackBar('Failed to load other feedback.');
    }
  }

  Future<void> _submitFeedback(UserData? userData) async {
    if (userData == null) {
      _showSnackBar('User data not available.');
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      _showSnackBar('Please enter your feedback.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': userData.uid,
        'name': userData.name,
        'email': userData.email ?? 'N/A',
        'rating': _rating,
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'platform': _platform,
        'appVersion': _appVersion,
      });
      _feedbackController.clear();
      setState(() {
        _rating = 3.0;
        _isSubmitting = false;
      });
      _showSnackBar('Feedback submitted successfully!');
      _loadOtherFeedback(); // Reload other feedback after submitting
    } catch (error) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Error submitting feedback: $error');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildShimmerLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                  _userData = null;
                  _otherFeedback.clear();
                });
                _loadInitialData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherFeedbackList() {
    if (_otherFeedback.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Center(child: Text('No feedback from other users yet.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'What Others Are Saying',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _otherFeedback.length,
          separatorBuilder: (context, index) => const Divider(thickness: 1.0),
          itemBuilder: (context, index) {
            final feedback = _otherFeedback[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback['name'] ?? 'Anonymous User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  RatingBarIndicator(
                    rating: (feedback['rating'] as num?)?.toDouble() ?? 0.0,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 18.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 8),
                  Text(feedback['feedback'] ?? 'No feedback provided.'),
                  const SizedBox(height: 4),
                  Text(
                    '${feedback['platform'] ?? 'Unknown Platform'} - ${feedback['appVersion'] ?? 'Unknown Version'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackContent(UserData userData) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Your Valuable Feedback',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              'Your feedback helps us improve our app and provide a better experience for everyone.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate Your Experience:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                        onRatingUpdate: (rating) => setState(() => _rating = rating),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Detailed Feedback:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tell us more about your experience...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ScaleTransition(
                      scale: _scaleAnimation!,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                await _animationController?.forward();
                                await _animationController?.reverse();
                                _submitFeedback(userData);
                              },
                        icon: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(FontAwesomeIcons.paperPlane, size: 20),
                        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback',
                            style: const TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildOtherFeedbackList(),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Thank you for helping us improve!',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 3,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading
            ? _buildShimmerLoading()
            : _errorMessage.isNotEmpty
                ? _buildErrorScreen()
                : (_userData != null)
                    ? _buildFeedbackContent(_userData!)
                    : _buildErrorScreen(),
      ),
    );
  }
}
