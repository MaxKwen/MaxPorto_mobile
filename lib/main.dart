import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/screens/menu.dart';
import 'package:maxporto_mobile/services/api_client.dart';
import 'package:maxporto_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  /// Diterima dari luar agar test bisa menyuntikkan ApiClient dengan
  /// http MockClient.
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    // MultiProvider menyisipkan ApiClient dan AuthState ke widget tree,
    // sehingga layar mana pun bisa memakai context.read/watch.
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(apiClient)),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}
