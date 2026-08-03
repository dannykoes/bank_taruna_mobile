# API Contract Bank Taruna Mobile

Dokumen ini menjelaskan kontrak API yang dipakai aplikasi. Endpoint dapat disesuaikan dengan backend website.

## 1. Berita

### Request

```http
GET https://banktaruna.com/wp-json/wp/v2/posts?per_page=10&_embed=1
Accept: application/json
```

### Mapping

| App Field | Source Field |
|---|---|
| id | id |
| title | title.rendered |
| excerpt | excerpt.rendered |
| content | content.rendered |
| date | date |
| link | link |
| imageUrl | jetpack_featured_media_url atau _embedded.wp:featuredmedia[0].source_url |

## 2. Pengajuan Kredit

### Request rekomendasi produksi

```http
POST https://banktaruna.com/api/mobile/pengajuan-kredit
Content-Type: application/json
Accept: application/json
```

### Payload

```json
{
  "nama_lengkap": "Budi Santoso",
  "no_ktp": "3322xxxxxxxxxxxx",
  "no_handphone": "081234567890",
  "email": "budi@email.com",
  "pekerjaan": "Karyawan Swasta",
  "penghasilan_bulan": "5000000",
  "alamat_lengkap": "Kudus",
  "jenis_kredit": "KREDIT MULTIGUNA",
  "jumlah_kredit": "50000000",
  "jangka_waktu": "24 Bulan",
  "tujuan_kredit": "Modal usaha",
  "source": "mobile_app"
}
```

### Response sukses

```json
{
  "success": true,
  "message": "Pengajuan berhasil diterima",
  "reference_number": "BT-2026-0001"
}
```

### Response gagal

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "email": ["Email tidak valid"]
  }
}
```

## 3. Banner

Jika backend sudah punya endpoint banner, gunakan pola:

```http
GET https://banktaruna.com/api/mobile/banners
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "title": "Bank Taruna Mobile",
      "subtitle": "Akses layanan dari genggaman Anda",
      "image_url": "https://banktaruna.com/path/banner.jpg",
      "cta": "Ajukan Kredit",
      "target": "loan_application"
    }
  ]
}
```
