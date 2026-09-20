# Upload dan Open Access

## Upload seluruh folder

1. Ekstrak `torajaculturalweb.zip`.
2. Buka repository GitHub bernama `torajaculturalweb`.
3. Hapus source lama jika repository sudah berisi versi sebelumnya.
4. Pilih **Add file > Upload files**.
5. Unggah seluruh isi folder `torajaculturalweb`, bukan folder ZIP.
6. Pastikan `.github/workflows/deploy-pages.yml` ikut terunggah.
7. Commit ke branch `main`.

## Aktifkan GitHub Pages

1. Buka **Settings > Pages** pada repository.
2. Pada **Build and deployment**, pilih **GitHub Actions**.
3. Buka tab **Actions** dan tunggu workflow `Deploy Toraja Cultural Web` selesai.
4. Website publik akan tersedia pada URL yang ditampilkan oleh workflow.

Jika nama akun GitHub dan repository sama-sama `torajaculturalweb`, URL umumnya:

`https://torajaculturalweb.github.io/torajaculturalweb/`

## Login admin

Halaman login:

`https://torajaculturalweb.github.io/torajaculturalweb/#/admin/login`

Buat akun admin dari **Supabase > Authentication > Users > Add user**. Pastikan `supabase/schema.sql` sudah dijalankan satu kali pada SQL Editor project Supabase yang sesuai.
