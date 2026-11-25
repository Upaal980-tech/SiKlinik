-- ============================================================
-- Skema Fisik Platform SiKlinik (PostgreSQL 14 ke atas)
-- 19 tabel, bentuk normal ketiga (3NF), multi-tenant (id_klinik)
-- ============================================================

CREATE TABLE paket_langganan (
  id_paket BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama_paket VARCHAR(50) NOT NULL,
  deskripsi_fitur TEXT NOT NULL,
  harga_bulanan NUMERIC(14,2) NOT NULL CHECK (harga_bulanan >= 0),
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE klinik (
  id_klinik BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_paket BIGINT NOT NULL,
  nama_klinik VARCHAR(150) NOT NULL,
  alamat TEXT NOT NULL,
  kontak VARCHAR(100) NOT NULL,
  no_izin VARCHAR(50) NOT NULL,
  status_langganan VARCHAR(16) NOT NULL DEFAULT 'aktif' CHECK (status_langganan IN ('aktif',
      'ditangguhkan', 'berhenti')),
  tgl_bergabung DATE NOT NULL DEFAULT CURRENT_DATE,
  CONSTRAINT fk_klinik_id_paket FOREIGN KEY (id_paket)
    REFERENCES paket_langganan (id_paket) ON DELETE RESTRICT
);

CREATE TABLE tagihan_langganan (
  id_tagihan_langganan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  periode CHAR(7) NOT NULL CHECK (periode ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
  jumlah NUMERIC(14,2) NOT NULL CHECK (jumlah >= 0),
  tgl_jatuh_tempo DATE NOT NULL,
  status_bayar VARCHAR(17) NOT NULL DEFAULT 'belum dibayar' CHECK (status_bayar IN ('belum dibayar',
      'dibayar', 'terlambat')),
  tgl_bayar TIMESTAMPTZ,
  ref_payment_gateway VARCHAR(100),
  CONSTRAINT uq_tagihan_langganan_periode UNIQUE (id_klinik, periode),
  CONSTRAINT fk_tagihan_langganan_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT
);

CREATE TABLE akun_pengguna (
  id_akun BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  nama_lengkap VARCHAR(150) NOT NULL,
  peran VARCHAR(27) NOT NULL CHECK (peran IN ('petugas pendaftaran',
      'perawat/bidan', 'dokter', 'kasir', 'apoteker', 'manajer operasional',
      'keuangan/pimpinan', 'admin klinik', 'customer success', 'pemilik siklinik',
      'admin keuangan siklinik')),
  mfa_aktif BOOLEAN NOT NULL DEFAULT FALSE,
  status_akun VARCHAR(12) NOT NULL DEFAULT 'aktif' CHECK (status_akun IN ('aktif',
      'nonaktif', 'terkunci')),
  terakhir_login TIMESTAMPTZ,
  CONSTRAINT fk_akun_pengguna_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT
);

CREATE TABLE audit_log (
  id_log BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT,
  id_akun BIGINT NOT NULL,
  aksi VARCHAR(10) NOT NULL CHECK (aksi IN ('login', 'baca', 'tambah', 'ubah',
      'hapus')),
  entitas VARCHAR(50) NOT NULL,
  id_entitas BIGINT,
  waktu TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  alamat_ip VARCHAR(45) NOT NULL,
  CONSTRAINT fk_audit_log_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_audit_log_id_akun FOREIGN KEY (id_akun)
    REFERENCES akun_pengguna (id_akun) ON DELETE RESTRICT
);

CREATE TABLE pasien (
  id_pasien BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  no_rm VARCHAR(20) NOT NULL,
  nik CHAR(16) CHECK (nik ~ '^[0-9]{16}$'),
  nama VARCHAR(150) NOT NULL,
  tgl_lahir DATE NOT NULL CHECK (tgl_lahir <= CURRENT_DATE),
  jenis_kelamin VARCHAR(13) NOT NULL CHECK (jenis_kelamin IN ('laki-laki',
      'perempuan')),
  alamat TEXT,
  no_telepon VARCHAR(20),
  no_bpjs VARCHAR(20),
  id_satusehat VARCHAR(50),
  tgl_registrasi DATE NOT NULL DEFAULT CURRENT_DATE,
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_pasien_no_rm UNIQUE (id_klinik, no_rm),
  CONSTRAINT uq_pasien_klinik UNIQUE (id_klinik, id_pasien),
  CONSTRAINT fk_pasien_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT
);

CREATE TABLE tenaga_medis (
  id_tenaga_medis BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_akun BIGINT UNIQUE,
  nama VARCHAR(150) NOT NULL,
  jenis_tenaga VARCHAR(20) NOT NULL CHECK (jenis_tenaga IN ('dokter', 'perawat',
      'bidan', 'apoteker', 'asisten apoteker')),
  no_str VARCHAR(30),
  spesialisasi VARCHAR(100),
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_tenaga_medis_no_str UNIQUE (id_klinik, no_str),
  CONSTRAINT uq_tenaga_medis_klinik UNIQUE (id_klinik, id_tenaga_medis),
  CONSTRAINT fk_tenaga_medis_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_tenaga_medis_id_akun FOREIGN KEY (id_akun)
    REFERENCES akun_pengguna (id_akun) ON DELETE RESTRICT
);

CREATE TABLE jadwal_dokter (
  id_jadwal BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_tenaga_medis BIGINT NOT NULL,
  hari VARCHAR(10) NOT NULL CHECK (hari IN ('senin', 'selasa', 'rabu', 'kamis',
      'jumat', 'sabtu', 'minggu')),
  jam_mulai TIME NOT NULL,
  jam_selesai TIME NOT NULL,
  kuota INTEGER NOT NULL CHECK (kuota > 0),
  CONSTRAINT ck_jadwal_jam CHECK (jam_selesai > jam_mulai),
  CONSTRAINT fk_jadwal_dokter_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_jadwal_dokter_id_tenaga_medis FOREIGN KEY (id_klinik, id_tenaga_medis)
    REFERENCES tenaga_medis (id_klinik, id_tenaga_medis) ON DELETE RESTRICT
);

CREATE TABLE kunjungan (
  id_kunjungan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_pasien BIGINT NOT NULL,
  id_tenaga_medis BIGINT NOT NULL,
  id_akun BIGINT NOT NULL,
  tgl_kunjungan TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  no_antrian INTEGER NOT NULL CHECK (no_antrian > 0),
  jenis_pendaftaran VARCHAR(10) NOT NULL CHECK (jenis_pendaftaran IN ('onsite',
      'online')),
  jenis_penjamin VARCHAR(12) NOT NULL CHECK (jenis_penjamin IN ('umum', 'BPJS',
      'asuransi')),
  status_kunjungan VARCHAR(13) NOT NULL DEFAULT 'menunggu' CHECK (status_kunjungan IN ('menunggu',
      'diperiksa', 'selesai', 'batal')),
  CONSTRAINT uq_kunjungan_klinik UNIQUE (id_klinik, id_kunjungan),
  CONSTRAINT fk_kunjungan_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_kunjungan_id_pasien FOREIGN KEY (id_klinik, id_pasien)
    REFERENCES pasien (id_klinik, id_pasien) ON DELETE RESTRICT,
  CONSTRAINT fk_kunjungan_id_tenaga_medis FOREIGN KEY (id_klinik, id_tenaga_medis)
    REFERENCES tenaga_medis (id_klinik, id_tenaga_medis) ON DELETE RESTRICT,
  CONSTRAINT fk_kunjungan_id_akun FOREIGN KEY (id_akun)
    REFERENCES akun_pengguna (id_akun) ON DELETE RESTRICT
);

CREATE TABLE rekam_medis (
  id_rekam_medis BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_kunjungan BIGINT NOT NULL UNIQUE,
  id_tenaga_medis BIGINT NOT NULL,
  keluhan TEXT NOT NULL,
  tanda_vital TEXT,
  diagnosis TEXT,
  tindakan TEXT,
  catatan TEXT,
  tgl_dibuat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tgl_diubah TIMESTAMPTZ,
  CONSTRAINT uq_rekam_medis_klinik UNIQUE (id_klinik, id_rekam_medis),
  CONSTRAINT fk_rekam_medis_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_rekam_medis_id_kunjungan FOREIGN KEY (id_klinik, id_kunjungan)
    REFERENCES kunjungan (id_klinik, id_kunjungan) ON DELETE RESTRICT,
  CONSTRAINT fk_rekam_medis_id_tenaga_medis FOREIGN KEY (id_klinik, id_tenaga_medis)
    REFERENCES tenaga_medis (id_klinik, id_tenaga_medis) ON DELETE RESTRICT
);

CREATE TABLE resep (
  id_resep BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_rekam_medis BIGINT NOT NULL,
  id_tenaga_medis BIGINT NOT NULL,
  tgl_resep TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_resep VARCHAR(14) NOT NULL DEFAULT 'menunggu' CHECK (status_resep IN ('menunggu',
      'diserahkan', 'batal')),
  CONSTRAINT uq_resep_klinik UNIQUE (id_klinik, id_resep),
  CONSTRAINT fk_resep_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_resep_id_rekam_medis FOREIGN KEY (id_klinik, id_rekam_medis)
    REFERENCES rekam_medis (id_klinik, id_rekam_medis) ON DELETE RESTRICT,
  CONSTRAINT fk_resep_id_tenaga_medis FOREIGN KEY (id_klinik, id_tenaga_medis)
    REFERENCES tenaga_medis (id_klinik, id_tenaga_medis) ON DELETE RESTRICT
);

CREATE TABLE obat (
  id_obat BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  kode_obat VARCHAR(30) NOT NULL,
  nama_obat VARCHAR(150) NOT NULL,
  satuan VARCHAR(30) NOT NULL,
  kategori VARCHAR(100),
  harga_jual NUMERIC(14,2) NOT NULL CHECK (harga_jual >= 0),
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_obat_kode UNIQUE (id_klinik, kode_obat),
  CONSTRAINT uq_obat_klinik UNIQUE (id_klinik, id_obat),
  CONSTRAINT fk_obat_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT
);

CREATE TABLE detail_resep (
  id_detail_resep BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_resep BIGINT NOT NULL,
  id_obat BIGINT NOT NULL,
  jumlah INTEGER NOT NULL CHECK (jumlah > 0),
  dosis VARCHAR(100) NOT NULL,
  aturan_pakai VARCHAR(200) NOT NULL,
  CONSTRAINT uq_detail_resep_obat UNIQUE (id_resep, id_obat),
  CONSTRAINT uq_detail_resep_klinik UNIQUE (id_klinik, id_detail_resep),
  CONSTRAINT fk_detail_resep_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_detail_resep_id_resep FOREIGN KEY (id_klinik, id_resep)
    REFERENCES resep (id_klinik, id_resep) ON DELETE RESTRICT,
  CONSTRAINT fk_detail_resep_id_obat FOREIGN KEY (id_klinik, id_obat)
    REFERENCES obat (id_klinik, id_obat) ON DELETE RESTRICT
);

CREATE TABLE stok_obat (
  id_stok BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_obat BIGINT NOT NULL,
  no_batch VARCHAR(50) NOT NULL,
  jumlah INTEGER NOT NULL CHECK (jumlah >= 0),
  tgl_masuk DATE NOT NULL DEFAULT CURRENT_DATE,
  tgl_kedaluwarsa DATE NOT NULL,
  CONSTRAINT uq_stok_obat_klinik UNIQUE (id_klinik, id_stok),
  CONSTRAINT ck_stok_kedaluwarsa CHECK (tgl_kedaluwarsa >= tgl_masuk),
  CONSTRAINT fk_stok_obat_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_stok_obat_id_obat FOREIGN KEY (id_klinik, id_obat)
    REFERENCES obat (id_klinik, id_obat) ON DELETE RESTRICT
);

CREATE TABLE penyerahan_obat (
  id_penyerahan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_detail_resep BIGINT NOT NULL,
  id_stok BIGINT NOT NULL,
  id_akun BIGINT NOT NULL,
  jumlah INTEGER NOT NULL CHECK (jumlah > 0),
  tgl_penyerahan TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_penyerahan_obat_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_penyerahan_obat_id_detail_resep FOREIGN KEY (id_klinik, id_detail_resep)
    REFERENCES detail_resep (id_klinik, id_detail_resep) ON DELETE RESTRICT,
  CONSTRAINT fk_penyerahan_obat_id_stok FOREIGN KEY (id_klinik, id_stok)
    REFERENCES stok_obat (id_klinik, id_stok) ON DELETE RESTRICT,
  CONSTRAINT fk_penyerahan_obat_id_akun FOREIGN KEY (id_akun)
    REFERENCES akun_pengguna (id_akun) ON DELETE RESTRICT
);

CREATE TABLE layanan (
  id_layanan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  kode_layanan VARCHAR(30) NOT NULL,
  nama_layanan VARCHAR(150) NOT NULL,
  tarif NUMERIC(14,2) NOT NULL CHECK (tarif >= 0),
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_layanan_kode UNIQUE (id_klinik, kode_layanan),
  CONSTRAINT uq_layanan_klinik UNIQUE (id_klinik, id_layanan),
  CONSTRAINT fk_layanan_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT
);

CREATE TABLE tagihan (
  id_tagihan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_kunjungan BIGINT NOT NULL UNIQUE,
  tgl_tagihan TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  total NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
  status_tagihan VARCHAR(15) NOT NULL DEFAULT 'belum lunas' CHECK (status_tagihan IN ('belum lunas',
      'lunas', 'batal')),
  CONSTRAINT uq_tagihan_klinik UNIQUE (id_klinik, id_tagihan),
  CONSTRAINT fk_tagihan_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_tagihan_id_kunjungan FOREIGN KEY (id_klinik, id_kunjungan)
    REFERENCES kunjungan (id_klinik, id_kunjungan) ON DELETE RESTRICT
);

CREATE TABLE detail_tagihan (
  id_detail_tagihan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_tagihan BIGINT NOT NULL,
  id_layanan BIGINT,
  id_detail_resep BIGINT,
  deskripsi VARCHAR(200) NOT NULL,
  qty INTEGER NOT NULL CHECK (qty > 0),
  harga_satuan NUMERIC(14,2) NOT NULL CHECK (harga_satuan >= 0),
  subtotal NUMERIC(14,2) NOT NULL CHECK (subtotal >= 0),
  CONSTRAINT ck_detail_tagihan_sumber CHECK ((id_layanan IS NULL) <> (id_detail_resep IS NULL)),
  CONSTRAINT ck_detail_tagihan_subtotal CHECK (subtotal = qty * harga_satuan),
  CONSTRAINT fk_detail_tagihan_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_detail_tagihan_id_tagihan FOREIGN KEY (id_klinik, id_tagihan)
    REFERENCES tagihan (id_klinik, id_tagihan) ON DELETE RESTRICT,
  CONSTRAINT fk_detail_tagihan_id_layanan FOREIGN KEY (id_klinik, id_layanan)
    REFERENCES layanan (id_klinik, id_layanan) ON DELETE RESTRICT,
  CONSTRAINT fk_detail_tagihan_id_detail_resep FOREIGN KEY (id_klinik, id_detail_resep)
    REFERENCES detail_resep (id_klinik, id_detail_resep) ON DELETE RESTRICT
);

CREATE TABLE pembayaran (
  id_pembayaran BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_klinik BIGINT NOT NULL,
  id_tagihan BIGINT NOT NULL,
  id_akun BIGINT NOT NULL,
  tgl_bayar TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  jumlah_bayar NUMERIC(14,2) NOT NULL CHECK (jumlah_bayar > 0),
  metode_bayar VARCHAR(12) NOT NULL CHECK (metode_bayar IN ('tunai', 'transfer',
      'QRIS', 'kartu')),
  CONSTRAINT fk_pembayaran_id_klinik FOREIGN KEY (id_klinik)
    REFERENCES klinik (id_klinik) ON DELETE RESTRICT,
  CONSTRAINT fk_pembayaran_id_tagihan FOREIGN KEY (id_klinik, id_tagihan)
    REFERENCES tagihan (id_klinik, id_tagihan) ON DELETE RESTRICT,
  CONSTRAINT fk_pembayaran_id_akun FOREIGN KEY (id_akun)
    REFERENCES akun_pengguna (id_akun) ON DELETE RESTRICT
);

-- Indeks
CREATE INDEX ix_klinik_paket ON klinik (id_paket);
CREATE INDEX ix_akun_klinik ON akun_pengguna (id_klinik);
CREATE INDEX ix_audit_akun_waktu ON audit_log (id_akun, waktu);
CREATE INDEX ix_audit_klinik_waktu ON audit_log (id_klinik, waktu);
CREATE INDEX ix_pasien_nik ON pasien (id_klinik, nik);
CREATE INDEX ix_pasien_nama ON pasien (id_klinik, nama);
CREATE INDEX ix_jadwal_dokter ON jadwal_dokter (id_klinik, id_tenaga_medis, hari);
CREATE INDEX ix_kunjungan_pasien ON kunjungan (id_klinik, id_pasien, tgl_kunjungan);
CREATE INDEX ix_kunjungan_dokter ON kunjungan (id_klinik, id_tenaga_medis, tgl_kunjungan);
CREATE INDEX ix_resep_rekam ON resep (id_klinik, id_rekam_medis);
CREATE INDEX ix_resep_status ON resep (id_klinik, status_resep);
CREATE INDEX ix_detail_resep_obat ON detail_resep (id_klinik, id_obat);
CREATE INDEX ix_stok_obat_exp ON stok_obat (id_klinik, id_obat, tgl_kedaluwarsa);
CREATE INDEX ix_penyerahan_detail ON penyerahan_obat (id_klinik, id_detail_resep);
CREATE INDEX ix_penyerahan_stok ON penyerahan_obat (id_klinik, id_stok);
CREATE INDEX ix_tagihan_status ON tagihan (id_klinik, status_tagihan, tgl_tagihan);
CREATE INDEX ix_detail_tagihan ON detail_tagihan (id_klinik, id_tagihan);
CREATE INDEX ix_pembayaran_tagihan ON pembayaran (id_klinik, id_tagihan);
CREATE INDEX ix_pembayaran_tgl ON pembayaran (id_klinik, tgl_bayar);

-- Tabel append-only: UPDATE dan DELETE ditolak
CREATE FUNCTION tolak_ubah_hapus() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Tabel % bersifat append-only', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_log_append_only BEFORE UPDATE OR DELETE ON audit_log
  FOR EACH ROW EXECUTE FUNCTION tolak_ubah_hapus();
CREATE TRIGGER trg_penyerahan_obat_append_only BEFORE UPDATE OR DELETE ON penyerahan_obat
  FOR EACH ROW EXECUTE FUNCTION tolak_ubah_hapus();
CREATE TRIGGER trg_pembayaran_append_only BEFORE UPDATE OR DELETE ON pembayaran
  FOR EACH ROW EXECUTE FUNCTION tolak_ubah_hapus();
