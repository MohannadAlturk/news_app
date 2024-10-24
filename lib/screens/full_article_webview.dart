import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FullArticleWebView extends StatefulWidget {
  final String articleUrl;

  const FullArticleWebView({
    super.key,
    required this.articleUrl,
  });

  @override
  _FullArticleWebViewState createState() => _FullArticleWebViewState();
}

class _FullArticleWebViewState extends State<FullArticleWebView> {
  late InAppWebViewController _webViewController;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Article'),
        actions: [
          // Optional: A refresh button for the WebView
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
                        },
          )
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            const Center(
              child: Text(
                'Failed to load page. Please check your connection.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.articleUrl)),  // Updated here
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _hasError = false;
                  _progress = 0.1;  // Start the progress at 10%
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _progress = 1.0;  // Page loaded completely
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print("Console message: ${consoleMessage.message}");
              },
            ),
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress), // Show progress bar
        ],
      ),
    );
  }
}
