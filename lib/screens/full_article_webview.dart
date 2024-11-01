import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/language_service.dart';

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
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    String languageCode = await LanguageService.getLanguageCode();
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedText('full_article', _currentLanguage)),
        actions: [
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
            Center(
              child: Text(
                getTranslatedText('failed_to_load', _currentLanguage),
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.articleUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _hasError = false;
                  _progress = 0.1; // Start the progress at 10%
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _progress = 1.0; // Page loaded completely
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
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _hasError = true;
                });
              },
            ),
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress), // Show progress bar
        ],
      ),
    );
  }

  String getTranslatedText(String key, String languageCode) {
    // Placeholder function: Implement translation retrieval here using an external file or localization package.
    return key;
  }
}
