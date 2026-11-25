import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:maxporto_mobile/main.dart';
import 'package:maxporto_mobile/screens/experience_form.dart';
import 'package:maxporto_mobile/screens/menu.dart';
import 'package:maxporto_mobile/widgets/left_drawer.dart';
import 'package:maxporto_mobile/widgets/project_card.dart';

import 'support/fake_backend.dart' show FakeBackend;

/// Ukuran layar ponsel (logical pixel) agar tata letak sama seperti di perangkat.
const Size phoneSize = Size(412, 915);

Future<void> pumpApp(WidgetTester tester, {Size size = phoneSize}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));
}

Future<void> openDrawer(WidgetTester tester) async {
  // Font test jauh lebih lebar dari Roboto; perkecil skala teks agar header
  // drawer tidak overflow hanya di lingkungan test.
  tester.platformDispatcher.textScaleFactorTestValue = 0.5;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> openFormFromCard(WidgetTester tester) async {
  final card = find.widgetWithText(ItemCard, 'Tambah Experience');
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> openFormFromDrawer(WidgetTester tester) async {
  await openDrawer(tester);
  await tester.tap(find.widgetWithText(ListTile, 'Add Experience'));
  await tester.pumpAndSettle();
}

/// Label dan hint bisa sama, jadi ambil satu teks agar field tidak dobel.
Finder field(String label) => find.ancestor(
  of: find.text(label).first,
  matching: find.byType(TextFormField),
);

/// Nilai yang sedang tersimpan di field (bukan hint/label).
String fieldValue(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(of: field(label), matching: find.byType(EditableText)),
    )
    .controller
    .text;

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

Future<void> fillValid(WidgetTester tester) async {
  await tester.enterText(field('Posisi'), 'Teaching Assistant');
  await tester.enterText(field('Organisasi'), 'Fasilkom UI');
  await tester.enterText(field('Deskripsi'), 'Asisten dosen PSD');
  await tester.enterText(field('Tahun Mulai'), '2025');
  await tester.enterText(field('Tahun Selesai'), '2026');
}

void main() {
  group('Akses formulir', () {
    testWidgets('kartu aksi memakai push sehingga bisa kembali ke menu', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromCard(tester);

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Add Experience Form'), findsOneWidget);
      final navigator = Navigator.of(
        tester.element(find.byType(ExperienceFormPage)),
      );
      // push: menu masih ada di bawah form (setara tombol Back perangkat).
      expect(navigator.canPop(), isTrue);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('drawer mempertahankan Home dan Add Project', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);

      for (final label in ['Home', 'Add Project', 'Add Experience']) {
        expect(
          find.widgetWithText(ListTile, label),
          findsOneWidget,
          reason: label,
        );
      }
    });

    testWidgets('drawer membuka form dengan pushReplacement', (tester) async {
      await pumpApp(tester);
      await openFormFromDrawer(tester);

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(ExperienceFormPage))).canPop(),
        isFalse,
      );
    });

    testWidgets('form memakai drawer yang sama dan Home kembali ke menu', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromDrawer(tester);

      await openDrawer(tester);
      expect(find.byType(LeftDrawer), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });
  });

  group('Validasi', () {
    testWidgets('isian kosong menampilkan error di setiap kolom wajib', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await tapSave(tester);

      for (final message in [
        'Posisi tidak boleh kosong!',
        'Organisasi tidak boleh kosong!',
        'Deskripsi tidak boleh kosong!',
        'Tahun mulai tidak boleh kosong!',
        'Isi tahun selesai atau aktifkan "Masih berjalan".',
      ]) {
        expect(find.text(message), findsOneWidget, reason: message);
      }
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('isian berisi spasi saja ditolak', (tester) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await fillValid(tester);
      await tester.enterText(field('Organisasi'), '    ');
      await tapSave(tester);

      expect(find.text('Organisasi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Posisi tidak boleh kosong!'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tahun selesai sebelum tahun mulai ditolak', (tester) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await fillValid(tester);
      await tester.enterText(field('Tahun Selesai'), '2024');
      await tapSave(tester);

      expect(
        find.text('Tahun selesai tidak boleh sebelum tahun mulai.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tahun di luar rentang model ditolak', (tester) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await fillValid(tester);
      await tester.enterText(field('Tahun Mulai'), '1800');
      await tapSave(tester);

      expect(find.text('Tahun harus di antara 1900 dan 2100.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('input tahun hanya menerima maksimal 4 digit', (tester) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await tester.enterText(field('Tahun Mulai'), '20ab2599');
      await tester.pump();

      expect(fieldValue(tester, 'Tahun Mulai'), '2025');
    });
  });

  group('Simpan dan dialog ringkasan', () {
    testWidgets('input valid menampilkan semua isian, OK mereset form', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await fillValid(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Organization').last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
      for (final line in [
        'Posisi: Teaching Assistant',
        'Organisasi: Fasilkom UI',
        'Deskripsi: Asisten dosen PSD',
        'Kategori: Organization',
        'Periode: 2025 - 2026',
      ]) {
        expect(
          find.descendant(of: dialog, matching: find.text(line)),
          findsOneWidget,
          reason: line,
        );
      }

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Dialog tertutup, pengguna tetap di form dan isian kembali kosong.
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(fieldValue(tester, 'Posisi'), isEmpty);
      expect(fieldValue(tester, 'Tahun Selesai'), isEmpty);
    });

    testWidgets('masih berjalan mengosongkan tahun selesai dan periode', (
      tester,
    ) async {
      await pumpApp(tester);
      await openFormFromCard(tester);
      await fillValid(tester);
      await tester.ensureVisible(find.text('Masih berjalan'));
      await tester.tap(find.text('Masih berjalan'));
      await tester.pumpAndSettle();

      expect(fieldValue(tester, 'Tahun Selesai'), isEmpty);
      await tapSave(tester);
      expect(find.text('Periode: 2025 - Sekarang'), findsOneWidget);
    });
  });

  for (final size in const [Size(320, 568), Size(360, 640)]) {
    testWidgets('tombol Simpan terjangkau di layar ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpApp(tester, size: size);
      await openFormFromCard(tester);
      await fillValid(tester);
      // SnackBar dari kartu masih tampil dan menutupi bagian bawah layar.
      expect(find.byType(SnackBar), findsOneWidget);
      await tapSave(tester);

      // Overflow dilaporkan sebagai exception; dialog membuktikan Simpan
      // bisa digulir ke layar dan ditekan.
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  }
}
