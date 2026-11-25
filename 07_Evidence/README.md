# 07 - Evidence & QA (Bukti Validasi & Kualitas)

**Disusun oleh:** Gerald Andrew Senjaya (QA & Notulen P13)  
**Direview oleh:** Muh. Subhan, S.ST., M.T. (Dosen Pengampu)

## Deskripsi Folder
Folder ini memuat bukti-bukti nyata (Jejak Digital) dari proses pengujian sistem, catatan rapat, serta bukti ketertelusuran (*traceability*) antara asumsi masalah klinik dengan solusi aplikasi yang kami bangun. 

*Catatan: Sesuai Bab I laporan, SiKlinik adalah proyek studi kasus fiktif (tanpa mitra eksternal). Oleh karena itu, "Masalah" yang diangkat adalah hasil analisis tim terhadap alur pelayanan klinik pada umumnya, yang diuji menggunakan data rekaan (dummy).*

## Daftar Artefak
1. **`Notulen-Standup-P13.md`**
   Catatan resmi rapat kelompok untuk pertemuan P13. Berisi daftar hadir, keputusan yang diambil, serta *to-do list* (revisi dari Gate 1) untuk dikerjakan di P14.
2. **`Matriks-Ketelusuran.md` / `.xlsx`**
   Tabel *Traceability Matrix* yang membuktikan rantai keselarasan desain:
   *   **Asumsi Masalah (Bab 2.1):** M1 (Data pasien tersebar), M2 (Pasien ganda), M3 (Rekam medis tak terlacak), M4 (Stok & tagihan manual).
   *   **Fitur MVP (Bab 2.7):** F01 (Registrasi MPI), F02 (Antrean), F03 (EMR), F04 (Resep), F05 (Kasir).
   *   **Use Case & User Story (Bab 4):** UC02/US01, UC04/US03, dst.
   *   **Desain Database (Bab 5):** Relasi tabel pasien, kunjungan, dan tagihan.
3. **`QA-Report-P13.md`**
   Laporan hasil *cross-check* QA yang memastikan bahwa desain UI (Wireframe) milik System Analyst sudah sesuai dengan alur BPMN, dan struktur Database Architect sudah bisa mengakomodasi fitur *Must* tersebut.
