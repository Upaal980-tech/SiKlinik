-- ============================================================
-- SiKlinik - UJI CONSTRAINT (PostgreSQL 14+)
-- Menguji seluruh constraint pada siklinik_skema_fisik.sql:
--   PRIMARY KEY identity, NOT NULL, CHECK, UNIQUE, FOREIGN KEY
--   (termasuk FK komposit antar-klinik / multi-tenant),
--   ON DELETE RESTRICT, nilai DEFAULT, dan trigger append-only.
--
-- Cara kerja:
--   * Semua dijalankan di satu transaksi dan diakhiri ROLLBACK,
--     jadi TIDAK ada data yang tersisa (data dummy Anda aman).
--   * Data uji memakai ID 9001 ke atas dan username/kode berawalan "uji",
--     sehingga tidak bentrok dengan data dummy.
--   * Tiap uji NEGATIF memastikan insert/ubah/hapus DITOLAK dengan
--     SQLSTATE yang benar DAN oleh constraint yang dimaksud (bukan
--     karena error lain). Tiap uji POSITIF memastikan data valid LOLOS.
--   * Hasil: LULUS / GAGAL pada tabel hasil_uji (ditampilkan di akhir).
--
-- Catatan:
--   * Sequence identity ikut terpakai oleh percobaan yang gagal
--     (nomor ID berikutnya melompat). Itu perilaku normal PostgreSQL.
--   * Jalankan sebagai satu skrip utuh. Pada klien dengan auto-commit
--     (DBeaver, pgAdmin) pakai mode "Execute script", bukan per-statement.
--   * Jalankan di database pengembangan, jangan di produksi.
-- ============================================================

BEGIN;

CREATE TEMP TABLE hasil_uji (
  no         SERIAL PRIMARY KEY,
  tabel      TEXT,
  deskripsi  TEXT,
  diharapkan TEXT,
  diperoleh  TEXT,
  status     TEXT
);

-- Uji negatif: pernyataan HARUS ditolak dengan SQLSTATE tertentu.
-- p_pola dicocokkan (LIKE) ke nama constraint, nama kolom, atau pesan error.
CREATE FUNCTION pg_temp.uji(p_tabel text, p_desk text, p_state text, p_pola text, p_sql text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
  v_state text; v_cons text; v_col text; v_msg text; v_ok boolean;
BEGIN
  BEGIN
    EXECUTE p_sql;
    RAISE EXCEPTION 'tidak ada error' USING ERRCODE = 'ZZ001';  -- membatalkan efek pernyataan
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_state = RETURNED_SQLSTATE, v_cons = CONSTRAINT_NAME,
                            v_col = COLUMN_NAME, v_msg = MESSAGE_TEXT;
  END;

  IF v_state = 'ZZ001' THEN
    INSERT INTO hasil_uji (tabel, deskripsi, diharapkan, diperoleh, status)
    VALUES (p_tabel, p_desk, p_state || COALESCE(' / ' || p_pola, ''),
            'TIDAK ADA ERROR - data yang seharusnya ditolak malah masuk', 'GAGAL');
  ELSE
    v_ok := v_state = p_state
            AND (p_pola IS NULL
                 OR COALESCE(v_cons, '') LIKE p_pola
                 OR COALESCE(v_col,  '') LIKE p_pola
                 OR v_msg LIKE p_pola);
    INSERT INTO hasil_uji (tabel, deskripsi, diharapkan, diperoleh, status)
    VALUES (p_tabel, p_desk, p_state || COALESCE(' / ' || p_pola, ''),
            v_state || COALESCE(' / ' || v_cons, COALESCE(' / ' || v_col, '')) || ' : ' || left(v_msg, 80),
            CASE WHEN v_ok THEN 'LULUS' ELSE 'GAGAL' END);
  END IF;
END $f$;

-- Uji positif: pernyataan HARUS berhasil (efeknya dipertahankan untuk uji berikutnya).
CREATE FUNCTION pg_temp.uji_ok(p_tabel text, p_desk text, p_sql text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE v_err text;
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    v_err := SQLSTATE || ' : ' || left(v_err, 100);
  END;
  INSERT INTO hasil_uji (tabel, deskripsi, diharapkan, diperoleh, status)
  VALUES (p_tabel, p_desk, 'berhasil', COALESCE(v_err, 'berhasil'),
          CASE WHEN v_err IS NULL THEN 'LULUS' ELSE 'GAGAL' END);
END $f$;

-- Uji nilai: SELECT boolean HARUS bernilai TRUE (untuk nilai DEFAULT).
CREATE FUNCTION pg_temp.tegas(p_tabel text, p_desk text, p_sql text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE v_bool boolean; v_err text;
BEGIN
  BEGIN
    EXECUTE p_sql INTO v_bool;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    v_err := SQLSTATE || ' : ' || left(v_err, 100);
  END;
  INSERT INTO hasil_uji (tabel, deskripsi, diharapkan, diperoleh, status)
  VALUES (p_tabel, p_desk, 'TRUE', COALESCE(v_err, v_bool::text),
          CASE WHEN v_err IS NULL AND v_bool IS TRUE THEN 'LULUS' ELSE 'GAGAL' END);
END $f$;


DO $uji$
BEGIN

-- ============================================================
-- DATA PENDUKUNG (fixture): dua klinik terpisah, A=9001 dan B=9002
-- Bila bagian ini error, seluruh skrip berhenti (sengaja, agar jelas).
-- ============================================================
INSERT INTO paket_langganan (id_paket, nama_paket, deskripsi_fitur, harga_bulanan) OVERRIDING SYSTEM VALUE
VALUES (9001, 'UJI', 'fixture', 1000);

INSERT INTO klinik (id_klinik, id_paket, nama_klinik, alamat, kontak, no_izin) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'Klinik Uji A', 'Jl. Uji 1', '0000', 'IZIN-UJI-A'),
       (9002, 9001, 'Klinik Uji B', 'Jl. Uji 2', '0000', 'IZIN-UJI-B');

INSERT INTO akun_pengguna (id_akun, id_klinik, username, password_hash, nama_lengkap, peran) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'uji_kasir_a',  'x', 'Kasir A',  'kasir'),
       (9002, 9002, 'uji_kasir_b',  'x', 'Kasir B',  'kasir'),
       (9003, 9001, 'uji_dokter_a', 'x', 'Dokter A', 'dokter');

INSERT INTO tenaga_medis (id_tenaga_medis, id_klinik, nama, jenis_tenaga, no_str) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'dr. Uji A', 'dokter', 'STR-UJI-A'),
       (9002, 9002, 'dr. Uji B', 'dokter', 'STR-UJI-B');

