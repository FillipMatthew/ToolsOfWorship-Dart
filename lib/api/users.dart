import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/properties.dart';
import '../types/sign_in_type.dart';

class ApiUsers {
  final String _authToken;

  ApiUsers(String authToken) : _authToken = authToken;

  Future<Map<String, dynamic>> signIn(String accountId, String password) async {
    String userPass = base64Encode(utf8.encode('$accountId:$password'));
    String basicAuth = 'Basic $userPass';

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/api/user/login'),
      headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.acceptHeader: ContentType.json.mimeType,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return json.decode(response.body);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Authentication failed: Invalid credentials');
    }

    throw Exception('Sign in failed with status code ${response.statusCode}');
  }

  Future<Map<String, dynamic>> authenticate(
      SignInType signInType, String accountId, String? password) async {
    String body = json.encode({
      'signInType': signInType,
      'accountId': accountId,
      'password': password,
    });

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/api/user/authenticate'),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      body: body,
    );

    if (response.statusCode == HttpStatus.ok) {
      return json.decode(response.body);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Authentication failed: Invalid credentials');
    }

    throw Exception('Authentication failed with status code ${response.statusCode}');
  }

  Future<bool> signup(String displayName, String email, String password) async {
    String body = json.encode({
      'displayName': displayName,
      'accountId': email,
      'password': password,
    });

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/api/user/register'),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      body: body,
    );

    if (response.statusCode == HttpStatus.created) {
      json.decode(response.body);
      return true;
    } else if (response.statusCode == HttpStatus.forbidden) {
      final errorBody = json.decode(response.body).toString();
      throw Exception('Registration failed: $errorBody');
    }

    return false;
  }
}
