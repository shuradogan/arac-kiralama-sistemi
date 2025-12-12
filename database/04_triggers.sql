-- ================================================
-- ARAÇ KİRALAMA SİSTEMİ - TRIGGERS
-- ================================================
-- Kullanım: psql -U postgres -d AracKiralamaDB -f 04_triggers.sql
-- ================================================
-- 5 Trigger Function + Trigger:
-- 1. trg_arac_durum_guncelle
-- 2. trg_gec_teslim_ceza_hesapla
-- 3. trg_otomatik_fatura_olustur
-- 4. trg_surucu_puan_guncelle
-- 5. trg_genel_log (bonus)
-- ================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ================================================
-- 1. ARAÇ DURUM GÜNCELLE
-- ================================================

--
-- Trigger Function: trg_arac_durum_guncelle
--

CREATE OR REPLACE FUNCTION public.trg_arac_durum_guncelle() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Kiralama başladığında
    IF NEW."durum" = 'DevamEdiyor' AND OLD."durum" = 'Rezerve' THEN
        UPDATE "Arac" SET "durum" = 'Kirada' WHERE "aracID" = NEW."aracID";
        
    -- Kiralama tamamlandığında
    ELSIF NEW."durum" = 'Tamamlandi' THEN
        UPDATE "Arac" SET "durum" = 'Musait' WHERE "aracID" = NEW."aracID";
        
    -- Kiralama iptal edildiğinde
    ELSIF NEW."durum" = 'Iptal' THEN
        UPDATE "Arac" SET "durum" = 'Musait' WHERE "aracID" = NEW."aracID";
    END IF;
    
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trg_arac_durum_guncelle() IS 'Kiralama durumu değiştiğinde aracın durumunu otomatik günceller';

--
-- Trigger: trg_arac_durum_guncelle_trigger
--

DROP TRIGGER IF EXISTS trg_arac_durum_guncelle_trigger ON public."Kiralama";

CREATE TRIGGER trg_arac_durum_guncelle_trigger
AFTER UPDATE ON public."Kiralama"
FOR EACH ROW
EXECUTE FUNCTION public.trg_arac_durum_guncelle();


-- ================================================
-- 2. GEÇ TESLİM CEZA HESAPLA
-- ================================================

--
-- Trigger Function: trg_gec_teslim_ceza_hesapla
--

CREATE OR REPLACE FUNCTION public.trg_gec_teslim_ceza_hesapla() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_gec_gun INTEGER;
    v_gunluk_ceza DECIMAL := 200.00; -- Günlük ceza tutarı
    v_toplam_ceza DECIMAL;
BEGIN
    -- İade tarihi güncellendiğinde kontrol et
    IF NEW."iadeTarihi" IS NOT NULL THEN
        
        -- Geç gün sayısını hesapla
        v_gec_gun := EXTRACT(DAY FROM (NEW."iadeTarihi" - NEW."bitisTarihi"));
        
        -- Eğer geç teslim varsa
        IF v_gec_gun > 0 THEN
            v_toplam_ceza := v_gec_gun * v_gunluk_ceza;
            
            -- Ceza kaydı oluştur (eğer yoksa)
            INSERT INTO "Ceza" (
                "kiralamaID", "cezaTipi", "gecGunSayisi", 
                "gunlukCezaTutari", "toplamCezaTutari", "aciklama"
            ) VALUES (
                NEW."kiralamaID",
                'Geç Teslim',
                v_gec_gun,
                v_gunluk_ceza,
                v_toplam_ceza,
                v_gec_gun || ' gün geç teslim nedeniyle ceza uygulandı.'
            )
            ON CONFLICT DO NOTHING;
            
            -- Kiralama tutarını güncelle
            UPDATE "Kiralama" 
            SET "toplamTutar" = "toplamTutar" + v_toplam_ceza
            WHERE "kiralamaID" = NEW."kiralamaID";
            
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trg_gec_teslim_ceza_hesapla() IS 'Geç teslim durumunda otomatik ceza hesaplar';

--
-- Trigger: trg_gec_teslim_ceza_trigger
--

DROP TRIGGER IF EXISTS trg_gec_teslim_ceza_trigger ON public."Kiralama";

CREATE TRIGGER trg_gec_teslim_ceza_trigger
AFTER UPDATE ON public."Kiralama"
FOR EACH ROW
WHEN (NEW."iadeTarihi" IS NOT NULL)
EXECUTE FUNCTION public.trg_gec_teslim_ceza_hesapla();


-- ================================================
-- 3. OTOMATİK FATURA OLUŞTUR
-- ================================================

--
-- Trigger Function: trg_otomatik_fatura_olustur
--

CREATE OR REPLACE FUNCTION public.trg_otomatik_fatura_olustur() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_fatura_no VARCHAR;
    v_ara_toplam DECIMAL;
    v_kdv_tutari DECIMAL;
    v_genel_toplam DECIMAL;
    v_musteri_id INTEGER;
    v_musteri_tipi VARCHAR;
