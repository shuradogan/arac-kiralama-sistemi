# 🚗 Araç Kiralama Backend - Basit Versiyon

## 🚀 HIZLI KURULUM (3 Adım)

### 1️⃣ Dosyaları Çıkart
ZIP'i masaüstüne çıkart → `backend-new` klasörü

### 2️⃣ .env Dosyasını Düzenle
`.env` dosyasını aç:
```
DB_PASSWORD=12345    ← Buraya kendi PostgreSQL şifrenizi yazın
```
Kaydet ve kapat.

### 3️⃣ Kurulum ve Çalıştırma
Terminal/CMD aç (`backend-new` klasöründe):

```bash
npm install
npm run dev
```

## ✅ BAŞARILI!

Tarayıcıda aç: **http://localhost:3000**

Göreceksiniz:
```json
{
  "message": "🚗 Araç Kiralama API",
  "status": "Çalışıyor!"
}
```

## 🧪 TEST

Araçları görmek için:
```
http://localhost:3000/api/araclar
```

## 🐛 SORUN ÇÖZME

**Hata:** `PostgreSQL bağlanamadı`
- **Çözüm:** pgAdmin'i aç, veritabanına bağlan

**Hata:** `Port 3000 kullanımda`
- **Çözüm:** `.env` dosyasında `PORT=3001` yap

**Hata:** `npm not found`
- **Çözüm:** Node.js kur, bilgisayarı yeniden başlat

## 📞 İletişim

Sorun yaşarsanız ekran görüntüsü gönderin!
