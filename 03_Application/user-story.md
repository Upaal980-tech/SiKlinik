# User Story SiKlinik

> Sumber: Laporan Akhir ASP Kelompok 5, **Bab IV.2** (Tabel 4.2) dan **Bab VII** (matriks ketelusuran).
> Format: *Sebagai [peran], saya ingin [tujuan] agar [manfaat]*.

## 1. Ringkasan

| ID | Peran | Tujuan singkat | Use case | Fitur | Prioritas | KPI |
| --- | --- | --- | --- | --- | --- | --- |
| US01 | Petugas pendaftaran | Daftarkan pasien tanpa duplikat | UC02 | F01 | Must | K1 |
| US02 | Petugas pendaftaran | Buat kunjungan dan antrean | UC03 | F02 | Must | K2 |
| US03 | Dokter | Isi rekam medis dan pilih layanan | UC04 | F03 | Must | K3 |
| US04 | Dokter | Buat e-resep | UC05 | F04 | Must | K2 |
| US05 | Apoteker | Serahkan obat dengan cek stok | UC06 | F04, F06 | Must / Should | K2 |
| US06 | Kasir | Tagihan otomatis dan pembayaran | UC07 | F05 | Must | K2 |
| US07 | Pengguna | Masuk dengan akun dan MFA | UC01 | F03 | Must | K3 |
| US08 | Manajer | Dashboard dan log akses | UC08, UC10 | F07, F08 | Should | K3 |

## 2. Detail dan Kriteria Penerimaan

### US01 Registrasi pasien tanpa duplikat
**Sebagai** petugas pendaftaran, **saya ingin** mendaftarkan pasien tanpa duplikat **agar** identitas pasien tunggal.

- [ ] Nama dan tanggal lahir wajib diisi; NIK 16 digit diisi bila dimiliki
- [ ] NIK atau kombinasi nama + tanggal lahir yang sudah ada memakai data lama dan menampilkan pesan
- [ ] Pasien baru mendapat nomor RM unik

Aturan bisnis: BR01, BR02, BR03

### US02 Buat kunjungan dan antrean
**Sebagai** petugas pendaftaran, **saya ingin** membuat kunjungan **agar** pasien masuk antrean dokter.

- [ ] Dokter dan jenis (onsite/online) wajib dipilih
- [ ] Nomor antrean berurutan per hari
- [ ] Status awal Menunggu dokter dan muncul di daftar pasien dokter tujuan

Aturan bisnis: BR04

### US03 Rekam medis dan layanan
**Sebagai** dokter, **saya ingin** mengisi rekam medis dan memilih layanan **agar** tagihan terbentuk otomatis.

- [ ] Keluhan dan diagnosis wajib diisi
- [ ] Riwayat pasien ditampilkan
- [ ] Pembukaan dan pembuatan rekam medis tercatat di log akses
- [ ] Peran selain dokter tidak melihat isi rekam medis

Aturan bisnis: BR05, BR08

### US04 E-resep
**Sebagai** dokter, **saya ingin** membuat e-resep **agar** apotek dapat langsung menyiapkan obat.

- [ ] Obat, jumlah, dan aturan pakai dapat dipilih
- [ ] Bila ada resep, status Menunggu obat dan resep muncul di apotek
- [ ] Bila tidak ada resep, status Menunggu bayar

Aturan bisnis: BR06

### US05 Penyerahan obat dengan pengecekan stok
**Sebagai** apoteker, **saya ingin** menyerahkan obat dengan pengecekan stok **agar** stok akurat.

- [ ] Penyerahan ditolak bila stok salah satu item kurang
- [ ] Stok dipotong per batch bila cukup
- [ ] Status menjadi Menunggu bayar

Aturan bisnis: BR07

### US06 Tagihan dan pembayaran
**Sebagai** kasir, **saya ingin** tagihan otomatis dan pembayaran **agar** tidak menghitung manual.

- [ ] Tagihan memuat layanan dan obat
- [ ] Metode: Tunai, Transfer, QRIS, atau Kartu; tunai menampilkan kembalian
- [ ] Setelah dicatat, status Selesai dan struk dapat dicetak

Aturan bisnis: BR08, BR09

### US07 Masuk dengan akun dan MFA
**Sebagai** pengguna, **saya ingin** masuk dengan akun dan MFA **agar** data klinik terlindungi.

- [ ] Login memakai kode klinik, username, kata sandi, lalu kode 6 digit
- [ ] Akun nonaktif ditolak
- [ ] Menu dan data hanya milik klinik dan peran pengguna

Aturan bisnis: BR10

### US08 Dashboard dan log akses
**Sebagai** manajer, **saya ingin** dashboard dan log akses **agar** dapat memantau dan mengaudit.

- [ ] Dashboard dan laporan bulanan dapat diunduh
- [ ] Log akses menampilkan siapa, kapan, dan objek yang diakses

## 3. Ketelusuran

| Masalah | Kebutuhan | Use case | User story | KPI |
| --- | --- | --- | --- | --- |
| M1, M2 | Data pasien tunggal tanpa duplikat | UC02 | US01 | K1 |
| M4 | Antrean dan status terlihat semua bagian | UC03 | US02 | K2 |
| M3 | Rekam medis terlindungi dan tercatat | UC04 | US03 | K3 |
| M3, M4 | Resep elektronik ke apotek | UC05 | US04 | K2 |
| M4 | Penyerahan obat dan stok akurat | UC06 | US05 | K2 |
| M4 | Tagihan otomatis dan pembayaran | UC07 | US06 | K2 |
| M3 | Hak akses per peran dan MFA | UC01 | US07 | K3 |
| M4 | Pemantauan dan audit | UC08, UC10 | US08 | K3 |

> **Catatan:** UC09, UC11, dan UC12 (prioritas Should/Could) belum punya user story di laporan. Bila perlu, tambahkan US09 sampai US11 pada dokumen ini.
