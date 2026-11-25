# 06 - Architecture Governance (Tata Kelola Arsitektur)

**Disusun oleh:** Gerald Andrew Senjaya (Network / DevOps) & M. Raihan Akbar (CEO)  
**Direview oleh:** Seluruh Tim

## Deskripsi Folder
Folder ini berisi dokumen tata kelola (governance) untuk memastikan setiap keputusan arsitektur terdokumentasi dengan baik, terhindar dari perubahan sepihak, dan sesuai dengan standar *compliance*. 

## Daftar Artefak
1. **`ADR-001-pemilihan-hosting.md`**
   *Architecture Decision Record* (ADR) yang mencatat alasan logis mengapa tim memilih Node.js + Render.com sebagai infrastruktur, dan mengapa tidak menggunakan Vercel atau Laravel/MySQL.
2. **`change-management-plan.md`**
   Prosedur Change Request (CR). Jika mitra meminta perubahan fitur/teknologi di masa depan, perubahan tersebut harus melewati alur ini (catat, analisis dampak, putuskan, komunikasikan).
3. **`compliance-checklist.md`**
   Daftar periksa kepatuhan sistem terhadap regulasi (misalnya kepatuhan penyimpanan data rekam medis sesuai UU PDP yang dibahas di Bab I laporan).

## Catatan Penting
Setiap keputusan teknis (terutama pemilihan *tech stack* dan hosting) tidak boleh diubah secara mendadak tanpa persetujuan CEO dan pencatatan di dalam folder ini.
