# BIVAK App — Marketplace Barter Gear Outdoor

Prototipe aplikasi web **BIVAK — Barter Item & Value Antar Komunitas**, dibangun dari dokumen rancangan MVP di `bivak-site`.

Satu file HTML, tanpa build step, tanpa dependensi, tanpa backend. Data contoh disimpan di `localStorage` browser.

---

## Yang sudah berfungsi

| Layar | Fitur |
| --- | --- |
| Beranda | Pencarian, filter kategori/kondisi/kota/rentang nilai, urutkan, favorit, badge "cocok" |
| Cocok untukmu | Pencocokan dua arah (barang incaran mereka × barang aktif kamu) + hitung selisih nilai |
| Detail barang | Foto/ilustrasi, kondisi, nilai taksasi, barang incaran, profil & reputasi pemilik, tombol Laporkan |
| Ajukan barter | Pilih satu atau beberapa barang milikmu, usulan selisih tunai otomatis, catatan, ringkasan adil/kurang/lebih |
| Penawaran | Kotak Masuk & Terkirim, pipeline status, chat privat per penawaran (dengan balasan simulasi) |
| Tambah barang | Form listing, upload maksimal 3 foto (dikompres ke WebP di perangkat), barang incaran, batas 5 listing/hari |
| Profil | Statistik, barang saya, arsip/aktifkan listing, riwayat barter, reputasi naik setelah barter selesai |

### Aturan status yang diterapkan

- Listing: `draf → aktif → dicadangkan → selesai / arsip`
- Penawaran: `Diajukan → Negosiasi → Disetujui → Selesai`, dengan cabang `Ditolak`, `Dibatalkan`, `Tidak terpilih`
- Menyetujui satu penawaran otomatis **mencadangkan** listing kedua pihak.
- Menyelesaikan barter menandai listing `selesai`, menutup penawaran lain sebagai `Tidak terpilih`, mencatat transaksi, dan menambah reputasi.
- Penawaran ditolak/dibatalkan mengembalikan listing ke `aktif`.

### Skema data (sama dengan rancangan Supabase)

`barter_profiles`, `barter_listings`, `barter_listing_photos`, `barter_wants`, `barter_offers`,
`barter_offer_items`, `barter_messages`, `barter_transactions`, `barter_reports` — direpresentasikan
sebagai objek `profiles`, `listings` (+`photos`, `wants`), `offers` (+`items`, `messages`),
`transactions`, `reports` di dalam `index.html`. Struktur ini siap dipindahkan ke tabel Supabase apa adanya.

---

## Menjalankan

```bash
# cukup buka langsung
open index.html

# atau server statis
python3 -m http.server 8000   # lalu buka http://localhost:8000
```

Tombol **Reset data contoh** di Beranda mengembalikan seluruh data prototipe ke awal.

## Deploy ke GitHub Pages

1. Buat repo publik baru, unggah seluruh isi folder ini (termasuk `.nojekyll` dan `.github`).
2. **Settings → Pages → Source: GitHub Actions**.
3. Situs aktif di `https://<username>.github.io/<nama-repo>/`.

---

## Langkah lanjut menuju produksi

1. Ganti penyimpanan `localStorage` dengan Supabase (`supabase-js`): tabel, indeks, dan RLS sesuai rancangan.
2. Login Google memakai akun Pintu Angin yang sudah ada, lalu isi `barter_profiles`.
3. Foto: unggah ke bucket privat, maksimal 3 per listing, signed URL saat ditampilkan.
4. Realtime hanya pada layar penawaran/chat; chat memuat 30–50 pesan terakhir.
5. Panel moderasi admin: laporan, arsip listing bermasalah, tanda akun tepercaya.

## Catatan

- BIVAK **bukan escrow**: aplikasi tidak memproses pembayaran dan tidak menjamin pengiriman.
- Nilai taksasi adalah referensi negosiasi dalam Rupiah, bukan saldo/dompet digital.
- Ilustrasi barang dibuat dengan SVG dari kode; foto asli bisa diunggah lewat form Tambah barang.
