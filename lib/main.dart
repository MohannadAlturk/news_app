import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/screens/login_page.dart';
import 'package:news_app/screens/news_screen.dart';
import 'package:news_app/services/firestore_service.dart';
import 'package:news_app/services/language_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await LanguageService.loadUserLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthStateWrapper(),
    );
  }
}

class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({super.key});

  Future<bool> _hasSavedInterests() async {
    final interests = await FirestoreService().getUserInterests();
    return interests.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _hasSavedInterests(),
            builder: (context, interestSnapshot) {
              if (interestSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (interestSnapshot.data == true) {
                return const NewsScreen();
              } else {
                return const InterestsScreen();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
