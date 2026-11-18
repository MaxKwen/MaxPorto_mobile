/// Aturan validasi form Experience, mengikuti model `Experience` di Django
/// (MaxPorto). Dipisah dari widget agar mudah dibaca dan diuji sendiri.
///
/// Setiap fungsi mengembalikan pesan error, atau `null` jika valid, sesuai
/// kontrak `validator` pada `TextFormField`.
class ExperienceValidators {
  ExperienceValidators._();

  /// Batas `max_length` field `CharField` pada model.
  static const int maxTitleLength = 255;
  static const int maxOrganizationLength = 255;

  /// Rentang tahun yang sama dengan `ExperienceForm` di Django.
  static const int minYear = 1900;
  static const int maxYear = 2100;

  /// Field teks wajib: tolak kosong/spasi saja dan batasi panjangnya.
  static String? requiredText(String? value, String fieldName, {int? max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$fieldName tidak boleh kosong!';
    }
    if (max != null && text.length > max) {
      return '$fieldName maksimal $max karakter.';
    }
    return null;
  }

  /// Tahun mulai: wajib, angka, dan di dalam rentang model.
  static String? startYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Tahun mulai tidak boleh kosong!';
    }
    return _yearRange(text);
  }

  /// Tahun selesai: dilewati jika pengalaman masih berjalan
  /// (`end_year = null` di model); jika diisi, tidak boleh sebelum tahun mulai.
  static String? endYear(
    String? value, {
    required bool isOngoing,
    required String startYear,
  }) {
    if (isOngoing) return null;
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Isi tahun selesai atau aktifkan "Masih berjalan".';
    }
    final rangeError = _yearRange(text);
    if (rangeError != null) return rangeError;

    final start = int.tryParse(startYear.trim());
    if (start != null && int.parse(text) < start) {
      return 'Tahun selesai tidak boleh sebelum tahun mulai.';
    }
    return null;
  }

  static String? _yearRange(String text) {
    final year = int.tryParse(text);
    if (year == null) {
      return 'Tahun harus berupa angka.';
    }
    if (year < minYear || year > maxYear) {
      return 'Tahun harus di antara $minYear dan $maxYear.';
    }
    return null;
  }
}
