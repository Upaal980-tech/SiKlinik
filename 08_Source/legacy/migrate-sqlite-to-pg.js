// Jalankan SEKALI untuk memindahkan data lama dari siklinik.db (SQLite) ke PostgreSQL.
// Pakai: node migrate-sqlite-to-pg.js
const sqlite3 = require('sqlite3');
const { pool, init } = require('../db');

(async () => {
    await init();
    const lite = new sqlite3.Database('../siklinik.db', sqlite3.OPEN_READONLY);
    lite.get('SELECT data FROM app_state WHERE id = 1', async (err, row) => {
        if (err) { console.error('Gagal baca SQLite:', err.message); process.exit(1); }
        if (!row) { console.log('Tidak ada data di SQLite, tidak ada yang dimigrasi.'); process.exit(0); }
        try {
            JSON.parse(row.data); // validasi
            await pool.query(
                `INSERT INTO app_state (id, data) VALUES (1, $1)
                 ON CONFLICT (id) DO UPDATE SET data = EXCLUDED.data, updated_at = now()`,
                [row.data]
            );
            console.log('✅ Migrasi selesai. Data SQLite sudah masuk ke PostgreSQL.');
        } catch (e) {
            console.error('Gagal migrasi:', e.message);
            process.exit(1);
        }
        await pool.end();
        lite.close();
    });
})();
