import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:maxporto_mobile/validators/experience_validators.dart';
import 'package:maxporto_mobile/widgets/left_drawer.dart';

/// Halaman form untuk menambahkan pengalaman (Experience) ke portofolio.
///
/// Field mengikuti model `Experience` di Django MaxPorto: posisi, organisasi,
/// deskripsi, kategori, tahun mulai, dan tahun selesai (kosong = masih
/// berjalan). Data belum dikirim ke backend; setelah lolos validasi, isian
/// ditampilkan dalam dialog ringkasan.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// Controller dipakai agar tahun selesai bisa dikosongkan saat
  /// "Masih berjalan" diaktifkan.
  final _endYearController = TextEditingController();

  String _title = "";
  String _organization = "";
  String _description = "";
  String _category = "Teaching"; // default, sama dengan data di Django
  String _startYear = "";
  bool _isOngoing = false;

  final List<String> _categories = [
    'Teaching',
    'Organization',
    'Committee',
    'Internship',
    'Other',
  ];

  @override
  void dispose() {
    _endYearController.dispose();
    super.dispose();
  }

  /// Dekorasi seragam untuk semua input, sama seperti form Tutorial 09.
  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _onSave() {
    // validate() menjalankan semua validator; dialog hanya muncul jika lolos.
    if (!_formKey.currentState!.validate()) return;

    final period = _isOngoing
        ? '$_startYear - Sekarang'
        : '$_startYear - ${_endYearController.text.trim()}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Experience berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posisi: ${_title.trim()}'),
                Text('Organisasi: ${_organization.trim()}'),
                Text('Deskripsi: ${_description.trim()}'),
                Text('Kategori: $_category'),
                Text('Periode: $period'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  /// Kosongkan semua field dan kembalikan state ke nilai awal.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = "";
      _organization = "";
      _description = "";
      _category = _categories.first;
      _startYear = "";
      _isOngoing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Input tahun: keyboard angka, hanya digit, maksimal 4 karakter.
    final yearFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    return Scaffold(
      // AppBar memakai warna primer tema, sama dengan halaman utama.
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer yang sama dengan halaman utama dan form proyek.
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // Seluruh form dapat di-scroll, sehingga field dan tombol Simpan tetap
        // terjangkau di layar sempit atau saat keyboard muncul.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Posisi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Posisi",
                    hint: "Contoh: Teaching Assistant",
                  ),
                  maxLength: ExperienceValidators.maxTitleLength,
                  textInputAction: TextInputAction.next,
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (value) => ExperienceValidators.requiredText(
                    value,
                    "Posisi",
                    max: ExperienceValidators.maxTitleLength,
                  ),
                ),
              ),

              // === Organisasi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Organisasi",
                    hint: "Contoh: Universitas Indonesia",
                  ),
                  maxLength: ExperienceValidators.maxOrganizationLength,
                  textInputAction: TextInputAction.next,
                  onChanged: (String? value) {
                    setState(() {
                      _organization = value!;
                    });
                  },
                  validator: (value) => ExperienceValidators.requiredText(
                    value,
                    "Organisasi",
                    max: ExperienceValidators.maxOrganizationLength,
                  ),
                ),
              ),

              // === Deskripsi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: _decoration(
                    "Deskripsi",
                    hint: "Jelaskan peran dan kontribusimu",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (value) =>
                      ExperienceValidators.requiredText(value, "Deskripsi"),
                ),
              ),

              // === Kategori ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration("Kategori"),
                  initialValue: _category,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Masih berjalan ===
              // Model menyimpan end_year = null untuk pengalaman yang belum
              // selesai; switch ini mewakili kondisi tersebut.
              SwitchListTile(
                title: const Text('Masih berjalan'),
                value: _isOngoing,
                onChanged: (bool value) {
                  setState(() {
                    _isOngoing = value;
                    if (value) _endYearController.clear();
                  });
                },
              ),

              // === Tahun Mulai & Tahun Selesai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: _decoration("Tahun Mulai", hint: "2025"),
                        keyboardType: TextInputType.number,
                        inputFormatters: yearFormatters,
                        onChanged: (String? value) {
                          setState(() {
                            _startYear = value!;
                          });
                        },
                        validator: ExperienceValidators.startYear,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endYearController,
                        enabled: !_isOngoing,
                        decoration: _decoration(
                          "Tahun Selesai",
                          hint: _isOngoing ? "Sekarang" : "2026",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: yearFormatters,
                        validator: (value) => ExperienceValidators.endYear(
                          value,
                          isOngoing: _isOngoing,
                          startYear: _startYear,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // === Tombol Simpan ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _onSave,
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
