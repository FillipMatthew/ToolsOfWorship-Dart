import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/users.dart';
import '../helpers/google_sign_in.dart';
import '../types/sign_in_type.dart';

class AccountAuthentication extends ChangeNotifier {
  String? _authToken;
  String? _displayName;
  SignInType? _signInType;

  Future<bool> signInSilent() async {
    if (isSignedIn) {
      return true;
    }

    // TODO: Implement refresh tokens. Use refresh token to get new auth token. Need auth token to get a refresh token.
    // Set a timer to use the refresh token to get a new Auth token every 12 minutes. Get a new refresh token every hour if remember signin is used.
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'signInToken');
    if (token != null) {
      return await _authenticate(SignInType.token, token, null);
    }

    return false;
  }

  Future<bool> signIn(String email, String password) async {
    return await _authenticate(SignInType.localUser, email, password);
  }

  Future<bool> authenticateWithGoogleSignIn() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.authenticate();
    if (!await helper.signIn()) {
      return false;
    }

    String? token = await helper.signInToken;
    if (token == null) {
      throw Exception('Could not retrieve google ID token.');
    }

    return await _authenticate(SignInType.googleSignIn, token, null);
  }

  Future<void> signOut() async {
    _authToken = null;
    _displayName = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'signInToken');

    // Only sign out from Google if the user signed in with Google
    if (_signInType == SignInType.googleSignIn) {
      GoogleSignInHelper helper = GoogleSignInHelper();
      await helper.signOut();
    }

    _signInType = null;
    notifyListeners();
  }

  bool get isSignedIn => _authToken != null && _displayName != null;

  String get displayName => _displayName ?? '';

  String get authToken => _authToken ?? '';

  Future<bool> _authenticate(
      SignInType signInType, String accountId, String? password) async {
    Map<String, dynamic> userData;
    if (signInType == SignInType.localUser) {
      userData = await ApiUsers(_authToken ?? '').signIn(accountId, password!);
    } else {
      userData = await ApiUsers(_authToken ?? '')
          .authenticate(signInType, accountId, password);
    }

    _authToken = userData['token'] as String?;
    _displayName = userData['displayName'] as String?;
    _signInType = signInType;
    notifyListeners();
    if (_authToken != null) {
      return true;
    } else {
      return false;
    }
  }
}
