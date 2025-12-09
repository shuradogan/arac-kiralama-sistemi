// src/routes/storedProcedureRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const spController = require('../controllers/storedProcedureController');

// Tüm route'lar authentication gerektiriyor
router.use(authMiddleware);

// 1. Yeni Kiralama Oluştur (Stored Procedure)
router.post('/kiralama-olustur', spController.yeniKiralamaOlusturSP);

// 2. Müşteri Toplam Harcama
router.get('/musteri-harcama', spController.musteriToplamHarcama);

// 3. En Yakın Sürücü Bul
router.get('/en-yakin-surucu', spController.enYakinSurucuBul);

// 4. Aylık Gelir Raporu
router.get('/aylik-gelir', spController.aylikGelirRaporu);

module.exports = router;
