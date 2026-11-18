# MaxPorto Mobile

Aplikasi mobile Flutter untuk portofolio pribadi **Maximus Quinn Hertada**
(NPM 2506613552, PBP B). Aplikasi ini adalah pendamping mobile dari website
Django [MaxPorto](https://github.com/MaxKwen/MaxPorto) dan disimpan di
repositori terpisah.

## Fitur

### Halaman utama (Tugas 7)

- Tiga `InfoCard` di bagian atas berisi NPM, nama, dan kelas.
- Tujuh tombol aksi (`ItemCard`) yang mengikuti bagian portofolio MaxPorto:
  Lihat Experience, Lihat Projects, Lihat Achievements, Tambah Experience,
  Tambah Project, Tambah Achievement, dan Logout.
- Setiap tombol memiliki warna latar sendiri yang disimpan di model
  `ItemHomepage`, sehingga tidak ada percabangan `if-else` untuk pewarnaan.
- Menekan tombol memunculkan SnackBar `Kamu telah menekan tombol <nama>!`.
  SnackBar sebelumnya disembunyikan terlebih dahulu agar pesan tidak menumpuk.
- Tata letak responsif: grid 2 kolom di ponsel (lebar < 480 px) dan 3 kolom di
  tablet/desktop, halaman dapat di-scroll, dan NPM tidak terpotong di layar
  sempit.

### Navigasi dan formulir (Tutorial 09 dan Tugas 8)

- `LeftDrawer` dipakai bersama oleh halaman utama, form proyek, dan form
  experience. Isinya Home, Add Project, dan Add Experience.
- Kartu **Tambah Project** dan **Tambah Experience** membuka form dengan
  `Navigator.push`, sehingga tombol Back perangkat/browser kembali ke menu.
- **Form Experience** (`ExperienceFormPage`) mengikuti model `Experience` di
  Django MaxPorto: posisi, organisasi, deskripsi, kategori, tahun mulai, dan
  tahun selesai, ditambah switch **Masih berjalan** (setara `end_year = null`).
- Validasi mengikuti aturan model: isian wajib tidak boleh kosong atau hanya
  spasi, posisi/organisasi maksimal 255 karakter, tahun berupa angka 1900-2100,
  dan tahun selesai tidak boleh sebelum tahun mulai. Input tahun memakai
  keyboard angka dan hanya menerima maksimal 4 digit.
- Tombol **Simpan** memanggil `validate()`; jika semua valid, dialog ringkasan
  menampilkan seluruh isian, dan tombol **OK** menutup dialog serta mereset form.
- Form dapat di-scroll dan memiliki ruang bawah ekstra, sehingga tombol Simpan
  tetap terjangkau di layar 320 px, saat keyboard tampil, atau saat SnackBar
  dari kartu aksi masih terlihat.

## Menjalankan proyek

```bash
flutter pub get
flutter run -d chrome      # atau pilih emulator Android
flutter analyze            # No issues found!
flutter test               # 38 test (widget + unit)
```

Proyek memakai paket `material_ui` (`import 'package:material_ui/material_ui.dart';`)
sesuai Tutorial 09, sehingga `flutter pub get` wajib dijalankan setelah clone.

Pengujian manual Tugas 8 di Chrome:

1. Buka form dari kartu **Tambah Experience**, lalu tekan Back di browser.
2. Buka form dari drawer **Add Experience**, lalu pilih **Home** di drawer.
3. Kosongkan salah satu isian wajib dan tekan **Simpan**: pesan error muncul di
   kolom terkait.
4. Lengkapi isian, tekan **Simpan**, dan periksa isi dialog.
5. Ulangi dengan DevTools mode perangkat selebar ponsel (misalnya 360 px).

## Struktur proyek

```text
lib/
├── main.dart                        # bootstrap: runApp, MaterialApp, dan tema
├── models/
│   └── item_homepage.dart           # ItemHomepage(name, icon, color)
├── screens/
│   ├── menu.dart                    # MyHomePage: identitas dan tombol aksi
│   ├── project_form.dart            # ProjectFormPage (Tutorial 09)
│   └── experience_form.dart         # ExperienceFormPage (Tugas 8)
├── validators/
│   └── experience_validators.dart   # aturan validasi form Experience
└── widgets/
    ├── info_card.dart               # InfoCard
    ├── left_drawer.dart             # LeftDrawer: Home, Add Project, Add Experience
    └── project_card.dart            # ItemCard: SnackBar + navigasi ke form
test/
├── home_page_test.dart              # halaman utama, warna, SnackBar, responsif
├── navigation_form_test.dart        # drawer dan form proyek (Tutorial 09)
├── experience_form_test.dart        # akses, validasi, dialog form Experience
└── experience_validators_test.dart  # unit test aturan validasi
```

## Progres mingguan

| Minggu | Isi | Branch |
| --- | --- | --- |
| Tutorial 08 | Halaman menu, `InfoCard`, `ItemCard`, SnackBar | `main` |
| Tugas 7 | Identitas sendiri, warna per tombol, refactor model/widget, widget test, layout responsif | `feature/action-menu`, `refactor/widget-structure`, `test/home-widgets`, `docs/readme-tugas-7` |
| Tutorial 09 | Drawer, form proyek, navigasi kartu, struktur `screens/` dan `widgets/`, `material_ui` | `main` |
| Tugas 8 | Form Experience, navigasi kartu dan drawer, test akses/validasi, README | `feature/experience-form`, `feature/experience-navigation`, `test/experience-form`, `docs/readme-tugas-8` |

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

### Tugas 8

1. **`Navigator.push()`, `pushReplacement()`, dan `pop()`**

   `Navigator` menyimpan halaman (route) sebagai tumpukan (*stack*).
   - `push()` menaruh route baru di atas stack. Halaman lama tetap ada di
     bawahnya, sehingga pengguna bisa kembali dengan tombol Back.
   - `pushReplacement()` mengganti route teratas dengan route baru. Halaman lama
     dibuang dari stack, sehingga Back tidak kembali ke halaman itu.
   - `pop()` membuang route teratas dan kembali ke route di bawahnya. Dialog
     juga merupakan route, sehingga tombol **OK** di dialog ringkasan memakai
     `Navigator.pop(context)` untuk menutup dialog dan kembali ke form.

   Kartu **Tambah Experience** di `ItemCard` (`lib/widgets/project_card.dart`)
   memakai `Navigator.push()`. Stack menjadi `[menu, form]`, sehingga tombol
   Back perangkat atau browser kembali ke menu. Opsi drawer (Home, Add Project,
   Add Experience) di `LeftDrawer` memakai `Navigator.pushReplacement()`, sama
   seperti Tutorial 09. Jika form dibuka dari drawer, stack `[menu]` menjadi
   `[form]`, lalu opsi **Home** mengganti form dengan `MyHomePage` baru sehingga
   stack kembali `[menu]`.

   Ada satu konsekuensi yang saya periksa dengan test: jika form dibuka dari
   kartu (`push`) lalu pengguna memilih **Home** di drawer, `pushReplacement`
   hanya mengganti form. Stack menjadi `[menu lama, menu baru]`, sehingga Back
   masih bisa kembali ke menu lama. Pengguna tetap sampai di halaman utama,
   tetapi stack tidak sepenuhnya bersih. Cara yang lebih rapi adalah
   `Navigator.pushAndRemoveUntil(...)` yang membuang semua route sebelumnya.
   Saya tetap memakai pola Tutorial 09 dan mencatat ini sebagai keterbatasan.

2. **Struktur `Scaffold`, `AppBar`, dan `Drawer`**

   `Scaffold` menyediakan slot standar untuk satu halaman: `appBar` di atas,
   `drawer` di samping, `body` untuk isi, serta tempat SnackBar di bawah. Karena
   halaman utama, form proyek, dan form experience semuanya memakai `Scaffold`
   dengan `AppBar` dan `drawer: const LeftDrawer()`, posisi judul, tombol
   hamburger, dan menu navigasi selalu sama di setiap halaman. Drawer juga
   ditulis sekali di `lib/widgets/left_drawer.dart` lalu dipakai ulang, sehingga
   menambah opsi Add Experience cukup dilakukan di satu tempat.

   Contoh warna tema: `main.dart` mengatur `ColorScheme.fromSeed(seedColor:
   Colors.indigo)`. `MyHomePage` dan `ExperienceFormPage` sama-sama memakai
   `Theme.of(context).colorScheme.primary` untuk warna `AppBar` dengan judul dan
   ikon putih, dan tombol **Simpan** di form experience juga memakai warna yang
   sama. Jika warna tema diganti di `main.dart`, kedua halaman ikut berubah.
   Sebaliknya, `ProjectFormPage` dan header drawer dari Tutorial 09 masih
   memakai `Colors.indigo` langsung, sehingga tidak akan ikut berubah.

3. **Tata letak formulir**

   Form experience disusun sebagai `Form` → `SingleChildScrollView` → `Column`.
   Setiap input dibungkus `Padding` agar ada jarak yang seragam, dan `Column`
   memakai `CrossAxisAlignment.stretch` agar semua input dan tombol **Simpan**
   selebar layar. Tahun mulai dan tahun selesai diletakkan berdampingan dalam
   `Row` dengan dua `Expanded` dan `SizedBox(width: 12)` di antaranya, karena
   keduanya pendek dan saling berkaitan sebagai satu periode.

   Widget pengatur jarak (`Padding`, `SizedBox`) membuat input tidak saling
   menempel dan tetap mudah disentuh. Widget penggulir (`SingleChildScrollView`)
   penting karena `Column` tidak bisa di-scroll sendiri. Di layar 320 px, atau
   saat keyboard muncul dan `Scaffold` memperkecil area `body`, isi form lebih
   tinggi daripada layar. Tanpa penggulir, form akan overflow dan tombol Simpan
   tidak bisa dijangkau. Saat menulis test, saya juga menemukan bahwa SnackBar
   dari kartu aksi menutupi tombol Simpan di layar sempit. Karena itu
   `SingleChildScrollView` diberi padding bawah 80 px agar tombol bisa digulir
   ke atas SnackBar.

4. **`GlobalKey<FormState>`, `validator`, dan `validate()`**

   `GlobalKey<FormState>` dipasang pada `Form` sehingga kode di luar widget
   `Form`, misalnya `onPressed` tombol Simpan, bisa mengakses state form lewat
   `_formKey.currentState`. Setiap `TextFormField` punya `validator` yang
   mengembalikan pesan error, atau `null` jika isiannya valid. Aturan validator
   form experience dipisahkan ke `lib/validators/experience_validators.dart`.
   Saat Simpan ditekan, `_formKey.currentState!.validate()` menjalankan semua
   validator, menampilkan pesan error di bawah kolom yang salah, dan
   mengembalikan `true` hanya jika semuanya valid. Dialog ringkasan hanya
   dipanggil jika hasilnya `true`.

   Contoh nilai yang ditolak: tahun mulai `2025` dan tahun selesai `2024`.
   Kolom tahun sudah memakai `TextInputType.number` dan
   `FilteringTextInputFormatter.digitsOnly`, sehingga hanya angka yang bisa
   diketik. Namun keyboard dan formatter hanya menjamin bentuk karakter, bukan
   makna data. Keduanya tidak bisa memeriksa hubungan antar-kolom, rentang tahun
   (misalnya `1800`), atau isian yang hanya berisi spasi pada kolom teks. Jenis
   keyboard juga hanya petunjuk: di web atau desktop, pengguna tetap mengetik
   dengan keyboard fisik. Karena itu aturan seperti "tahun selesai tidak boleh
   sebelum tahun mulai" tetap harus diperiksa oleh validator.

## AI disclosure

### Cara AI digunakan

Saya menggunakan Hermes Agent (model Claude) sebagai asisten pengembangan lokal.
AI membaca PDF tutorial dan tugas dari folder kuliah saya, menyusun checklist
dari rubrik, lalu mengimplementasikan perubahan per tahap. Setiap tahap saya
tinjau, lalu saya sendiri yang commit, merge, dan push.

**Tugas 7** dikerjakan di branch `feature/action-menu`,
`refactor/widget-structure`, `test/home-widgets`, dan `docs/readme-tugas-7`.
Bagian yang dibantu AI:
- Mengganti data contoh Burhan dengan identitas saya dan menyusun tombol aksi
  yang mengikuti bagian Experience, Projects, dan Achievements di MaxPorto.
- Menambahkan atribut `color` pada `ItemHomepage` dan memisahkan model serta
  widget ke `lib/models/` dan `lib/widgets/` beserta komentar/docstring.
- Menulis widget test di `test/home_page_test.dart`.
- Menemukan dan memperbaiki tata letak yang rusak di layar ponsel sempit.
- Menyusun draf jawaban pertanyaan reflektif dan README.

**Tutorial 09** dikerjakan langsung di `main` atas keputusan saya. Kode
tutorial sudah saya kerjakan sebelum AI dilibatkan; AI memeriksa kesesuaiannya dengan PDF, menjalankan
`flutter pub add material_ui` dan mengganti import, serta memperbaiki test yang
gagal setelah tombol ketujuh dan drawer ditambahkan.

**Tugas 8** dikerjakan di branch `feature/experience-form`,
`feature/experience-navigation`, `test/experience-form`, dan
`docs/readme-tugas-8`. Saya meminta AI memilih bagian portofolio yang paling
cocok; AI memilih Experience karena modelnya memiliki batas panjang dan
pasangan tahun mulai/selesai yang bisa divalidasi urutannya. Saya memutuskan
memakai branch per fitur dan review per tahap. Bagian yang dibantu AI:
- `lib/screens/experience_form.dart` dan `lib/validators/experience_validators.dart`,
  dengan field dan aturan yang diturunkan dari model dan `ExperienceForm`
  Django MaxPorto.
- Navigasi dari kartu aksi dan opsi Add Experience di `LeftDrawer`.
- 22 test baru di `test/experience_form_test.dart` dan
  `test/experience_validators_test.dart`.
- Draf jawaban reflektif Tugas 8 dan pembaruan README ini.

Strategi yang dipakai: AI diminta membaca spesifikasi lebih dulu, mengusulkan
rencana tahap beserta pesan commit, lalu berhenti untuk review di setiap tahap.
Pemeriksaan di setiap tahap tidak hanya `flutter analyze` dan `flutter test`,
tetapi juga:
- screenshot hasil `flutter build web` di Chrome headless dengan lebar ponsel;
- probe test sekali pakai untuk membuktikan perilaku navigasi sebelum ditulis
  di README (misalnya isi stack setelah memilih Home);
- *mutation check*: bagian kode sengaja dirusak satu per satu (padding bawah
  form, cek urutan tahun, label drawer) untuk memastikan test benar-benar
  gagal, lalu kode dikembalikan.

### Chat history

| File | Cakupan |
| --- | --- |
| [`20261112_tutorial-8-and-tugas-7-development.md`](ai-chat-history/20261112_tutorial-8-and-tugas-7-development.md) | Tutorial 08 dan Tugas 7, 10-12 November 2026, 201 pesan (15 dari saya). Bagian awal sesi tentang Tutorial 7 dan Tugas 6 diarsipkan di repositori MaxPorto. |
| [`20261118_tutorial-9-and-tugas-8-development.md`](ai-chat-history/20261118_tutorial-9-and-tugas-8-development.md) | Tutorial 09 dan Tugas 8, 17-18 November 2026, 177 pesan (8 dari saya). Snapshot diambil sebelum README ini selesai ditinjau. |

Kedua file diekspor dengan redaksi otomatis. Jumlah pesan, cakupan, dan checksum
SHA-256 dicatat dalam [`manifest.jsonl`](ai-chat-history/manifest.jsonl).

### Keterbatasan AI dan perbaikan manual

Tugas 7:
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

Tutorial 09 dan Tugas 8:
- Test layar sempit untuk form experience awalnya gagal dan AI pertama kali
  menduga masalah validasi. Setelah ditelusuri, penyebabnya adalah bug UX
  nyata: SnackBar dari kartu aksi menutupi tombol Simpan di layar 320-360 px.
  Bug ini diperbaiki di commit `fix:` terpisah dan dikunci dengan test.
- Saat menyisipkan import, alat edit AI sempat mengganti baris import yang
  salah di `left_drawer.dart`. Kesalahan ini terlihat dari diff dan diperbaiki
  sebelum `flutter analyze` dijalankan, sehingga diff tetap perlu dibaca.
- Font bawaan test Flutter jauh lebih lebar daripada font asli, sehingga header
  drawer Tutorial 09 dilaporkan overflow hanya di test. Test drawer memakai skala
  teks 0,5 sebagai solusi. Akibatnya, test tidak memeriksa tata letak header
  yang sebenarnya; tampilannya saya periksa lewat screenshot dan `flutter run`.
- Opsi Home di drawer memakai `pushReplacement` sesuai tutorial, sehingga jika
  form dibuka dari kartu, menu lama masih tersisa di stack (lihat jawaban
  Tugas 8 nomor 1). Hal ini belum saya ubah.
- `ProjectFormPage` dan header drawer masih memakai `Colors.indigo` dari
  tutorial, belum warna tema.
- Draf jawaban reflektif saya baca ulang dan sesuaikan dengan pemahaman saya
  sebelum di-commit.
