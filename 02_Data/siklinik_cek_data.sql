-- ============================================================
-- SiKlinik - CEK DATA (PostgreSQL 14+)
-- Hanya membaca data (SELECT); aman dijalankan kapan saja.
-- Membuat satu tabel sementara (hasil_cek) yang hilang saat sesi berakhir.
--
-- Cara membaca hasil:
--   * Bagian 1 : jumlah baris tiap tabel
--   * Bagian 2 : pemeriksaan integritas. Kolom "jumlah" = banyak baris
--                yang melanggar. Harus 0.
--                tingkat ERROR      -> data salah / tidak konsisten
--                tingkat PERINGATAN -> janggal, perlu ditinjau manusia
--   * Bagian 3 : ringkasan OK / ERROR / PERINGATAN
-- Untuk melihat baris pelanggarnya, salin klausa FROM...WHERE dari
-- pemeriksaan yang bersangkutan lalu ganti COUNT(*) dengan SELECT *.
-- ============================================================


-- ------------------------------------------------------------
-- BAGIAN 1 - Jumlah baris per tabel
-- ------------------------------------------------------------
WITH r(urutan, tabel, jumlah, minimum_diharapkan) AS (
  VALUES
   ( 1, 'paket_langganan',   (SELECT COUNT(*) FROM paket_langganan),   5),
   ( 2, 'klinik',            (SELECT COUNT(*) FROM klinik),            5),
   ( 3, 'akun_pengguna',     (SELECT COUNT(*) FROM akun_pengguna),    30),
   ( 4, 'tenaga_medis',      (SELECT COUNT(*) FROM tenaga_medis),     30),
   ( 5, 'jadwal_dokter',     (SELECT COUNT(*) FROM jadwal_dokter),    30),
   ( 6, 'pasien',            (SELECT COUNT(*) FROM pasien),           30),
   ( 7, 'obat',              (SELECT COUNT(*) FROM obat),             30),
   ( 8, 'layanan',           (SELECT COUNT(*) FROM layanan),          30),
   ( 9, 'tagihan_langganan', (SELECT COUNT(*) FROM tagihan_langganan), 0),
   (10, 'audit_log',         (SELECT COUNT(*) FROM audit_log),         0),
   (11, 'kunjungan',         (SELECT COUNT(*) FROM kunjungan),         0),
   (12, 'rekam_medis',       (SELECT COUNT(*) FROM rekam_medis),       0),
   (13, 'resep',             (SELECT COUNT(*) FROM resep),             0),
   (14, 'detail_resep',      (SELECT COUNT(*) FROM detail_resep),      0),
   (15, 'stok_obat',         (SELECT COUNT(*) FROM stok_obat),         0),
   (16, 'penyerahan_obat',   (SELECT COUNT(*) FROM penyerahan_obat),   0),
   (17, 'tagihan',           (SELECT COUNT(*) FROM tagihan),           0),
   (18, 'detail_tagihan',    (SELECT COUNT(*) FROM detail_tagihan),    0),
   (19, 'pembayaran',        (SELECT COUNT(*) FROM pembayaran),        0)
)
SELECT tabel, jumlah, minimum_diharapkan,
       CASE WHEN jumlah >= minimum_diharapkan THEN 'OK' ELSE 'KURANG' END AS status
FROM r
ORDER BY urutan;


-- ------------------------------------------------------------
-- BAGIAN 2 - Pemeriksaan integritas (jumlah pelanggaran harus 0)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS pg_temp.hasil_cek;

