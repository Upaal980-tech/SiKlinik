// Jalankan SEKALI untuk memindahkan data lama dari siklinik.db (SQLite) ke PostgreSQL.
// Pakai: npm run migrate   (taruh siklinik.db di folder 08_Source)
const sqlite3 = require('sqlite3');
const pool = require('../src/config/database');
const appStateModel = require('../src/models/appStateModel');

(async () => {
    await appStateModel.createTable();
    const lite = new sqlite3.Database('./siklinik.db', sqlite3.OPEN_READONLY);
    lite.get('SELECT data FROM app_state WHERE id = 1', async (err, row) => {
        if (err) { console.error('Gagal baca SQLite:', err.message); process.exit(1); }
        if (!row) { console.log('Tidak ada data di SQLite, tidak ada yang dimigrasi.'); process.exit(0); }
        try {
            await appStateModel.save(JSON.parse(row.data));
            console.log('✅ Migrasi selesai. Data SQLite sudah masuk ke PostgreSQL.');
        } catch (e) {
            console.error('Gagal migrasi:', e.message);
            process.exit(1);
        }
        await pool.end();
        lite.close();
    });
})();
