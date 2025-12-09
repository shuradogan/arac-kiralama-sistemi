// src/controllers/storedProcedureController.js
const { pool } = require('../config/database');

// 1. Yeni Kiralama Oluştur (Stored Procedure ile)
exports.yeniKiralamaOlusturSP = async (req, res) => {
  console.log('📝 YENİ KİRALAMA İSTEĞİ (Stored Procedure)');
  console.log('Body:', req.body);

  const { aracID, teslimLokasyonID, iadeLokasyonID, baslangicTarihi, bitisTarihi } = req.body;
  const musteriID = req.user.musteriID;

  try {
    // Stored Procedure'ü çağır
    const result = await pool.query(
      `SELECT * FROM sp_yeni_kiralama_olustur($1, $2, $3, $4, $5, $6)`,
      [musteriID, aracID, teslimLokasyonID, iadeLokasyonID, baslangicTarihi, bitisTarihi]
    );

    const kiralama = result.rows[0];

    console.log('✅ Kiralama oluşturuldu:', kiralama);

    res.json({
      success: true,
      message: kiralama.mesaj,
      data: {
        kiralamaID: kiralama.kiralama_id,
        toplamTutar: kiralama.toplam_tutar,
        gunSayisi: kiralama.gun_sayisi
      }
    });

  } catch (error) {
    console.error('❌ Kiralama hatası:', error.message);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// 2. Müşteri Toplam Harcama (Stored Procedure ile)
exports.musteriToplamHarcama = async (req, res) => {
  console.log('💰 MÜŞTERİ TOPLAM HARCAMA İSTEĞİ (Stored Procedure)');
  
  const musteriID = req.user.musteriID;

  try {
    const result = await pool.query(
      `SELECT * FROM sp_musteri_toplam_harcama($1)`,
      [musteriID]
    );

    const harcama = result.rows[0];

    console.log('✅ Toplam harcama:', harcama);

    res.json({
      success: true,
      data: {
        musteriID: harcama.musteri_id,
        ad: harcama.ad,
        soyad: harcama.soyad,
        toplamKiralamaSayisi: parseInt(harcama.toplam_kiralama_sayisi),
        toplamHarcama: parseFloat(harcama.toplam_harcama),
        ortalamaHarcama: parseFloat(harcama.ortalama_harcama),
        sonKiralamaTarihi: harcama.son_kiralama_tarihi
      }
    });

  } catch (error) {
    console.error('❌ Harcama hatası:', error.message);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// 3. En Yakın Müsait Sürücü Bul (Stored Procedure ile)
exports.enYakinSurucuBul = async (req, res) => {
  console.log('🚖 EN YAKIN SÜRÜCÜ İSTEĞİ (Stored Procedure)');
  
  const { latitude, longitude, limit } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).json({
      success: false,
      message: 'Konum bilgisi gerekli!'
    });
  }

  try {
    const result = await pool.query(
      `SELECT * FROM sp_en_yakin_musait_surucu_bul($1, $2, $3)`,
      [parseFloat(latitude), parseFloat(longitude), parseInt(limit) || 5]
    );

    const surucular = result.rows;

    console.log('✅ Bulunan sürücü sayısı:', surucular.length);

    res.json({
      success: true,
      count: surucular.length,
      data: surucular.map(s => ({
        surucuID: s.surucu_id,
        ad: s.ad,
        soyad: s.soyad,
        telefon: s.telefon,
        ortalamaPuan: parseFloat(s.ortalama_puan),
        mesafeKm: parseFloat(s.mesafe_km),
        aracPlaka: s.arac_plaka,
        aracModel: s.arac_model
      }))
    });

  } catch (error) {
    console.error('❌ Sürücü arama hatası:', error.message);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// 4. Aylık Gelir Raporu (Stored Procedure ile)
exports.aylikGelirRaporu = async (req, res) => {
  console.log('📊 AYLIK GELİR RAPORU İSTEĞİ (Stored Procedure)');
  
  const { yil, ay } = req.query;

  if (!yil || !ay) {
    return res.status(400).json({
      success: false,
      message: 'Yıl ve ay bilgisi gerekli!'
    });
  }

  try {
    const result = await pool.query(
      `SELECT * FROM sp_aylik_gelir_raporu($1, $2)`,
      [parseInt(yil), parseInt(ay)]
    );

    const rapor = result.rows[0];

    console.log('✅ Rapor oluşturuldu:', rapor);

    res.json({
      success: true,
      data: {
        ay: rapor.ay,
        toplamKiralamaSayisi: parseInt(rapor.toplam_kiralama_sayisi),
        tamamlananKiralama: parseInt(rapor.tamamlanan_kiralama),
        iptalEdilenKiralama: parseInt(rapor.iptal_edilen_kiralama),
        toplamGelir: parseFloat(rapor.toplam_gelir),
        ortalamaGelir: parseFloat(rapor.ortalama_gelir),
        enCokKiralananArac: rapor.en_cok_kiralanan_arac,
        enFazlaGelirGetirirenMusteri: rapor.en_fazla_gelir_getiren_musteri
      }
    });

  } catch (error) {
    console.error('❌ Rapor hatası:', error.message);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};