INSERT INTO pasien (id_pasien, id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'RM-UJI-1', 'Pasien Uji A', '1990-01-01', 'laki-laki'),
       (9002, 9002, 'RM-UJI-9', 'Pasien Uji B', '1991-02-02', 'perempuan');

INSERT INTO obat (id_obat, id_klinik, kode_obat, nama_obat, satuan, harga_jual) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'OBT-UJI-1', 'Obat Uji A', 'tablet', 1000),
       (9002, 9002, 'OBT-UJI-2', 'Obat Uji B', 'tablet', 1000);

INSERT INTO layanan (id_layanan, id_klinik, kode_layanan, nama_layanan, tarif) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 'LYN-UJI-1', 'Layanan Uji A', 50000),
       (9002, 9002, 'LYN-UJI-2', 'Layanan Uji B', 50000);

INSERT INTO kunjungan (id_kunjungan, id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 9001, 1, 'onsite', 'umum'),
       (9002, 9002, 9002, 9002, 9002, 1, 'online', 'BPJS'),
       (9003, 9002, 9002, 9002, 9002, 2, 'onsite', 'umum');   -- 9003 sengaja dibiarkan tanpa rekam medis/tagihan

INSERT INTO rekam_medis (id_rekam_medis, id_klinik, id_kunjungan, id_tenaga_medis, keluhan) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 'Demam'),
       (9002, 9002, 9002, 9002, 'Batuk');

INSERT INTO resep (id_resep, id_klinik, id_rekam_medis, id_tenaga_medis) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001),
       (9002, 9002, 9002, 9002);

INSERT INTO detail_resep (id_detail_resep, id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 10, '500 mg', '3 x 1 sesudah makan'),
       (9002, 9002, 9002, 9002, 10, '500 mg', '3 x 1 sesudah makan');

INSERT INTO stok_obat (id_stok, id_klinik, id_obat, no_batch, jumlah, tgl_masuk, tgl_kedaluwarsa) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 'B-UJI-1', 100, '2026-01-01', '2028-01-01'),
       (9002, 9002, 9002, 'B-UJI-2', 100, '2026-01-01', '2028-01-01');

INSERT INTO penyerahan_obat (id_penyerahan, id_klinik, id_detail_resep, id_stok, id_akun, jumlah) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 9001, 5);

INSERT INTO tagihan (id_tagihan, id_klinik, id_kunjungan, total) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 100000),
       (9002, 9002, 9002, 0);

INSERT INTO detail_tagihan (id_detail_tagihan, id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 'Konsultasi', 2, 50000, 100000);

INSERT INTO pembayaran (id_pembayaran, id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 9001, 100000, 'tunai');

INSERT INTO audit_log (id_log, id_klinik, id_akun, aksi, entitas, id_entitas, alamat_ip) OVERRIDING SYSTEM VALUE
VALUES (9001, 9001, 9001, 'login', 'akun_pengguna', 9001, '127.0.0.1');


-- ============================================================
-- 1. paket_langganan
-- ============================================================
PERFORM pg_temp.uji('paket_langganan', 'harga_bulanan negatif ditolak', '23514', 'paket_langganan_harga_bulanan_check%',
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES ('X', 'Y', -1)$q$);
PERFORM pg_temp.uji('paket_langganan', 'nama_paket NULL ditolak', '23502', 'nama_paket',
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES (NULL, 'Y', 1)$q$);
PERFORM pg_temp.uji('paket_langganan', 'deskripsi_fitur NULL ditolak', '23502', 'deskripsi_fitur',
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES ('X', NULL, 1)$q$);
PERFORM pg_temp.uji('paket_langganan', 'harga_bulanan NULL ditolak', '23502', 'harga_bulanan',
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES ('X', 'Y', NULL)$q$);
PERFORM pg_temp.uji('paket_langganan', 'nama_paket 51 karakter (batas VARCHAR(50)) ditolak', '22001', NULL,
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES (repeat('x', 51), 'Y', 1)$q$);
PERFORM pg_temp.uji('paket_langganan', 'harga_bulanan 1 triliun (melebihi NUMERIC(14,2)) ditolak', '22003', NULL,
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES ('X', 'Y', 1000000000000)$q$);
PERFORM pg_temp.uji('paket_langganan', 'ID diisi manual pada GENERATED ALWAYS ditolak', '428C9', NULL,
  $q$INSERT INTO paket_langganan (id_paket, nama_paket, deskripsi_fitur, harga_bulanan) VALUES (9100, 'X', 'Y', 1)$q$);
PERFORM pg_temp.uji_ok('paket_langganan', 'paket valid dengan harga 0 (gratis) diterima',
  $q$INSERT INTO paket_langganan (nama_paket, deskripsi_fitur, harga_bulanan) VALUES ('Gratis Uji', 'Uji', 0)$q$);
PERFORM pg_temp.tegas('paket_langganan', 'default status_aktif = TRUE',
  $q$SELECT status_aktif FROM paket_langganan WHERE id_paket = 9001$q$);

-- ============================================================
-- 2. klinik
-- ============================================================
PERFORM pg_temp.uji('klinik', 'status_langganan di luar daftar ditolak', '23514', 'klinik_status_langganan_check%',
  $q$INSERT INTO klinik (id_paket, nama_klinik, alamat, kontak, no_izin, status_langganan) VALUES (9001, 'K', 'A', 'B', 'C', 'tutup')$q$);
PERFORM pg_temp.uji('klinik', 'id_paket tidak ada ditolak', '23503', 'fk_klinik_id_paket',
  $q$INSERT INTO klinik (id_paket, nama_klinik, alamat, kontak, no_izin) VALUES (999999, 'K', 'A', 'B', 'C')$q$);
PERFORM pg_temp.uji('klinik', 'alamat NULL ditolak', '23502', 'alamat',
  $q$INSERT INTO klinik (id_paket, nama_klinik, alamat, kontak, no_izin) VALUES (9001, 'K', NULL, 'B', 'C')$q$);
