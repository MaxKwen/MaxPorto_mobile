import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/models/project.dart';
import 'package:maxporto_mobile/services/api_client.dart';
import 'package:maxporto_mobile/services/auth_state.dart';
import 'package:maxporto_mobile/widgets/auth_guard.dart';
import 'package:maxporto_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman form untuk menambahkan proyek baru ke portofolio.
///
/// Field mengikuti `ProjectSerializer` MaxPorto. Tombol Save mengirim POST
/// `/api/v1/projects/` dengan token; dialog konfirmasi muncul setelah
/// server menjawab 201 Created.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  /// Batas `max_length` pada model Project Django.
  static const int maxTitleLength = 255;
  static const int maxCategoryLength = 100;

  /// Isian wajib: tolak kosong/spasi saja dan batasi panjangnya.
  static String? validateRequired(String? value, String label, {int? max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return "$label tidak boleh kosong!";
    if (max != null && text.length > max) {
      return "$label maksimal $max karakter.";
    }
    return null;
  }

  /// URL kosong boleh (`URLField(blank=True)`); jika diisi harus http/https.
  static String? validateOptionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return "Masukkan URL yang valid (diawali http:// atau https://).";
    }
    return null;
  }

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _description = "";
  String _category = "";
  String _projectUrl = "";
  String _thumbnail = "";
  bool _isSubmitting = false;

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context) || !mounted) return;

    final token = context.read<AuthState>().token!;
    final newProject = Project(
      title: _title.trim(),
      description: _description.trim(),
      category: _category.trim(),
      projectUrl: _projectUrl.trim(),
      thumbnail: _thumbnail.trim(),
    );

    setState(() => _isSubmitting = true);
    Project? created;
    try {
      created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isAuthError) {
        // Token kedaluwarsa/dicabut: akhiri sesi lalu minta login ulang.
        await context.read<AuthState>().logout();
        if (!mounted) return;
        _showSnackBar("Sesi berakhir, silakan login ulang.");
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _showSnackBar("Akun ini tidak punya izin menambah proyek.");
      } else {
        _showSnackBar("Gagal menyimpan proyek (status ${e.statusCode}).");
      }
    } catch (_) {
      // Server mati, CORS, atau jaringan bermasalah.
      if (mounted) _showSnackBar("Tidak dapat terhubung ke server.");
    } finally {
      // Reset sebelum dialog tampil agar spinner tidak berputar di baliknya.
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (created != null && mounted) await _showCreatedDialog(created);
  }

  Future<void> _showCreatedDialog(Project project) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${project.id}'),
                Text('Title: ${project.title}'),
                Text('Description: ${project.description}'),
                Text('Tech Stack: ${project.category}'),
                Text('Project URL: ${project.projectUrl}'),
                Text('Image URL: ${project.thumbnail}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Ruang bawah ekstra agar Save tidak tertutup SnackBar.
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration("Title"),
                  onChanged: (value) => _title = value,
                  validator: (value) => ProjectFormPage.validateRequired(
                    value,
                    "Title",
                    max: ProjectFormPage.maxTitleLength,
                  ),
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration("Description"),
                  onChanged: (value) => _description = value,
                  validator: (value) =>
                      ProjectFormPage.validateRequired(value, "Description"),
                ),
              ),

              // === Tech Stack (field `category` di Django) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Tech Stack",
                    hint: "Contoh: Flutter, Django",
                  ),
                  onChanged: (value) => _category = value,
                  validator: (value) => ProjectFormPage.validateRequired(
                    value,
                    "Tech Stack",
                    max: ProjectFormPage.maxCategoryLength,
                  ),
                ),
              ),

              // === Project URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Project URL",
                    hint: "https://github.com/...",
                  ),
                  onChanged: (value) => _projectUrl = value,
                  validator: ProjectFormPage.validateOptionalUrl,
                ),
              ),

              // === Project Image URL (field `thumbnail` di Django) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Project Image URL (Optional)",
                    hint: "https://.../image.png",
                  ),
                  onChanged: (value) => _thumbnail = value,
                  validator: ProjectFormPage.validateOptionalUrl,
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
