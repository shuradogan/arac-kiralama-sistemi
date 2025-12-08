const express = require('express');
const cors = require('cors');
const pool = require('./src/config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Route'lar
const authRoutes = require('./src/routes/authRoutes');
const kiralamaRoutes = require('./src/routes/kiralamaRoutes');
const profilRoutes = require('./src/routes/profilRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/kiralamalar', kiralamaRoutes);
app.use('/api/profil', profilRoutes);

// Test endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: '🚗 Araç Kiralama API',
    status: 'Çalışıyor!',
    endpoints: {
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login',
      araclar: 'GET /api/araclar',
      aracDetay: 'GET /api/araclar/:aracID',
      yeniKiralama: 'POST /api/kiralamalar',
      kiralamalarim: 'GET /api/kiralamalar',
      kiralamaIptal: 'DELETE /api/kiralamalar/:kiralamaID',
      profil: 'GET /api/profil',
      profilGuncelle: 'PUT /api/profil'
    }
  });
});

// araçları listele
app.get('/api/araclar', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        a."aracID",
        a."plaka",
        a."yil",
        a."renk",
        a."gunlukKiraUcreti",
        a."durum",
        m."markaAdi",
        mo."modelAdi"
      FROM "Arac" a
      JOIN "Model" mo ON a."modelID" = mo."modelID"
      JOIN "Marka" m ON mo."markaID" = m."markaID"
      WHERE a."durum" = 'Musait'
      ORDER BY a."gunlukKiraUcreti" ASC
    `);
    
    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error(' Araçlar hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
});

// araç detay
app.get('/api/araclar/:aracID', async (req, res) => {
  try {
    const { aracID } = req.params;
    
    const result = await pool.query(`
      SELECT 
        a.*,
        m."markaAdi",
        mo."modelAdi",
        mo."kasaTipi",
        ak."kategoriAdi"
      FROM "Arac" a
      JOIN "Model" mo ON a."modelID" = mo."modelID"
      JOIN "Marka" m ON mo."markaID" = m."markaID"
      JOIN "AracKategori" ak ON a."kategoriID" = ak."kategoriID"
      WHERE a."aracID" = $1
    `, [aracID]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Araç bulunamadı!' 
      });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error(' Araç detay hatası:', error.message);
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔═════════════════════════════════════╗
║   Server: http://localhost:${PORT}     ║
║   Network: http://0.0.0.0:${PORT}      ║
╚═════════════════════════════════════╝
  `);
});
