# Bank Taruna Mobile

Aplikasi mobile company profile **PT. BPR Taruna Adidaya Santosa** berbasis Flutter/Dart dengan UI modern, dominan merah-biru, responsive, dan struktur clean code.

## Fitur utama

- Beranda modern dengan banner, shortcut layanan, produk utama, berita terbaru.
- Simulasi kredit dengan metode **Flat** dan **Anuitas**.
- Form pengajuan kredit sesuai struktur form website Bank Taruna.
- Berita/informasi terbaru yang mencoba mengambil data dari API website.
- Profil, visi misi, nilai layanan, kontak telepon, WhatsApp, email, dan tombol website resmi.
- Responsive layout: nyaman untuk mobile kecil, tablet, dan desktop preview.
- Layer API terpisah agar endpoint website mudah diganti tanpa membongkar UI.

## Sumber website yang dijadikan acuan

Website: `https://banktaruna.com`

Rute publik yang dipakai sebagai dasar fitur:

- `/` untuk beranda dan banner.
- `/simulasi-kredit` untuk simulasi kredit.
- `/pengajuanonline` untuk daftar layanan pengajuan.
- `/formpengajuankredit` untuk struktur field pengajuan kredit.
- `/informasi` untuk daftar berita.
- `/visimisi` untuk profil, visi, dan misi.

## Cara menjalankan

> Folder ini berisi source code Flutter. Untuk membuat folder platform Android/iOS, jalankan `flutter create .` di dalam folder project.

```bash
cd bank_taruna_mobile
flutter create .
flutter pub get
flutter run
```

Build Android release:

```bash
flutter build apk --release
```

Build App Bundle untuk Play Store:

```bash
flutter build appbundle --release
```

## Konfigurasi API

Ubah konfigurasi di:

```dart
lib/core/constants/app_constants.dart
lib/core/constants/api_endpoints.dart
```

Default base URL:

```dart
static const String baseUrl = 'https://banktaruna.com';
```

Endpoint berita saat ini diarahkan ke pola WordPress REST API:

```dart
/wp-json/wp/v2/posts?per_page=...&_embed=1
```

Jika website Bank Taruna menggunakan custom backend selain WordPress, cukup ganti `ApiEndpoints.wpPosts` dan mapping di `NewsRepository`.

## Catatan penting pengajuan kredit

Website publik menampilkan form kredit di `/formpengajuankredit`, tetapi endpoint submit JSON produksi tidak terlihat dari teks halaman publik. Karena itu repository pengajuan kredit dibuat aman:

- Tidak memalsukan sukses jika server hanya mengembalikan HTML.
- Mengharuskan respons JSON tervalidasi untuk dianggap sukses.
- Mudah diganti ke endpoint produksi, misalnya `/api/pengajuan/kredit`.

Ubah ini di:

```dart
static const String loanApplicationSubmit = '/formpengajuankredit';
```

Rekomendasi endpoint produksi:

```http
POST /api/mobile/pengajuan-kredit
Content-Type: application/json
```

Payload yang dikirim aplikasi:

```json
{
  "nama_lengkap": "...",
  "no_ktp": "...",
  "no_handphone": "...",
  "email": "...",
  "pekerjaan": "...",
  "penghasilan_bulan": "...",
  "alamat_lengkap": "...",
  "jenis_kredit": "...",
  "jumlah_kredit": "...",
  "jangka_waktu": "...",
  "tujuan_kredit": "...",
  "source": "mobile_app"
}
```

Respons sukses yang disarankan:

```json
{
  "success": true,
  "message": "Pengajuan berhasil diterima",
  "reference_number": "BT-2026-0001"
}
```

## Struktur folder

```text
lib/
  app.dart
  main.dart
  core/
    constants/
    network/
    theme/
    utils/
    widgets/
  features/
    applications/
    home/
    news/
    profile/
    simulation/
  shared/
    models/
```

## Rekomendasi sebelum rilis produksi

1. Pastikan endpoint submit pengajuan kredit resmi tersedia dan mengembalikan JSON.
2. Tambahkan OTP/email verification untuk mencegah spam dan data palsu.
3. Tambahkan consent pemrosesan data pribadi sesuai kebutuhan kepatuhan internal.
4. Tambahkan certificate pinning bila kebijakan keamanan bank mewajibkan.
5. Lakukan penetration test dan validasi server-side semua field.
6. Siapkan privacy policy dan terms di halaman aplikasi.

