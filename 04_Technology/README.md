
# 04 - Technology Architecture (Arsitektur Teknologi)

**Disusun oleh:** Gerald Andrew Senjaya (Network / DevOps)  
**Direview oleh:** Naufal Ulul Albab (Programmer)

## Deskripsi Folder
Folder ini memuat seluruh artefak keputusan teknologi, topologi jaringan, dan perencanaan infrastruktur untuk aplikasi SiKlinik (MVP). Fokus utama dari folder ini adalah memastikan aplikasi dapat berjalan dengan andal, aman, dan sesuai dengan batasan biaya (TCO).

## Daftar Artefak
1. **`topologi-to-be.png` / `.drawio`**
   Diagram alur jaringan target (Client -> Cloud -> Node.js Server -> SQLite Database) dengan pendekatan *Multi-Tenant*.
2. **`deployment-diagram.png` / `.drawio`**
   Rancangan penempatan komponen (Frontend, Backend, Database) di dalam server cloud.
3. **`security-plan.md`**
   Rencana keamanan sistem, mencakup protokol HTTPS/SSL, penerapan MFA (Multi-Factor Authentication), dan strategi *Automated Backup* untuk SQLite.
4. **`tco-analysis.md`**
   Analisis Total Cost of Ownership (TCO) perbandingan penyedia cloud (Render.com vs Railway).

## Catatan Teknis
- **Stack Teknologi:** Node.js, Express.js, SQLite.
- **Hosting Target (P14):** Render.com (Free Tier).
- **Strategi Rilis:** Kami akan menerapkan CI/CD (Continuous Integration / Continuous Deployment) menggunakan integrasi GitHub dan Render.
