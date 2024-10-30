import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Speichern der ausgewählten Interessen in Firestore
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

  // Lesen der ausgewählten Interessen des Benutzers
  Future<List<String>> getUserInterests() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Abrufen und Zurückgeben der Interessen als Liste von Strings
        List<String> interests = List<String>.from(userDoc.get('selectedInterests'));
        return interests;
      } else {
        return []; // Falls keine Interessen gespeichert sind, eine leere Liste zurückgeben
      }
    } catch (e) {
      print("Error fetching interests: $e");
      return []; // Leere Liste bei Fehler zurückgeben
    }
  }
}
