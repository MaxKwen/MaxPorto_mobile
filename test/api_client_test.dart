import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:maxporto_mobile/models/project.dart';
import 'package:maxporto_mobile/services/api_client.dart';
import 'package:maxporto_mobile/services/auth_state.dart';

import 'support/fake_backend.dart' show FakeBackend;

void main() {
  group('Project JSON', () {
    test('fromJson memetakan snake_case dan mengabaikan field lain', () {
      final project = Project.fromJson(FakeBackend.sampleProject);
      expect(project.id, 1);
      expect(project.title, 'MaxPorto');
      expect(project.category, 'Django');
      expect(project.projectUrl, 'https://github.com/MaxKwen/MaxPorto');
      expect(project.thumbnail, '');
    });

    test('thumbnail/project_url null atau hilang menjadi string kosong', () {
      final project = Project.fromJson({
        'id': 5,
        'title': 'A',
        'description': 'B',
        'category': 'C',
        'thumbnail': null,
      });
      expect(project.projectUrl, '');
      expect(project.thumbnail, '');
    });

    test('toJson tidak mengirim id', () {
      const project = Project(
        id: 9,
        title: 'A',
        description: 'B',
        category: 'C',
        projectUrl: 'https://a.b',
      );
      expect(project.toJson(), {
        'title': 'A',
        'description': 'B',
        'category': 'C',
        'project_url': 'https://a.b',
        'thumbnail': '',
      });
    });
  });

  group('ApiClient', () {
    test('getProjects mengurai daftar dan memakai header Accept', () async {
      final backend = FakeBackend();
      final projects = await backend.apiClient.getProjects();
      expect(projects.single.title, 'MaxPorto');
      expect(backend.requests.single.headers['Accept'], 'application/json');
    });

    test('getProjects mendukung teks UTF-8', () async {
      final client = ApiClient(
        baseUrl: 'http://test',
        client: MockClient(
          (_) async => http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {'id': 1, 'title': 'Café', 'description': 'é', 'category': 'x'},
              ]),
            ),
            200,
          ),
        ),
      );
      expect((await client.getProjects()).single.title, 'Café');
    });

    test('status non-2xx melempar ApiException', () async {
      final backend = FakeBackend(failProjects: true);
      expect(
        backend.apiClient.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('obtainToken mengembalikan token, kredensial salah gagal', () async {
      final backend = FakeBackend();
      expect(
        await backend.apiClient.obtainToken('owner', 'secret'),
        FakeBackend.validToken,
      );
      expect(
        backend.apiClient.obtainToken('owner', 'salah'),
        throwsA(isA<ApiException>()),
      );
    });

    test('isAuthError hanya untuk 401 atau 403 Invalid token', () {
      expect(const ApiException(401, '').isAuthError, isTrue);
      expect(
        const ApiException(403, '{"detail":"Invalid token."}').isAuthError,
        isTrue,
      );
      expect(
        const ApiException(403, '{"detail":"Only the owner"}').isAuthError,
        isFalse,
      );
      expect(const ApiException(500, '').isAuthError, isFalse);
    });
  });

  group('AuthState', () {
    test('login dan logout memberi tahu listener', () async {
      final backend = FakeBackend();
      final auth = AuthState(backend.apiClient);
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');
      expect(auth.isLoggedIn, isTrue);
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(notified, 2);
      expect(backend.activeToken, isNull);
    });

    test('logout tetap mengakhiri sesi lokal walau server menolak', () async {
      final backend = FakeBackend();
      final auth = AuthState(backend.apiClient, initialToken: 'kedaluwarsa');
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });
  });
}
