import 'package:flutter/material.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/services/firestore_service.dart';

class LanguageSelectorWidget extends StatefulWidget {
  final ValueChanged<String> onLanguageChanged;
  final String currentLanguage;

  const LanguageSelectorWidget({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  _LanguageSelectorWidgetState createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  late String _selectedLanguage;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    String? languageCode = await _firestoreService.getUserLanguage();
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
      });
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    await LanguageService.loadLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    widget.onLanguageChanged(languageCode);
    await _firestoreService.saveUserLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: const Icon(Icons.language, color: Colors.blue),
        dropdownColor: Colors.white,
        underline: Container(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _saveLanguagePreference(newValue);
          }
        },
        items: [
          DropdownMenuItem(
            value: 'en',
            child: _buildMenuItem('English', '🇬🇧'),
          ),
          DropdownMenuItem(
            value: 'de',
            child: _buildMenuItem('Deutsch', '🇩🇪'),
          ),
          DropdownMenuItem(
            value: 'bg',
            child: _buildMenuItem('Български', '🇧🇬'),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: _buildMenuItem('العربية', '🇸🇦'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String text, String flag) {
    return Row(
      children: [
        Text(
          flag,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }
}
