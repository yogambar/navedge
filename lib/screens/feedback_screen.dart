import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart'; // For fade in animation

import '../user_data_provider.dart'; // Assuming this is the correct path

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 3.0; // Default rating
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Simulate loading user data
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _userData = Provider.of<UserData>(context, listen: false);
        _isLoading = false;
      });
    }
  }

  Future<void> _submitFeedback(UserData? userData) async {
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not available.')),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': userData.uid, // Optional: If you have user IDs
        'name': userData.name,
        'email': userData.email ?? 'N/A',
        'rating': _rating,
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _feedbackController.clear();
      setState(() {
        _rating = 3.0; // Reset rating
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
    } catch (error) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $error')),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200,
              height: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const ListTile(
              title: SizedBox(height: 16, width: 150, child: ColoredBox(color: Colors.white)),
              subtitle: SizedBox(height: 12, width: 200, child: ColoredBox(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 180,
              height: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (_) => const Icon(Icons.star, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent(UserData userData) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 100),
              child: Text(
                'We value your feedback!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            FadeIn(
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Your Name: ${userData.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            FadeIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Your Email: ${userData.email ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: const Text(
                'Rate your experience:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            FadeIn(
              duration: const Duration(milliseconds: 500),
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: const Text(
                'Share your feedback:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            FadeIn(
              duration: const Duration(milliseconds: 700),
              child: TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tell us what you think...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeIn(
              duration: const Duration(milliseconds: 800),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitFeedback(userData),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Feedback'),
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
        title: const Text('Feedback'),
        centerTitle: true,
        elevation: 2,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? _buildShimmerLoading()
            : _userData != null
                ? _buildFeedbackContent(_userData!)
                : const Center(child: Text('Could not load user data.')), // Handle potential error
      ),
    );
  }
}
