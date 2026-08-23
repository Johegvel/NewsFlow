import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frontend/data/datasources/remote_api_datasource.dart';

void main() {
  group('RemoteApiDataSource authentication', () {
    test('login reads the JWT and nested user returned by Rails', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'email': 'user@example.com',
          'password': 'NewsFlow123!',
        });

        return http.Response(
          jsonEncode({
            'token': 'jwt-token',
            'user': {
              'id': 7,
              'name': 'Usuario de prueba',
              'email': 'user@example.com',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final dataSource = RemoteApiDataSourceImpl(client: client);

      final session = await dataSource.login(
        'user@example.com',
        'NewsFlow123!',
      );

      expect(session.token, 'jwt-token');
      expect(session.user.id, 7);
      expect(session.user.email, 'user@example.com');
    });

    test('protected requests send the configured Bearer token', () async {
      final client = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer jwt-token');
        return http.Response(
          jsonEncode({
            'id': 4,
            'user_id': 7,
            'post_id': 12,
            'post': {
              'id': 12,
              'title': 'Noticia guardada',
              'content': 'Contenido',
              'user': {'id': 3, 'name': 'Flews'},
              'community': {
                'id': 2,
                'name': 'Ciencia',
                'slug': 'ciencia',
              },
              'viewer_saved_post_id': 4,
            },
          }),
          201,
        );
      });
      final dataSource = RemoteApiDataSourceImpl(client: client)
        ..setAuthToken('jwt-token');

      final saved = await dataSource.savePost(postId: 12, userId: 7);

      expect(saved.id, 4);
      expect(saved.post.title, 'Noticia guardada');
      expect(saved.post.isSavedByViewer, isTrue);
    });

    test('post interactions parse viewer state and support removing it', () async {
      var requestNumber = 0;
      final client = MockClient((request) async {
        requestNumber++;
        expect(request.headers['authorization'], 'Bearer jwt-token');
        if (requestNumber == 1) {
          expect(request.method, 'GET');
          return http.Response(
            jsonEncode({
              'id': 12,
              'title': 'Noticia',
              'content': 'Contenido',
              'reactions_count': 3,
              'viewer_reaction_id': 9,
              'viewer_saved_post_id': 4,
              'user': {'id': 3, 'name': 'Flews'},
              'community': {'id': 2, 'name': 'Ciencia'},
            }),
            200,
          );
        }
        expect(request.method, 'DELETE');
        expect(request.url.path, endsWith('/reactions/9'));
        return http.Response('', 204);
      });
      final dataSource = RemoteApiDataSourceImpl(client: client)
        ..setAuthToken('jwt-token');

      final post = await dataSource.fetchPost(12);
      expect(post.reactionsCount, 3);
      expect(post.isLikedByViewer, isTrue);
      expect(post.isSavedByViewer, isTrue);

      await dataSource.deleteReaction(post.viewerReactionId!);
    });

    test('saved posts reject incomplete server payloads with a useful error', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([{'id': 4, 'post_id': 12}]), 200);
      });
      final dataSource = RemoteApiDataSourceImpl(client: client)
        ..setAuthToken('jwt-token');

      expect(
        () => dataSource.fetchSavedPosts(7),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('publicación guardada completa'),
          ),
        ),
      );
    });
  });
}
