import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isSubscribed = false;
  bool _isLoading = true;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (_user != null) {
        await _loadSubscription();
      } else {
        _isSubscribed = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;

  Future<void> _loadSubscription() async {
    if (_user == null) return;
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    _isSubscribed = (doc.data()?['subscriptionStatus'] ?? false) == true;
  }

  Future<void> refreshSubscription() async {
    await _loadSubscription();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}