PERFORM pg_temp.uji('klinik', 'no_izin NULL ditolak', '23502', 'no_izin',
  $q$INSERT INTO klinik (id_paket, nama_klinik, alamat, kontak, no_izin) VALUES (9001, 'K', 'A', 'B', NULL)$q$);
PERFORM pg_temp.uji('klinik', 'paket yang dipakai klinik tidak boleh dihapus (RESTRICT)', '23503', 'fk_klinik_id_paket',
  $q$DELETE FROM paket_langganan WHERE id_paket = 9001$q$);
PERFORM pg_temp.tegas('klinik', 'default status_langganan = aktif dan tgl_bergabung = hari ini',
  $q$SELECT status_langganan = 'aktif' AND tgl_bergabung = CURRENT_DATE FROM klinik WHERE id_klinik = 9001$q$);

-- ============================================================
-- 3. tagihan_langganan
-- ============================================================
PERFORM pg_temp.uji('tagihan_langganan', 'periode bulan 13 ditolak', '23514', 'tagihan_langganan_periode_check%',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026-13', 1000, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'periode bulan 00 ditolak', '23514', 'tagihan_langganan_periode_check%',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026-00', 1000, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'periode berformat YYYY/MM ditolak', '23514', 'tagihan_langganan_periode_check%',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026/11', 1000, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'jumlah negatif ditolak', '23514', 'tagihan_langganan_jumlah_check%',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026-11', -1, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'status_bayar di luar daftar ditolak', '23514', 'tagihan_langganan_status_bayar_check%',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo, status_bayar) VALUES (9001, '2026-11', 1000, '2026-12-10', 'lunas')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'id_klinik tidak ada ditolak', '23503', 'fk_tagihan_langganan_id_klinik',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (999999, '2026-11', 1000, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'tgl_jatuh_tempo NULL ditolak', '23502', 'tgl_jatuh_tempo',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah) VALUES (9001, '2026-11', 1000)$q$);
PERFORM pg_temp.uji_ok('tagihan_langganan', 'tagihan valid diterima',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026-11', 299000, '2026-12-10')$q$);
PERFORM pg_temp.uji('tagihan_langganan', 'periode ganda untuk klinik yang sama ditolak', '23505', 'uq_tagihan_langganan_periode',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9001, '2026-11', 299000, '2026-12-10')$q$);
PERFORM pg_temp.uji_ok('tagihan_langganan', 'periode yang sama untuk klinik lain diterima',
  $q$INSERT INTO tagihan_langganan (id_klinik, periode, jumlah, tgl_jatuh_tempo) VALUES (9002, '2026-11', 299000, '2026-12-10')$q$);
PERFORM pg_temp.tegas('tagihan_langganan', 'default status_bayar = belum dibayar',
  $q$SELECT status_bayar = 'belum dibayar' FROM tagihan_langganan WHERE id_klinik = 9001 AND periode = '2026-11'$q$);

-- ============================================================
-- 4. akun_pengguna
-- ============================================================
PERFORM pg_temp.uji('akun_pengguna', 'username ganda ditolak', '23505', 'akun_pengguna_username_key',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (9001, 'uji_kasir_a', 'x', 'N', 'kasir')$q$);
PERFORM pg_temp.uji('akun_pengguna', 'peran di luar daftar ditolak', '23514', 'akun_pengguna_peran_check%',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (9001, 'uji_x1', 'x', 'N', 'satpam')$q$);
PERFORM pg_temp.uji('akun_pengguna', 'status_akun di luar daftar ditolak', '23514', 'akun_pengguna_status_akun_check%',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran, status_akun) VALUES (9001, 'uji_x2', 'x', 'N', 'kasir', 'cuti')$q$);
PERFORM pg_temp.uji('akun_pengguna', 'id_klinik tidak ada ditolak', '23503', 'fk_akun_pengguna_id_klinik',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (999999, 'uji_x3', 'x', 'N', 'kasir')$q$);
PERFORM pg_temp.uji('akun_pengguna', 'password_hash NULL ditolak', '23502', 'password_hash',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (9001, 'uji_x4', NULL, 'N', 'kasir')$q$);
PERFORM pg_temp.uji('akun_pengguna', 'username NULL ditolak', '23502', 'username',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (9001, NULL, 'x', 'N', 'kasir')$q$);
PERFORM pg_temp.uji_ok('akun_pengguna', 'akun platform tanpa klinik (id_klinik NULL) diterima',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran) VALUES (NULL, 'uji_cs', 'x', 'CS Uji', 'customer success')$q$);
PERFORM pg_temp.uji_ok('akun_pengguna', 'semua 11 nilai peran yang sah diterima',
  $q$INSERT INTO akun_pengguna (id_klinik, username, password_hash, nama_lengkap, peran)
     SELECT 9001, 'uji_peran_' || i, 'x', 'Peran ' || i, p
     FROM unnest(ARRAY['petugas pendaftaran','perawat/bidan','dokter','kasir','apoteker','manajer operasional',
                       'keuangan/pimpinan','admin klinik','customer success','pemilik siklinik','admin keuangan siklinik'])
          WITH ORDINALITY AS t(p, i)$q$);
