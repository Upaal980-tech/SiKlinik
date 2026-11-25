-- ============================================================
-- Data dummy SiKlinik (tabel master) - PostgreSQL 14+
-- Jalankan SETELAH siklinik_skema_fisik.sql, pada database kosong.
-- Seluruh data fiktif. password_hash hanya string acak berformat bcrypt
-- (tidak ada password asli yang dapat diturunkan darinya).
-- ID diisi eksplisit (OVERRIDING SYSTEM VALUE), lalu sequence disinkronkan.
-- ============================================================
BEGIN;

-- paket_langganan (5 baris)
INSERT INTO paket_langganan (id_paket, nama_paket, deskripsi_fitur, harga_bulanan, status_aktif) OVERRIDING SYSTEM VALUE VALUES
  (1, 'Starter', '1 klinik, 3 pengguna, pendaftaran, rekam medis dasar, kasir', 299000.00, TRUE),
  (2, 'Standar', 'Hingga 10 pengguna, antrian online, farmasi dan stok obat, laporan bulanan', 599000.00, TRUE),
  (3, 'Profesional', 'Hingga 30 pengguna, integrasi BPJS (P-Care) dan SATUSEHAT, MFA, laporan keuangan', 1199000.00, TRUE),
  (4, 'Enterprise', 'Pengguna tidak terbatas, multi-cabang, dukungan prioritas 24/7, audit log lanjutan', 2499000.00, TRUE),
  (5, 'Legacy Lite', 'Paket lama (tidak dijual lagi): pendaftaran dan kasir saja', 199000.00, FALSE);
SELECT setval(pg_get_serial_sequence('paket_langganan', 'id_paket'), (SELECT MAX(id_paket) FROM paket_langganan));

-- klinik (5 baris)
INSERT INTO klinik (id_klinik, id_paket, nama_klinik, alamat, kontak, no_izin, status_langganan, tgl_bergabung) OVERRIDING SYSTEM VALUE VALUES
  (1, 3, 'Klinik Pratama Sehat Sentosa', 'Jl. Slamet Riyadi No. 45, Kel. Kebun Handil, Kec. Jelutung, Kota Jambi, Jambi 36124', '0741-7551234 / sentosa@kliniksentosa.id', '503/0142/DPMPTSP/2023', 'aktif', '2023-03-15'),
  (2, 2, 'Klinik Medika Utama', 'Jl. Sultan Thaha No. 112, Kel. Telanaipura, Kec. Telanaipura, Kota Jambi, Jambi 36361', '0741-7088821 / info@medikautama.co.id', '503/0377/DPMPTSP/2023', 'aktif', '2023-08-01'),
  (3, 2, 'Klinik Bunda Sehat', 'Jl. Kapten Pattimura No. 8, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi, Jambi 36129', '0812-7345-6620 / admin@bundasehat.id', '503/0058/DPMPTSP/2024', 'aktif', '2024-02-12'),
  (4, 4, 'Klinik Husada Mandiri', 'Jl. Jenderal Sudirman No. 301, Kel. 20 Ilir D.II, Kec. Ilir Timur I, Kota Palembang, Sumatera Selatan 30129', '0711-3560981 / kontak@husadamandiri.id', '445/1290/DPMPTSP/2024', 'aktif', '2025-01-20'),
  (5, 1, 'Klinik Sehat Bersama', 'Jl. Khatib Sulaiman No. 77, Kel. Lolong Belanti, Kec. Padang Utara, Kota Padang, Sumatera Barat 25173', '0751-4472210 / halo@sehatbersama.id', '503/0911/DPMPTSP/2025', 'ditangguhkan', '2025-06-09');
SELECT setval(pg_get_serial_sequence('klinik', 'id_klinik'), (SELECT MAX(id_klinik) FROM klinik));

