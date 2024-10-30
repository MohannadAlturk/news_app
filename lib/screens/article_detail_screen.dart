import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../view_models/article_detail_viewmodel.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/text_to_speech_bar.dart';
import '../services/text_to_speech_service.dart';  // Import the TTS service
import 'package:intl/intl.dart';
import 'full_article_webview.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = TextToSpeechService();
  }

  @override
  void dispose() {
    // Stop TTS when exiting the screen
    _ttsService.stop();
    _ttsService.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Unknown Date";
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(dateTime);
    } catch (e) {
      return "Unknown Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      ArticleDetailViewModel()
        ..fetchAndSummarizeArticle(widget.article['url']),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.article['title'],
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ArticleDetailViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.article['urlToImage'] != null &&
                        widget.article['urlToImage'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          widget.article['urlToImage'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Image not available',
                              style: TextStyle(color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      widget.article['title'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(widget.article['publishedAt']),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          widget.article['source']?['name'] ?? 'Unknown Source',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      viewModel.summary,
                      style: const TextStyle(
                          fontSize: 20, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullArticleWebView(
                                      articleUrl: widget.article['url'],
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text(
                            'Read more',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Share.share(
                                'Check this out: ${widget.article['title']} - ${widget.article['url']} - Sent with NewsAI');
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            'Share',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (viewModel.summary.isNotEmpty)
                      TextToSpeechBar(
                        text: viewModel.summary,
                        ttsService: _ttsService,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0,),
      ),
    );
  }
}
