import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/screens/login_screen.dart';
import 'package:maxporto_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Ensures the user is authenticated, pushing [LoginScreen] when needed.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  // LoginScreen mengembalikan true lewat Navigator.pop setelah login berhasil;
  // tombol Back mengembalikan null.
  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return loggedIn ?? false;
}