-- akun_pengguna (30 baris)
INSERT INTO akun_pengguna (id_akun, id_klinik, username, password_hash, nama_lengkap, peran, mfa_aktif, status_akun, terakhir_login) OVERRIDING SYSTEM VALUE VALUES
  (1, NULL, 'cs.rina', '$2b$12$MBhdaPLJ0CBJZbBXza3h.S0phRZpLJuKrqfD4NuIjsWGDbjIbKuh4', 'Rina Oktaviani', 'customer success', TRUE, 'aktif', '2026-11-24 08:15:00+07'),
  (2, NULL, 'owner.bagas', '$2b$12$sStrYgHTdS5uganFbCmxgGZmZ9w4QfPdf0xsaP9JEMRS0Gvu5e/Mg', 'Bagas Wicaksono', 'pemilik siklinik', TRUE, 'aktif', '2026-11-23 19:40:00+07'),
  (3, NULL, 'fin.sari', '$2b$12$pMj1S4.fULkXRtS.n8AMslcFcII8GOO6Tf0ZXlxt23NdaGpAba.HF', 'Sari Indrawati', 'admin keuangan siklinik', TRUE, 'aktif', '2026-11-24 09:02:00+07'),
  (4, 1, 'admin.sentosa', '$2b$12$bGCoHch8ZO6d6yWKK1r0y5EKFxpLdWW3P0Vh5dH2KE/JcTy87ZxFT', 'Ferry Kurniawan', 'admin klinik', TRUE, 'aktif', '2026-11-24 07:30:00+07'),
  (5, 1, 'daftar.sentosa1', '$2b$12$u.vf4i08RWjZFFmFE7SFIVGGcxNdDIzmfYmcfwOk4mH/4KHZfOqGd', 'Melinda Putri', 'petugas pendaftaran', FALSE, 'aktif', '2026-11-24 07:45:00+07'),
  (6, 1, 'kasir.sentosa1', '$2b$12$tiS2k/kLPfMLRgiYpYf8eEJ0hD.oOfS20/MHRCtQ1ODlsDrYdLryR', 'Yanti Rosdiana', 'kasir', FALSE, 'aktif', '2026-11-24 07:52:00+07'),
  (7, 1, 'dr.hendra', '$2b$12$cSUyBUoydgSLuC6aX4qlbaBWxohGhqxoBMfUfCL1qm1MvWeD1.Xs1', 'dr. Hendra Wijaya', 'dokter', TRUE, 'aktif', '2026-11-24 08:05:00+07'),
  (8, 1, 'dr.maya', '$2b$12$GomNklynxjOWzuUkx.kiY1n522Z6TIioJclaXQBDd6H4zWv9xdQ.L', 'dr. Maya Kusuma', 'dokter', TRUE, 'aktif', '2026-11-21 13:10:00+07'),
  (9, 1, 'bd.lestari', '$2b$12$0aU5EdN4P5m203S63fdh8ch2HicgomIPRbvRZGzyo5zFYzvAu7.rk', 'Bd. Lestari Handayani, S.Tr.Keb', 'perawat/bidan', FALSE, 'aktif', '2026-11-24 07:58:00+07'),
  (10, 1, 'apt.yusuf', '$2b$12$vza8ag18BvpxT5OBwBI0P5VEfunZ4npuhzeI6AEqaGDBdXARcO6MZ', 'apt. Yusuf Ramadhan, S.Farm', 'apoteker', FALSE, 'aktif', '2026-11-24 08:01:00+07'),
  (11, 1, 'mgr.sentosa', '$2b$12$5etTMSlLBluwXHdLkNDq0tGp/z8L1s4R1Ug751gndJh3d5upB9nV8', 'Dedi Firmansyah', 'manajer operasional', TRUE, 'aktif', '2026-11-22 16:20:00+07'),
  (12, 2, 'admin.medika', '$2b$12$Zrfphh/WIcy8c683AJjaxdlt6q0or4glebNWmNVWZ7hiKWjbsUk/O', 'Kurnia Dewanti', 'admin klinik', TRUE, 'aktif', '2026-11-24 07:20:00+07'),
  (13, 2, 'daftar.medika', '$2b$12$hDEjO8L/i672pVEe7MGx8HERRkIdNzau32k0lFKYZfIScUHS.y36j', 'Sinta Rahmawati', 'petugas pendaftaran', FALSE, 'aktif', '2026-11-24 07:40:00+07'),
  (14, 2, 'kasir.medika', '$2b$12$Cbii4HbfX0MaRgQHFTli2N5kxg92ID1neBJbAgDU62hV18J6qyonL', 'Doni Setiawan', 'kasir', FALSE, 'aktif', '2026-11-24 07:44:00+07'),
  (15, 2, 'dr.andika', '$2b$12$Soy9ixC4JmenMx.5yEWs92EYgOi28NBcSl/yJaM5NR9jgz76d4QvW', 'dr. Andika Pratama', 'dokter', TRUE, 'aktif', '2026-11-23 08:12:00+07'),
  (16, 2, 'dr.sinta', '$2b$12$PGhzpg.ik8R37qou4nWcvbyDm6uvR9COoK2K4/QyRH6fpwIoum8CG', 'dr. Sinta Maharani, Sp.A', 'dokter', TRUE, 'aktif', '2026-11-24 09:10:00+07'),
  (17, 2, 'ns.putra', '$2b$12$cibJ1KK2TkBDnFjrt1QdyVTUIuc9Qb5e4e/5iSH2qk0e4kXv7Lcur', 'Ns. Putra Ananda, S.Kep', 'perawat/bidan', FALSE, 'aktif', '2026-11-24 07:50:00+07'),
  (18, 2, 'apt.dewi', '$2b$12$jjAwh/E9ibraWePKDl2CsOJjnzUXOsgTe7jpM5HQawsJw/fN4tfut', 'apt. Dewi Safitri, S.Farm', 'apoteker', FALSE, 'aktif', '2026-11-24 08:30:00+07'),
  (19, 3, 'admin.bunda', '$2b$12$Lb6BnaG5kyMPDCk9MKcPv4tzRzK8yhCtZ22csKtrFwhWN4JZAEodO', 'Marlina Sari', 'admin klinik', TRUE, 'aktif', '2026-11-24 07:10:00+07'),
  (20, 3, 'daftar.bunda', '$2b$12$YGYZboQ.hQOeUMBO/rcnAUfEOzMG63sL3aDk4BF7x0L82HInQGOhn', 'Ayu Ningsih', 'petugas pendaftaran', FALSE, 'aktif', '2026-11-24 07:35:00+07'),
  (21, 3, 'kasir.bunda', '$2b$12$uj41KMZ13byp4xzKm0metR6GJIJ1KtOFoNyr0EilrLZR7aLqtMha0', 'Heni Susanti', 'kasir', FALSE, 'aktif', '2026-11-20 15:48:00+07'),
  (22, 3, 'dr.rizky', '$2b$12$BgBVglpq.VQxGQBJZuz4pStlnIERSEIg2082zgZMq1Mi8lDawF.Yk', 'dr. Rizky Ramadhan', 'dokter', TRUE, 'aktif', '2026-11-24 08:20:00+07'),
  (23, 3, 'bd.fitri', '$2b$12$ZPejnN.91UOubrHwD1A4Hm0xzjMxAnT4sJ1Ld1xIwlpaoTHMWqqQc', 'Bd. Fitriani, S.Tr.Keb', 'perawat/bidan', FALSE, 'terkunci', '2026-11-19 10:05:00+07'),
  (24, 3, 'apt.nurul', '$2b$12$LQeXURHU953nmR2G62khFrHl53CFtiHJv5D3Wn6RF3LpIUDd22Sst', 'apt. Nurul Hidayah, S.Farm', 'apoteker', FALSE, 'aktif', '2026-11-23 14:00:00+07'),
  (25, 4, 'admin.husada', '$2b$12$ivypEoGoKvieRoIQqlwOIluoOJ0sAslVZp8WaPRHjKCpOuRSVT2Dy', 'Taufik Hidayat', 'admin klinik', TRUE, 'aktif', '2026-11-24 07:05:00+07'),
  (26, 4, 'dr.agung', '$2b$12$sc2i3bcl6Wt25iuzSXPeE7tLNiISg3Q1Ja3qBzEwtcvItaBmKoQPC', 'dr. Agung Setiawan, Sp.PD', 'dokter', TRUE, 'aktif', '2026-11-24 08:40:00+07'),
  (27, 4, 'kasir.husada', '$2b$12$i6P63.IAeZR0MickNEcz4GM9AcQj0.rczVIsGAv6DvteArGqcLoPD', 'Lilis Suryani', 'kasir', FALSE, 'aktif', '2026-11-23 16:30:00+07'),
  (28, 5, 'admin.sehatbersama', '$2b$12$rpU57VPG4CjXDXDmlw6eCWirEogNt1x2vpV99tgI0I1VjnLInjl30', 'Yohanes Mulyadi', 'admin klinik', TRUE, 'aktif', '2026-10-30 09:00:00+07'),
  (29, 5, 'dr.melati', '$2b$12$T2q3Dr1hFHxsSBQ2COGcssvCR3tt2HPswmhdMBV9vNff3Zi8XNPH3', 'dr. Melati Sari', 'dokter', FALSE, 'nonaktif', '2026-09-12 11:25:00+07'),
  (30, 5, 'daftar.sehat', '$2b$12$U2JmqGjkSUsaNXPc9Bst5OJGlw7yyHOmH35qOVO1FNRkTSnaqiIeX', 'Rani Oktarina', 'petugas pendaftaran', FALSE, 'nonaktif', NULL);