PERFORM pg_temp.uji('akun_pengguna', 'klinik yang punya akun tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM klinik WHERE id_klinik = 9001$q$);
PERFORM pg_temp.uji('akun_pengguna', 'akun yang punya riwayat tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM akun_pengguna WHERE id_akun = 9001$q$);
PERFORM pg_temp.tegas('akun_pengguna', 'default mfa_aktif = FALSE dan status_akun = aktif',
  $q$SELECT NOT mfa_aktif AND status_akun = 'aktif' FROM akun_pengguna WHERE id_akun = 9001$q$);

-- ============================================================
-- 5. audit_log (append-only)
-- ============================================================
PERFORM pg_temp.uji('audit_log', 'aksi di luar daftar ditolak', '23514', 'audit_log_aksi_check%',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (9001, 9001, 'export', 'pasien', '10.0.0.1')$q$);
PERFORM pg_temp.uji('audit_log', 'id_akun tidak ada ditolak', '23503', 'fk_audit_log_id_akun',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (9001, 999999, 'baca', 'pasien', '10.0.0.1')$q$);
PERFORM pg_temp.uji('audit_log', 'id_klinik tidak ada ditolak', '23503', 'fk_audit_log_id_klinik',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (999999, 9001, 'baca', 'pasien', '10.0.0.1')$q$);
PERFORM pg_temp.uji('audit_log', 'alamat_ip NULL ditolak', '23502', 'alamat_ip',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (9001, 9001, 'baca', 'pasien', NULL)$q$);
PERFORM pg_temp.uji('audit_log', 'entitas NULL ditolak', '23502', 'entitas',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (9001, 9001, 'baca', NULL, '10.0.0.1')$q$);
PERFORM pg_temp.uji_ok('audit_log', 'log tingkat platform (id_klinik NULL) diterima',
  $q$INSERT INTO audit_log (id_klinik, id_akun, aksi, entitas, alamat_ip) VALUES (NULL, 9001, 'baca', 'klinik', '10.0.0.1')$q$);
PERFORM pg_temp.uji('audit_log', 'UPDATE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$UPDATE audit_log SET aksi = 'baca' WHERE id_log = 9001$q$);
PERFORM pg_temp.uji('audit_log', 'DELETE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$DELETE FROM audit_log WHERE id_log = 9001$q$);

-- ============================================================
-- 6. pasien
-- ============================================================
PERFORM pg_temp.uji('pasien', 'NIK 15 digit ditolak', '23514', 'pasien_nik_check%',
  $q$INSERT INTO pasien (id_klinik, no_rm, nik, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', '123456789012345', 'N', '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'NIK 17 digit ditolak', '22001', NULL,
  $q$INSERT INTO pasien (id_klinik, no_rm, nik, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', '12345678901234567', 'N', '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'NIK berisi huruf ditolak', '23514', 'pasien_nik_check%',
  $q$INSERT INTO pasien (id_klinik, no_rm, nik, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', '12345678901234AB', 'N', '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'tgl_lahir di masa depan ditolak', '23514', 'pasien_tgl_lahir_check%',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', 'N', CURRENT_DATE + 1, 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'jenis_kelamin "L" (bukan laki-laki/perempuan) ditolak', '23514', 'pasien_jenis_kelamin_check%',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', 'N', '1990-01-01', 'L')$q$);
PERFORM pg_temp.uji('pasien', 'no_rm ganda dalam klinik yang sama ditolak', '23505', 'uq_pasien_no_rm',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-1', 'N', '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'id_klinik tidak ada ditolak', '23503', 'fk_pasien_id_klinik',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (999999, 'RM-UJI-2', 'N', '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'nama NULL ditolak', '23502', 'nama',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-2', NULL, '1990-01-01', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'tgl_lahir NULL ditolak', '23502', 'tgl_lahir',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, jenis_kelamin) VALUES (9001, 'RM-UJI-2', 'N', 'laki-laki')$q$);
PERFORM pg_temp.uji_ok('pasien', 'no_rm yang sama di klinik lain diterima (isolasi tenant)',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9002, 'RM-UJI-1', 'Pasien Uji C', '1985-05-05', 'perempuan')$q$);
PERFORM pg_temp.uji_ok('pasien', 'pasien tanpa NIK/alamat/telepon/BPJS diterima (kolom opsional)',
  $q$INSERT INTO pasien (id_klinik, no_rm, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-3', 'Pasien Uji D', CURRENT_DATE, 'perempuan')$q$);
PERFORM pg_temp.uji_ok('pasien', 'NIK 16 digit valid diterima',
  $q$INSERT INTO pasien (id_klinik, no_rm, nik, nama, tgl_lahir, jenis_kelamin) VALUES (9001, 'RM-UJI-4', '1571051403852051', 'Pasien Uji E', '1985-03-14', 'laki-laki')$q$);
PERFORM pg_temp.uji('pasien', 'pasien yang punya kunjungan tidak boleh dihapus (RESTRICT)', '23503', 'fk_kunjungan_id_pasien',
  $q$DELETE FROM pasien WHERE id_pasien = 9001$q$);
PERFORM pg_temp.tegas('pasien', 'default status_aktif = TRUE dan tgl_registrasi = hari ini',
  $q$SELECT status_aktif AND tgl_registrasi = CURRENT_DATE FROM pasien WHERE id_pasien = 9001$q$);

-- ============================================================
-- 7. tenaga_medis
-- ============================================================
PERFORM pg_temp.uji('tenaga_medis', 'jenis_tenaga di luar daftar ditolak', '23514', 'tenaga_medis_jenis_tenaga_check%',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga, no_str) VALUES (9001, 'N', 'dokter gigi', 'STR-X1')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'no_str ganda dalam klinik yang sama ditolak', '23505', 'uq_tenaga_medis_no_str',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga, no_str) VALUES (9001, 'N', 'dokter', 'STR-UJI-A')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'id_akun tidak ada ditolak', '23503', 'fk_tenaga_medis_id_akun',
  $q$INSERT INTO tenaga_medis (id_klinik, id_akun, nama, jenis_tenaga, no_str) VALUES (9001, 999999, 'N', 'dokter', 'STR-X2')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'id_klinik tidak ada ditolak', '23503', 'fk_tenaga_medis_id_klinik',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga, no_str) VALUES (999999, 'N', 'dokter', 'STR-X3')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'nama NULL ditolak', '23502', 'nama',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga, no_str) VALUES (9001, NULL, 'dokter', 'STR-X4')$q$);
PERFORM pg_temp.uji_ok('tenaga_medis', 'no_str yang sama di klinik lain diterima',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga, no_str) VALUES (9002, 'dr. Uji C', 'dokter', 'STR-UJI-A')$q$);
PERFORM pg_temp.uji_ok('tenaga_medis', 'beberapa tenaga tanpa no_str (NULL) dalam satu klinik diterima',
  $q$INSERT INTO tenaga_medis (id_klinik, nama, jenis_tenaga) VALUES (9001, 'Ns. Uji 1', 'perawat'), (9001, 'Ns. Uji 2', 'perawat')$q$);
PERFORM pg_temp.uji_ok('tenaga_medis', 'tenaga terhubung ke akun diterima',
  $q$INSERT INTO tenaga_medis (id_klinik, id_akun, nama, jenis_tenaga, no_str) VALUES (9001, 9003, 'dr. Uji D', 'dokter', 'STR-UJI-D')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'satu akun dipakai dua tenaga medis ditolak', '23505', 'tenaga_medis_id_akun_key',
  $q$INSERT INTO tenaga_medis (id_klinik, id_akun, nama, jenis_tenaga, no_str) VALUES (9001, 9003, 'dr. Uji E', 'dokter', 'STR-UJI-E')$q$);
PERFORM pg_temp.uji('tenaga_medis', 'tenaga yang punya kunjungan/jadwal tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM tenaga_medis WHERE id_tenaga_medis = 9001$q$);

-- ============================================================
-- 8. jadwal_dokter
-- ============================================================
PERFORM pg_temp.uji('jadwal_dokter', 'jam_selesai sama dengan jam_mulai ditolak', '23514', 'ck_jadwal_jam',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9001, 'senin', '08:00', '08:00', 10)$q$);
PERFORM pg_temp.uji('jadwal_dokter', 'jam_selesai lebih awal dari jam_mulai ditolak', '23514', 'ck_jadwal_jam',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9001, 'senin', '12:00', '08:00', 10)$q$);
PERFORM pg_temp.uji('jadwal_dokter', 'kuota 0 ditolak', '23514', 'jadwal_dokter_kuota_check%',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9001, 'senin', '08:00', '12:00', 0)$q$);
PERFORM pg_temp.uji('jadwal_dokter', 'hari di luar daftar ("monday") ditolak', '23514', 'jadwal_dokter_hari_check%',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9001, 'monday', '08:00', '12:00', 10)$q$);
PERFORM pg_temp.uji('jadwal_dokter', 'tenaga medis milik klinik lain ditolak (FK komposit)', '23503', 'fk_jadwal_dokter_id_tenaga_medis',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9002, 'senin', '08:00', '12:00', 10)$q$);
PERFORM pg_temp.uji('jadwal_dokter', 'kuota NULL ditolak', '23502', 'kuota',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai) VALUES (9001, 9001, 'senin', '08:00', '12:00')$q$);
PERFORM pg_temp.uji_ok('jadwal_dokter', 'jadwal valid diterima',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota) VALUES (9001, 9001, 'senin', '08:00', '12:00', 20)$q$);
PERFORM pg_temp.uji_ok('jadwal_dokter', 'ketujuh nilai hari yang sah diterima',
  $q$INSERT INTO jadwal_dokter (id_klinik, id_tenaga_medis, hari, jam_mulai, jam_selesai, kuota)
     SELECT 9002, 9002, h, '08:00', '12:00', 5
     FROM unnest(ARRAY['senin','selasa','rabu','kamis','jumat','sabtu','minggu']) AS h$q$);

