import 'package:flutter/material.dart';

/// Kartu identitas pemilik portofolio, misalnya NPM, nama, atau kelas.
class InfoCard extends StatelessWidget {
  /// Judul kartu yang ditampilkan tebal, misalnya `NPM`.
  final String title;

  /// Isi kartu di bawah judul.
  final String content;

  /// Jika `true`, isi tidak dipatah ke baris baru, melainkan diperkecil agar
  /// muat. Cocok untuk angka seperti NPM yang tidak boleh terpotong.
  final bool singleLine;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      // Lebar kartu ditentukan induknya (Expanded di MyHomePage).
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        // Menyusun teks title dan content secara vertikal di tengah kartu.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            if (singleLine)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(content, maxLines: 1, softWrap: false),
              )
            else
              Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
