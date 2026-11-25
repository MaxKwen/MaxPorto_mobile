import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:maxporto_mobile/screens/login_screen.dart';
import 'package:maxporto_mobile/screens/menu.dart';
import 'package:maxporto_mobile/screens/project_form.dart';
import 'package:maxporto_mobile/widgets/left_drawer.dart';
import 'package:maxporto_mobile/widgets/project_card.dart';

import 'support/fake_backend.dart';

/// Navigator milik halaman yang sedang tampil, untuk memeriksa isi stack.
NavigatorState navigatorOf(WidgetTester tester, Finder page) {
  return Navigator.of(tester.element(page));
}

Future<void> tapCard(WidgetTester tester, String name) async {
  final card = find.widgetWithText(ItemCard, name);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

/// Login lewat kartu Tambah Project sehingga form terbuka dengan token aktif.
Future<FakeBackend> openFormLoggedIn(WidgetTester tester) async {
  final backend = await pumpApp(tester);
  await tapCard(tester, 'Tambah Project');
  await submitLogin(tester);
  return backend;
}

Future<void> fillValidProject(WidgetTester tester) async {
  await tester.enterText(field('Title'), ' TempoBIS ');
  await tester.enterText(field('Description'), 'Pengenal BISINDO');
  await tester.enterText(field('Tech Stack'), 'Python, MediaPipe');
  await tester.enterText(field('Project URL'), 'https://example.com/tempobis');
}

void main() {
  group('LeftDrawer', () {
    testWidgets('header, semua rute, dan opsi Login saat tamu', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);

      expect(find.byType(LeftDrawer), findsOneWidget);
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      for (final label in [
        'Home',
        'Projects',
        'Add Project',
        'Add Experience',
        'Login',
      ]) {
        expect(
          find.widgetWithText(ListTile, label),
          findsOneWidget,
          reason: label,
        );
      }
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
    });

    testWidgets('Add Project tanpa login membuka LoginScreen', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('setelah login, Add Project menggantikan menu dengan form', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
      await tester.pumpAndSettle();
      await submitLogin(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      // pushReplacement: tidak ada halaman menu di bawah form.
      expect(
        navigatorOf(tester, find.byType(ProjectFormPage)).canPop(),
        isFalse,
      );
    });

    testWidgets('drawer menampilkan Logout setelah login, lalu Login lagi', (
      tester,
    ) async {
      final backend = await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Login'));
      await tester.pumpAndSettle();
      await submitLogin(tester);

      // LoginScreen di-pop dengan hasil true; drawer kembali terlihat.
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah logout.'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(backend.activeToken, isNull);
      expect(
        backend.requests.last.url.path,
        '/api/v1/auth/logout/',
        reason: 'logout harus mencabut token di server',
      );
    });

    testWidgets('Home dari drawer form kembali ke menu', (tester) async {
      await openFormLoggedIn(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('Kartu Tambah Project', () {
    testWidgets('login lalu push form di atas menu, Back kembali', (
      tester,
    ) async {
      await openFormLoggedIn(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);
      // push: menu masih ada di bawah form sehingga bisa kembali.
      final navigator = navigatorOf(tester, find.byType(ProjectFormPage));
      expect(navigator.canPop(), isTrue);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('sudah login: kartu langsung membuka form', (tester) async {
      await openFormLoggedIn(tester);
      navigatorOf(tester, find.byType(ProjectFormPage)).pop();
      await tester.pumpAndSettle();

      await tapCard(tester, 'Tambah Project');
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets('Back dari LoginScreen membatalkan dan tetap di menu', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Tambah Project');
      navigatorOf(tester, find.byType(LoginScreen)).pop();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('ProjectFormPage', () {
    testWidgets('field mengikuti ProjectSerializer', (tester) async {
      await openFormLoggedIn(tester);

      for (final label in [
        'Title',
        'Description',
        'Tech Stack',
        'Project URL',
        'Project Image URL (Optional)',
      ]) {
        expect(field(label), findsOneWidget, reason: label);
      }
      expect(find.text('Save'), findsOneWidget);
      await openDrawer(tester);
      expect(find.byType(LeftDrawer), findsOneWidget);
    });

    testWidgets('isian wajib kosong/spasi ditolak tanpa request', (
      tester,
    ) async {
      final backend = await openFormLoggedIn(tester);
      final before = backend.requests.length;
      await tester.enterText(field('Title'), '   ');
      await tapSave(tester);

      expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Description tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tech Stack tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(backend.requests.length, before);
    });

    testWidgets('URL tidak valid ditolak', (tester) async {
      await openFormLoggedIn(tester);
      await fillValidProject(tester);
      await tester.enterText(field('Project URL'), 'github.com/tanpa-skema');
      await tester.enterText(
        field('Project Image URL (Optional)'),
        'ftp://x.com/a.png',
      );
      await tapSave(tester);

      expect(
        find.text('Masukkan URL yang valid (diawali http:// atau https://).'),
        findsNWidgets(2),
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('input valid dikirim dengan token, dialog setelah 201', (
      tester,
    ) async {
      final backend = await openFormLoggedIn(tester);
      await fillValidProject(tester);
      await tapSave(tester);

      final request = backend.requests.last;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/projects/');
      expect(
        request.headers['Authorization'],
        'Token ${FakeBackend.validToken}',
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      // id dibuat server, jadi tidak ikut dikirim; nilai sudah di-trim.
      expect(body, {
        'title': 'TempoBIS',
        'description': 'Pengenal BISINDO',
        'category': 'Python, MediaPipe',
        'project_url': 'https://example.com/tempobis',
        'thumbnail': '',
      });

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('ID: 2')),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('token dicabut di server: logout lalu minta login ulang', (
      tester,
    ) async {
      final backend = await openFormLoggedIn(tester);
      backend.activeToken = 'token-lain'; // token aplikasi jadi tidak valid
      await fillValidProject(tester);
      await tapSave(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sesi berakhir, silakan login ulang.'), findsOneWidget);
    });
  });
}
