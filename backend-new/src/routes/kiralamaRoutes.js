
const express = require('express');
const router = express.Router();
const kiralamaController = require('../controllers/kiralamaController');
const authMiddleware = require('../middleware/auth');

// tüm route'lar login gerektiriyo
router.use(authMiddleware);

router.post('/', kiralamaController.yeniKiralamaOlustur);
router.get('/', kiralamaController.getKiralamalarim);
router.delete('/:kiralamaID', kiralamaController.kiralamaIptal);
router.get('/lokasyonlar', kiralamaController.getLokasyonlar);

module.exports = router;
