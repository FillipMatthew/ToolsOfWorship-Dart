import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

import 'package:tools_of_worship_server/properties.dart';

class AccountAuthentication {
  static String signToken(String userIdentifier) {
    final jwt = JWT(
      {
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
      issuer: 'https://ToolsOfWorship.com',
      subject: userIdentifier,
    );

    String token = jwt.sign(
      SecretKey(Properties.jwtSecret),
      expiresIn: Duration(hours: 12),
    );

    print('Signed token: $token\n');

    return token;
  }

  static String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Properties.jwtSecret));

      print('Payload: ${jwt.payload}');
      return jwt.subject;
    } on JWTExpiredError {
      print('JWT expired.');
    } on JWTError catch (ex) {
      print(ex.message); // Invalid signature
    }

    return null;
  }

  static Middleware checkAuthorisation() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.url.path != 'apis/Users/Authenticate' &&
            request.context['authDetails'] == null) {
          return Response.forbidden('Not authorised to perform this function.');
        }

        return null;
      },
    );
  }

  static Middleware handleAuth() {
    return (Handler innerHandler) {
      return (Request request) async {
        String? subject = _authenticateRequest(request);
        final updatedRequest = request.change(
          context: {'authDetails': subject},
        );
        return await innerHandler(updatedRequest);
      };
    };
  }

  // Returns the authenticated token subject if the request is authorised.
  static String? _authenticateRequest(Request request) {
    print('Invalid auth token');
    String? authHeader = request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null) {
      return null;
    }

    return _isAuthorized(authHeader);
  }

  static String? _isAuthorized(String authHeader) {
    final parts = authHeader.split(' ');
    if (parts.length != 2 || parts[0] != 'Bearer') {
      return null;
    }

    return verifyToken(parts[1]);
  }
}
