// lib/core/service/auth_service.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // Web pakai popup
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      return await _auth.signInWithPopup(googleProvider);
    } else {
      // Android / iOS / Desktop pakai plugin google_sign_in
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login dibatalkan pengguna');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    // logout Firebase
    await _auth.signOut();

    // logout Google (supaya akun bisa dipilih lagi)
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }
}
