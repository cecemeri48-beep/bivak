# BIVAK — Barter Perlengkapan Gunung

Aplikasi web satu berkas (`index.html`) untuk barter perlengkapan gunung: pasang barang,
ajukan penawaran, negosiasi lewat pesan, sampai barter selesai. Data tersimpan di
perangkat (localStorage) dan tersinkron ke Supabase saat pengguna masuk.

- Situs: https://bivak-three.vercel.app/
- Bahasa antarmuka: Indonesia

## Struktur berkas

```
index.html      Seluruh aplikasi (HTML + CSS + JavaScript)
404.html        Halaman tidak ditemukan
favicon.svg     Ikon situs
robots.txt      Aturan perayap mesin pencari
assets/img/     Gambar yang dipakai aplikasi (logo, foto kategori, gambar bagikan)
assets/         Berkas logo & gambar sumber beresolusi penuh
SQL-BIVAK-...sql  Skema basis data Supabase
```

## Menjalankan secara lokal

Cukup jalankan server statis dari folder ini:

```bash
python3 -m http.server 8080
# buka http://localhost:8080
```

Membuka `index.html` langsung lewat `file://` juga bisa, tetapi login Google
tidak berfungsi karena Supabase membutuhkan asal (origin) berupa http/https.

## Menyiapkan Supabase

1. Buat proyek Supabase, lalu jalankan isi `SQL-BIVAK-listing-penawaran-chat.sql`
   di SQL Editor. Skrip itu membuat tabel `barter_profiles`, `barter_listings`,
   `barter_offers`, `barter_offer_items`, `barter_messages`, `barter_transactions`,
   `barter_reports` beserta kebijakan RLS-nya.
2. Buat bucket Storage bernama `barter-photos` (publik untuk dibaca).
3. Aktifkan penyedia Google di Authentication → Providers, lalu tambahkan domain
   situs ke Redirect URLs.
4. Sesuaikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di bagian atas skrip
   `index.html`.

> Kunci `anon` memang boleh terlihat publik, tetapi keamanan datanya sepenuhnya
> bergantung pada kebijakan RLS. Pastikan RLS aktif di semua tabel di atas
> sebelum situs dipakai orang banyak.

## Mode demo

Bila Supabase tidak dapat dijangkau (jaringan bermasalah, CDN terblokir, atau
konfigurasi belum diisi), aplikasi otomatis berpindah ke mode demo lokal setelah
beberapa detik dan tetap dapat dipakai dengan data contoh.

## Deploy

Proyek ini statis, jadi cukup diunggah apa adanya.

```bash
vercel deploy --prod
```

Pastikan folder `assets/` turut terunggah, karena gambar sekarang berupa berkas
terpisah, bukan lagi ditanam di dalam HTML.

## Catatan pemeliharaan

- Gambar tidak lagi ditanam sebagai data URI. Menambah foto kategori baru berarti
  menaruh berkasnya di `assets/img/` dan menambahkan jalurnya di objek `CAT_PHOTO`
  atau `REEL_SRC`.
- Daftar barang ditampilkan 20 item per halaman dengan tombol lanjutan; nilainya
  diatur lewat konstanta `PAGE_SIZE`.
- Data lama di localStorage dinormalkan oleh fungsi `normalize()` saat dimuat,
  sehingga struktur data versi sebelumnya tidak membuat tampilan gagal.
