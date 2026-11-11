import 'package:flutter/material.dart';
import 'package:maxporto_mobile/models/item_homepage.dart';
import 'package:maxporto_mobile/widgets/info_card.dart';
import 'package:maxporto_mobile/widgets/item_card.dart';

/// Halaman utama: identitas pemilik dan menu aksi portofolio.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506613552";
  final String nama = "Maximus Quinn Hertada";
  final String kelas = "PBP B";

  final List<ItemHomepage> items = [
    // Menu mengikuti bagian portofolio MaxPorto; setiap tombol punya warna sendiri.
    ItemHomepage("Lihat Experience", Icons.work, Colors.blue.shade700),
    ItemHomepage("Lihat Projects", Icons.folder, Colors.deepPurple),
    ItemHomepage("Lihat Achievements", Icons.emoji_events, Colors.brown),
    ItemHomepage("Tambah Experience", Icons.add_circle, Colors.green.shade800),
    ItemHomepage("Tambah Achievement", Icons.add_task, Colors.teal.shade700),
    ItemHomepage("Logout", Icons.logout, Colors.red.shade700),
  ];

  /// Di bawah lebar ini (semua ponsel), grid memakai 2 kolom agar kata
  /// panjang seperti "Achievements" tidak terpotong; tablet/desktop tetap 3.
  static const double narrowScreenWidth = 480;

  @override
  Widget build(BuildContext context) {
    final int columns = MediaQuery.sizeOf(context).width < narrowScreenWidth
        ? 2
        : 3;

    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // Body dapat di-scroll agar tidak overflow pada layar pendek.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris 3 InfoCard: Expanded membagi lebar rata tanpa melebihi
            // layar, IntrinsicHeight + stretch menyamakan tinggi kartu.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InfoCard(
                      title: 'NPM',
                      content: npm,
                      singleLine: true,
                    ),
                  ),
                  Expanded(
                    child: InfoCard(title: 'Name', content: nama),
                  ),
                  Expanded(
                    child: InfoCard(title: 'Class', content: kelas),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // Grid tidak scroll sendiri; seluruh halaman yang di-scroll.
                  GridView.count(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: columns,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
