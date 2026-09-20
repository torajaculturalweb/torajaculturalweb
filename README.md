# Toraja Cultural Web

Sistem Informasi Budaya Toraja berbasis web untuk edukasi, promosi, dan pelestarian budaya. Dibangun dengan React, Vite, dan Supabase. Project siap dijalankan lokal, di Vercel, atau open access melalui GitHub Pages.

Panduan tercepat untuk publikasi tersedia di `UPLOAD-GITHUB.md`.

## Fitur

- Website publik: budaya, destinasi, agenda, artikel, galeri, pencarian, kuis, kontak.
- Evaluasi penelitian: kuesioner SUS 10 butir, kalkulasi otomatis, dashboard hasil dan ekspor CSV.
- Panel admin: login Supabase Auth dan CRUD konten budaya, destinasi, artikel, serta agenda.
- Keamanan: Row Level Security; publik hanya membaca konten published dan admin mengelola data.
- Mode demo: halaman publik tetap dapat dijalankan sebelum Supabase dikonfigurasi.

## 1. Jalankan lokal

Persyaratan: Node.js 20 atau lebih baru.

### Cara termudah di Windows

1. Ekstrak seluruh ZIP.
2. Buka folder `toraja-cultural-system`.
3. Klik dua kali `start-local.bat`.
4. Pada penggunaan pertama, tunggu proses `npm install` selesai.
5. Browser akan membuka `http://localhost:5173` secara otomatis.
6. Jangan tutup jendela Command Prompt selama website dipakai.
7. Tekan `Ctrl+C` untuk menghentikan server.

Jika Windows SmartScreen muncul, pilih **More info**, lalu **Run anyway**. File ini hanya menjalankan `npm install` dan server Vite dari folder project.

### Melalui terminal

```bash
npm install
npm run dev
```

Karena konfigurasi Supabase telah tersedia di `src/lib/supabase.js`, pembuatan `.env` bersifat opsional. Anda juga dapat menjalankan `npm start` agar browser terbuka otomatis.

Konfigurasi publishable Supabase untuk project ini sudah ditanamkan pada `src/lib/supabase.js`, sehingga aplikasi dapat langsung terhubung tanpa file `.env`. File `.env.example` tetap tersedia apabila konfigurasi hendak dipindahkan kembali ke environment variables pada pengembangan berikutnya.

## 2. Siapkan Supabase

1. Buat project baru di https://supabase.com.
2. Buka **SQL Editor**, salin seluruh isi `supabase/schema.sql`, lalu klik **Run**.
3. Buka **Authentication > Users > Add user**, masukkan email dan password admin.
4. Trigger pada SQL otomatis membuat profil admin ketika user dibuat.
5. Buka **Project Settings > API** untuk memeriksa Project URL dan publishable key.
6. Jika memakai project Supabase berbeda, ganti konstanta `url` dan `key` di `src/lib/supabase.js` atau pindahkan kembali ke `.env`:

```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

Jangan memakai `service_role` key di frontend atau Vercel.

## 3. Unggah ke GitHub

```bash
git init
git add .
git commit -m "Initial Toraja cultural information system"
git branch -M main
git remote add origin https://github.com/USERNAME/NAMA-REPOSITORY.git
git push -u origin main
```

File `.env` sudah masuk `.gitignore` sehingga kredensial lokal tidak ikut terunggah.

## 4. Deploy ke Vercel

1. Masuk ke Vercel dan pilih **Add New > Project**.
2. Import repository GitHub.
3. Framework preset akan terdeteksi sebagai **Vite**.
4. Build command: `npm run build`.
5. Output directory: `dist`.
6. Tambahkan Environment Variables `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY`.
7. Klik **Deploy**.

`vercel.json` telah mengatur rewrite agar semua route React dapat dibuka langsung atau direfresh.

## 5. Login administrator

Buka `/admin/login`, lalu gunakan akun yang dibuat melalui Supabase Authentication. Jangan membuat password admin lewat SQL.

## Verifikasi

```bash
npm run test
npm run build
```

## Catatan penelitian

Skor SUS dihitung memakai prosedur baku: butir ganjil dikurangi 1, butir genap dihitung 5 dikurangi jawaban, lalu total dikali 2,5. Hasil disimpan pada tabel `sus_responses` dan dapat diekspor oleh admin.
