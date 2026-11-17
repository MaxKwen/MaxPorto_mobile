import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maxporto_mobile/main.dart';
import 'package:maxporto_mobile/screens/menu.dart';
import 'package:maxporto_mobile/screens/project_form.dart';
import 'package:maxporto_mobile/widgets/left_drawer.dart';
import 'package:maxporto_mobile/widgets/project_card.dart';

/// Ukuran layar ponsel (logical pixel) agar tata letak sama seperti di perangkat.
const Size phoneSize = Size(412, 915);

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
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

/// Navigator milik halaman yang sedang tampil, untuk memeriksa isi stack.
NavigatorState navigatorOf(WidgetTester tester, Finder page) {
  return Navigator.of(tester.element(page));
}

Future<void> openFormFromMenu(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ItemCard, 'Tambah Project'));
  await tester.pumpAndSettle();
}

/// Hint dan label "Nama Proyek" sama, jadi ambil satu teks saja agar field
/// yang sama tidak terhitung dua kali.
Finder field(String label) => find.ancestor(
  of: find.text(label).first,
  matching: find.byType(TextFormField),
);

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  group('LeftDrawer', () {
    testWidgets('home page drawer shows header and both routes', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawer(tester);

      expect(find.byType(LeftDrawer), findsOneWidget);
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ListTile, 'Home'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Add Project'), findsOneWidget);
    });

    testWidgets('Add Project replaces the menu instead of stacking on it', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      // pushReplacement: tidak ada halaman menu di bawah form.
      expect(
        navigatorOf(tester, find.byType(ProjectFormPage)).canPop(),
        isFalse,
      );
    });

    testWidgets('Home on the form drawer returns to the menu', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
      await tester.pumpAndSettle();

      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('Tambah Project button', () {
    testWidgets('pushes the form on top of the menu, Back returns', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromMenu(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);
      // push: menu masih ada di bawah form sehingga bisa kembali.
      final navigator = navigatorOf(tester, find.byType(ProjectFormPage));
      expect(navigator.canPop(), isTrue);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('other buttons stay on the menu', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(ItemCard, 'Lihat Projects'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('ProjectFormPage', () {
    testWidgets('has all inputs, the drawer, and the default category', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromMenu(tester);

      expect(field('Nama Proyek'), findsOneWidget);
      expect(field('Deskripsi Proyek'), findsOneWidget);
      expect(field('Teknologi yang Digunakan'), findsOneWidget);
      expect(field('Tautan Proyek'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Web Development'), findsWidgets);
      expect(find.text('Save'), findsOneWidget);

      await openDrawer(tester);
      expect(find.byType(LeftDrawer), findsOneWidget);
    });

    testWidgets('empty required fields show errors and no dialog', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromMenu(tester);
      await tapSave(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('whitespace-only input is rejected', (tester) async {
      await pumpApp(tester);
      await openFormFromMenu(tester);
      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.enterText(field('Deskripsi Proyek'), 'Ada isinya');
      await tapSave(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('valid form shows every value in the dialog, OK resets', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromMenu(tester);

      await tester.enterText(field('Nama Proyek'), 'TempoBIS');
      await tester.enterText(field('Deskripsi Proyek'), 'Pengenal BISINDO');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Machine Learning').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        field('Teknologi yang Digunakan'),
        'Python, MediaPipe',
      );
      await tester.enterText(field('Tautan Proyek'), 'https://example.com');
      await tapSave(tester);

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      for (final line in [
        'Nama Proyek: TempoBIS',
        'Deskripsi: Pengenal BISINDO',
        'Kategori: Machine Learning',
        'Teknologi: Python, MediaPipe',
        'Tautan: https://example.com',
      ]) {
        expect(
          find.descendant(of: dialog, matching: find.text(line)),
          findsOneWidget,
        );
      }

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      // Form di-reset: isian teks kembali kosong, form tetap tampil.
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('TempoBIS'), findsNothing);
      expect(find.text('Pengenal BISINDO'), findsNothing);
    });
  });
}
