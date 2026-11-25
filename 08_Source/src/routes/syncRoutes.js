// ROUTES: menghubungkan URL ke fungsi controller.
const express = require('express');
const syncController = require('../controllers/syncController');

const router = express.Router();

router.get('/sync', syncController.getData);
router.post('/sync', syncController.saveData);

module.exports = router;
