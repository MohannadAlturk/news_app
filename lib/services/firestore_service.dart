import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserInterests(List<String> selectedInterests) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'selectedInterests': selectedInterests,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving interests: $e");
    }
  }

  Future<void> saveUserLanguage(String languageCode) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'selectedLanguage': languageCode,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving language: $e");
    }
  }

  Future<List<String>> getUserInterests() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists ? List<String>.from(userDoc.get('selectedInterests')) : [];
    } catch (e) {
      print("Error fetching interests: $e");
      return [];
    }
  }

  Future<String?> getUserLanguage() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists ? userDoc.get('selectedLanguage') : null;
    } catch (e) {
      print("Error fetching language: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteArticles() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('favorites') && data['favorites'] is List) {
        return List<Map<String, dynamic>>.from(data['favorites']);
      }
    }
    // Return an empty list if "favorites" field doesn't exist
    return [];
  }


  Future<void> addArticleToFavorites(Map<String, dynamic> article, String locale) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    await userDoc.set({
      'favorites': FieldValue.arrayUnion([article]),
    }, SetOptions(merge: true)); // Use merge to ensure existing data is not overwritten
  }

  Future<void> removeArticleFromFavorites(Map<String, dynamic> article) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    await userDoc.update({
      'favorites': FieldValue.arrayRemove([article]),
    });
  }

  Future<bool> isFavorite(Map<String, dynamic> article) async {
    List<Map<String, dynamic>> favorites = await getFavoriteArticles();
    return favorites.any((favArticle) => favArticle['title'] == article['title']);
  }
}