-- ============================================================
-- 9. kunjungan
-- ============================================================
PERFORM pg_temp.uji('kunjungan', 'no_antrian 0 ditolak', '23514', 'kunjungan_no_antrian_check%',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 9001, 0, 'onsite', 'umum')$q$);
PERFORM pg_temp.uji('kunjungan', 'jenis_pendaftaran di luar daftar ditolak', '23514', 'kunjungan_jenis_pendaftaran_check%',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 9001, 5, 'telepon', 'umum')$q$);
PERFORM pg_temp.uji('kunjungan', 'jenis_penjamin di luar daftar ditolak', '23514', 'kunjungan_jenis_penjamin_check%',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 9001, 5, 'onsite', 'swasta')$q$);
PERFORM pg_temp.uji('kunjungan', 'status_kunjungan di luar daftar ditolak', '23514', 'kunjungan_status_kunjungan_check%',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin, status_kunjungan) VALUES (9001, 9001, 9001, 9001, 5, 'onsite', 'umum', 'ditunda')$q$);
PERFORM pg_temp.uji('kunjungan', 'pasien milik klinik lain ditolak (FK komposit)', '23503', 'fk_kunjungan_id_pasien',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9002, 9001, 9001, 5, 'onsite', 'umum')$q$);
PERFORM pg_temp.uji('kunjungan', 'tenaga medis milik klinik lain ditolak (FK komposit)', '23503', 'fk_kunjungan_id_tenaga_medis',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9002, 9001, 5, 'onsite', 'umum')$q$);
PERFORM pg_temp.uji('kunjungan', 'id_akun tidak ada ditolak', '23503', 'fk_kunjungan_id_akun',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 999999, 5, 'onsite', 'umum')$q$);
PERFORM pg_temp.uji('kunjungan', 'no_antrian NULL ditolak', '23502', 'no_antrian',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 9001, 'onsite', 'umum')$q$);
PERFORM pg_temp.uji_ok('kunjungan', 'kunjungan valid (penjamin asuransi, daftar online) diterima',
  $q$INSERT INTO kunjungan (id_klinik, id_pasien, id_tenaga_medis, id_akun, no_antrian, jenis_pendaftaran, jenis_penjamin) VALUES (9001, 9001, 9001, 9001, 5, 'online', 'asuransi')$q$);
PERFORM pg_temp.tegas('kunjungan', 'default status_kunjungan = menunggu',
  $q$SELECT status_kunjungan = 'menunggu' FROM kunjungan WHERE id_kunjungan = 9001$q$);