CREATE TEMP TABLE hasil_cek AS
WITH cek(kelompok, cek, tingkat, jumlah) AS (

-- ===== A. Batas antar-klinik (multi-tenant) =====
SELECT 'A. Tenant', 'tenaga_medis: id_akun milik klinik lain', 'ERROR', COUNT(*)::int
FROM tenaga_medis t JOIN akun_pengguna a ON a.id_akun = t.id_akun
WHERE a.id_klinik IS DISTINCT FROM t.id_klinik
UNION ALL
SELECT 'A. Tenant', 'kunjungan: id_akun pendaftar bukan akun klinik yang sama', 'ERROR', COUNT(*)::int
FROM kunjungan k JOIN akun_pengguna a ON a.id_akun = k.id_akun
WHERE a.id_klinik IS DISTINCT FROM k.id_klinik
UNION ALL
SELECT 'A. Tenant', 'penyerahan_obat: id_akun bukan akun klinik yang sama', 'ERROR', COUNT(*)::int
FROM penyerahan_obat p JOIN akun_pengguna a ON a.id_akun = p.id_akun
WHERE a.id_klinik IS DISTINCT FROM p.id_klinik
UNION ALL
SELECT 'A. Tenant', 'pembayaran: id_akun kasir bukan akun klinik yang sama', 'ERROR', COUNT(*)::int
FROM pembayaran p JOIN akun_pengguna a ON a.id_akun = p.id_akun
WHERE a.id_klinik IS DISTINCT FROM p.id_klinik
UNION ALL
SELECT 'A. Tenant', 'audit_log: id_klinik log berbeda dengan klinik akun pelaku', 'ERROR', COUNT(*)::int
FROM audit_log l JOIN akun_pengguna a ON a.id_akun = l.id_akun
WHERE l.id_klinik IS NOT NULL AND a.id_klinik IS NOT NULL AND l.id_klinik <> a.id_klinik

-- ===== B. Akun, klinik, paket =====
UNION ALL
SELECT 'B. Akun & klinik', 'akun platform (tanpa klinik) dengan peran klinik', 'ERROR', COUNT(*)::int
FROM akun_pengguna
WHERE id_klinik IS NULL
  AND peran NOT IN ('customer success','pemilik siklinik','admin keuangan siklinik')
UNION ALL
SELECT 'B. Akun & klinik', 'akun milik klinik dengan peran platform SiKlinik', 'ERROR', COUNT(*)::int
FROM akun_pengguna
WHERE id_klinik IS NOT NULL
  AND peran IN ('customer success','pemilik siklinik','admin keuangan siklinik')
UNION ALL
SELECT 'B. Akun & klinik', 'tenaga_medis terhubung akun: peran akun tidak sesuai jenis tenaga', 'ERROR', COUNT(*)::int
FROM tenaga_medis t JOIN akun_pengguna a ON a.id_akun = t.id_akun
WHERE a.peran <> CASE t.jenis_tenaga
                   WHEN 'dokter'  THEN 'dokter'
                   WHEN 'perawat' THEN 'perawat/bidan'
                   WHEN 'bidan'   THEN 'perawat/bidan'
                   ELSE 'apoteker' END
UNION ALL
SELECT 'B. Akun & klinik', 'tenaga_medis aktif tetapi akunnya nonaktif', 'ERROR', COUNT(*)::int
FROM tenaga_medis t JOIN akun_pengguna a ON a.id_akun = t.id_akun
WHERE t.status_aktif AND a.status_akun = 'nonaktif'
UNION ALL
SELECT 'B. Akun & klinik', 'username bukan huruf kecil/angka/titik/garis bawah (3-50 karakter)', 'ERROR', COUNT(*)::int
FROM akun_pengguna WHERE username !~ '^[a-z0-9._]{3,50}$'
UNION ALL
SELECT 'B. Akun & klinik', 'password_hash bukan format bcrypt (khusus data dummy)', 'PERINGATAN', COUNT(*)::int
FROM akun_pengguna WHERE password_hash !~ '^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$'
UNION ALL
SELECT 'B. Akun & klinik', 'peran dokter/apoteker/admin klinik tanpa MFA', 'PERINGATAN', COUNT(*)::int
FROM akun_pengguna
WHERE status_akun = 'aktif' AND NOT mfa_aktif AND peran IN ('admin klinik','pemilik siklinik','admin keuangan siklinik')
UNION ALL
SELECT 'B. Akun & klinik', 'klinik berstatus aktif tanpa akun admin klinik yang aktif', 'ERROR', COUNT(*)::int
FROM klinik k
WHERE k.status_langganan = 'aktif'
  AND NOT EXISTS (SELECT 1 FROM akun_pengguna a
                  WHERE a.id_klinik = k.id_klinik AND a.peran = 'admin klinik' AND a.status_akun = 'aktif')
UNION ALL
SELECT 'B. Akun & klinik', 'klinik berstatus aktif tanpa dokter aktif', 'PERINGATAN', COUNT(*)::int
FROM klinik k
WHERE k.status_langganan = 'aktif'
  AND NOT EXISTS (SELECT 1 FROM tenaga_medis t
                  WHERE t.id_klinik = k.id_klinik AND t.jenis_tenaga = 'dokter' AND t.status_aktif)
UNION ALL
SELECT 'B. Akun & klinik', 'klinik aktif memakai paket yang sudah nonaktif', 'PERINGATAN', COUNT(*)::int
FROM klinik k JOIN paket_langganan p ON p.id_paket = k.id_paket
WHERE k.status_langganan = 'aktif' AND NOT p.status_aktif
UNION ALL
SELECT 'B. Akun & klinik', 'no_izin klinik ganda', 'ERROR', COUNT(*)::int
FROM (SELECT 1 FROM klinik GROUP BY no_izin HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'B. Akun & klinik', 'nama_klinik ganda', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM klinik GROUP BY lower(nama_klinik) HAVING COUNT(*) > 1) x

-- ===== C. Pasien =====
UNION ALL
SELECT 'C. Pasien', 'NIK tidak cocok dengan tgl_lahir / jenis_kelamin (digit 7-12)', 'ERROR', COUNT(*)::int
FROM pasien
WHERE nik IS NOT NULL
  AND (   substr(nik, 11, 2) <> to_char(tgl_lahir, 'YY')
       OR substr(nik,  9, 2) <> to_char(tgl_lahir, 'MM')
       OR substr(nik,  7, 2)::int <> EXTRACT(DAY FROM tgl_lahir)::int
                                     + CASE WHEN jenis_kelamin = 'perempuan' THEN 40 ELSE 0 END)
UNION ALL
SELECT 'C. Pasien', 'NIK ganda dalam satu klinik (skema tidak punya UNIQUE untuk NIK)', 'ERROR', COUNT(*)::int
FROM (SELECT 1 FROM pasien WHERE nik IS NOT NULL GROUP BY id_klinik, nik HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'C. Pasien', 'kemungkinan pasien ganda (nama + tgl_lahir sama dalam satu klinik)', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM pasien GROUP BY id_klinik, lower(btrim(nama)), tgl_lahir HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'C. Pasien', 'no_rm tidak berformat RM-nnnnn (khusus data dummy)', 'PERINGATAN', COUNT(*)::int
FROM pasien WHERE no_rm !~ '^RM-[0-9]{5}$'
UNION ALL
SELECT 'C. Pasien', 'no_bpjs bukan 13 digit', 'ERROR', COUNT(*)::int
FROM pasien WHERE no_bpjs IS NOT NULL AND no_bpjs !~ '^[0-9]{13}$'
UNION ALL
SELECT 'C. Pasien', 'id_satusehat tidak berformat P0 + 10 digit', 'PERINGATAN', COUNT(*)::int
FROM pasien WHERE id_satusehat IS NOT NULL AND id_satusehat !~ '^P0[0-9]{10}$'
UNION ALL
SELECT 'C. Pasien', 'no_telepon bukan nomor seluler Indonesia (08xx, 10-13 digit)', 'PERINGATAN', COUNT(*)::int
FROM pasien WHERE no_telepon IS NOT NULL AND no_telepon !~ '^08[0-9]{8,11}$'
UNION ALL
SELECT 'C. Pasien', 'tgl_registrasi lebih awal dari tgl_bergabung klinik', 'ERROR', COUNT(*)::int
FROM pasien p JOIN klinik k ON k.id_klinik = p.id_klinik
WHERE p.tgl_registrasi < k.tgl_bergabung
UNION ALL
SELECT 'C. Pasien', 'tgl_registrasi lebih awal dari tgl_lahir', 'ERROR', COUNT(*)::int
FROM pasien WHERE tgl_registrasi < tgl_lahir
UNION ALL
SELECT 'C. Pasien', 'nama kosong / hanya spasi', 'ERROR', COUNT(*)::int
FROM pasien WHERE btrim(nama) = ''

-- ===== D. Tenaga medis & jadwal =====
UNION ALL
SELECT 'D. Tenaga & jadwal', 'no_str bukan 16 karakter alfanumerik', 'PERINGATAN', COUNT(*)::int
FROM tenaga_medis WHERE no_str IS NOT NULL AND no_str !~ '^[0-9A-Za-z]{16}$'
UNION ALL
SELECT 'D. Tenaga & jadwal', 'dokter/perawat/bidan/apoteker tanpa no_str', 'ERROR', COUNT(*)::int
FROM tenaga_medis
WHERE no_str IS NULL AND jenis_tenaga IN ('dokter','perawat','bidan','apoteker')
UNION ALL
SELECT 'D. Tenaga & jadwal', 'dokter tanpa spesialisasi (isi "Dokter Umum" bila umum)', 'PERINGATAN', COUNT(*)::int
FROM tenaga_medis WHERE jenis_tenaga = 'dokter' AND (spesialisasi IS NULL OR btrim(spesialisasi) = '')
UNION ALL
SELECT 'D. Tenaga & jadwal', 'nama tenaga medis ganda dalam satu klinik', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM tenaga_medis GROUP BY id_klinik, lower(nama) HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'D. Tenaga & jadwal', 'jadwal_dokter untuk tenaga selain dokter/bidan', 'ERROR', COUNT(*)::int
FROM jadwal_dokter j JOIN tenaga_medis t ON t.id_klinik = j.id_klinik AND t.id_tenaga_medis = j.id_tenaga_medis
WHERE t.jenis_tenaga NOT IN ('dokter','bidan')
UNION ALL
SELECT 'D. Tenaga & jadwal', 'jadwal_dokter untuk tenaga nonaktif', 'ERROR', COUNT(*)::int
FROM jadwal_dokter j JOIN tenaga_medis t ON t.id_klinik = j.id_klinik AND t.id_tenaga_medis = j.id_tenaga_medis
WHERE NOT t.status_aktif
UNION ALL
SELECT 'D. Tenaga & jadwal', 'jadwal tumpang tindih (tenaga & hari sama)', 'ERROR', COUNT(*)::int
FROM jadwal_dokter a JOIN jadwal_dokter b
  ON a.id_klinik = b.id_klinik AND a.id_tenaga_medis = b.id_tenaga_medis AND a.hari = b.hari
 AND a.id_jadwal < b.id_jadwal
 AND a.jam_mulai < b.jam_selesai AND b.jam_mulai < a.jam_selesai
UNION ALL
SELECT 'D. Tenaga & jadwal', 'jadwal di luar jam 06:00-22:00', 'PERINGATAN', COUNT(*)::int
FROM jadwal_dokter WHERE jam_mulai < TIME '06:00' OR jam_selesai > TIME '22:00'

-- ===== E. Obat, layanan, stok =====
UNION ALL
SELECT 'E. Obat & layanan', 'nama_obat ganda dalam satu klinik', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM obat GROUP BY id_klinik, lower(nama_obat) HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'E. Obat & layanan', 'obat aktif dengan harga_jual 0', 'PERINGATAN', COUNT(*)::int
FROM obat WHERE status_aktif AND harga_jual = 0
UNION ALL
SELECT 'E. Obat & layanan', 'kode_obat tidak berformat OBT-nnn (khusus data dummy)', 'PERINGATAN', COUNT(*)::int
FROM obat WHERE kode_obat !~ '^OBT-[0-9]{3}$'
UNION ALL
SELECT 'E. Obat & layanan', 'nama_layanan ganda dalam satu klinik', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM layanan GROUP BY id_klinik, lower(nama_layanan) HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'E. Obat & layanan', 'layanan aktif dengan tarif 0', 'PERINGATAN', COUNT(*)::int
FROM layanan WHERE status_aktif AND tarif = 0
UNION ALL
SELECT 'E. Obat & layanan', 'kode_layanan tidak berformat LYN-nnn (khusus data dummy)', 'PERINGATAN', COUNT(*)::int
FROM layanan WHERE kode_layanan !~ '^LYN-[0-9]{3}$'
UNION ALL
SELECT 'E. Obat & layanan', 'stok_obat: batch ganda untuk obat yang sama', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM stok_obat GROUP BY id_klinik, id_obat, no_batch HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'E. Obat & layanan', 'stok_obat sudah kedaluwarsa tetapi jumlah masih > 0', 'PERINGATAN', COUNT(*)::int
FROM stok_obat WHERE tgl_kedaluwarsa < CURRENT_DATE AND jumlah > 0

-- ===== F. Alur kunjungan, rekam medis, resep, obat =====
UNION ALL
SELECT 'F. Alur klinis', 'kunjungan: tenaga medis bukan dokter/bidan', 'ERROR', COUNT(*)::int
FROM kunjungan k JOIN tenaga_medis t ON t.id_klinik = k.id_klinik AND t.id_tenaga_medis = k.id_tenaga_medis
WHERE t.jenis_tenaga NOT IN ('dokter','bidan')
UNION ALL
SELECT 'F. Alur klinis', 'kunjungan lebih awal dari tgl_registrasi pasien', 'ERROR', COUNT(*)::int
FROM kunjungan k JOIN pasien p ON p.id_klinik = k.id_klinik AND p.id_pasien = k.id_pasien
WHERE (k.tgl_kunjungan AT TIME ZONE 'Asia/Jakarta')::date < p.tgl_registrasi
UNION ALL
SELECT 'F. Alur klinis', 'no_antrian ganda (klinik + dokter + hari sama)', 'PERINGATAN', COUNT(*)::int
FROM (SELECT 1 FROM kunjungan
      GROUP BY id_klinik, id_tenaga_medis, (tgl_kunjungan AT TIME ZONE 'Asia/Jakarta')::date, no_antrian
      HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'F. Alur klinis', 'kunjungan selesai tanpa rekam_medis', 'ERROR', COUNT(*)::int
FROM kunjungan k
WHERE k.status_kunjungan = 'selesai'
  AND NOT EXISTS (SELECT 1 FROM rekam_medis r WHERE r.id_kunjungan = k.id_kunjungan)
UNION ALL
SELECT 'F. Alur klinis', 'rekam_medis pada kunjungan berstatus batal', 'ERROR', COUNT(*)::int
FROM rekam_medis r JOIN kunjungan k ON k.id_klinik = r.id_klinik AND k.id_kunjungan = r.id_kunjungan
WHERE k.status_kunjungan = 'batal'
UNION ALL
SELECT 'F. Alur klinis', 'rekam_medis kunjungan selesai tanpa diagnosis', 'PERINGATAN', COUNT(*)::int
FROM rekam_medis r JOIN kunjungan k ON k.id_klinik = r.id_klinik AND k.id_kunjungan = r.id_kunjungan
WHERE k.status_kunjungan = 'selesai' AND (r.diagnosis IS NULL OR btrim(r.diagnosis) = '')
UNION ALL
SELECT 'F. Alur klinis', 'rekam_medis: tgl_diubah lebih awal dari tgl_dibuat', 'ERROR', COUNT(*)::int
FROM rekam_medis WHERE tgl_diubah IS NOT NULL AND tgl_diubah < tgl_dibuat
UNION ALL
SELECT 'F. Alur klinis', 'rekam_medis dibuat oleh apoteker/asisten apoteker', 'ERROR', COUNT(*)::int
FROM rekam_medis r JOIN tenaga_medis t ON t.id_klinik = r.id_klinik AND t.id_tenaga_medis = r.id_tenaga_medis
WHERE t.jenis_tenaga IN ('apoteker','asisten apoteker')
UNION ALL
SELECT 'F. Alur klinis', 'resep ditulis oleh selain dokter', 'ERROR', COUNT(*)::int
FROM resep s JOIN tenaga_medis t ON t.id_klinik = s.id_klinik AND t.id_tenaga_medis = s.id_tenaga_medis
WHERE t.jenis_tenaga <> 'dokter'
UNION ALL
SELECT 'F. Alur klinis', 'resep lebih awal dari kunjungannya', 'ERROR', COUNT(*)::int
FROM resep s
JOIN rekam_medis r ON r.id_klinik = s.id_klinik AND r.id_rekam_medis = s.id_rekam_medis
JOIN kunjungan k  ON k.id_klinik = r.id_klinik AND k.id_kunjungan = r.id_kunjungan
WHERE s.tgl_resep < k.tgl_kunjungan
UNION ALL
SELECT 'F. Alur klinis', 'resep tanpa detail_resep (kecuali batal)', 'PERINGATAN', COUNT(*)::int
FROM resep s
WHERE s.status_resep <> 'batal'
  AND NOT EXISTS (SELECT 1 FROM detail_resep d WHERE d.id_klinik = s.id_klinik AND d.id_resep = s.id_resep)
UNION ALL
SELECT 'F. Alur klinis', 'resep diserahkan tetapi tidak ada penyerahan_obat', 'ERROR', COUNT(*)::int
FROM resep s
WHERE s.status_resep = 'diserahkan'
  AND NOT EXISTS (SELECT 1 FROM detail_resep d
                  JOIN penyerahan_obat p ON p.id_klinik = d.id_klinik AND p.id_detail_resep = d.id_detail_resep
                  WHERE d.id_klinik = s.id_klinik AND d.id_resep = s.id_resep)
UNION ALL
SELECT 'F. Alur klinis', 'ada penyerahan_obat padahal resep batal / masih menunggu', 'ERROR', COUNT(*)::int
FROM penyerahan_obat p
JOIN detail_resep d ON d.id_klinik = p.id_klinik AND d.id_detail_resep = p.id_detail_resep
JOIN resep s        ON s.id_klinik = d.id_klinik AND s.id_resep = d.id_resep
WHERE s.status_resep <> 'diserahkan'
UNION ALL
SELECT 'F. Alur klinis', 'penyerahan_obat: obat pada stok berbeda dengan obat pada resep', 'ERROR', COUNT(*)::int
FROM penyerahan_obat p
JOIN detail_resep d ON d.id_klinik = p.id_klinik AND d.id_detail_resep = p.id_detail_resep
JOIN stok_obat so   ON so.id_klinik = p.id_klinik AND so.id_stok = p.id_stok
WHERE so.id_obat <> d.id_obat
UNION ALL
SELECT 'F. Alur klinis', 'total penyerahan melebihi jumlah pada detail_resep', 'ERROR', COUNT(*)::int
FROM (SELECT d.id_detail_resep
      FROM detail_resep d JOIN penyerahan_obat p
        ON p.id_klinik = d.id_klinik AND p.id_detail_resep = d.id_detail_resep
      GROUP BY d.id_detail_resep, d.jumlah
      HAVING SUM(p.jumlah) > d.jumlah) x
UNION ALL
SELECT 'F. Alur klinis', 'penyerahan dari stok yang sudah kedaluwarsa', 'ERROR', COUNT(*)::int
FROM penyerahan_obat p JOIN stok_obat so ON so.id_klinik = p.id_klinik AND so.id_stok = p.id_stok
WHERE (p.tgl_penyerahan AT TIME ZONE 'Asia/Jakarta')::date > so.tgl_kedaluwarsa
UNION ALL
SELECT 'F. Alur klinis', 'penyerahan sebelum stok masuk', 'ERROR', COUNT(*)::int
FROM penyerahan_obat p JOIN stok_obat so ON so.id_klinik = p.id_klinik AND so.id_stok = p.id_stok
WHERE (p.tgl_penyerahan AT TIME ZONE 'Asia/Jakarta')::date < so.tgl_masuk

-- ===== G. Tagihan & pembayaran =====
UNION ALL
SELECT 'G. Keuangan', 'tagihan.total tidak sama dengan jumlah subtotal detail_tagihan', 'ERROR', COUNT(*)::int
FROM tagihan t
WHERE t.status_tagihan <> 'batal'
  AND t.total <> COALESCE((SELECT SUM(d.subtotal) FROM detail_tagihan d
                           WHERE d.id_klinik = t.id_klinik AND d.id_tagihan = t.id_tagihan), 0)
UNION ALL
SELECT 'G. Keuangan', 'tagihan tanpa detail_tagihan (kecuali batal)', 'PERINGATAN', COUNT(*)::int
FROM tagihan t
WHERE t.status_tagihan <> 'batal'
  AND NOT EXISTS (SELECT 1 FROM detail_tagihan d WHERE d.id_klinik = t.id_klinik AND d.id_tagihan = t.id_tagihan)
UNION ALL
SELECT 'G. Keuangan', 'tagihan lunas tetapi total pembayaran kurang dari total', 'ERROR', COUNT(*)::int
FROM tagihan t
WHERE t.status_tagihan = 'lunas'
  AND COALESCE((SELECT SUM(p.jumlah_bayar) FROM pembayaran p
                WHERE p.id_klinik = t.id_klinik AND p.id_tagihan = t.id_tagihan), 0) < t.total
UNION ALL
SELECT 'G. Keuangan', 'tagihan belum lunas padahal pembayaran sudah menutup total', 'ERROR', COUNT(*)::int
FROM tagihan t
WHERE t.status_tagihan = 'belum lunas' AND t.total > 0
  AND COALESCE((SELECT SUM(p.jumlah_bayar) FROM pembayaran p
                WHERE p.id_klinik = t.id_klinik AND p.id_tagihan = t.id_tagihan), 0) >= t.total
UNION ALL
SELECT 'G. Keuangan', 'total pembayaran melebihi total tagihan', 'ERROR', COUNT(*)::int
FROM tagihan t
WHERE COALESCE((SELECT SUM(p.jumlah_bayar) FROM pembayaran p
                WHERE p.id_klinik = t.id_klinik AND p.id_tagihan = t.id_tagihan), 0) > t.total
UNION ALL
SELECT 'G. Keuangan', 'pembayaran pada tagihan berstatus batal', 'ERROR', COUNT(*)::int
FROM pembayaran p JOIN tagihan t ON t.id_klinik = p.id_klinik AND t.id_tagihan = p.id_tagihan
WHERE t.status_tagihan = 'batal'
UNION ALL
SELECT 'G. Keuangan', 'pembayaran lebih awal dari tgl_tagihan', 'ERROR', COUNT(*)::int
FROM pembayaran p JOIN tagihan t ON t.id_klinik = p.id_klinik AND t.id_tagihan = p.id_tagihan
WHERE p.tgl_bayar < t.tgl_tagihan
UNION ALL
SELECT 'G. Keuangan', 'tagihan aktif untuk kunjungan yang batal', 'PERINGATAN', COUNT(*)::int
FROM tagihan t JOIN kunjungan k ON k.id_klinik = t.id_klinik AND k.id_kunjungan = t.id_kunjungan
WHERE k.status_kunjungan = 'batal' AND t.status_tagihan <> 'batal'
UNION ALL
SELECT 'G. Keuangan', 'detail_tagihan layanan: harga_satuan berbeda dari tarif layanan saat ini', 'PERINGATAN', COUNT(*)::int
FROM detail_tagihan d JOIN layanan l ON l.id_klinik = d.id_klinik AND l.id_layanan = d.id_layanan
WHERE d.harga_satuan <> l.tarif
UNION ALL
SELECT 'G. Keuangan', 'detail_tagihan obat: qty berbeda dari jumlah pada detail_resep', 'PERINGATAN', COUNT(*)::int
FROM detail_tagihan d JOIN detail_resep r ON r.id_klinik = d.id_klinik AND r.id_detail_resep = d.id_detail_resep
WHERE d.qty <> r.jumlah
UNION ALL
SELECT 'G. Keuangan', 'detail_tagihan obat berasal dari resep kunjungan lain', 'ERROR', COUNT(*)::int
FROM detail_tagihan d
JOIN tagihan t       ON t.id_klinik = d.id_klinik AND t.id_tagihan = d.id_tagihan
JOIN detail_resep dr ON dr.id_klinik = d.id_klinik AND dr.id_detail_resep = d.id_detail_resep
JOIN resep s         ON s.id_klinik = dr.id_klinik AND s.id_resep = dr.id_resep
JOIN rekam_medis rm  ON rm.id_klinik = s.id_klinik AND rm.id_rekam_medis = s.id_rekam_medis
WHERE rm.id_kunjungan <> t.id_kunjungan

-- ===== H. Langganan SaaS =====
UNION ALL
SELECT 'H. Langganan', 'tagihan_langganan dibayar tanpa tgl_bayar', 'ERROR', COUNT(*)::int
FROM tagihan_langganan WHERE status_bayar = 'dibayar' AND tgl_bayar IS NULL
UNION ALL
SELECT 'H. Langganan', 'tagihan_langganan belum dibayar/terlambat tetapi tgl_bayar terisi', 'ERROR', COUNT(*)::int
FROM tagihan_langganan WHERE status_bayar <> 'dibayar' AND tgl_bayar IS NOT NULL
UNION ALL
SELECT 'H. Langganan', 'tagihan_langganan dibayar tanpa ref_payment_gateway', 'PERINGATAN', COUNT(*)::int
FROM tagihan_langganan WHERE status_bayar = 'dibayar' AND ref_payment_gateway IS NULL
UNION ALL
SELECT 'H. Langganan', 'periode tagihan_langganan lebih awal dari bulan bergabung klinik', 'ERROR', COUNT(*)::int
FROM tagihan_langganan t JOIN klinik k ON k.id_klinik = t.id_klinik
WHERE t.periode < to_char(k.tgl_bergabung, 'YYYY-MM')
UNION ALL
SELECT 'H. Langganan', 'jumlah tagihan_langganan berbeda dari harga paket klinik saat ini', 'PERINGATAN', COUNT(*)::int
FROM tagihan_langganan t
JOIN klinik k ON k.id_klinik = t.id_klinik
JOIN paket_langganan p ON p.id_paket = k.id_paket
WHERE t.jumlah <> p.harga_bulanan
UNION ALL
SELECT 'H. Langganan', 'klinik berstatus berhenti/ditangguhkan masih punya tagihan belum dibayar', 'PERINGATAN', COUNT(*)::int
FROM tagihan_langganan t JOIN klinik k ON k.id_klinik = t.id_klinik
WHERE k.status_langganan <> 'aktif' AND t.status_bayar = 'belum dibayar'

-- ===== I. Sequence identity (penting setelah insert ID manual) =====
UNION ALL
SELECT 'I. Sequence', 'sequence tertinggal dari MAX(id): ' || v.tabel, 'ERROR',
       CASE WHEN COALESCE(s.last_value, 0) < v.maks THEN 1 ELSE 0 END
FROM (VALUES
  ('paket_langganan',   'id_paket',             (SELECT COALESCE(MAX(id_paket),0)             FROM paket_langganan)),
  ('klinik',            'id_klinik',            (SELECT COALESCE(MAX(id_klinik),0)            FROM klinik)),
  ('tagihan_langganan', 'id_tagihan_langganan', (SELECT COALESCE(MAX(id_tagihan_langganan),0) FROM tagihan_langganan)),
  ('akun_pengguna',     'id_akun',              (SELECT COALESCE(MAX(id_akun),0)              FROM akun_pengguna)),
  ('audit_log',         'id_log',               (SELECT COALESCE(MAX(id_log),0)               FROM audit_log)),
  ('pasien',            'id_pasien',            (SELECT COALESCE(MAX(id_pasien),0)            FROM pasien)),
  ('tenaga_medis',      'id_tenaga_medis',      (SELECT COALESCE(MAX(id_tenaga_medis),0)      FROM tenaga_medis)),
  ('jadwal_dokter',     'id_jadwal',            (SELECT COALESCE(MAX(id_jadwal),0)            FROM jadwal_dokter)),
  ('kunjungan',         'id_kunjungan',         (SELECT COALESCE(MAX(id_kunjungan),0)         FROM kunjungan)),
  ('rekam_medis',       'id_rekam_medis',       (SELECT COALESCE(MAX(id_rekam_medis),0)       FROM rekam_medis)),
  ('resep',             'id_resep',             (SELECT COALESCE(MAX(id_resep),0)             FROM resep)),
  ('obat',              'id_obat',              (SELECT COALESCE(MAX(id_obat),0)              FROM obat)),
  ('detail_resep',      'id_detail_resep',      (SELECT COALESCE(MAX(id_detail_resep),0)      FROM detail_resep)),
  ('stok_obat',         'id_stok',              (SELECT COALESCE(MAX(id_stok),0)              FROM stok_obat)),
  ('penyerahan_obat',   'id_penyerahan',        (SELECT COALESCE(MAX(id_penyerahan),0)        FROM penyerahan_obat)),
  ('layanan',           'id_layanan',           (SELECT COALESCE(MAX(id_layanan),0)           FROM layanan)),
  ('tagihan',           'id_tagihan',           (SELECT COALESCE(MAX(id_tagihan),0)           FROM tagihan)),
  ('detail_tagihan',    'id_detail_tagihan',    (SELECT COALESCE(MAX(id_detail_tagihan),0)    FROM detail_tagihan)),
  ('pembayaran',        'id_pembayaran',        (SELECT COALESCE(MAX(id_pembayaran),0)        FROM pembayaran))
) AS v(tabel, kolom, maks)
LEFT JOIN pg_sequences s
  ON quote_ident(s.schemaname) || '.' || quote_ident(s.sequencename) = pg_get_serial_sequence(v.tabel, v.kolom)
)
SELECT row_number() OVER ()::int AS no, kelompok, cek, tingkat, jumlah,
       CASE WHEN jumlah = 0 THEN 'OK' ELSE tingkat END AS status
FROM cek;

-- Detail: baris yang bermasalah ditampilkan paling atas
SELECT no, kelompok, cek, jumlah, status
FROM hasil_cek
ORDER BY (status = 'OK'), (status = 'PERINGATAN'), no;


-- ------------------------------------------------------------
-- BAGIAN 3 - Ringkasan
-- ------------------------------------------------------------
SELECT status, COUNT(*) AS jumlah_pemeriksaan, SUM(jumlah) AS total_baris_bermasalah
FROM hasil_cek
GROUP BY status
ORDER BY CASE status WHEN 'ERROR' THEN 1 WHEN 'PERINGATAN' THEN 2 ELSE 3 END;

DROP TABLE IF EXISTS pg_temp.hasil_cek;
