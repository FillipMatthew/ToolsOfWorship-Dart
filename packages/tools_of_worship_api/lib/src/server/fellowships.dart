import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:xid/xid.dart';

import '../types/access_level.dart';
import '../types/fellowship.dart';
import 'interfaces/fellowships_data_provider.dart';

class ApiFellowships {
  final FellowshipsDataProvider _fellowshipsDataProvider;

  ApiFellowships(FellowshipsDataProvider fellowshipsDataProvider)
      : _fellowshipsDataProvider = fellowshipsDataProvider;

  Router get router {
    Router router = Router();

    router.post('/Add', _postAdd);
    router.post('/Join', _postJoin);
    router.post('/List', _postList);

    return router;
  }

  Future<Response> _postAdd(Request request) async {
    print('ApiFellowship: _postAdd');

    String userId = request.context['authDetails'] as String;

    final payload = await request.readAsString();

    try {
      dynamic data = json.decode(payload);
      String? name = data['name'];
      if (name == null || name.isEmpty) {
        return Response.forbidden('Invalid request.');
      }

      if (await _fellowshipsDataProvider.exists(name, userId)) {
        return Response.forbidden('Already exists.');
      }

      String fellowshipId = Xid.string();

      if (!await _fellowshipsDataProvider.create(fellowshipId, name, userId)) {
        return Response.internalServerError(
            body: 'Failed to create fellowship.');
      }

      return Response.ok(
        json.encode({
          'id': fellowshipId,
          'name': name,
        }),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      );
    } on FormatException catch (_) {
      return Response.forbidden('Invalid request.');
    }
  }

  Future<Response> _postJoin(Request request) async {
    print('ApiFellowship: _postJoin');
    return Response.internalServerError();
  }

  Future<Response> _postList(Request request) async {
    print('ApiFellowship: _postList');

    String userId = request.context['authDetails'] as String;

    try {
      Stream<Fellowship> userFellowships = _fellowshipsDataProvider
          .getUserFellowships(userId, AccessLevel.readOnly);

      List<Map<String, dynamic>> fellowships = [];
      await for (Fellowship fellowship in userFellowships) {
        if (fellowship.isValid) {
          fellowships.add(fellowship.toJson());
        }
      }

      return Response.ok(
        json.encode(fellowships),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      );
    } on FormatException catch (_) {
      return Response.forbidden('Invalid request.');
    }
  }
}
