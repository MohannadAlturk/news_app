import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../widgets/submit_button_widget.dart';

class NoConnectionDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionDialog({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Consistent padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dialog takes minimal space
          children: [
            Text(
              getTranslatedText('no_internet'),
              style: const TextStyle(
                fontSize: 20, // Title text
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12), // Spacing between title and content
            Text(
              getTranslatedText('internet_required'),
              style: const TextStyle(
                fontSize: 16, // Body text
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Spacing before button
            SubmitButtonWidget(
              isLogin: true,
              onPressed: onRetry, // Retry action passed as a callback
              loginText: getTranslatedText('retry'),
              registerText: '',
            ),
          ],
        ),
      ),
    );
  }
  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
