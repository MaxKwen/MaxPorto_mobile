import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/models/project.dart';
import 'package:maxporto_mobile/screens/login_screen.dart';
import 'package:maxporto_mobile/screens/project_detail_screen.dart';
import 'package:maxporto_mobile/screens/project_list_screen.dart';
import 'package:maxporto_mobile/widgets/project_card.dart';

import 'support/fake_backend.dart';

Future<void> openProjectList(WidgetTester tester) async {
  final card = find.widgetWithText(ItemCard, 'Lihat Projects');
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  group('ProjectListScreen', () {
    testWidgets('tamu bisa melihat proyek dari API tanpa login', (
      tester,
    ) async {
      await pumpApp(tester);
      await openProjectList(tester);

      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('MaxPorto'), findsOneWidget);
      expect(find.textContaining('Django'), findsOneWidget);
    });

    testWidgets('loading menampilkan indikator sebelum data datang', (
      tester,
    ) async {
      final backend = FakeBackend()..projectsGate = Completer<void>();
      await pumpApp(tester, backend: backend);
      final card = find.widgetWithText(ItemCard, 'Lihat Projects');
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      // Respons ditahan; tunggu transisi halaman tanpa pumpAndSettle karena
      // indikator loading beranimasi terus.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      backend.projectsGate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('MaxPorto'), findsOneWidget);
    });

    testWidgets('daftar kosong menampilkan pesan', (tester) async {
      await pumpApp(tester, backend: FakeBackend(projects: []));
      await openProjectList(tester);

      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('error menampilkan Retry yang memuat ulang', (tester) async {
      final backend = FakeBackend(failProjects: true);
      await pumpApp(tester, backend: backend);
      await openProjectList(tester);

      expect(find.textContaining('Failed to load projects'), findsOneWidget);
      backend.failProjects = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('MaxPorto'), findsOneWidget);
    });

    testWidgets('tap proyek membuka detail', (tester) async {
      await pumpApp(tester);
      await openProjectList(tester);
      await tester.tap(find.text('MaxPorto'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('Website portofolio Django'), findsOneWidget);
      expect(find.text('https://github.com/MaxKwen/MaxPorto'), findsOneWidget);
    });
  });

  group('ProjectDetailScreen', () {
    Future<void> pumpDetail(WidgetTester tester, Project project) {
      return tester.pumpWidget(
        MaterialApp(home: ProjectDetailScreen(project: project)),
      );
    }

    testWidgets('tanpa thumbnail tidak ada widget gambar', (tester) async {
      await pumpDetail(tester, Project.fromJson(FakeBackend.sampleProject));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('dengan thumbnail menampilkan Image.network', (tester) async {
      await pumpDetail(
        tester,
        const Project(
          title: 'A',
          description: 'B',
          category: 'C',
          projectUrl: '',
          thumbnail: 'https://example.com/a.png',
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as NetworkImage).url, 'https://example.com/a.png');
      // URL kosong tidak memunculkan bagian Project URL.
      expect(find.text('Project URL'), findsNothing);
    });
  });

  group('LoginScreen', () {
    testWidgets('kolom kosong divalidasi', (tester) async {
      await pumpApp(tester);
      final card = find.widgetWithText(ItemCard, 'Tambah Project');
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
    });

    testWidgets('password salah menampilkan SnackBar dan tetap di login', (
      tester,
    ) async {
      await pumpApp(tester);
      final card = find.widgetWithText(ItemCard, 'Tambah Project');
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      await submitLogin(tester, password: 'salah');

      expect(find.text('Login gagal (status 400).'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  testWidgets('kartu Logout mengakhiri sesi', (tester) async {
    final backend = await pumpApp(tester);
    final add = find.widgetWithText(ItemCard, 'Tambah Project');
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    await submitLogin(tester);
    Navigator.of(tester.element(find.text('Add Project Form'))).pop();
    await tester.pumpAndSettle();

    final logout = find.widgetWithText(ItemCard, 'Logout');
    await tester.ensureVisible(logout);
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah logout.'), findsOneWidget);
    expect(backend.activeToken, isNull);
  });
}