SELECT setval(pg_get_serial_sequence('akun_pengguna', 'id_akun'), (SELECT MAX(id_akun) FROM akun_pengguna));

-- tenaga_medis (30 baris)
INSERT INTO tenaga_medis (id_tenaga_medis, id_klinik, id_akun, nama, jenis_tenaga, no_str, spesialisasi, status_aktif) OVERRIDING SYSTEM VALUE VALUES
  (1, 1, 7, 'dr. Hendra Wijaya', 'dokter', '3173110120180001', 'Dokter Umum', TRUE),
  (2, 1, 8, 'dr. Maya Kusuma', 'dokter', '3173110120190012', 'Dokter Umum', TRUE),
  (3, 1, NULL, 'drg. Gita Permatasari', 'dokter', '1571110120200034', 'Dokter Gigi', TRUE),
  (4, 1, 9, 'Bd. Lestari Handayani, S.Tr.Keb', 'bidan', '1571120220210007', 'Kesehatan Ibu dan Anak', TRUE),
  (5, 1, NULL, 'Ns. Eko Prasetyo, S.Kep', 'perawat', '1571130320200045', NULL, TRUE),
  (6, 1, 10, 'apt. Yusuf Ramadhan, S.Farm', 'apoteker', '1571140420190021', 'Farmasi Klinik', TRUE),
  (7, 1, NULL, 'Rina Marlina, A.Md.Farm', 'asisten apoteker', '1571150520220018', NULL, TRUE),
  (8, 1, NULL, 'Ns. Dian Anggraini, S.Kep', 'perawat', '1571130320230052', NULL, TRUE),
  (9, 2, 15, 'dr. Andika Pratama', 'dokter', '1571110120170066', 'Dokter Umum', TRUE),
  (10, 2, 16, 'dr. Sinta Maharani, Sp.A', 'dokter', '1571110120150023', 'Spesialis Anak', TRUE),
  (11, 2, NULL, 'dr. Fajar Nugroho, Sp.OG', 'dokter', '1571110120140031', 'Spesialis Kandungan dan Kebidanan', TRUE),
  (12, 2, 17, 'Ns. Putra Ananda, S.Kep', 'perawat', '1571130320210077', NULL, TRUE),
  (13, 2, 18, 'apt. Dewi Safitri, S.Farm', 'apoteker', '1571140420200015', 'Farmasi Klinik', TRUE),
  (14, 2, NULL, 'Wulan Sari, A.Md.Farm', 'asisten apoteker', '1571150520230029', NULL, TRUE),
  (15, 2, NULL, 'Ns. Rahmat Hidayat, S.Kep', 'perawat', '1571130320220081', NULL, TRUE),
  (16, 2, NULL, 'drg. Lia Amelia', 'dokter', '1571110120190044', 'Dokter Gigi', TRUE),
  (17, 3, 22, 'dr. Rizky Ramadhan', 'dokter', '1571110120210058', 'Dokter Umum', TRUE),
  (18, 3, 23, 'Bd. Fitriani, S.Tr.Keb', 'bidan', '1571120220200039', 'Kesehatan Ibu dan Anak', TRUE),
  (19, 3, NULL, 'dr. Anisa Putri, Sp.OG', 'dokter', '1571110120160012', 'Spesialis Kandungan dan Kebidanan', TRUE),
  (20, 3, 24, 'apt. Nurul Hidayah, S.Farm', 'apoteker', '1571140420220063', 'Farmasi Klinik', TRUE),
  (21, 3, NULL, 'Bd. Siti Aminah, A.Md.Keb', 'bidan', '1571120220180027', NULL, TRUE),
  (22, 3, NULL, 'Ns. Yoga Saputra, S.Kep', 'perawat', '1571130320240090', NULL, TRUE),
  (23, 4, 26, 'dr. Agung Setiawan, Sp.PD', 'dokter', '1671110120130019', 'Spesialis Penyakit Dalam', TRUE),
  (24, 4, NULL, 'dr. Rosa Melinda', 'dokter', '1671110120200072', 'Dokter Umum', TRUE),
  (25, 4, NULL, 'apt. Hendri Gunawan, S.Farm', 'apoteker', '1671140420210048', 'Farmasi Klinik', TRUE),
  (26, 4, NULL, 'Ns. Tika Oktaviani, S.Kep', 'perawat', '1671130320230036', NULL, TRUE),
  (27, 5, 29, 'dr. Melati Sari', 'dokter', '1371110120190025', 'Dokter Umum', FALSE),
  (28, 5, NULL, 'dr. Dani Firmansyah, Sp.A', 'dokter', '1371110120170041', 'Spesialis Anak', TRUE),
  (29, 5, NULL, 'Bd. Yuni Astuti, S.Tr.Keb', 'bidan', '1371120220220053', 'Kesehatan Ibu dan Anak', TRUE),
  (30, 5, NULL, 'apt. Reza Fahlevi, S.Farm', 'apoteker', '1371140420210069', 'Farmasi Klinik', TRUE);
