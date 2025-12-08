
const express = require('express');
const router = express.Router();
const profilController = require('../controllers/profilController');
const authMiddleware = require('../middleware/auth');

// bütün route'lar login gerektiriyo
router.use(authMiddleware);

router.get('/', profilController.getProfil);
router.put('/', profilController.updateProfil);

module.exports = router;
