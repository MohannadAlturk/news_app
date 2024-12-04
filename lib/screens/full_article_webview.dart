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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          getTranslatedText('full_article'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.blue,

      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Text(
                getTranslatedText('failed_to_load'),
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
                  _progress = 0.1;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _progress = 1.0;
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
                onReceivedError: (controller, request, error) {
                  setState(() {
                    _hasError = true;
                  });
              }
            ),
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