SELECT setval(pg_get_serial_sequence('tenaga_medis', 'id_tenaga_medis'), (SELECT MAX(id_tenaga_medis) FROM tenaga_medis));

-- jadwal_dokter (30 baris)
INSERT INTO jadwal_dokter (id_jadwal, id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) OVERRIDING SYSTEM VALUE VALUES
  (1, 1, 1, 'senin', '08:00', '12:00', 20),
  (2, 1, 1, 'rabu', '08:00', '12:00', 20),
  (3, 1, 1, 'jumat', '08:00', '11:00', 15),
  (4, 1, 2, 'selasa', '13:00', '17:00', 20),
  (5, 1, 2, 'kamis', '13:00', '17:00', 20),
  (6, 1, 2, 'sabtu', '09:00', '13:00', 25),
  (7, 1, 3, 'senin', '14:00', '18:00', 12),
  (8, 1, 3, 'kamis', '14:00', '18:00', 12),
  (9, 1, 4, 'selasa', '08:00', '12:00', 15),
  (10, 1, 4, 'jumat', '08:00', '12:00', 15),
  (11, 2, 9, 'senin', '08:00', '14:00', 25),
  (12, 2, 9, 'rabu', '08:00', '14:00', 25),
  (13, 2, 10, 'selasa', '09:00', '13:00', 15),
  (14, 2, 10, 'kamis', '09:00', '13:00', 15),
  (15, 2, 10, 'sabtu', '09:00', '12:00', 12),
  (16, 2, 11, 'rabu', '15:00', '19:00', 10),
  (17, 2, 11, 'jumat', '15:00', '19:00', 10),
  (18, 2, 16, 'senin', '16:00', '20:00', 10),
  (19, 2, 16, 'kamis', '16:00', '20:00', 10),
  (20, 3, 17, 'senin', '08:00', '13:00', 20),
  (21, 3, 17, 'selasa', '08:00', '13:00', 20),
  (22, 3, 17, 'kamis', '08:00', '13:00', 20),
  (23, 3, 19, 'rabu', '14:00', '18:00', 10),
  (24, 3, 19, 'sabtu', '09:00', '12:00', 10),
  (25, 3, 18, 'jumat', '08:00', '12:00', 12),
  (26, 3, 18, 'senin', '13:00', '17:00', 12),
  (27, 4, 23, 'senin', '08:00', '12:00', 15),
  (28, 4, 23, 'rabu', '08:00', '12:00', 15),
  (29, 4, 24, 'selasa', '13:00', '17:00', 15),
  (30, 5, 28, 'senin', '08:00', '12:00', 20);
