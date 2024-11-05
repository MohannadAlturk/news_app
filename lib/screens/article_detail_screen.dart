import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/text_to_speech_service.dart';
import '../view_models/article_detail_viewmodel.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/text_to_speech_bar.dart';
import 'full_article_webview.dart';
import 'package:news_app/services/language_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
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
    return MultiProvider(
      providers: [
        Provider<TextToSpeechService>(
          create: (_) => TextToSpeechService(),
          dispose: (_, ttsService) => ttsService.dispose(),
        ),
        ChangeNotifierProvider<ArticleDetailViewModel>(
          create: (context) => ArticleDetailViewModel(
            Provider.of<TextToSpeechService>(context, listen: false),
          )..fetchAndSummarizeArticle(widget.article['url']),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.article['title'],
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          color: Colors.white, // Set background color to white
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
                            return Text(
                              getTranslatedText('image_not_available'),
                              style: const TextStyle(color: Colors.grey),
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
                          widget.article['source']?['name'] ??
                              getTranslatedText('unknown_source'),
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
                          child: Text(
                            getTranslatedText('read_more'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Share.share(
                                '${getTranslatedText('check_this_out')}: ${widget.article['title']} - ${widget.article['url']} - Sent with NewsAI');
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: Text(
                            getTranslatedText('share'),
                            style: const TextStyle(color: Colors.white),
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
                        playText: getTranslatedText('play'),
                        pauseText: getTranslatedText('pause'),
                        stopText: getTranslatedText('stop'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return getTranslatedText("unknown_date");
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(dateTime);
    } catch (e) {
      return getTranslatedText("unknown_date");
    }
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
