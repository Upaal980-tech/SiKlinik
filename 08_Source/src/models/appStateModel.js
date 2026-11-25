// MODEL: satu-satunya tempat yang boleh menulis query SQL untuk tabel app_state.
const pool = require('../config/database');

// Buat tabel otomatis kalau belum ada
async function createTable() {
    await pool.query(`
        CREATE TABLE IF NOT EXISTS app_state (
            id          INTEGER PRIMARY KEY,
            data        JSONB NOT NULL,
            updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        )
    `);
}

// Ambil data aplikasi; mengembalikan null kalau belum ada
async function get() {
    const { rows } = await pool.query('SELECT data FROM app_state WHERE id = 1');
    return rows.length ? rows[0].data : null;
}

// Simpan data aplikasi (insert, atau timpa kalau sudah ada)
async function save(data) {
    await pool.query(
        `INSERT INTO app_state (id, data, updated_at)
         VALUES (1, $1, now())
         ON CONFLICT (id) DO UPDATE
         SET data = EXCLUDED.data, updated_at = now()`,
        [JSON.stringify(data)]
    );
}

module.exports = { createTable, get, save };