SELECT setval(pg_get_serial_sequence('jadwal_dokter', 'id_jadwal'), (SELECT MAX(id_jadwal) FROM jadwal_dokter));

-- pasien (30 baris)
INSERT INTO pasien (id_pasien, id_klinik, no_rm, nik, nama, tgl_lahir, jenis_kelamin, alamat, no_telepon, no_bpjs, id_satusehat, tgl_registrasi, status_aktif) OVERRIDING SYSTEM VALUE VALUES
  (1, 1, 'RM-00001', '1571051403852051', 'Budi Santoso', '1985-03-14', 'laki-laki', 'Jl. Sultan Thaha No. 129, RT.11/RW.03, Kel. Talang Banjar, Kec. Jambi Timur, Kota Jambi', '08222995900', '0009439690784', NULL, '2025-09-12', TRUE),
  (2, 1, 'RM-00002', '1571056207927913', 'Siti Nurhaliza', '1992-07-22', 'perempuan', 'Jl. Hayam Wuruk No. 117, RT.02/RW.01, Kel. Danau Sipin, Kec. Danau Teluk, Kota Jambi', '081367735925', NULL, 'P05625881537', '2025-05-16', TRUE),
  (3, 1, 'RM-00003', '1571020511784383', 'Ahmad Fauzi', '1978-11-05', 'laki-laki', 'Jl. Kapten Pattimura No. 25, RT.01/RW.05, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi', '085232595327', NULL, 'P04701687339', '2026-07-09', TRUE),
  (4, 1, 'RM-00004', '1571067001900798', 'Dewi Lestari', '1990-01-30', 'perempuan', 'Jl. Prof. Dr. Sri Soedewi No. 121, RT.05/RW.09, Kel. Paal Merah, Kec. Paal Merah, Kota Jambi', '08126245650', '0009835841687', NULL, '2024-04-13', TRUE),
  (5, 1, 'RM-00005', '1571051709691947', 'Rudi Hartono', '1969-09-17', 'laki-laki', 'Jl. HOS Cokroaminoto No. 96, RT.06/RW.09, Kel. Kota Baru, Kec. Kota Baru, Kota Jambi', '08213986800', '0005787298259', 'P06949588879', '2024-09-20', TRUE),
  (6, 1, 'RM-00006', '1571054204587781', 'Ani Yuliani', '1958-04-02', 'perempuan', 'Jl. Jenderal Sudirman No. 29, RT.07/RW.05, Kel. Pasar Jambi, Kec. Pasar Jambi, Kota Jambi', '08119749930', NULL, 'P09623091307', '2024-02-04', TRUE),
  (7, 1, 'RM-00007', '1571061106156862', 'Muhammad Rizki Pratama', '2015-06-11', 'laki-laki', 'Jl. Orang Kayo Hitam No. 106, RT.09/RW.08, Kel. Danau Sipin, Kec. Danau Teluk, Kota Jambi', '08112838578', '0002785854973', NULL, '2024-11-06', TRUE),
  (8, 1, 'RM-00008', NULL, 'Putri Ayu Wulandari', '2019-12-03', 'perempuan', 'Jl. Hayam Wuruk No. 58, RT.05/RW.05, Kel. Talang Banjar, Kec. Jambi Timur, Kota Jambi', '08537575844', '0008665240415', NULL, '2025-07-25', TRUE),
  (9, 1, 'RM-00009', '1571052802727850', 'Hasan Basri', '1972-02-28', 'laki-laki', 'Jl. Lingkar Selatan No. 70, RT.09/RW.05, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi', '08139933083', NULL, 'P06571208267', '2025-03-14', TRUE),
  (10, 1, 'RM-00010', '1571085910833268', 'Nurhayati', '1983-10-19', 'perempuan', 'Jl. Hayam Wuruk No. 16, RT.02/RW.04, Kel. Pasar Jambi, Kec. Pasar Jambi, Kota Jambi', '08222620672', NULL, NULL, '2025-08-11', TRUE),
  (11, 1, 'RM-00011', '1571050808640614', 'Joko Susilo', '1964-08-08', 'laki-laki', 'Jl. M. Yamin No. 28, RT.06/RW.05, Kel. Paal Merah, Kec. Paal Merah, Kota Jambi', '085228743152', NULL, NULL, '2024-01-19', TRUE),
  (12, 1, 'RM-00012', '1571036505010231', 'Intan Permata Sari', '2001-05-25', 'perempuan', 'Jl. M. Yamin No. 50, RT.03/RW.07, Kel. Paal Merah, Kec. Paal Merah, Kota Jambi', '081185161227', '0003046374549', NULL, '2025-11-21', TRUE),
  (13, 2, 'RM-00001', '1571011212884286', 'Andi Wijaya', '1988-12-12', 'laki-laki', 'Jl. Slamet Riyadi No. 31, RT.08/RW.05, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi', '081384145933', NULL, 'P07956878339', '2026-01-06', TRUE),
  (14, 2, 'RM-00002', '1571024903958610', 'Lina Marlina', '1995-03-09', 'perempuan', 'Jl. Jenderal Sudirman No. 20, RT.10/RW.02, Kel. Talang Banjar, Kec. Jambi Timur, Kota Jambi', '08129822587', '0003971870728', 'P09087406403', '2026-07-03', TRUE),
  (15, 2, 'RM-00003', '1571022106550743', 'Bambang Sutrisno', '1955-06-21', 'laki-laki', 'Jl. Sultan Thaha No. 139, RT.01/RW.02, Kel. Pasar Jambi, Kec. Pasar Jambi, Kota Jambi', '08524622656', '0006618251286', 'P03004786863', '2026-05-17', FALSE),
  (16, 2, 'RM-00004', '1571045409107547', 'Maryam Zahra', '2010-09-14', 'perempuan', 'Jl. Hayam Wuruk No. 49, RT.12/RW.02, Kel. Jelutung, Kec. Jelutung, Kota Jambi', '081290331190', '0000306738302', 'P04395995342', '2025-12-09', TRUE),
  (17, 2, 'RM-00005', '1571041701036776', 'Fikri Alamsyah', '2003-01-17', 'laki-laki', 'Jl. Slamet Riyadi No. 143, RT.10/RW.03, Kel. Paal Merah, Kec. Paal Merah, Kota Jambi', '085387056856', '0004628733427', NULL, '2025-09-07', TRUE),
  (18, 2, 'RM-00006', '1571077007766825', 'Rosmawati', '1976-07-30', 'perempuan', 'Jl. Orang Kayo Hitam No. 66, RT.04/RW.06, Kel. Danau Sipin, Kec. Danau Teluk, Kota Jambi', '08537518304', '0009901398373', NULL, '2024-10-01', TRUE),
  (19, 2, 'RM-00007', '1571060404904968', 'Yusuf Ibrahim', '1990-04-04', 'laki-laki', 'Jl. Orang Kayo Hitam No. 31, RT.12/RW.08, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi', '08136385467', '0005445877175', NULL, '2024-02-01', TRUE),
  (20, 2, 'RM-00008', '1571066311685127', 'Tuti Handayani', '1968-11-23', 'perempuan', 'Jl. M. Yamin No. 57, RT.12/RW.03, Kel. Telanaipura, Kec. Telanaipura, Kota Jambi', '081289964235', '0009378547772', NULL, '2026-04-27', TRUE),
  (21, 2, 'RM-00009', NULL, 'Dimas Aditya', '2022-02-15', 'laki-laki', 'Jl. Kapten Pattimura No. 140, RT.08/RW.03, Kel. Jelutung, Kec. Jelutung, Kota Jambi', '08228010062', NULL, 'P02038750997', '2025-12-22', TRUE),
  (22, 2, 'RM-00010', '1571086708810258', 'Sri Wahyuni', '1981-08-27', 'perempuan', 'Jl. Lingkar Selatan No. 106, RT.01/RW.01, Kel. Talang Banjar, Kec. Jambi Timur, Kota Jambi', '082284086211', '0003398454615', NULL, '2024-01-14', TRUE),
  (23, 3, 'RM-00001', '1571081905879257', 'Edi Kurniawan', '1987-05-19', 'laki-laki', 'Jl. Hayam Wuruk No. 21, RT.11/RW.01, Kel. Kenali Besar, Kec. Alam Barajo, Kota Jambi', '081266870021', '0006591803397', 'P01489025039', '2024-10-18', TRUE),
  (24, 3, 'RM-00002', '1571035010936526', 'Ratna Dewi', '1993-10-10', 'perempuan', 'Jl. Hayam Wuruk No. 42, RT.10/RW.04, Kel. Kota Baru, Kec. Kota Baru, Kota Jambi', '082285621850', '0003159996504', NULL, '2026-09-20', TRUE),
  (25, 3, 'RM-00003', '1571083112998039', 'Syahrul Gunawan', '1999-12-31', 'laki-laki', 'Jl. Lingkar Selatan No. 97, RT.07/RW.03, Kel. Pasar Jambi, Kec. Pasar Jambi, Kota Jambi', '085319431142', '0002655110475', NULL, '2024-10-02', TRUE),
  (26, 3, 'RM-00004', '1571024603622171', 'Halimah', '1962-03-06', 'perempuan', 'Jl. HOS Cokroaminoto No. 115, RT.09/RW.09, Kel. Jelutung, Kec. Jelutung, Kota Jambi', '082210158199', NULL, NULL, '2024-05-11', TRUE),
  (27, 3, 'RM-00005', '1571010209744782', 'Teguh Prasetyo', '1974-09-02', 'laki-laki', 'Jl. Sultan Thaha No. 144, RT.04/RW.09, Kel. Danau Sipin, Kec. Danau Teluk, Kota Jambi', '081322444721', '0004647154379', NULL, '2025-04-10', TRUE),
  (28, 3, 'RM-00006', '1571085806081753', 'Nabila Azzahra', '2008-06-18', 'perempuan', 'Jl. Slamet Riyadi No. 102, RT.06/RW.07, Kel. Paal Merah, Kec. Paal Merah, Kota Jambi', '081175692459', NULL, 'P05265479356', '2024-06-29', TRUE),
  (29, 3, 'RM-00007', '1571051102966438', 'Rendi Saputra', '1996-02-11', 'laki-laki', 'Jl. M. Yamin No. 52, RT.10/RW.09, Kel. Kota Baru, Kec. Kota Baru, Kota Jambi', '08137374167', '0004342661797', 'P08868058911', '2025-02-19', TRUE),
  (30, 3, 'RM-00008', '1571046911895817', 'Eka Rahmawati', '1989-11-29', 'perempuan', 'Jl. M. Yamin No. 103, RT.06/RW.07, Kel. Telanaipura, Kec. Telanaipura, Kota Jambi', '08121438889', NULL, 'P05679825071', '2024-07-31', TRUE);