BEGIN
    -- Sadece ödeme tamamlandığında çalışsın
    IF NEW."durum" = 'Tamamlandi' AND (OLD."durum" IS NULL OR OLD."durum" != 'Tamamlandi') THEN
        
        -- Fatura numarası oluştur (yıl-ay-sıra)
        v_fatura_no := 'FAT' || TO_CHAR(CURRENT_DATE, 'YYYYMM') || LPAD(nextval('fatura_sira_seq')::TEXT, 6, '0');
        
        -- KDV hesapla
        v_ara_toplam := NEW."netTutar";
        v_kdv_tutari := v_ara_toplam * 0.20; -- %20 KDV
        v_genel_toplam := v_ara_toplam + v_kdv_tutari;
        
        -- Müşteri tipini bul
        IF NEW."kiralamaID" IS NOT NULL THEN
            SELECT m."musteriTipi" INTO v_musteri_tipi
            FROM "Kiralama" k
            JOIN "Musteri" m ON k."musteriID" = m."musteriID"
            WHERE k."kiralamaID" = NEW."kiralamaID";
        ELSIF NEW."cagirmaID" IS NOT NULL THEN
            SELECT m."musteriTipi" INTO v_musteri_tipi
            FROM "AracCagirma" c
            JOIN "Musteri" m ON c."musteriID" = m."musteriID"
            WHERE c."cagirmaID" = NEW."cagirmaID";
        END IF;
        
        -- Fatura oluştur
        INSERT INTO "Fatura" (
            "odemeID", "faturaNo", "faturaTarihi", 
            "kdvOrani", "kdvTutari", "araToplam", "genelToplam", "faturaTipi"
        ) VALUES (
            NEW."odemeID",
            v_fatura_no,
            CURRENT_DATE,
            20.00,
            v_kdv_tutari,
            v_ara_toplam,
            v_genel_toplam,
            COALESCE(v_musteri_tipi, 'Bireysel')
        );
        
    END IF;
    
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trg_otomatik_fatura_olustur() IS 'Ödeme tamamlandığında otomatik fatura oluşturur';

--
-- Trigger: trg_otomatik_fatura_trigger
--

DROP TRIGGER IF EXISTS trg_otomatik_fatura_trigger ON public."Odeme";

CREATE TRIGGER trg_otomatik_fatura_trigger
AFTER UPDATE ON public."Odeme"
FOR EACH ROW
WHEN (NEW."durum" = 'Tamamlandi')
EXECUTE FUNCTION public.trg_otomatik_fatura_olustur();


-- ================================================
-- 4. SÜRÜCÜ PUAN GÜNCELLE
-- ================================================

--
-- Trigger Function: trg_surucu_puan_guncelle
--

CREATE OR REPLACE FUNCTION public.trg_surucu_puan_guncelle() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_ortalama_puan DECIMAL;
    v_toplam_yolculuk INTEGER;
BEGIN
    -- Sürücünün ortalama puanını hesapla
    SELECT 
        AVG("puan")::DECIMAL(3,2),
        COUNT(*)
    INTO v_ortalama_puan, v_toplam_yolculuk
    FROM "Degerlendirme"
    WHERE "surucuID" = NEW."surucuID";
    
    -- Sürücü tablosunu güncelle
    UPDATE "Surucu"
    SET 
        "ortalamaPuan" = v_ortalama_puan,
        "toplamYolculuk" = v_toplam_yolculuk
    WHERE "surucuID" = NEW."surucuID";
    
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trg_surucu_puan_guncelle() IS 'Değerlendirme eklendiğinde sürücünün ortalama puanını günceller';

--
-- Trigger: trg_surucu_puan_trigger
--

DROP TRIGGER IF EXISTS trg_surucu_puan_trigger ON public."Degerlendirme";

CREATE TRIGGER trg_surucu_puan_trigger
AFTER INSERT ON public."Degerlendirme"
FOR EACH ROW
EXECUTE FUNCTION public.trg_surucu_puan_guncelle();


-- ================================================
-- 5. GENEL LOG (BONUS)
-- ================================================

--
-- Trigger Function: trg_genel_log
--

CREATE OR REPLACE FUNCTION public.trg_genel_log() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO "IslemLog" ("tabloAdi", "islemTipi", "yeniVeri")
        VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW)::JSONB);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO "IslemLog" ("tabloAdi", "islemTipi", "eskiVeri", "yeniVeri")
        VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO "IslemLog" ("tabloAdi", "islemTipi", "eskiVeri")
        VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD)::JSONB);
        RETURN OLD;
    END IF;
END;
$$;

-- ================================================
-- TAMAMLANDI!
-- ================================================
-- Trigger'lar başarıyla oluşturuldu.
-- Kullanım: psql -U postgres -d AracKiralamaDB -f 04_triggers.sql
-- ================================================
