// CONTROLLER: menerima request, memanggil model, mengirim response.
const appStateModel = require('../models/appStateModel');

async function getData(req, res) {
    try {
        const data = await appStateModel.get();
        res.json(data);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
}

async function saveData(req, res) {
    try {
        await appStateModel.save(req.body);
        res.json({ status: 'ok' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
}

module.exports = { getData, saveData };
