import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/main.dart';
import 'package:maxporto_mobile/services/api_client.dart';

/// Backend DRF palsu berbasis [MockClient] agar test tidak butuh server Django.
///
/// Meniru kontrak MaxPorto: GET proyek publik, login token untuk
/// `owner`/`secret`, POST proyek hanya dengan token valid (selain itu 403
/// "Invalid token."), dan logout 204 yang mencabut token.
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? projects, this.failProjects = false})
    : projects = projects ?? [sampleProject];

  static const validToken = 'tok-owner';
  static const sampleProject = {
    'id': 1,
    'title': 'MaxPorto',
    'description': 'Website portofolio Django',
    'category': 'Django',
    'project_url': 'https://github.com/MaxKwen/MaxPorto',
    'thumbnail': '',
    'is_featured': true,
    'star_count': 3,
  };

  final List<Map<String, dynamic>> projects;
  bool failProjects;
  String? activeToken;

  /// Jika diisi, GET proyek menunggu Completer ini (untuk menguji loading).
  Completer<void>? projectsGate;

  /// Semua request yang masuk, untuk memeriksa header dan body.
  final List<http.Request> requests = [];

  late final ApiClient apiClient = ApiClient(
    client: MockClient(_handle),
    baseUrl: 'http://test',
  );

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;
    final auth = request.headers['Authorization'];
    final tokenOk = activeToken != null && auth == 'Token $activeToken';

    if (path == '/api/v1/projects/' && request.method == 'GET') {
      await projectsGate?.future;
      if (failProjects) return http.Response('Server error', 500);
      return _json(projects, 200);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (!tokenOk) return _json({'detail': 'Invalid token.'}, 403);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {...body, 'id': projects.length + 1};
      projects.add(created);
      return _json(created, 201);
    }
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        activeToken = validToken;
        return _json({'token': validToken}, 200);
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }
    if (path == '/api/v1/auth/logout/') {
      if (!tokenOk) return _json({'detail': 'Invalid token.'}, 403);
      activeToken = null;
      return http.Response('', 204);
    }
    return http.Response('Not found', 404);
  }

  static http.Response _json(Object body, int status) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// Ukuran layar ponsel (logical pixel) agar tata letak sama seperti di perangkat.
const Size phoneSize = Size(412, 915);

/// Pasang aplikasi lengkap (MultiProvider + MaterialApp) dengan backend palsu.
Future<FakeBackend> pumpApp(
  WidgetTester tester, {
  FakeBackend? backend,
  Size size = phoneSize,
}) async {
  final fake = backend ?? FakeBackend();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(apiClient: fake.apiClient));
  return fake;
}

Future<void> openDrawer(WidgetTester tester) async {
  // Font test (setiap huruf berupa kotak selebar ukuran font) jauh lebih lebar
  // dari Roboto, sehingga teks DrawerHeader tutorial terbungkus berlebihan dan
  // overflow hanya di test. Perkecil skala teks agar setara tampilan asli.
  tester.platformDispatcher.textScaleFactorTestValue = 0.5;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
  await tester.pumpAndSettle();
}

/// Label dan hint bisa sama, jadi ambil satu teks agar field tidak dobel.
Finder field(String label) => find.ancestor(
  of: find.text(label).first,
  matching: find.byType(TextFormField),
);

/// Isi form login lalu tekan tombol Login.
Future<void> submitLogin(
  WidgetTester tester, {
  String username = 'owner',
  String password = 'secret',
}) async {
  await tester.enterText(field('Username'), username);
  await tester.enterText(field('Password'), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}