SELECT setval(pg_get_serial_sequence('pasien', 'id_pasien'), (SELECT MAX(id_pasien) FROM pasien));

-- obat (30 baris)
INSERT INTO obat (id_obat, id_klinik, kode_obat, nama_obat, satuan, kategori, harga_jual, status_aktif) OVERRIDING SYSTEM VALUE VALUES
  (1, 1, 'OBT-001', 'Paracetamol 500 mg', 'Tablet', 'Analgesik-Antipiretik', 600.00, TRUE),
  (2, 1, 'OBT-002', 'Ibuprofen 400 mg', 'Tablet', 'Analgesik-Antipiretik', 1500.00, TRUE),
  (3, 1, 'OBT-003', 'Asam Mefenamat 500 mg', 'Tablet', 'Analgesik-Antipiretik', 1200.00, TRUE),
  (4, 1, 'OBT-004', 'Amoxicillin 500 mg', 'Kapsul', 'Antibiotik', 1800.00, TRUE),
  (5, 1, 'OBT-005', 'Cefadroxil 500 mg', 'Kapsul', 'Antibiotik', 3500.00, TRUE),
  (6, 1, 'OBT-006', 'Ciprofloxacin 500 mg', 'Tablet', 'Antibiotik', 3000.00, TRUE),
  (7, 1, 'OBT-007', 'Metformin 500 mg', 'Tablet', 'Antidiabetik', 700.00, TRUE),
  (8, 1, 'OBT-008', 'Glimepiride 2 mg', 'Tablet', 'Antidiabetik', 2500.00, TRUE),
  (9, 1, 'OBT-009', 'Amlodipine 5 mg', 'Tablet', 'Antihipertensi', 900.00, TRUE),
  (10, 1, 'OBT-010', 'Captopril 25 mg', 'Tablet', 'Antihipertensi', 600.00, TRUE),
  (11, 1, 'OBT-011', 'Omeprazole 20 mg', 'Kapsul', 'Saluran Cerna', 1500.00, TRUE),
  (12, 1, 'OBT-012', 'Antasida DOEN', 'Tablet kunyah', 'Saluran Cerna', 500.00, TRUE),
  (13, 1, 'OBT-013', 'Cetirizine 10 mg', 'Tablet', 'Antihistamin', 1200.00, TRUE),
  (14, 1, 'OBT-014', 'Ambroxol 30 mg', 'Tablet', 'Mukolitik', 600.00, TRUE),
  (15, 1, 'OBT-015', 'Paracetamol Sirup 120 mg/5 ml (60 ml)', 'Botol', 'Analgesik-Antipiretik', 15000.00, TRUE),
  (16, 1, 'OBT-016', 'Vitamin B Kompleks', 'Tablet', 'Vitamin dan Suplemen', 500.00, TRUE),
  (17, 2, 'OBT-001', 'Paracetamol 500 mg', 'Tablet', 'Analgesik-Antipiretik', 700.00, TRUE),
  (18, 2, 'OBT-002', 'Natrium Diklofenak 50 mg', 'Tablet', 'Analgesik-Antipiretik', 1000.00, TRUE),
  (19, 2, 'OBT-003', 'Amoxicillin 500 mg', 'Kapsul', 'Antibiotik', 2000.00, TRUE),
  (20, 2, 'OBT-004', 'Azithromycin 500 mg', 'Tablet', 'Antibiotik', 9000.00, TRUE),
  (21, 2, 'OBT-005', 'Kotrimoksazol 480 mg', 'Tablet', 'Antibiotik', 800.00, TRUE),
  (22, 2, 'OBT-006', 'Metronidazole 500 mg', 'Tablet', 'Antibiotik', 1000.00, TRUE),
  (23, 2, 'OBT-007', 'Simvastatin 20 mg', 'Tablet', 'Antikolesterol', 1800.00, TRUE),
  (24, 2, 'OBT-008', 'Loratadine 10 mg', 'Tablet', 'Antihistamin', 1500.00, TRUE),
  (25, 2, 'OBT-009', 'Salbutamol 2 mg', 'Tablet', 'Bronkodilator', 500.00, TRUE),
  (26, 2, 'OBT-010', 'Dexamethasone 0,5 mg', 'Tablet', 'Kortikosteroid', 400.00, FALSE),
  (27, 2, 'OBT-011', 'Domperidone 10 mg', 'Tablet', 'Saluran Cerna', 900.00, TRUE),
  (28, 2, 'OBT-012', 'Sulfas Ferosus 200 mg', 'Tablet', 'Vitamin dan Suplemen', 400.00, TRUE),
  (29, 2, 'OBT-013', 'Salep Hidrokortison 2,5% (5 g)', 'Tube', 'Dermatologi', 14000.00, TRUE),
  (30, 2, 'OBT-014', 'Povidone Iodine 10% (60 ml)', 'Botol', 'Antiseptik', 16000.00, TRUE);
