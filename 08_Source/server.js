const express = require('express');
const cors = require('cors');
const path = require('path');
const { pool, init } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
// Limit diperbesar karena data JSON dari frontend cukup besar
app.use(express.json({ limit: '10mb' }));
app.use(express.static(path.join(__dirname, 'public')));

// API untuk mengambil data dari Database
app.get('/api/sync', async (req, res) => {
    try {
        const { rows } = await pool.query('SELECT data FROM app_state WHERE id = 1');
        res.json(rows.length ? rows[0].data : null);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// API untuk menyimpan data ke Database
app.post('/api/sync', async (req, res) => {
    try {
        await pool.query(
            `INSERT INTO app_state (id, data, updated_at)
             VALUES (1, $1, now())
             ON CONFLICT (id) DO UPDATE
             SET data = EXCLUDED.data, updated_at = now()`,
            [JSON.stringify(req.body)]
        );
        res.json({ status: 'ok' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

init()
    .then(() => {
        app.listen(PORT, () => {
            console.log(`✅ Server SiKlinik berjalan di http://localhost:${PORT}`);
            console.log(`🐘 Database PostgreSQL aktif`);
        });
    })
    .catch(err => {
        console.error('❌ Gagal konek ke PostgreSQL:', err.message);
        process.exit(1);
    });
