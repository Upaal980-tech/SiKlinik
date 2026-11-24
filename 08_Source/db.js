require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'siklinik'
});

// Buat tabel otomatis kalau belum ada
async function init() {
    await pool.query(`
        CREATE TABLE IF NOT EXISTS app_state (
            id          INTEGER PRIMARY KEY,
            data        JSONB NOT NULL,
            updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        )
    `);
}

module.exports = { pool, init };
