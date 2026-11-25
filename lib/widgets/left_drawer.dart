import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/screens/experience_form.dart';
import 'package:maxporto_mobile/screens/menu.dart';
import 'package:maxporto_mobile/screens/project_form.dart';
import 'package:maxporto_mobile/screens/project_list_screen.dart';
import 'package:maxporto_mobile/services/auth_state.dart';
import 'package:maxporto_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Drawer navigasi yang dipakai bersama oleh halaman utama dan halaman form.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: drawer dibangun ulang saat login/logout sehingga opsi
    // Login/Logout selalu sesuai state.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // pushReplacement mengganti halaman teratas, sehingga berpindah
            // lewat drawer tidak menumpuk halaman di stack Navigator.
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Projects'),
            // Daftar proyek publik, tidak perlu login.
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Aksi terproteksi: minta login dulu jika belum.
            onTap: () async {
              if (!await ensureLoggedIn(context) || !context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceFormPage(),
                ),
              );
            },
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthState>().logout();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Kamu telah logout.')),
                  );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => ensureLoggedIn(context),
            ),
        ],
      ),
    );
  }
}
