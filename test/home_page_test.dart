import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maxporto_mobile/main.dart';
import 'package:maxporto_mobile/menu.dart';
import 'package:maxporto_mobile/models/item_homepage.dart';
import 'package:maxporto_mobile/widgets/info_card.dart';
import 'package:maxporto_mobile/widgets/item_card.dart';

/// Ukuran layar ponsel (logical pixel) agar tata letak sama seperti di perangkat.
const Size phoneSize = Size(412, 915);

const List<String> expectedActions = [
  'Lihat Experience',
  'Lihat Projects',
  'Lihat Achievements',
  'Tambah Experience',
  'Tambah Achievement',
  'Logout',
];

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
}

void main() {
  testWidgets('home page is a StatelessWidget with the app bar title', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.widget(find.byType(MyHomePage)), isA<StatelessWidget>());
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('three InfoCards show the owner identity, not Burhan', (
    tester,
  ) async {
    await pumpApp(tester);

    final cards = tester.widgetList<InfoCard>(find.byType(InfoCard)).toList();
    expect(cards.map((card) => card.title), ['NPM', 'Name', 'Class']);
    expect(cards.map((card) => card.content), [
      '2506613552',
      'Maximus Quinn Hertada',
      'PBP B',
    ]);
    expect(cards.first.singleLine, isTrue);
    expect(find.text('Burhan'), findsNothing);
    expect(find.text('2406000001'), findsNothing);
  });

  testWidgets('six action buttons appear in order with icons', (tester) async {
    await pumpApp(tester);

    final items = tester
        .widgetList<ItemCard>(find.byType(ItemCard))
        .map((card) => card.item)
        .toList();
    expect(items.map((item) => item.name), expectedActions);
    for (final item in items) {
      expect(
        find.descendant(
          of: find.widgetWithText(ItemCard, item.name),
          matching: find.byIcon(item.icon),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('every action button uses its own background color', (
    tester,
  ) async {
    await pumpApp(tester);

    final colors = <Color>[];
    for (final name in expectedActions) {
      final card = find.widgetWithText(ItemCard, name);
      final material = tester.widget<Material>(
        find.descendant(of: card, matching: find.byType(Material)).first,
      );
      // Warna latar kartu harus sama dengan warna di model, bukan warna tema.
      expect(material.color, tester.widget<ItemCard>(card).item.color);
      colors.add(material.color!);
    }
    expect(colors.toSet(), hasLength(expectedActions.length));
  });

  testWidgets('tapping each button shows a matching SnackBar', (tester) async {
    await pumpApp(tester);

    for (final name in expectedActions) {
      await tester.tap(find.widgetWithText(ItemCard, name));
      // Tunggu animasi SnackBar lama keluar dan SnackBar baru masuk.
      await tester.pumpAndSettle();
      // hideCurrentSnackBar memastikan hanya pesan terbaru yang tampil.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });

  testWidgets('layout fits phone and tablet sizes without overflow', (
    tester,
  ) async {
    final cases = <Size, int>{
      Size(320, 568): 2, // ponsel kecil
      Size(360, 640): 2,
      Size(412, 915): 2,
      Size(1024, 768): 3, // tablet landscape
    };
    for (final entry in cases.entries) {
      tester.view.physicalSize = entry.key;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      // Overflow akan tercatat sebagai exception dan menggagalkan test.
      expect(tester.takeException(), isNull, reason: '${entry.key}');
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, entry.value, reason: '${entry.key}');
    }
    tester.view.reset();
  });

  testWidgets('ItemCard renders any ItemHomepage on its own', (tester) async {
    final item = ItemHomepage('Coba', Icons.star, Colors.pink);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ItemCard(item))));

    expect(find.text('Coba'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    await tester.tap(find.byType(ItemCard));
    await tester.pump();
    expect(find.text('Kamu telah menekan tombol Coba!'), findsOneWidget);
  });
}
