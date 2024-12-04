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
import 'package:news_app/view_models/news_viewmodel.dart';
import 'package:provider/provider.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await LanguageService.loadUserLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsViewModel()), // Provide NewsViewModel
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthStateWrapper(),
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
                return const InterestsScreen(isFirstLogin: true);
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
