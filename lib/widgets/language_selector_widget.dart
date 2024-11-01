import 'package:flutter/material.dart';
import 'package:news_app/services/language_service.dart';

class LanguageSelectorWidget extends StatefulWidget {
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelectorWidget({super.key, required this.onLanguageChanged});

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
    widget.onLanguageChanged(languageCode);
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
        underline: Container(), // Remove the default underline
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
