import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading_dots.json', // Replace with your loading animation asset
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium, // Use titleMedium or bodyLarge
            ),
          ],
        ],
      ),
    );
  }
}
