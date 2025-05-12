import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../core/constants/api_constants.dart'; // Your API constants

// Conditional import for web-specific libraries
// import 'dart:ui_web' as ui_web if (kIsWeb);
// import 'dart:html' as html if (kIsWeb);

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
          child: _buildStreetViewContent(),
        ),
      ),
    );
  }

  Widget _buildStreetViewContent() {
    // if (kIsWeb) {
    //   // Embed Street View using iframe for web
    //   final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.latitude},${widget.longitude}&fov=80&heading=70&pitch=0';
    //
    //   // Register a unique key for the HtmlElementView
    //   final String viewType = 'streetview-iframe-${widget.latitude}-${widget.longitude}';
    //   ui_web.platformViewRegistry.registerViewFactory(
    //     viewType,
    //     (int viewId) => html.IFrameElement()
    //       ..width = '${MediaQuery.of(context).size.width * 0.9}'
    //       ..height = '${MediaQuery.of(context).size.height * 0.7}'
    //       ..style.border = 'none'
    //       ..src = streetViewUrl,
    //   );
    //
    //   return SizedBox(
    //     width: MediaQuery.of(context).size.width * 0.9,
    //     height: MediaQuery.of(context).size.height * 0.7,
    //     child: HtmlElementView(viewType: viewType),
    //   );
    // } else
    if (_isMobile()) {
      // Use WebView for mobile platforms
      final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.latitude},${widget.longitude}&fov=80&heading=70&pitch=0';
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading Street View')),
                  );
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(streetViewUrl)),
      );
    } else {
      // Fallback for other platforms
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '⚠️ Street View might not be fully supported on this platform.',
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
}
