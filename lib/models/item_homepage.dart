import 'package:flutter/material.dart';

/// Data satu tombol aksi di halaman utama.
///
/// Warna disimpan di model, sehingga [ItemCard] cukup membaca [color]
/// tanpa percabangan if-else per tombol.
class ItemHomepage {
  /// Label tombol; juga dipakai pada pesan SnackBar.
  final String name;

  /// Ikon yang ditampilkan di atas label.
  final IconData icon;

  /// Warna latar kartu tombol.
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