PERFORM pg_temp.uji('kunjungan', 'kunjungan yang punya rekam medis tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM kunjungan WHERE id_kunjungan = 9001$q$);

-- ============================================================
-- 10. rekam_medis
-- ============================================================
PERFORM pg_temp.uji('rekam_medis', 'satu kunjungan dua rekam medis ditolak', '23505', 'rekam_medis_id_kunjungan_key',
  $q$INSERT INTO rekam_medis (id_klinik, id_kunjungan, id_tenaga_medis, keluhan) VALUES (9001, 9001, 9001, 'Ulang')$q$);
PERFORM pg_temp.uji('rekam_medis', 'keluhan NULL ditolak', '23502', 'keluhan',
  $q$INSERT INTO rekam_medis (id_klinik, id_kunjungan, id_tenaga_medis) VALUES (9002, 9003, 9002)$q$);
PERFORM pg_temp.uji('rekam_medis', 'kunjungan milik klinik lain ditolak (FK komposit)', '23503', 'fk_rekam_medis_id_kunjungan',
  $q$INSERT INTO rekam_medis (id_klinik, id_kunjungan, id_tenaga_medis, keluhan) VALUES (9001, 9003, 9001, 'X')$q$);
PERFORM pg_temp.uji('rekam_medis', 'tenaga medis milik klinik lain ditolak (FK komposit)', '23503', 'fk_rekam_medis_id_tenaga_medis',
  $q$INSERT INTO rekam_medis (id_klinik, id_kunjungan, id_tenaga_medis, keluhan) VALUES (9002, 9003, 9001, 'X')$q$);
PERFORM pg_temp.uji('rekam_medis', 'rekam medis yang punya resep tidak boleh dihapus (RESTRICT)', '23503', 'fk_resep_id_rekam_medis',
  $q$DELETE FROM rekam_medis WHERE id_rekam_medis = 9001$q$);

-- ============================================================
-- 11. resep
-- ============================================================
PERFORM pg_temp.uji('resep', 'status_resep di luar daftar ditolak', '23514', 'resep_status_resep_check%',
  $q$INSERT INTO resep (id_klinik, id_rekam_medis, id_tenaga_medis, status_resep) VALUES (9001, 9001, 9001, 'selesai')$q$);
PERFORM pg_temp.uji('resep', 'rekam medis milik klinik lain ditolak (FK komposit)', '23503', 'fk_resep_id_rekam_medis',
  $q$INSERT INTO resep (id_klinik, id_rekam_medis, id_tenaga_medis) VALUES (9001, 9002, 9001)$q$);
PERFORM pg_temp.uji('resep', 'tenaga medis milik klinik lain ditolak (FK komposit)', '23503', 'fk_resep_id_tenaga_medis',
  $q$INSERT INTO resep (id_klinik, id_rekam_medis, id_tenaga_medis) VALUES (9001, 9001, 9002)$q$);
PERFORM pg_temp.uji_ok('resep', 'resep kedua pada rekam medis yang sama diterima (boleh >1 resep)',
  $q$INSERT INTO resep (id_klinik, id_rekam_medis, id_tenaga_medis) VALUES (9001, 9001, 9001)$q$);
PERFORM pg_temp.tegas('resep', 'default status_resep = menunggu',
  $q$SELECT status_resep = 'menunggu' FROM resep WHERE id_resep = 9001$q$);

-- ============================================================
-- 12. obat
-- ============================================================
PERFORM pg_temp.uji('obat', 'kode_obat ganda dalam klinik yang sama ditolak', '23505', 'uq_obat_kode',
  $q$INSERT INTO obat (id_klinik, kode_obat, nama_obat, satuan, harga_jual) VALUES (9001, 'OBT-UJI-1', 'N', 'tablet', 1)$q$);
PERFORM pg_temp.uji('obat', 'harga_jual negatif ditolak', '23514', 'obat_harga_jual_check%',
  $q$INSERT INTO obat (id_klinik, kode_obat, nama_obat, satuan, harga_jual) VALUES (9001, 'OBT-X1', 'N', 'tablet', -1)$q$);
PERFORM pg_temp.uji('obat', 'satuan NULL ditolak', '23502', 'satuan',
  $q$INSERT INTO obat (id_klinik, kode_obat, nama_obat, harga_jual) VALUES (9001, 'OBT-X2', 'N', 1)$q$);
PERFORM pg_temp.uji('obat', 'id_klinik tidak ada ditolak', '23503', 'fk_obat_id_klinik',
  $q$INSERT INTO obat (id_klinik, kode_obat, nama_obat, satuan, harga_jual) VALUES (999999, 'OBT-X3', 'N', 'tablet', 1)$q$);
PERFORM pg_temp.uji_ok('obat', 'kode_obat yang sama di klinik lain diterima',
  $q$INSERT INTO obat (id_klinik, kode_obat, nama_obat, satuan, harga_jual) VALUES (9002, 'OBT-UJI-1', 'Obat Uji C', 'tablet', 0)$q$);
PERFORM pg_temp.uji('obat', 'obat yang punya stok/resep tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM obat WHERE id_obat = 9001$q$);

-- ============================================================
-- 13. detail_resep
-- ============================================================
PERFORM pg_temp.uji('detail_resep', 'jumlah 0 ditolak', '23514', 'detail_resep_jumlah_check%',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai) VALUES (9001, 9001, 9001, 0, 'd', 'a')$q$);
PERFORM pg_temp.uji('detail_resep', 'obat yang sama dua kali dalam satu resep ditolak', '23505', 'uq_detail_resep_obat',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai) VALUES (9001, 9001, 9001, 5, 'd', 'a')$q$);
PERFORM pg_temp.uji('detail_resep', 'obat milik klinik lain ditolak (FK komposit)', '23503', 'fk_detail_resep_id_obat',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai) VALUES (9001, 9001, 9002, 5, 'd', 'a')$q$);
PERFORM pg_temp.uji('detail_resep', 'resep milik klinik lain ditolak (FK komposit)', '23503', 'fk_detail_resep_id_resep',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai) VALUES (9001, 9002, 9001, 5, 'd', 'a')$q$);
PERFORM pg_temp.uji('detail_resep', 'dosis NULL ditolak', '23502', 'dosis',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, aturan_pakai) VALUES (9001, 9001, 9001, 5, 'a')$q$);
PERFORM pg_temp.uji('detail_resep', 'aturan_pakai NULL ditolak', '23502', 'aturan_pakai',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis) VALUES (9001, 9001, 9001, 5, 'd')$q$);
PERFORM pg_temp.uji_ok('detail_resep', 'obat yang sama pada resep berbeda diterima',
  $q$INSERT INTO detail_resep (id_klinik, id_resep, id_obat, jumlah, dosis, aturan_pakai)
     SELECT 9001, r.id_resep, 9001, 3, '500 mg', '2 x 1'
     FROM resep r WHERE r.id_klinik = 9001 AND r.id_resep <> 9001 LIMIT 1$q$);

-- ============================================================
-- 14. stok_obat
-- ============================================================
PERFORM pg_temp.uji('stok_obat', 'jumlah negatif ditolak', '23514', 'stok_obat_jumlah_check%',
  $q$INSERT INTO stok_obat (id_klinik, id_obat, no_batch, jumlah, tgl_masuk, tgl_kedaluwarsa) VALUES (9001, 9001, 'B-X1', -1, '2026-01-01', '2028-01-01')$q$);
