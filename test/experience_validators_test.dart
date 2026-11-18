import 'package:flutter_test/flutter_test.dart';
import 'package:maxporto_mobile/validators/experience_validators.dart';

void main() {
  group('requiredText', () {
    test('menolak null, kosong, dan spasi saja', () {
      for (final value in [null, '', '   ', '\n\t']) {
        expect(
          ExperienceValidators.requiredText(value, 'Posisi'),
          'Posisi tidak boleh kosong!',
          reason: 'input: ${value?.codeUnits}',
        );
      }
    });

    test('menerima teks dan memangkas spasi sebelum cek panjang', () {
      expect(ExperienceValidators.requiredText(' TA ', 'Posisi'), isNull);
      // 255 karakter + spasi di tepi tetap valid karena spasi dipangkas.
      final atLimit = ' ${'a' * 255} ';
      expect(
        ExperienceValidators.requiredText(atLimit, 'Posisi', max: 255),
        isNull,
      );
    });

    test('menolak teks melebihi batas max_length model', () {
      expect(
        ExperienceValidators.requiredText('a' * 256, 'Posisi', max: 255),
        'Posisi maksimal 255 karakter.',
      );
    });
  });

  group('startYear', () {
    test('wajib diisi', () {
      expect(
        ExperienceValidators.startYear(''),
        'Tahun mulai tidak boleh kosong!',
      );
    });

    test('harus angka di rentang 1900-2100', () {
      expect(
        ExperienceValidators.startYear('abc'),
        'Tahun harus berupa angka.',
      );
      expect(
        ExperienceValidators.startYear('1899'),
        'Tahun harus di antara 1900 dan 2100.',
      );
      expect(
        ExperienceValidators.startYear('2101'),
        'Tahun harus di antara 1900 dan 2100.',
      );
      expect(ExperienceValidators.startYear('1900'), isNull);
      expect(ExperienceValidators.startYear('2100'), isNull);
    });
  });

  group('endYear', () {
    test('dilewati saat pengalaman masih berjalan', () {
      expect(
        ExperienceValidators.endYear('', isOngoing: true, startYear: '2025'),
        isNull,
      );
    });

    test('wajib diisi jika tidak masih berjalan', () {
      expect(
        ExperienceValidators.endYear('', isOngoing: false, startYear: '2025'),
        'Isi tahun selesai atau aktifkan "Masih berjalan".',
      );
    });

    test('tidak boleh sebelum tahun mulai, boleh sama', () {
      expect(
        ExperienceValidators.endYear(
          '2024',
          isOngoing: false,
          startYear: '2025',
        ),
        'Tahun selesai tidak boleh sebelum tahun mulai.',
      );
      expect(
        ExperienceValidators.endYear(
          '2025',
          isOngoing: false,
          startYear: '2025',
        ),
        isNull,
      );
    });

    test('tetap cek rentang walau tahun mulai belum valid', () {
      expect(
        ExperienceValidators.endYear('3000', isOngoing: false, startYear: ''),
        'Tahun harus di antara 1900 dan 2100.',
      );
      expect(
        ExperienceValidators.endYear('2026', isOngoing: false, startYear: 'x'),
        isNull,
      );
    });
  });
}
