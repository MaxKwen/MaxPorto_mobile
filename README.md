# MaxPorto Mobile

Aplikasi mobile Flutter untuk portofolio pribadi **Maximus Quinn Hertada**
(NPM 2506613552, PBP B). Aplikasi ini adalah pendamping mobile dari website
Django [MaxPorto](https://github.com/MaxKwen/MaxPorto) dan disimpan di
repositori terpisah.

## Fitur

- Tiga `InfoCard` di bagian atas berisi NPM, nama, dan kelas.
- Enam tombol aksi (`ItemCard`) yang mengikuti bagian portofolio MaxPorto:
  Lihat Experience, Lihat Projects, Lihat Achievements, Tambah Experience,
  Tambah Achievement, dan Logout.
- Setiap tombol memiliki warna latar sendiri yang disimpan di model
  `ItemHomepage`, sehingga tidak ada percabangan `if-else` untuk pewarnaan.
- Menekan tombol memunculkan SnackBar `Kamu telah menekan tombol <nama>!`.
  SnackBar sebelumnya disembunyikan terlebih dahulu agar pesan tidak menumpuk.
- Tata letak responsif: grid 2 kolom di ponsel (lebar < 480 px) dan 3 kolom di
  tablet/desktop, halaman dapat di-scroll, dan NPM tidak terpotong di layar
  sempit.

## Menjalankan proyek

```bash
flutter pub get
flutter run -d chrome      # atau pilih emulator Android
flutter analyze            # No issues found!
flutter test               # 7 widget test
```

## Struktur proyek

```text
lib/
├── main.dart                 # bootstrap: runApp, MaterialApp, dan tema
├── menu.dart                 # MyHomePage (StatelessWidget): identitas dan daftar tombol
├── models/
│   └── item_homepage.dart    # ItemHomepage(name, icon, color)
└── widgets/
    ├── info_card.dart        # InfoCard
    └── item_card.dart        # ItemCard + SnackBar
test/
└── home_page_test.dart       # widget test halaman utama
```

## Pertanyaan reflektif

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, seluruh antarmuka disusun dari widget yang saling bersarang
   sehingga membentuk pohon (*widget tree*). Setiap widget menerima widget lain
   lewat properti seperti `child` atau `children`. Widget induk menentukan
   **constraint** (batas lebar dan tinggi minimum/maksimum) untuk anaknya, anak
   memilih ukurannya sendiri di dalam batas itu, lalu induk menentukan posisi
   anak. Aturan ini sering diringkas sebagai *constraints go down, sizes go up,
   parent sets position*.

   Di aplikasi ini, `MaterialApp` → `MyHomePage` → `Scaffold` →
   `SingleChildScrollView` → `Column`. `Column` itu berisi baris `InfoCard` dan
   `GridView` berisi `ItemCard`. Contoh nyatanya: `Expanded` di dalam `Row`
   membagi lebar layar rata ke tiga `InfoCard`, sehingga kartu tidak lagi
   menghitung lebarnya sendiri. Data juga mengalir dari induk ke anak, misalnya
   `MyHomePage` mengirim objek `ItemHomepage` ke setiap `ItemCard` lewat
   konstruktor. Selain itu, widget anak dapat mencari data dari leluhurnya
   melalui `BuildContext`, seperti `Theme.of(context)` dan
   `ScaffoldMessenger.of(context)`.

2. **Widget yang digunakan**

   | Widget | Fungsi di proyek ini |
   | --- | --- |
   | `MaterialApp` | Root aplikasi: judul, tema Material 3, dan halaman awal. |
   | `MyApp` | Widget buatan sendiri (`StatelessWidget`) yang membungkus `MaterialApp`. |
   | `MyHomePage` | Halaman utama (`StatelessWidget`) berisi identitas dan menu. |
   | `Scaffold` | Kerangka halaman Material: `appBar`, `body`, dan tempat SnackBar. |
   | `AppBar` | Bar atas berjudul "MyPortfolio" dengan warna primer tema. |
   | `SingleChildScrollView` | Membuat isi halaman dapat di-scroll di layar pendek. |
   | `Column` | Menyusun anak secara vertikal (halaman, isi kartu, isi tombol). |
   | `Row` | Menyusun tiga `InfoCard` secara horizontal. |
   | `IntrinsicHeight` | Menyamakan tinggi ketiga `InfoCard` mengikuti yang paling tinggi. |
   | `Expanded` | Membagi lebar `Row` secara rata ke setiap `InfoCard`. |
   | `InfoCard` | Widget buatan sendiri untuk menampilkan judul dan isi identitas. |
   | `Card` | Permukaan Material dengan bayangan (`elevation`) untuk `InfoCard`. |
   | `Container` | Memberi padding di dalam kartu dan tombol. |
   | `Padding` | Memberi jarak di sekitar teks sambutan dan antara ikon dan label. |
   | `SizedBox` | Memberi jarak kosong dengan ukuran tetap. |
   | `Center` | Menempatkan anak di tengah area yang tersedia. |
   | `Text` | Menampilkan teks (judul, identitas, sambutan, label tombol). |
   | `FittedBox` | Mengecilkan NPM agar tetap satu baris di layar sempit. |
   | `GridView.count` | Menampilkan tombol aksi dalam kisi 2 atau 3 kolom. |
   | `ItemCard` | Widget buatan sendiri untuk satu tombol aksi berwarna. |
   | `Material` | Memberi warna latar dan sudut membulat pada `ItemCard`, serta permukaan untuk efek riak. |
   | `InkWell` | Mendeteksi ketukan (`onTap`) dan menampilkan efek riak. |
   | `Icon` | Menampilkan ikon tombol. |
   | `ScaffoldMessenger` | Menampilkan dan menyembunyikan SnackBar milik `Scaffold` terdekat. |
   | `SnackBar` | Pesan singkat di bagian bawah layar saat tombol ditekan. |

   `ItemHomepage` bukan widget, melainkan model data (nama, ikon, warna) untuk
   setiap tombol. `ThemeData` dan `ColorScheme` juga bukan widget, melainkan
   objek konfigurasi tema yang dipakai `MaterialApp`.

3. **Fungsi `MaterialApp` dan alasan dipakai sebagai root**

   `MaterialApp` menyiapkan semua yang dibutuhkan aplikasi bergaya Material
   Design: tema (`ThemeData`) yang dapat dibaca widget di bawahnya, navigasi
   (`Navigator` dan route, termasuk `home`), lokalisasi, arah teks, judul
   aplikasi, serta `ScaffoldMessenger` tingkat aplikasi. Banyak widget Material
   seperti `Scaffold`, `AppBar`, `Card`, `InkWell`, dan `SnackBar` bergantung
   pada leluhur-leluhur tersebut. Tanpa `MaterialApp`, misalnya, `Text` tidak
   memiliki arah teks dan gaya default, sementara `ScaffoldMessenger.of(context)`
   tidak menemukan messenger. Karena itu `MaterialApp` diletakkan paling atas
   agar seluruh widget tree mewarisi konfigurasi yang sama. Di proyek ini,
   `MaterialApp` mengatur judul "MyPortfolio", skema warna indigo dengan
   Material 3, dan `MyHomePage` sebagai halaman awal.

4. **`StatelessWidget` vs `StatefulWidget`**

   `StatelessWidget` tidak memiliki state internal yang dapat berubah. Tampilannya
   hanya bergantung pada konfigurasi dari konstruktor dan data yang diwarisi
   (misalnya tema), dan ia dibangun ulang hanya ketika induknya membangun ulang
   dengan konfigurasi baru atau data warisan tersebut berubah.
   `StatefulWidget` dipasangkan dengan objek `State` yang bertahan selama widget
   ada di tree. Ketika data di dalamnya berubah, `setState()` menandai widget
   untuk dibangun ulang. `State` juga menyediakan siklus hidup seperti
   `initState` dan `dispose`.

   Pilih `StatelessWidget` jika tampilan murni ditentukan oleh input, seperti
   `InfoCard`, `ItemCard`, dan `MyHomePage` pada tugas ini: identitas dan daftar
   tombol tidak berubah selama aplikasi berjalan, dan SnackBar ditampilkan oleh
   `ScaffoldMessenger`, bukan oleh state milik kartu. Pilih `StatefulWidget` jika
   widget harus mengingat data yang berubah karena interaksi atau waktu, seperti
   counter, isian form, checkbox, hasil fetch dari API, animasi, atau controller
   yang perlu di-`dispose`.

5. **`BuildContext`**

   `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree
   (secara teknis, ia adalah `Element` milik widget tersebut). Setiap metode
   `build(BuildContext context)` menerima context miliknya sendiri. Context ini
   penting karena menjadi jalan bagi widget untuk mencari data dan layanan dari
   leluhurnya melalui pola `X.of(context)`.

   Di proyek ini:
   - `Theme.of(context).colorScheme.primary` dipakai di `MyHomePage` untuk warna
     `AppBar`.
   - `MediaQuery.sizeOf(context).width` dipakai untuk memilih grid 2 atau 3
     kolom.
   - `ScaffoldMessenger.of(context)` dipakai di `ItemCard` untuk menampilkan
     SnackBar.

   Karena pencarian dimulai dari posisi context ke atas, context yang dipakai
   harus berada **di bawah** widget yang dicari. Contohnya,
   `ScaffoldMessenger.of(context)` bekerja di `ItemCard` karena kartu tersebut
   berada di bawah `MaterialApp` dan `Scaffold`. Memakai context milik widget
   yang berada di atas `MaterialApp` tidak akan menemukan messenger tersebut.

6. **Hot reload vs hot restart**

   **Hot reload** menyuntikkan kode Dart yang berubah ke Dart VM yang sedang
   berjalan, lalu Flutter membangun ulang widget tree. State aplikasi tetap
   dipertahankan, sehingga cocok untuk mencoba perubahan tampilan dengan cepat,
   misalnya mengganti warna tombol atau teks di `build`.
   **Hot restart** juga memuat kode baru, tetapi membuang seluruh state dan
   menjalankan ulang aplikasi dari `main()`. Prosesnya lebih lambat daripada hot
   reload, tetapi masih lebih cepat daripada kompilasi ulang penuh.

   Hot reload tidak cukup jika perubahan tidak dijalankan ulang oleh proses
   rebuild, misalnya perubahan di `main()` atau `initState()`, initializer
   variabel global/static, mengubah sebuah class menjadi enum (atau sebaliknya),
   mengubah parameter generik, atau mengubah widget dari Stateless menjadi
   Stateful. Untuk kasus tersebut gunakan hot restart. **Full restart**
   (menghentikan dan menjalankan ulang `flutter run`) diperlukan jika perubahan
   menyentuh bagian native atau konfigurasi build, seperti menambah plugin atau
   dependency di `pubspec.yaml`, mengubah kode Android/iOS, atau mengubah
   konfigurasi Gradle.

## AI disclosure

### Cara AI digunakan

Saya menggunakan Hermes Agent sebagai asisten pengembangan lokal untuk Tugas 7.
AI membantu membaca PDF Tutorial 08 dan Tugas 7, menyusun checklist dari rubrik,
dan mengimplementasikan perubahan secara bertahap. Setiap tahap dikerjakan di
branch terpisah (`feature/action-menu`, `refactor/widget-structure`,
`test/home-widgets`), lalu saya tinjau, commit, merge, dan push sendiri.

Bagian yang dibantu AI:
- Mengganti data contoh Burhan dengan identitas saya dan menyusun enam tombol
  aksi yang mengikuti bagian Experience, Projects, dan Achievements di MaxPorto.
- Menambahkan atribut `color` pada `ItemHomepage` dan memisahkan model serta
  widget ke `lib/models/` dan `lib/widgets/` beserta komentar/docstring.
- Menulis 7 widget test di `test/home_page_test.dart`.
- Menemukan dan memperbaiki tata letak yang rusak di layar ponsel sempit.
- Menyusun draf jawaban pertanyaan reflektif dan README ini.

Strategi yang dipakai: AI diminta bekerja per tahap kecil dengan pemeriksaan di
setiap tahap (`flutter analyze`, `flutter test`, dan screenshot hasil
`flutter build web` di Chrome headless dengan emulasi lebar 320, 360, 412, dan
800 px). Untuk refactor, screenshot sebelum dan sesudah dibandingkan untuk
memastikan tampilan tidak berubah.

### Chat history

Percakapan pengembangan Tutorial 08 dan Tugas 7 tersedia pada
[`20261112_tutorial-8-and-tugas-7-development.md`](ai-chat-history/20261112_tutorial-8-and-tugas-7-development.md).
File ini adalah potongan dari satu sesi Hermes Agent, mulai 10 November 2026
hingga snapshot 12 November 2026, dan berisi 201 pesan (15 pesan dari saya),
diekspor dengan redaksi otomatis. Bagian awal sesi tentang Tutorial 7 dan Tugas 6
sudah diarsipkan di repositori MaxPorto. Snapshot diambil sebelum README ini
selesai ditinjau. Jumlah pesan, cakupan, dan checksum SHA-256 dicatat dalam
[`manifest.jsonl`](ai-chat-history/manifest.jsonl).

### Keterbatasan AI dan perbaikan manual

- Test pertama dijalankan dengan ukuran layar lebar, sehingga tidak mendeteksi
  bahwa grid 3 kolom memotong kata "Achievements" dan memecah NPM menjadi dua
  baris di ponsel. Masalah ini baru terlihat setelah hasil build diperiksa
  secara visual di ukuran ponsel, lalu diperbaiki dan dikunci dengan test lintas
  ukuran layar. Lolos test tidak berarti tampilan sudah benar.
- Perbaikan pertama untuk kartu identitas masih membuat `Row` overflow di layar
  320 px. Hasil test menunjukkan error tersebut sehingga pendekatannya diganti
  dengan `Expanded`.
- AI tidak bisa menjadi sumber kebenaran untuk data pribadi; NPM, nama, kelas,
  dan pilihan menu saya verifikasi sendiri.
- Draf jawaban reflektif saya baca ulang dan sesuaikan dengan pemahaman saya
  sebelum di-commit.
