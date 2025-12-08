
const pool = require('../config/database');

// Yeni Kiralama Oluştur (CREATE)
exports.yeniKiralamaOlustur = async (req, res) => {
  console.log(' YENİ KİRALAMA İSTEĞİ');
  console.log('Body:', req.body);
  
  const client = await pool.connect();
  
  try {
    const { 
      aracID, 
      teslimLokasyonID, 
      iadeLokasyonID, 
      baslangicTarihi, 
      bitisTarihi 
    } = req.body;

    // Müşteri ID'yi token'dan al
    const musteriResult = await client.query(
      'SELECT "musteriID" FROM "Musteri" WHERE "kullaniciID" = $1',
      [req.user.kullaniciID]
    );

    if (musteriResult.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Müşteri kaydı bulunamadı!' 
      });
    }

    const musteriID = musteriResult.rows[0].musteriID;

    // Araç bilgilerini al
    const aracResult = await client.query(
      'SELECT "gunlukKiraUcreti", "durum" FROM "Arac" WHERE "aracID" = $1',
      [aracID]
    );

    if (aracResult.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Araç bulunamadı!' 
      });
    }

    const arac = aracResult.rows[0];

    if (arac.durum !== 'Musait') {
      return res.status(400).json({ 
        success: false, 
        message: 'Araç müsait değil!' 
      });
    }

    // Gün sayısını hesapla
    const gunSayisi = Math.ceil(
      (new Date(bitisTarihi) - new Date(baslangicTarihi)) / (1000 * 60 * 60 * 24)
    );

    if (gunSayisi < 1) {
      return res.status(400).json({ 
        success: false, 
        message: 'Kiralama süresi en az 1 gün olmalıdır!' 
      });
    }

    const toplamTutar = parseFloat(arac.gunlukKiraUcreti) * gunSayisi;

    await client.query('BEGIN');

    // Kiralama oluştur
    const kiralamaResult = await client.query(
      `INSERT INTO "Kiralama" 
      ("musteriID", "aracID", "teslimLokasyonID", "iadeLokasyonID", 
       "baslangicTarihi", "bitisTarihi", "gunlukUcret", "toplamTutar", "durum")
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING "kiralamaID"`,
      [musteriID, aracID, teslimLokasyonID, iadeLokasyonID, 
       baslangicTarihi, bitisTarihi, arac.gunlukKiraUcreti, toplamTutar, 'Rezerve']
    );

    const kiralamaID = kiralamaResult.rows[0].kiralamaID;

    // Araç durumunu güncelle
    await client.query(
      'UPDATE "Arac" SET "durum" = $1 WHERE "aracID" = $2',
      ['Kirada', aracID]
    );

    await client.query('COMMIT');

    console.log(' Kiralama oluşturuldu, ID:', kiralamaID);

    res.status(201).json({
      success: true,
      message: 'Kiralama başarıyla oluşturuldu!',
      data: {
        kiralamaID,
        toplamTutar,
        gunSayisi
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error(' Kiralama hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Kiralama oluşturulamadı!',
      error: error.message 
    });
  } finally {
    client.release();
  }
};

// Kiralamalarımı Listele (READ)
exports.getKiralamalarim = async (req, res) => {
  console.log(' KİRALAMALARIM İSTEĞİ');
  
  try {
    // Müşteri ID'yi bul
    const musteriResult = await pool.query(
      'SELECT "musteriID" FROM "Musteri" WHERE "kullaniciID" = $1',
      [req.user.kullaniciID]
    );

    if (musteriResult.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Müşteri kaydı bulunamadı!' 
      });
    }

    const musteriID = musteriResult.rows[0].musteriID;

    const result = await pool.query(
      `SELECT 
        k."kiralamaID",
        k."baslangicTarihi",
        k."bitisTarihi",
        k."toplamTutar",
        k."durum",
        a."plaka",
        m."markaAdi",
        mo."modelAdi",
        a."yil",
        a."renk",
        tl."lokasyonAdi" as "teslimLokasyonu",
        il."lokasyonAdi" as "iadeLokasyonu"
      FROM "Kiralama" k
      JOIN "Arac" a ON k."aracID" = a."aracID"
      JOIN "Model" mo ON a."modelID" = mo."modelID"
      JOIN "Marka" m ON mo."markaID" = m."markaID"
      JOIN "Lokasyon" tl ON k."teslimLokasyonID" = tl."lokasyonID"
      JOIN "Lokasyon" il ON k."iadeLokasyonID" = il."lokasyonID"
      WHERE k."musteriID" = $1
      ORDER BY k."baslangicTarihi" DESC`,
      [musteriID]
    );

    console.log(' Kiralamalar bulundu:', result.rows.length);

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });

  } catch (error) {
    console.error(' Kiralamalar hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Kiralamalar getirilemedi!',
      error: error.message 
    });
  }
};

// Kiralama İptal Et (DELETE)
exports.kiralamaIptal = async (req, res) => {
  console.log(' KİRALAMA İPTAL İSTEĞİ');
  
  const client = await pool.connect();
  
  try {
    const { kiralamaID } = req.params;

    // Müşteri ID'yi bul
    const musteriResult = await client.query(
      'SELECT "musteriID" FROM "Musteri" WHERE "kullaniciID" = $1',
      [req.user.kullaniciID]
    );

    const musteriID = musteriResult.rows[0].musteriID;

    // Kiralama kontrolü
    const kiralamaResult = await client.query(
      'SELECT "durum", "aracID" FROM "Kiralama" WHERE "kiralamaID" = $1 AND "musteriID" = $2',
      [kiralamaID, musteriID]
    );

    if (kiralamaResult.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Kiralama bulunamadı!' 
      });
    }

    const kiralama = kiralamaResult.rows[0];

    if (kiralama.durum === 'Tamamlandi') {
      return res.status(400).json({ 
        success: false, 
        message: 'Tamamlanmış kiralama iptal edilemez!' 
      });
    }

    if (kiralama.durum === 'Iptal') {
      return res.status(400).json({ 
        success: false, 
        message: 'Kiralama zaten iptal edilmiş!' 
      });
    }

    await client.query('BEGIN');

    // Kirala mayı iptal et
    await client.query(
      'UPDATE "Kiralama" SET "durum" = $1 WHERE "kiralamaID" = $2',
      ['Iptal', kiralamaID]
    );

    // Araç durumunu güncelle
    await client.query(
      'UPDATE "Arac" SET "durum" = $1 WHERE "aracID" = $2',
      ['Musait', kiralama.aracID]
    );

    await client.query('COMMIT');

    console.log(' Kiralama iptal edildi:', kiralamaID);

    res.json({
      success: true,
      message: 'Kiralama başarıyla iptal edildi!'
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error(' İptal hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Kiralama iptal edilemedi!',
      error: error.message 
    });
  } finally {
    client.release();
  }
};

// Lokasyonları Listele
exports.getLokasyonlar = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        l.*,
        s."sehirAdi"
      FROM "Lokasyon" l
      JOIN "Sehir" s ON l."sehirID" = s."sehirID"
      WHERE l."aktifMi" = true
      ORDER BY s."sehirAdi", l."lokasyonAdi"`
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error(' Lokasyonlar hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};
