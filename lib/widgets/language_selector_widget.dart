import 'package:flutter/material.dart';
import 'package:news_app/services/language_service.dart';

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  _LanguageSelectorWidgetState createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    String languageCode = await LanguageService.getLanguageCode();
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    await LanguageService.setLanguageCode(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    // Here, you can add logic to reload the app’s language if necessary.
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedLanguage,
      icon: const Icon(Icons.language, color: Colors.blue),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _saveLanguagePreference(newValue);
        }
      },
      items: <String>['en', 'de', 'bg', 'ar']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(_getLanguageName(value)),
        );
      }).toList(),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'de':
        return 'Deutsch';
      case 'bg':
        return 'Български';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }
}
