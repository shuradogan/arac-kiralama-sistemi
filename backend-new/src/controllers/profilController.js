
const pool = require('../config/database');

// profil bilgisini getir (READ)
exports.getProfil = async (req, res) => {
  console.log(' PROFİL İSTEĞİ');
  
  try {
    const result = await pool.query(
      `SELECT 
        "kullaniciID", "tcNo", "ad", "soyad", "telefon", 
        "email", "dogumTarihi", "cinsiyet", "profilFoto"
      FROM "Kullanici" 
      WHERE "kullaniciID" = $1`,
      [req.user.kullaniciID]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Kullanıcı bulunamadı!' 
      });
    }

    console.log(' Profil bulundu');

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error) {
    console.error(' Profil hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// profil güncelle (UPDATE)
exports.updateProfil = async (req, res) => {
  console.log(' PROFİL GÜNCELLEME İSTEĞİ');
  console.log('Body:', req.body);
  
  try {
    const { ad, soyad, telefon, dogumTarihi, cinsiyet } = req.body;

    if (!ad || !soyad || !telefon) {
      return res.status(400).json({ 
        success: false, 
        message: 'Ad, soyad ve telefon gerekli!' 
      });
    }

    const result = await pool.query(
      `UPDATE "Kullanici" 
      SET "ad" = $1, "soyad" = $2, "telefon" = $3, 
          "dogumTarihi" = $4, "cinsiyet" = $5
      WHERE "kullaniciID" = $6
      RETURNING "ad", "soyad", "telefon", "dogumTarihi", "cinsiyet"`,
      [ad, soyad, telefon, dogumTarihi, cinsiyet, req.user.kullaniciID]
    );

    console.log(' Profil güncellendi');

    res.json({
      success: true,
      message: 'Profil başarıyla güncellendi!',
      data: result.rows[0]
    });

  } catch (error) {
    console.error(' Güncelleme hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Profil güncellenemedi!',
      error: error.message 
    });
  }
};
