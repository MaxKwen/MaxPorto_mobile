import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/models/project.dart';

/// Detail satu proyek dari API; gambar hanya tampil jika `thumbnail` diisi.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.thumbnail.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  project.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // URL rusak tidak membuat layar error.
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 120,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(project.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(label: Text(project.category)),
            const SizedBox(height: 12),
            Text(project.description, style: textTheme.bodyLarge),
            if (project.projectUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Project URL', style: textTheme.titleSmall),
              SelectableText(project.projectUrl),
            ],
          ],
        ),
      ),
    );
  }
}
