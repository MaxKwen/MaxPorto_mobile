import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/models/item_homepage.dart';
import 'package:maxporto_mobile/screens/experience_form.dart';
import 'package:maxporto_mobile/screens/project_form.dart';
import 'package:maxporto_mobile/screens/project_list_screen.dart';
import 'package:maxporto_mobile/services/auth_state.dart';
import 'package:maxporto_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Kartu tombol aksi berwarna yang menampilkan SnackBar saat ditekan dan
/// membuka halaman yang sesuai untuk tombol yang sudah punya halaman.
class ItemCard extends StatelessWidget {
  /// Data tombol: label, ikon, dan warna latar.
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showSnackBar(BuildContext context, String message) {
    // clearSnackBars juga membuang antrean, sehingga hasil logout tidak
    // tertahan di belakang pesan umum "Kamu telah menekan tombol ...".
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _push(BuildContext context, Widget page) {
    // push menumpuk halaman di atas menu, sehingga tombol Back
    // sistem/browser kembali ke halaman menu.
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _onTap(BuildContext context) async {
    _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");

    switch (item.name) {
      case "Lihat Projects":
        _push(context, const ProjectListScreen());
      case "Tambah Project":
        // Aksi terproteksi: buka LoginScreen dulu jika belum login.
        if (await ensureLoggedIn(context) && context.mounted) {
          _push(context, const ProjectFormPage());
        }
      case "Tambah Experience":
        _push(context, const ExperienceFormPage());
      case "Logout":
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) {
          _showSnackBar(context, "Kamu belum login.");
          return;
        }
        await auth.logout();
        if (context.mounted) _showSnackBar(context, "Kamu telah logout.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Warna latar diambil dari model item.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
