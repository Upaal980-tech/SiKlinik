// Pengaturan aplikasi Express (middleware, route, folder view).
const express = require('express');
const cors = require('cors');
const path = require('path');
const syncRoutes = require('./routes/syncRoutes');

const app = express();

app.use(cors());
// Limit diperbesar karena data JSON dari frontend cukup besar
app.use(express.json({ limit: '10mb' }));

// VIEW: frontend statis (HTML, CSS, JS) di folder public/
app.use(express.static(path.join(__dirname, '..', 'public')));

// API
app.use('/api', syncRoutes);

module.exports = app;