SELECT setval(pg_get_serial_sequence('obat', 'id_obat'), (SELECT MAX(id_obat) FROM obat));

-- layanan (30 baris)
INSERT INTO layanan (id_layanan, id_klinik, kode_layanan, nama_layanan, tarif, status_aktif) OVERRIDING SYSTEM VALUE VALUES
  (1, 1, 'LYN-001', 'Konsultasi Dokter Umum', 50000.00, TRUE),
  (2, 1, 'LYN-002', 'Konsultasi Dokter Gigi', 75000.00, TRUE),
  (3, 1, 'LYN-003', 'Pemeriksaan Kehamilan (ANC)', 80000.00, TRUE),
  (4, 1, 'LYN-004', 'Imunisasi Dasar', 60000.00, TRUE),
  (5, 1, 'LYN-005', 'KB Suntik 3 Bulan', 40000.00, TRUE),
  (6, 1, 'LYN-006', 'Jahit Luka (per 5 jahitan)', 150000.00, TRUE),
  (7, 1, 'LYN-007', 'Ganti Perban', 35000.00, TRUE),
  (8, 1, 'LYN-008', 'Nebulizer', 75000.00, TRUE),
  (9, 1, 'LYN-009', 'Suntik Intramuskular', 25000.00, TRUE),
  (10, 1, 'LYN-010', 'Cek Gula Darah', 25000.00, TRUE),
  (11, 1, 'LYN-011', 'Cek Kolesterol', 40000.00, TRUE),
  (12, 1, 'LYN-012', 'Cek Asam Urat', 30000.00, TRUE),
  (13, 1, 'LYN-013', 'Pengukuran Tekanan Darah', 10000.00, TRUE),
  (14, 1, 'LYN-014', 'Surat Keterangan Sehat', 30000.00, TRUE),
  (15, 1, 'LYN-015', 'Cabut Gigi', 150000.00, TRUE),
  (16, 1, 'LYN-016', 'Tambal Gigi', 200000.00, TRUE),
  (17, 2, 'LYN-001', 'Konsultasi Dokter Umum', 60000.00, TRUE),
  (18, 2, 'LYN-002', 'Konsultasi Dokter Spesialis Anak', 150000.00, TRUE),
  (19, 2, 'LYN-003', 'Konsultasi Dokter Spesialis Kandungan', 175000.00, TRUE),
  (20, 2, 'LYN-004', 'USG Kandungan', 150000.00, TRUE),
  (21, 2, 'LYN-005', 'Pemasangan Infus', 100000.00, TRUE),
  (22, 2, 'LYN-006', 'EKG', 100000.00, TRUE),
  (23, 2, 'LYN-007', 'Darah Rutin', 85000.00, TRUE),
  (24, 2, 'LYN-008', 'Urin Lengkap', 50000.00, TRUE),
  (25, 2, 'LYN-009', 'Tes Kehamilan', 25000.00, TRUE),
  (26, 2, 'LYN-010', 'Rapid Test Antigen', 100000.00, TRUE),
  (27, 2, 'LYN-011', 'Hemoglobin (Hb)', 25000.00, TRUE),
  (28, 2, 'LYN-012', 'Scaling Gigi', 250000.00, TRUE),
  (29, 2, 'LYN-013', 'Nebulizer', 80000.00, TRUE),
  (30, 2, 'LYN-014', 'Surat Keterangan Sehat', 35000.00, TRUE);
SELECT setval(pg_get_serial_sequence('layanan', 'id_layanan'), (SELECT MAX(id_layanan) FROM layanan));

COMMIT;
