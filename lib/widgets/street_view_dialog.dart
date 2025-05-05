import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

import '../core/constants/api_constants.dart'; // Your API constants

class StreetViewDialog extends StatefulWidget {
  final double latitude;
  final double longitude;

  const StreetViewDialog({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<StreetViewDialog> createState() => _StreetViewDialogState();
}

class _StreetViewDialogState extends State<StreetViewDialog> {
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildWebView(),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    if (_isMobile()) {
      return WebViewWidget(
        controller: _webViewController ??= WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                debugPrint('✅ Street View page loaded: $url');
              },
              onWebResourceError: (error) {
                debugPrint('❗ Error loading Street View: $error');
                if (mounted) {
                  _webViewController?.loadRequest(Uri.parse(getProxyStreetViewUrl()));
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(getStreetViewUrl())),
      );
    } else {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '⚠️ Street View not supported on this platform.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
  }

  bool _isMobile() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String getStreetViewUrl() {
    final apiKey = ApiConstants.googleApiKey;
    return 'https://www.google.com/maps/embed/v1/streetview?location=${widget.latitude},${widget.longitude}&key=$apiKey';
  }

  String getProxyStreetViewUrl() {
    return '${ApiConstants.proxyBaseUrl}/streetview?location=${widget.latitude},${widget.longitude}';
  }
}

