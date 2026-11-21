// PATCH-27
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../api/erp_session.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Resultat de l'envoi du SMS.
class PhoneCodeResult {
  const PhoneCodeResult({this.verificationId, this.resendToken, this.autoSignedIn = false});
  final String? verificationId;
  final int? resendToken;
  final bool autoSignedIn; // Android a lu le SMS et connecte tout seul
}

/// Connexion Firebase: telephone (SMS) et Google.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _ready = false;
  bool get ready => _ready;

  final _auto = StreamController<void>.broadcast();

  /// Emet quand la connexion a ete faite automatiquement (SMS lu par Android).
  Stream<void> get autoSignedIn => _auto.stream;

  Future<void> init() async {
    await ErpSession.instance.load();
    try {
      await Firebase.initializeApp();
      _ready = true;
    } catch (e) {
      debugPrint('Firebase non configure: $e');
    }
  }

  FirebaseAuth get _auth {
    if (!_ready) throw const AuthFailure('Sign-in is not available right now.');
    return FirebaseAuth.instance;
  }

  bool get isSignedIn => ErpSession.instance.isSignedIn || (_ready && FirebaseAuth.instance.currentUser != null);
  User? get user => _ready ? FirebaseAuth.instance.currentUser : null;

  Future<void> signOut() async {
    await ErpSession.instance.logout();
    if (!_ready) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  /// Envoie le code SMS a [phone] (format E.164, ex: +2250712345678).
  Future<PhoneCodeResult> sendCode(String phone, {int? resendToken}) {
    final auth = _auth;
    final done = Completer<PhoneCodeResult>();
    auth.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        try {
          await auth.signInWithCredential(cred);
          _auto.add(null);
          if (!done.isCompleted) done.complete(const PhoneCodeResult(autoSignedIn: true));
        } on FirebaseAuthException catch (e) {
          if (!done.isCompleted) done.completeError(AuthFailure(_message(e)));
        }
      },
      verificationFailed: (e) {
        if (!done.isCompleted) done.completeError(AuthFailure(_message(e)));
      },
      codeSent: (id, token) {
        if (!done.isCompleted) done.complete(PhoneCodeResult(verificationId: id, resendToken: token));
      },
      codeAutoRetrievalTimeout: (_) {},
    ).catchError((Object e) {
      if (!done.isCompleted) done.completeError(AuthFailure(e is FirebaseAuthException ? _message(e) : 'Something went wrong. Please try again.'));
    });
    return done.future;
  }

  /// Verifie le code a 6 chiffres saisi par l'utilisateur.
  Future<void> confirmCode(String verificationId, String code) async {
    try {
      final cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
      await _auth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_message(e));
    }
  }

  /// Connexion Google (flux Firebase natif). Renvoie null si l'utilisateur annule.
  Future<User?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider()..addScope('email');
      final cred = await _auth.signInWithProvider(provider);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled' || e.code == 'popup-closed-by-user') return null;
      throw AuthFailure(_message(e));
    }
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'This phone number is not valid.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      case 'invalid-verification-code':
        return 'Incorrect code. Please try again.';
      case 'session-expired':
      case 'code-expired':
        return 'This code has expired. Request a new one.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled yet.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
