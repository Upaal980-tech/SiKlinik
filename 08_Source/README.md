# SiKlinik – Source Code (08_Source)

Sistem informasi klinik multi-tenant (Kelompok 5 – Klinik Digital, Kelas R001).

Disusun oleh: M. Naufal Ulul Albab (Programmer)

## Tech stack
- Backend: Node.js + Express
- Database: PostgreSQL (driver `pg`)
- Frontend: HTML, CSS, JavaScript (folder `public/`)

## Cara menjalankan di lokal
1. Pasang Node.js (v18 ke atas) dan PostgreSQL (v14 ke atas).
2. Buat database kosong bernama `siklinik` di PostgreSQL.
3. Salin `.env.example` menjadi `.env`, lalu isi `DB_PASSWORD` sesuai password PostgreSQL kamu.
4. Install dependensi:
   ```
   npm install
   ```
5. Jalankan server:
   ```
   npm start
   ```
6. Buka http://localhost:3000

## Struktur folder
```
08_Source/
├── server.js        # server Express + endpoint API
├── db.js            # koneksi PostgreSQL
├── public/          # frontend (index.html, app.js, style.css)
├── legacy/          # skrip migrasi lama dari SQLite
├── .env.example     # contoh konfigurasi (tanpa password asli)
└── package.json
```

## Branch
- `main`: versi stabil
- `dev`: integrasi
- `feature/...`: pekerjaan per fitur, digabung ke `dev` lewat pull request

## Akun demo
(isi akun demo di sini)