PERFORM pg_temp.uji('stok_obat', 'tgl_kedaluwarsa lebih awal dari tgl_masuk ditolak', '23514', 'ck_stok_kedaluwarsa',
  $q$INSERT INTO stok_obat (id_klinik, id_obat, no_batch, jumlah, tgl_masuk, tgl_kedaluwarsa) VALUES (9001, 9001, 'B-X2', 10, '2026-06-01', '2026-01-01')$q$);
PERFORM pg_temp.uji('stok_obat', 'obat milik klinik lain ditolak (FK komposit)', '23503', 'fk_stok_obat_id_obat',
  $q$INSERT INTO stok_obat (id_klinik, id_obat, no_batch, jumlah, tgl_masuk, tgl_kedaluwarsa) VALUES (9001, 9002, 'B-X3', 10, '2026-01-01', '2028-01-01')$q$);
PERFORM pg_temp.uji('stok_obat', 'tgl_kedaluwarsa NULL ditolak', '23502', 'tgl_kedaluwarsa',
  $q$INSERT INTO stok_obat (id_klinik, id_obat, no_batch, jumlah, tgl_masuk) VALUES (9001, 9001, 'B-X4', 10, '2026-01-01')$q$);
PERFORM pg_temp.uji_ok('stok_obat', 'stok jumlah 0 (habis) dan kedaluwarsa = tgl masuk diterima',
  $q$INSERT INTO stok_obat (id_klinik, id_obat, no_batch, jumlah, tgl_masuk, tgl_kedaluwarsa) VALUES (9001, 9001, 'B-UJI-0', 0, '2026-01-01', '2026-01-01')$q$);

-- ============================================================
-- 15. penyerahan_obat (append-only)
-- ============================================================
PERFORM pg_temp.uji('penyerahan_obat', 'jumlah 0 ditolak', '23514', 'penyerahan_obat_jumlah_check%',
  $q$INSERT INTO penyerahan_obat (id_klinik, id_detail_resep, id_stok, id_akun, jumlah) VALUES (9001, 9001, 9001, 9001, 0)$q$);
PERFORM pg_temp.uji('penyerahan_obat', 'detail_resep milik klinik lain ditolak (FK komposit)', '23503', 'fk_penyerahan_obat_id_detail_resep',
  $q$INSERT INTO penyerahan_obat (id_klinik, id_detail_resep, id_stok, id_akun, jumlah) VALUES (9001, 9002, 9001, 9001, 1)$q$);
PERFORM pg_temp.uji('penyerahan_obat', 'stok milik klinik lain ditolak (FK komposit)', '23503', 'fk_penyerahan_obat_id_stok',
  $q$INSERT INTO penyerahan_obat (id_klinik, id_detail_resep, id_stok, id_akun, jumlah) VALUES (9001, 9001, 9002, 9001, 1)$q$);
PERFORM pg_temp.uji('penyerahan_obat', 'id_akun tidak ada ditolak', '23503', 'fk_penyerahan_obat_id_akun',
  $q$INSERT INTO penyerahan_obat (id_klinik, id_detail_resep, id_stok, id_akun, jumlah) VALUES (9001, 9001, 9001, 999999, 1)$q$);
PERFORM pg_temp.uji_ok('penyerahan_obat', 'penyerahan bertahap (kedua) untuk detail resep yang sama diterima',
  $q$INSERT INTO penyerahan_obat (id_klinik, id_detail_resep, id_stok, id_akun, jumlah) VALUES (9001, 9001, 9001, 9001, 2)$q$);
