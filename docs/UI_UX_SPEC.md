# UI/UX Specification

## Visual Direction

- Dominan merah dan biru untuk mencerminkan identitas bank yang tegas dan terpercaya.
- Material 3, rounded card, clean spacing, dan high contrast agar mudah dibaca nasabah.
- Bottom navigation berisi lima menu utama: Beranda, Simulasi, Pengajuan, Berita, Profil.

## UX Flow

### Beranda

1. User melihat identitas bank dan banner utama.
2. User dapat langsung masuk ke simulasi kredit, pengajuan, berita, atau WhatsApp.
3. Produk utama ditampilkan sebagai card: Kredit, Deposito, Tabungan.
4. Berita terbaru tampil di bawah produk.

### Simulasi Kredit

1. User input plafon, tenor, bunga, dan tipe angsuran.
2. Sistem menghitung estimasi angsuran bulanan, total pembayaran, dan total bunga.
3. Ada disclaimer bahwa hasil hanya estimasi.

### Pengajuan Kredit

1. User mengisi data pemohon.
2. User memilih jenis kredit dan tenor.
3. User mengirim data ke endpoint resmi website.
4. App hanya menampilkan sukses jika endpoint mengembalikan JSON tervalidasi.

### Berita

1. App mengambil berita dari API website.
2. Jika API belum tersedia, app menampilkan fallback agar UI tetap bisa diuji.
3. Detail berita dapat dibuka dan user bisa lanjut ke website resmi.

### Profil

1. User membaca visi, misi, dan nilai layanan.
2. User dapat menghubungi bank lewat telepon, WhatsApp, email, atau website.
