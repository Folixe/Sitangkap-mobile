# Laporan DFile: Sitangkap App (Mobile + Web)

## 1. Gambaran Umum

- Nama proyek: `sitangkap_app`
- Platform target: Android, iOS, Web, Windows, macOS, Linux
- Teknologi: Flutter
- Root project: `c:\dani\MObile\Sitangkap-mobile`


## 2. Struktur Utama

- `lib/main.dart`
  - Titik masuk aplikasi Flutter
  - Menjalankan `SitangkapApp` dengan `AuthWrapper`

- `lib/screens/`
  - `auth_wrapper.dart` — menentukan apakah user sudah login dan memutuskan halaman awal
  - `home_tab.dart` — tampilan dashboard dan ringkasan tangkapan bulan ini
  - `input_catch_screen.dart` — form input tangkapan dengan foto dan berat
  - `history_tab.dart` — riwayat tangkapan, tampilan semua entry
  - `login_screen.dart`, `register_screen.dart`, `profile_tab.dart`, `edit_profile_screen.dart` — fungsi otentikasi dan profil

- `lib/services/api_service.dart`
  - Layanan HTTP untuk login, register, profil, ambil data referensi, tangkapan, update profil
  - Menangani upload foto multipart untuk submit tangkapan
  - Mendukung fallback API untuk emulator Android (`10.0.2.2`)

- `lib/services/socket_service.dart`
  - Layanan WebSocket untuk real-time update
  - Aplikasi mendengarkan event seperti `catch_created` dan `catches_updated`

- `lib/widgets/` dan `lib/screens/camera_screen.dart`
  - Komponen UI tambahan, painter custom, dan kamera


## 3. Fitur Utama Aplikasi

### Mobile / Web Umum

- Login dan registrasi pengguna nelayan
- Dashboard menampilkan:
  - Nama nelayan
  - Kelompok nelayan
  - Total tangkapan bulan ini
  - Aktivitas terakhir
- Input tangkapan baru:
  - Pilih tanggal melaut
  - Pilih jenis ikan utama
  - Masukkan berat (kg)
  - Ambil foto dari kamera atau galeri
- Riwayat tangkapan:
  - Menampilkan semua tangkapan dalam format daftar
  - Status verifikasi: `PENDING` atau `TERVERIFIKASI`

### Real-time dan Update Data

- `home_tab.dart` dan `history_tab.dart` memiliki:
  - polling data setiap 10 detik
  - koneksi WebSocket untuk menerima event perubahan
- Pemrosesan event WebSocket memicu refresh data otomatis
- Setelah input berhasil, halaman kembali dan melakukan fetch ulang data


## 4. Integrasi Backend

### Endpoint API utama

- `GET /reference-data` — data dropdown jenis ikan
- `POST /nelayan/register` — registrasi user
- `POST /nelayan/login` — login dan simpan token
- `GET /nelayan/profile` — ambil profil nelayan
- `PUT /nelayan/profile/update` — update profil
- `GET /nelayan/catches` — ambil data tangkapan
- `POST /nelayan/catches/store` — submit tangkapan baru dengan foto

### Autentikasi dan token

- Token disimpan di `SharedPreferences` dengan key `auth_token`
- Semua permintaan yang butuh token mengirim header `Authorization: Bearer <token>`


## 5. Perbedaan Mobile vs Web

- Aplikasi dasar sama untuk mobile dan web karena berbasis Flutter satu kode
- Pada web, penggunaan kamera/galeri mungkin berbeda dan bergantung pada browser
- `api_service.dart` sudah menggunakan `http` yang kompatibel web
- `SocketService` dibuat dengan `web_socket_channel`, mendukung web dan desktop


## 6. Dependensi Utama

- `flutter` SDK
- `http` — request API
- `shared_preferences` — simpan session token
- `image_picker` — ambil foto kamera/galeri
- `intl` — format tanggal
- `provider` — state management bila digunakan
- `http_parser` — tipe konten upload foto
- `web_socket_channel` — WebSocket real-time
- `camera` — dukungan kamera mobile
- `path` — manipulasi nama file


## 7. Cara Menjalankan

### Mobile / Desktop

1. Buka terminal di root proyek:
   ```powershell
   cd C:\dani\MObile\Sitangkap-mobile
   flutter pub get
   flutter run
   ```

2. Pilih target device / emulator yang tersedia

### Web

1. Pastikan Chrome atau browser lain tersedia
2. Jalankan:
   ```powershell
   flutter run -d chrome
   ```


## 8. Catatan Kunci dan Rekomendasi

- Aplikasi sudah mendukung real-time dengan WebSocket, tetapi backend harus mengirim event JSON yang sesuai.
- Untuk pengujian Android emulator, endpoint API lokal harus mencapai `10.0.2.2:8000`.
- Jika menggunakan perangkat fisik, ganti `baseUrl` ke IP lokal mesin dev.
- Perlu verifikasi bahwa backend menerima field multipart dengan nama `foto` dan return JSON terstruktur.


## 9. Hal yang Perlu Dicek

- Endpoint WebSocket (`ws://127.0.0.1:6000/ws`) harus aktif jika mau real-time penuh
- Format respons API harus cocok dengan `status` dan struktur `catches`
- Pada web, upload foto berfungsi hanya jika server mendukung multipart melalui browser


## 10. Kesimpulan

Proyek ini adalah aplikasi Flutter full stack yang mendukung mobile dan web dengan satu basis kode. Laporan ini menunjukkan bahwa arsitektur sudah mencakup:
- login/registrasi
- input dan upload tangkapan
- tampilan history
- refresh data otomatis
- integrasi backend API + WebSocket

Untuk peluncuran, fokuskan pada konfigurasi backend lokal dan validasi endpoint real-time.
