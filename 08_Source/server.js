// Titik masuk aplikasi: siapkan database, lalu jalankan server.
const app = require('./src/app');
const appStateModel = require('./src/models/appStateModel');

const PORT = process.env.PORT || 3000;

appStateModel.createTable()
    .then(() => {
        app.listen(PORT, () => {
            console.log(`✅ Server SiKlinik berjalan di http://localhost:${PORT}`);
            console.log('🐘 Database PostgreSQL aktif');
        });
    })
    .catch(err => {
        console.error('❌ Gagal konek ke PostgreSQL:', err.message);
        process.exit(1);
    });
