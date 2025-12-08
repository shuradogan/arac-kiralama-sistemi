
const pool = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// kullanıcı kaydı 
exports.register = async (req, res) => {
  console.log(' REGISTER İSTEĞİ GELDİ');
  console.log('Body:', JSON.stringify(req.body, null, 2));
  
  const client = await pool.connect();
  
  try {
    const { 
      tcNo, ad, soyad, telefon, email, sifre, 
      dogumTarihi, cinsiyet, kullaniciTipi 
    } = req.body;

    console.log(' Parse edilen veriler:', { tcNo, ad, soyad, email, kullaniciTipi });

    // validation
    if (!tcNo || !ad || !soyad || !telefon || !email || !sifre || !kullaniciTipi) {
      console.log(' Eksik alan var!');
      return res.status(400).json({ 
        success: false, 
        message: 'Tüm alanları doldurunuz!' 
      });
    }

    
    console.log(' Email kontrolü yapılıyor:', email);
    const emailCheck = await client.query(
      'SELECT "kullaniciID" FROM "Kullanici" WHERE "email" = $1',
      [email]
    );

    if (emailCheck.rows.length > 0) {
      console.log(' Email zaten var:', email);
      return res.status(400).json({ 
        success: false, 
        message: 'Bu email zaten kullanılıyor!' 
      });
    }

    
    console.log(' TC No kontrolü yapılıyor:', tcNo);
    const tcCheck = await client.query(
      'SELECT "kullaniciID" FROM "Kullanici" WHERE "tcNo" = $1',
      [tcNo]
    );

    if (tcCheck.rows.length > 0) {
      console.log(' TC No zaten var:', tcNo);
      return res.status(400).json({ 
        success: false, 
        message: 'Bu TC No zaten kayıtlı!' 
      });
    }

   
    console.log(' Şifre hashleniyor...');
    const hashedPassword = await bcrypt.hash(sifre, 10);
    console.log(' Şifre hashlendi');

    await client.query('BEGIN');
    console.log(' Transaction başladı');

   
    console.log(' Kullanıcı oluşturuluyor...');
    const userResult = await client.query(
      `INSERT INTO "Kullanici" 
      ("tcNo", "ad", "soyad", "telefon", "email", "sifre", "dogumTarihi", "cinsiyet") 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
      RETURNING "kullaniciID"`,
      [tcNo, ad, soyad, telefon, email, hashedPassword, dogumTarihi || null, cinsiyet || 'Erkek']
    );

    const kullaniciID = userResult.rows[0].kullaniciID;
    console.log(' Kullanıcı oluşturuldu, ID:', kullaniciID);

  
    if (kullaniciTipi === 'musteri') {
      console.log(' Müşteri kaydı oluşturuluyor...');
      await client.query(
        'INSERT INTO "Musteri" ("kullaniciID", "musteriTipi") VALUES ($1, $2)',
        [kullaniciID, 'Bireysel']
      );
      console.log(' Müşteri kaydı oluşturuldu');
    }

    await client.query('COMMIT');
    console.log(' Transaction commit edildi');

   
    const token = jwt.sign(
      { kullaniciID, email, kullaniciTipi },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    console.log(' KAYIT BAŞARILI! Kullanıcı ID:', kullaniciID);

    res.status(201).json({
      success: true,
      message: 'Kayıt başarılı!',
      data: {
        kullaniciID,
        ad,
        soyad,
        email,
        kullaniciTipi,
        token
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('!!! REGISTER ERROR !!!');
    console.error('Error message:', error.message);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      success: false, 
      message: 'Kayıt sırasında hata oluştu!',
      error: error.message 
    });
  } finally {
    client.release();
  }
};

// Kullanıcı Girişi (Login)
exports.login = async (req, res) => {
  console.log(' LOGIN İSTEĞİ GELDİ');
  console.log('Body:', { email: req.body.email });
  
  try {
    const { email, sifre } = req.body;

    if (!email || !sifre) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email ve şifre gerekli!' 
      });
    }

    // userı bul
    const userResult = await pool.query(
      'SELECT * FROM "Kullanici" WHERE "email" = $1 AND "aktifMi" = true',
      [email]
    );

    if (userResult.rows.length === 0) {
      console.log(' Kullanıcı bulunamadı:', email);
      return res.status(401).json({ 
        success: false, 
        message: 'Email veya şifre hatalı!' 
      });
    }

    const user = userResult.rows[0];

    // şifre kontrol
    const passwordMatch = await bcrypt.compare(sifre, user.sifre);

    if (!passwordMatch) {
      console.log(' Şifre yanlış');
      return res.status(401).json({ 
        success: false, 
        message: 'Email veya şifre hatalı!' 
      });
    }

    // kullanıcı tipi ney
    let kullaniciTipi = 'kullanici';
    
    const musteriCheck = await pool.query(
      'SELECT "musteriID" FROM "Musteri" WHERE "kullaniciID" = $1',
      [user.kullaniciID]
    );
    
    if (musteriCheck.rows.length > 0) {
      kullaniciTipi = 'musteri';
    }

    // son giriş tarihin güncelle
    await pool.query(
      'UPDATE "Kullanici" SET "sonGirisTarihi" = CURRENT_TIMESTAMP WHERE "kullaniciID" = $1',
      [user.kullaniciID]
    );

    // token oluştur
    const token = jwt.sign(
      { 
        kullaniciID: user.kullaniciID, 
        email: user.email, 
        kullaniciTipi 
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    console.log(' Giriş başarılı, Kullanıcı ID:', user.kullaniciID);

    res.json({
      success: true,
      message: 'Giriş başarılı!',
      data: {
        kullaniciID: user.kullaniciID,
        ad: user.ad,
        soyad: user.soyad,
        email: user.email,
        telefon: user.telefon,
        kullaniciTipi,
        token
      }
    });

  } catch (error) {
    console.error(' LOGIN ERROR:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Giriş sırasında hata oluştu!',
      error: error.message 
    });
  }
};
