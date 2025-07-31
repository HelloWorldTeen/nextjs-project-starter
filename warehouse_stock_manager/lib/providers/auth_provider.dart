import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  User? user;
  String? role;
  bool isLoading = true;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    user = firebaseUser;
    if (user != null) {
      await _fetchUserRole();
    } else {
      role = null;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserRole() async {
    if (user == null) return;
    final snapshot = await _dbRef.child('users/${user!.uid}/role').get();
    if (snapshot.exists) {
      role = snapshot.value as String?;
    } else {
      role = null;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
