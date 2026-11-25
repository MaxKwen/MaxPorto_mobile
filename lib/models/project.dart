import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Field mengikuti `ProjectSerializer` MaxPorto (Tugas 6), bukan contoh
/// tutorial: `category` mengambil peran `tech_stack`, `thumbnail` mengambil
/// peran `project_image_url`, dan `id` berupa integer (bukan UUID).
/// Field lain dari API (`is_featured`, `star_count`, dll.) diabaikan.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.category,
    required this.projectUrl,
    this.thumbnail = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Dibuat oleh Django, jadi tidak ikut dikirim pada body POST.
  @JsonKey(includeToJson: false)
  final int? id;
  final String title;
  final String description;

  /// Kategori/teknologi proyek, misalnya "Django" atau "Flutter".
  final String category;

  /// URL proyek; boleh kosong karena `URLField(blank=True)` di model.
  @JsonKey(defaultValue: '')
  final String projectUrl;

  /// URL gambar proyek; boleh kosong atau tidak dikirim.
  @JsonKey(defaultValue: '')
  final String thumbnail;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
