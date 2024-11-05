import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserInterests(List<String> selectedInterests) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.set({
        'selectedInterests': selectedInterests,
      }, SetOptions(merge: true));

      print("Interests saved successfully.");
    } catch (e) {
      print("Error saving interests: $e");
    }
  }

  Future<void> saveUserLanguage(String languageCode) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.set({
        'selectedLanguage': languageCode,
      }, SetOptions(merge: true));

      print("Language saved successfully.");
    } catch (e) {
      print("Error saving language: $e");
    }
  }

  Future<List<String>> getUserInterests() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        List<String> interests = List<String>.from(userDoc.get('selectedInterests'));
        return interests;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching interests: $e");
      return [];
    }
  }

  Future<String?> getUserLanguage() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (data.containsKey('selectedLanguage')) {
          return data['selectedLanguage'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching language: $e");
      return null;
    }
  }
}