PERFORM pg_temp.uji('penyerahan_obat', 'UPDATE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$UPDATE penyerahan_obat SET jumlah = 1 WHERE id_penyerahan = 9001$q$);
PERFORM pg_temp.uji('penyerahan_obat', 'DELETE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$DELETE FROM penyerahan_obat WHERE id_penyerahan = 9001$q$);

-- ============================================================
-- 16. layanan
-- ============================================================
PERFORM pg_temp.uji('layanan', 'kode_layanan ganda dalam klinik yang sama ditolak', '23505', 'uq_layanan_kode',
  $q$INSERT INTO layanan (id_klinik, kode_layanan, nama_layanan, tarif) VALUES (9001, 'LYN-UJI-1', 'N', 1)$q$);
PERFORM pg_temp.uji('layanan', 'tarif negatif ditolak', '23514', 'layanan_tarif_check%',
  $q$INSERT INTO layanan (id_klinik, kode_layanan, nama_layanan, tarif) VALUES (9001, 'LYN-X1', 'N', -1)$q$);
PERFORM pg_temp.uji('layanan', 'nama_layanan NULL ditolak', '23502', 'nama_layanan',
  $q$INSERT INTO layanan (id_klinik, kode_layanan, tarif) VALUES (9001, 'LYN-X2', 1)$q$);
PERFORM pg_temp.uji('layanan', 'id_klinik tidak ada ditolak', '23503', 'fk_layanan_id_klinik',
  $q$INSERT INTO layanan (id_klinik, kode_layanan, nama_layanan, tarif) VALUES (999999, 'LYN-X3', 'N', 1)$q$);
PERFORM pg_temp.uji_ok('layanan', 'kode_layanan yang sama di klinik lain diterima; tarif 0 diterima',
  $q$INSERT INTO layanan (id_klinik, kode_layanan, nama_layanan, tarif) VALUES (9002, 'LYN-UJI-1', 'Layanan Gratis', 0)$q$);
PERFORM pg_temp.uji('layanan', 'layanan yang sudah ditagihkan tidak boleh dihapus (RESTRICT)', '23503', 'fk_detail_tagihan_id_layanan',
  $q$DELETE FROM layanan WHERE id_layanan = 9001$q$);

-- ============================================================
-- 17. tagihan
-- ============================================================
PERFORM pg_temp.uji('tagihan', 'satu kunjungan dua tagihan ditolak', '23505', 'tagihan_id_kunjungan_key',
  $q$INSERT INTO tagihan (id_klinik, id_kunjungan) VALUES (9001, 9001)$q$);
PERFORM pg_temp.uji('tagihan', 'total negatif ditolak', '23514', 'tagihan_total_check%',
  $q$INSERT INTO tagihan (id_klinik, id_kunjungan, total) VALUES (9002, 9003, -1)$q$);
PERFORM pg_temp.uji('tagihan', 'status_tagihan di luar daftar ditolak', '23514', 'tagihan_status_tagihan_check%',
  $q$INSERT INTO tagihan (id_klinik, id_kunjungan, status_tagihan) VALUES (9002, 9003, 'void')$q$);
PERFORM pg_temp.uji('tagihan', 'kunjungan milik klinik lain ditolak (FK komposit)', '23503', 'fk_tagihan_id_kunjungan',
  $q$INSERT INTO tagihan (id_klinik, id_kunjungan) VALUES (9001, 9003)$q$);
PERFORM pg_temp.tegas('tagihan', 'default total = 0 dan status_tagihan = belum lunas',
  $q$SELECT total = 0 AND status_tagihan = 'belum lunas' FROM tagihan WHERE id_tagihan = 9002$q$);
PERFORM pg_temp.uji('tagihan', 'tagihan yang punya detail/pembayaran tidak boleh dihapus (RESTRICT)', '23503', 'fk_%',
  $q$DELETE FROM tagihan WHERE id_tagihan = 9001$q$);

-- ============================================================
-- 18. detail_tagihan
-- ============================================================
PERFORM pg_temp.uji('detail_tagihan', 'layanan DAN detail_resep sama-sama terisi ditolak (XOR)', '23514', 'ck_detail_tagihan_sumber',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, id_detail_resep, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 9001, 'x', 1, 1000, 1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'layanan DAN detail_resep sama-sama kosong ditolak (XOR)', '23514', 'ck_detail_tagihan_sumber',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 'x', 1, 1000, 1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'subtotal tidak sama dengan qty x harga_satuan ditolak', '23514', 'ck_detail_tagihan_subtotal',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 'x', 2, 1000, 1999)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'qty 0 ditolak', '23514', 'detail_tagihan_qty_check%',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 'x', 0, 1000, 0)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'harga_satuan negatif ditolak (juga membuat subtotal negatif)', '23514', 'detail_tagihan_%check%',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 'x', 1, -1000, -1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'layanan milik klinik lain ditolak (FK komposit)', '23503', 'fk_detail_tagihan_id_layanan',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9002, 'x', 1, 1000, 1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'tagihan milik klinik lain ditolak (FK komposit)', '23503', 'fk_detail_tagihan_id_tagihan',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9002, 9001, 'x', 1, 1000, 1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'detail_resep milik klinik lain ditolak (FK komposit)', '23503', 'fk_detail_tagihan_id_detail_resep',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_detail_resep, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9002, 'x', 1, 1000, 1000)$q$);
PERFORM pg_temp.uji('detail_tagihan', 'deskripsi NULL ditolak', '23502', 'deskripsi',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 1, 1000, 1000)$q$);
PERFORM pg_temp.uji_ok('detail_tagihan', 'baris tagihan dari obat (id_detail_resep) diterima',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_detail_resep, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 'Obat', 10, 1000, 10000)$q$);
PERFORM pg_temp.uji_ok('detail_tagihan', 'baris layanan gratis (harga 0, subtotal 0) diterima',
  $q$INSERT INTO detail_tagihan (id_klinik, id_tagihan, id_layanan, deskripsi, qty, harga_satuan, subtotal) VALUES (9001, 9001, 9001, 'Gratis', 1, 0, 0)$q$);

-- ============================================================
-- 19. pembayaran (append-only)
-- ============================================================
PERFORM pg_temp.uji('pembayaran', 'jumlah_bayar 0 ditolak', '23514', 'pembayaran_jumlah_bayar_check%',
  $q$INSERT INTO pembayaran (id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar) VALUES (9001, 9001, 9001, 0, 'tunai')$q$);
PERFORM pg_temp.uji('pembayaran', 'metode_bayar di luar daftar ditolak', '23514', 'pembayaran_metode_bayar_check%',
  $q$INSERT INTO pembayaran (id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar) VALUES (9001, 9001, 9001, 1000, 'cek')$q$);
PERFORM pg_temp.uji('pembayaran', 'tagihan milik klinik lain ditolak (FK komposit)', '23503', 'fk_pembayaran_id_tagihan',
  $q$INSERT INTO pembayaran (id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar) VALUES (9001, 9002, 9001, 1000, 'tunai')$q$);
PERFORM pg_temp.uji('pembayaran', 'id_akun tidak ada ditolak', '23503', 'fk_pembayaran_id_akun',
  $q$INSERT INTO pembayaran (id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar) VALUES (9001, 9001, 999999, 1000, 'tunai')$q$);
PERFORM pg_temp.uji_ok('pembayaran', 'keempat metode bayar (tunai, transfer, QRIS, kartu) diterima',
  $q$INSERT INTO pembayaran (id_klinik, id_tagihan, id_akun, jumlah_bayar, metode_bayar)
     SELECT 9001, 9001, 9001, 1000, m FROM unnest(ARRAY['tunai','transfer','QRIS','kartu']) AS m$q$);
PERFORM pg_temp.uji('pembayaran', 'UPDATE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$UPDATE pembayaran SET jumlah_bayar = 1 WHERE id_pembayaran = 9001$q$);
PERFORM pg_temp.uji('pembayaran', 'DELETE ditolak trigger append-only', 'P0001', '%append-only%',
  $q$DELETE FROM pembayaran WHERE id_pembayaran = 9001$q$);

END
$uji$;


-- ============================================================
-- HASIL
-- ============================================================
-- Rincian: baris GAGAL tampil paling atas
SELECT no, tabel, deskripsi, diharapkan, diperoleh, status
FROM hasil_uji
ORDER BY (status = 'LULUS'), no;

-- Ringkasan per tabel
SELECT tabel,
       COUNT(*)                                  AS jumlah_uji,
       COUNT(*) FILTER (WHERE status = 'LULUS')  AS lulus,
       COUNT(*) FILTER (WHERE status = 'GAGAL')  AS gagal
FROM hasil_uji
GROUP BY tabel
ORDER BY MIN(no);

-- Ringkasan total
SELECT COUNT(*)                                  AS total_uji,
       COUNT(*) FILTER (WHERE status = 'LULUS')  AS lulus,
       COUNT(*) FILTER (WHERE status = 'GAGAL')  AS gagal
FROM hasil_uji;

-- Batalkan seluruh data uji (tabel & fungsi sementara ikut hilang)
ROLLBACK;
