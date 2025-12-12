--
-- PostgreSQL database dump
--

\restrict RBmz1CoPOYieohUYvpXKpVcflOOzfnLOtMxtzO4Fmv3P7jF21s8ePzeIcR12lwD

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-08 22:47:35

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 277 (class 1255 OID 17043)
-- Name: trg_arac_durum_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_arac_durum_guncelle() RETURNS trigger
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


ALTER FUNCTION public.trg_arac_durum_guncelle() OWNER TO postgres;

--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 277
-- Name: FUNCTION trg_arac_durum_guncelle(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.trg_arac_durum_guncelle() IS 'Kiralama durumu değiştiğinde aracın durumunu otomatik günceller';


--
-- TOC entry 290 (class 1255 OID 17068)
-- Name: trg_gec_teslim_ceza_hesapla(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_gec_teslim_ceza_hesapla() RETURNS trigger
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


ALTER FUNCTION public.trg_gec_teslim_ceza_hesapla() OWNER TO postgres;

--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 290
-- Name: FUNCTION trg_gec_teslim_ceza_hesapla(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.trg_gec_teslim_ceza_hesapla() IS 'Geç teslim durumunda otomatik ceza hesaplar';


--
-- TOC entry 292 (class 1255 OID 17085)
-- Name: trg_genel_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_genel_log() RETURNS trigger
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


ALTER FUNCTION public.trg_genel_log() OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 17045)
-- Name: trg_otomatik_fatura_olustur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_otomatik_fatura_olustur() RETURNS trigger
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


ALTER FUNCTION public.trg_otomatik_fatura_olustur() OWNER TO postgres;

--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 289
-- Name: FUNCTION trg_otomatik_fatura_olustur(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.trg_otomatik_fatura_olustur() IS 'Ödeme tamamlandığında otomatik fatura oluşturur';


--
-- TOC entry 291 (class 1255 OID 17070)
-- Name: trg_surucu_puan_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_surucu_puan_guncelle() RETURNS trigger
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


ALTER FUNCTION public.trg_surucu_puan_guncelle() OWNER TO postgres;

--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 291
-- Name: FUNCTION trg_surucu_puan_guncelle(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.trg_surucu_puan_guncelle() IS 'Değerlendirme eklendiğinde sürücünün ortalama puanını günceller';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 16441)
-- Name: Adres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Adres" (
    "adresID" integer NOT NULL,
    "kullaniciID" integer NOT NULL,
    "sehirID" integer NOT NULL,
    "adresBasligi" character varying(50),
    "adresSatiri1" text NOT NULL,
    "adresSatiri2" text,
    "postaKodu" character varying(10),
    "varsayilanMi" boolean DEFAULT false
);


ALTER TABLE public."Adres" OWNER TO postgres;

--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE "Adres"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Adres" IS 'Kullanıcı adresleri';


--
-- TOC entry 225 (class 1259 OID 16440)
-- Name: Adres_adresID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Adres_adresID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Adres_adresID_seq" OWNER TO postgres;

--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 225
-- Name: Adres_adresID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Adres_adresID_seq" OWNED BY public."Adres"."adresID";


--
-- TOC entry 248 (class 1259 OID 16633)
-- Name: Arac; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Arac" (
    "aracID" integer NOT NULL,
    plaka character varying(20) NOT NULL,
    "kategoriID" integer NOT NULL,
    "modelID" integer NOT NULL,
    "surucuID" integer NOT NULL,
    yil integer NOT NULL,
    renk character varying(30),
    "yakitTipi" character varying(20),
    "vitesTipi" character varying(20),
    "koltukSayisi" integer NOT NULL,
    kilometre integer DEFAULT 0,
    "gunlukKiraUcreti" numeric(10,2) NOT NULL,
    "cagirmaBaslangicUcreti" numeric(10,2) NOT NULL,
    "cagirmaKmUcreti" numeric(10,2) NOT NULL,
    durum character varying(20) DEFAULT 'Musait'::character varying,
    "ruhsatSeriNo" character varying(50),
    "ruhsatTarihi" date,
    "kayitTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Arac_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Musait'::character varying, 'Kirada'::character varying, 'Cagirda'::character varying, 'Bakimda'::character varying, 'Arizali'::character varying])::text[]))),
    CONSTRAINT "Arac_vitesTipi_check" CHECK ((("vitesTipi")::text = ANY ((ARRAY['Manuel'::character varying, 'Otomatik'::character varying, 'Yarimotomatik'::character varying])::text[]))),
    CONSTRAINT "Arac_yakitTipi_check" CHECK ((("yakitTipi")::text = ANY ((ARRAY['Benzin'::character varying, 'Dizel'::character varying, 'Elektrik'::character varying, 'Hibrit'::character varying, 'LPG'::character varying])::text[])))
);


ALTER TABLE public."Arac" OWNER TO postgres;

--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE "Arac"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Arac" IS 'Araç bilgileri - kiralama ve çağırma için kullanılır';


--
-- TOC entry 261 (class 1259 OID 16818)
-- Name: AracCagirma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AracCagirma" (
    "cagirmaID" integer NOT NULL,
    "musteriID" integer NOT NULL,
    "surucuID" integer,
    "aracID" integer,
    "baslangicLat" numeric(10,8) NOT NULL,
    "baslangicLng" numeric(11,8) NOT NULL,
    "bitisLat" numeric(10,8),
    "bitisLng" numeric(11,8),
    "baslangicAdres" text NOT NULL,
    "bitisAdres" text,
    "talepTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "kabulTarihi" timestamp without time zone,
    "baslangicTarihi" timestamp without time zone,
    "bitisTarihi" timestamp without time zone,
    mesafe numeric(10,2),
    sure integer,
    "baslangicUcret" numeric(10,2),
    "kmUcreti" numeric(10,2),
    "toplamTutar" numeric(10,2),
    durum character varying(20) DEFAULT 'Beklemede'::character varying,
    CONSTRAINT "AracCagirma_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Beklemede'::character varying, 'KabulEdildi'::character varying, 'Basladi'::character varying, 'Tamamlandi'::character varying, 'Iptal'::character varying])::text[])))
);


ALTER TABLE public."AracCagirma" OWNER TO postgres;

--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE "AracCagirma"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."AracCagirma" IS 'Uber tarzı araç çağırma işlemleri';


--
-- TOC entry 260 (class 1259 OID 16817)
-- Name: AracCagirma_cagirmaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."AracCagirma_cagirmaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AracCagirma_cagirmaID_seq" OWNER TO postgres;

--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 260
-- Name: AracCagirma_cagirmaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."AracCagirma_cagirmaID_seq" OWNED BY public."AracCagirma"."cagirmaID";


--
-- TOC entry 232 (class 1259 OID 16497)
-- Name: AracKategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AracKategori" (
    "kategoriID" integer NOT NULL,
    "kategoriAdi" character varying(50) NOT NULL,
    aciklama text,
    "minKoltukSayisi" integer,
    "maxKoltukSayisi" integer
);


ALTER TABLE public."AracKategori" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16496)
-- Name: AracKategori_kategoriID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."AracKategori_kategoriID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AracKategori_kategoriID_seq" OWNER TO postgres;

--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 231
-- Name: AracKategori_kategoriID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."AracKategori_kategoriID_seq" OWNED BY public."AracKategori"."kategoriID";


--
-- TOC entry 250 (class 1259 OID 16673)
-- Name: AracKonum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AracKonum" (
    "konumID" integer NOT NULL,
    "aracID" integer NOT NULL,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    hiz integer DEFAULT 0,
    yon integer,
    "guncellemeTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    adres text
);


ALTER TABLE public."AracKonum" OWNER TO postgres;

--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE "AracKonum"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."AracKonum" IS 'Araçların anlık GPS konumu';


--
-- TOC entry 249 (class 1259 OID 16672)
-- Name: AracKonum_konumID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."AracKonum_konumID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AracKonum_konumID_seq" OWNER TO postgres;

--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 249
-- Name: AracKonum_konumID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."AracKonum_konumID_seq" OWNED BY public."AracKonum"."konumID";


--
-- TOC entry 247 (class 1259 OID 16632)
-- Name: Arac_aracID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Arac_aracID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Arac_aracID_seq" OWNER TO postgres;

--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 247
-- Name: Arac_aracID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Arac_aracID_seq" OWNED BY public."Arac"."aracID";


--
-- TOC entry 254 (class 1259 OID 16718)
-- Name: BakimKayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BakimKayit" (
    "bakimID" integer NOT NULL,
    "aracID" integer NOT NULL,
    "bakimTipi" character varying(50) NOT NULL,
    "bakimTarihi" date NOT NULL,
    "sonrakiBakimTarihi" date,
    kilometre integer,
    tutar numeric(10,2),
    "servisYeri" character varying(100),
    aciklama text,
    "faturaDosyasi" text
);


ALTER TABLE public."BakimKayit" OWNER TO postgres;

--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE "BakimKayit"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."BakimKayit" IS 'Araç bakım geçmişi';


--
-- TOC entry 253 (class 1259 OID 16717)
-- Name: BakimKayit_bakimID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."BakimKayit_bakimID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."BakimKayit_bakimID_seq" OWNER TO postgres;

--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 253
-- Name: BakimKayit_bakimID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."BakimKayit_bakimID_seq" OWNED BY public."BakimKayit"."bakimID";


--
-- TOC entry 274 (class 1259 OID 17049)
-- Name: Ceza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ceza" (
    "cezaID" integer NOT NULL,
    "kiralamaID" integer NOT NULL,
    "cezaTipi" character varying(50) NOT NULL,
    "gecGunSayisi" integer,
    "gunlukCezaTutari" numeric(10,2),
    "toplamCezaTutari" numeric(10,2) NOT NULL,
    aciklama text,
    "olusturmaTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "odendiMi" boolean DEFAULT false
);


ALTER TABLE public."Ceza" OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 17048)
-- Name: Ceza_cezaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Ceza_cezaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Ceza_cezaID_seq" OWNER TO postgres;

--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 273
-- Name: Ceza_cezaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Ceza_cezaID_seq" OWNED BY public."Ceza"."cezaID";


--
-- TOC entry 265 (class 1259 OID 16894)
-- Name: Degerlendirme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Degerlendirme" (
    "degerlendirmeID" integer NOT NULL,
    "cagirmaID" integer NOT NULL,
    "musteriID" integer NOT NULL,
    "surucuID" integer NOT NULL,
    puan integer NOT NULL,
    yorum text,
    "degerlendirmeTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "surucuYanit" text,
    "yanitTarihi" timestamp without time zone,
    CONSTRAINT "Degerlendirme_puan_check" CHECK (((puan >= 1) AND (puan <= 5)))
);


ALTER TABLE public."Degerlendirme" OWNER TO postgres;

--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE "Degerlendirme"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Degerlendirme" IS 'Yolculuk ve sürücü değerlendirmeleri';


--
-- TOC entry 264 (class 1259 OID 16893)
-- Name: Degerlendirme_degerlendirmeID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Degerlendirme_degerlendirmeID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Degerlendirme_degerlendirmeID_seq" OWNER TO postgres;

--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 264
-- Name: Degerlendirme_degerlendirmeID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Degerlendirme_degerlendirmeID_seq" OWNED BY public."Degerlendirme"."degerlendirmeID";


--
-- TOC entry 271 (class 1259 OID 17003)
-- Name: DestekTalebi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DestekTalebi" (
    "talepID" integer NOT NULL,
    "kullaniciID" integer NOT NULL,
    "yoneticiID" integer,
    konu character varying(200) NOT NULL,
    mesaj text NOT NULL,
    oncelik character varying(20) DEFAULT 'Normal'::character varying,
    durum character varying(20) DEFAULT 'Acik'::character varying,
    "olusturmaTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "guncellemeTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "kapatmaTarihi" timestamp without time zone,
    CONSTRAINT "DestekTalebi_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Acik'::character varying, 'Cevaplandi'::character varying, 'Cozuldu'::character varying, 'Kapali'::character varying])::text[]))),
    CONSTRAINT "DestekTalebi_oncelik_check" CHECK (((oncelik)::text = ANY ((ARRAY['Dusuk'::character varying, 'Normal'::character varying, 'Yuksek'::character varying, 'Acil'::character varying])::text[])))
);


ALTER TABLE public."DestekTalebi" OWNER TO postgres;

--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE "DestekTalebi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."DestekTalebi" IS 'Müşteri destek talepleri';


--
-- TOC entry 270 (class 1259 OID 17002)
-- Name: DestekTalebi_talepID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DestekTalebi_talepID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DestekTalebi_talepID_seq" OWNER TO postgres;

--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 270
-- Name: DestekTalebi_talepID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DestekTalebi_talepID_seq" OWNED BY public."DestekTalebi"."talepID";


--
-- TOC entry 238 (class 1259 OID 16538)
-- Name: EkHizmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EkHizmet" (
    "hizmetID" integer NOT NULL,
    "hizmetAdi" character varying(100) NOT NULL,
    aciklama text,
    "gunlukUcret" numeric(10,2) NOT NULL,
    "stokAdedi" integer DEFAULT 0,
    "aktifMi" boolean DEFAULT true
);


ALTER TABLE public."EkHizmet" OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16537)
-- Name: EkHizmet_hizmetID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."EkHizmet_hizmetID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."EkHizmet_hizmetID_seq" OWNER TO postgres;

--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 237
-- Name: EkHizmet_hizmetID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."EkHizmet_hizmetID_seq" OWNED BY public."EkHizmet"."hizmetID";


--
-- TOC entry 269 (class 1259 OID 16977)
-- Name: Fatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Fatura" (
    "faturaID" integer NOT NULL,
    "odemeID" integer NOT NULL,
    "faturaNo" character varying(50) NOT NULL,
    "faturaTarihi" date DEFAULT CURRENT_DATE,
    "firmaAdi" character varying(200),
    "vergiNo" character varying(20),
    "vergiDairesi" character varying(100),
    adres text,
    "kdvOrani" numeric(5,2) DEFAULT 20.00,
    "kdvTutari" numeric(10,2),
    "araToplam" numeric(12,2) NOT NULL,
    "genelToplam" numeric(12,2) NOT NULL,
    "faturaTipi" character varying(20),
    "pdfDosyasi" text,
    CONSTRAINT "Fatura_faturaTipi_check" CHECK ((("faturaTipi")::text = ANY ((ARRAY['Bireysel'::character varying, 'Kurumsal'::character varying])::text[])))
);


ALTER TABLE public."Fatura" OWNER TO postgres;

--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE "Fatura"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Fatura" IS 'Ödeme faturaları';


--
-- TOC entry 268 (class 1259 OID 16976)
-- Name: Fatura_faturaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Fatura_faturaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Fatura_faturaID_seq" OWNER TO postgres;

--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 268
-- Name: Fatura_faturaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Fatura_faturaID_seq" OWNED BY public."Fatura"."faturaID";


--
-- TOC entry 256 (class 1259 OID 16736)
-- Name: HasarKayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HasarKayit" (
    "hasarID" integer NOT NULL,
    "aracID" integer NOT NULL,
    "kiralamaID" integer,
    "cagirmaID" integer,
    "hasarTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "hasarTipi" character varying(50) NOT NULL,
    "hasarAciklamasi" text,
    "sorumluKisi" character varying(20),
    "tamirTutari" numeric(10,2),
    "sigortaKapsamindaMi" boolean DEFAULT false,
    durumu character varying(20) DEFAULT 'Beklemede'::character varying,
    fotograflar text,
    CONSTRAINT "HasarKayit_durumu_check" CHECK (((durumu)::text = ANY ((ARRAY['Beklemede'::character varying, 'Onariliyor'::character varying, 'Tamamlandi'::character varying])::text[]))),
    CONSTRAINT "HasarKayit_sorumluKisi_check" CHECK ((("sorumluKisi")::text = ANY ((ARRAY['Musteri'::character varying, 'Surucu'::character varying, 'Diger'::character varying])::text[])))
);


ALTER TABLE public."HasarKayit" OWNER TO postgres;

--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE "HasarKayit"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."HasarKayit" IS 'Araç hasar kayıtları';


--
-- TOC entry 255 (class 1259 OID 16735)
-- Name: HasarKayit_hasarID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."HasarKayit_hasarID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."HasarKayit_hasarID_seq" OWNER TO postgres;

--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 255
-- Name: HasarKayit_hasarID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."HasarKayit_hasarID_seq" OWNED BY public."HasarKayit"."hasarID";


--
-- TOC entry 276 (class 1259 OID 17073)
-- Name: IslemLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."IslemLog" (
    "logID" integer NOT NULL,
    "tabloAdi" character varying(50) NOT NULL,
    "islemTipi" character varying(20) NOT NULL,
    "kayitID" integer,
    "eskiVeri" jsonb,
    "yeniVeri" jsonb,
    "kullaniciID" integer,
    "islemZamani" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public."IslemLog" OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 17072)
-- Name: IslemLog_logID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."IslemLog_logID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."IslemLog_logID_seq" OWNER TO postgres;

--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 275
-- Name: IslemLog_logID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."IslemLog_logID_seq" OWNED BY public."IslemLog"."logID";


--
-- TOC entry 258 (class 1259 OID 16758)
-- Name: Kiralama; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kiralama" (
    "kiralamaID" integer NOT NULL,
    "musteriID" integer NOT NULL,
    "aracID" integer NOT NULL,
    "teslimLokasyonID" integer NOT NULL,
    "iadeLokasyonID" integer NOT NULL,
    "baslangicTarihi" timestamp without time zone NOT NULL,
    "bitisTarihi" timestamp without time zone NOT NULL,
    "teslimTarihi" timestamp without time zone,
    "iadeTarihi" timestamp without time zone,
    "gunlukUcret" numeric(10,2) NOT NULL,
    "toplamTutar" numeric(12,2) NOT NULL,
    durum character varying(20) DEFAULT 'Rezerve'::character varying,
    "teslimKM" integer,
    "iadeKM" integer,
    notlar text,
    CONSTRAINT "Kiralama_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Rezerve'::character varying, 'DevamEdiyor'::character varying, 'Tamamlandi'::character varying, 'Iptal'::character varying])::text[])))
);


ALTER TABLE public."Kiralama" OWNER TO postgres;

--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE "Kiralama"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Kiralama" IS 'Araç kiralama işlemleri';


--
-- TOC entry 259 (class 1259 OID 16797)
-- Name: KiralamaEkHizmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."KiralamaEkHizmet" (
    "kiralamaID" integer NOT NULL,
    "hizmetID" integer NOT NULL,
    adet integer DEFAULT 1,
    "gunlukUcret" numeric(10,2) NOT NULL,
    "toplamTutar" numeric(10,2) NOT NULL
);


ALTER TABLE public."KiralamaEkHizmet" OWNER TO postgres;

--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE "KiralamaEkHizmet"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."KiralamaEkHizmet" IS 'Kiralama ek hizmetleri - Çoka-çok ilişki tablosu';


--
-- TOC entry 257 (class 1259 OID 16757)
-- Name: Kiralama_kiralamaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Kiralama_kiralamaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kiralama_kiralamaID_seq" OWNER TO postgres;

--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 257
-- Name: Kiralama_kiralamaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Kiralama_kiralamaID_seq" OWNED BY public."Kiralama"."kiralamaID";


--
-- TOC entry 224 (class 1259 OID 16419)
-- Name: Kullanici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kullanici" (
    "kullaniciID" integer NOT NULL,
    "tcNo" character varying(11) NOT NULL,
    ad character varying(50) NOT NULL,
    soyad character varying(50) NOT NULL,
    telefon character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    sifre character varying(255) NOT NULL,
    "dogumTarihi" date,
    cinsiyet character varying(10),
    "profilFoto" text,
    "kayitTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "sonGirisTarihi" timestamp without time zone,
    "aktifMi" boolean DEFAULT true
);


ALTER TABLE public."Kullanici" OWNER TO postgres;

--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE "Kullanici"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Kullanici" IS 'Kalıtım üst sınıfı - Tüm kullanıcı tipleri için temel tablo';


--
-- TOC entry 223 (class 1259 OID 16418)
-- Name: Kullanici_kullaniciID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Kullanici_kullaniciID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kullanici_kullaniciID_seq" OWNER TO postgres;

--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 223
-- Name: Kullanici_kullaniciID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Kullanici_kullaniciID_seq" OWNED BY public."Kullanici"."kullaniciID";


--
-- TOC entry 240 (class 1259 OID 16552)
-- Name: Lokasyon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Lokasyon" (
    "lokasyonID" integer NOT NULL,
    "lokasyonAdi" character varying(100) NOT NULL,
    "sehirID" integer NOT NULL,
    adres text NOT NULL,
    latitude numeric(10,8),
    longitude numeric(11,8),
    telefon character varying(20),
    email character varying(100),
    "calismaSaatleri" character varying(100),
    tip character varying(50),
    "aktifMi" boolean DEFAULT true,
    CONSTRAINT "Lokasyon_tip_check" CHECK (((tip)::text = ANY ((ARRAY['Sube'::character varying, 'Otopark'::character varying, 'Havalimani'::character varying, 'Otogar'::character varying])::text[])))
);


ALTER TABLE public."Lokasyon" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16551)
-- Name: Lokasyon_lokasyonID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Lokasyon_lokasyonID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Lokasyon_lokasyonID_seq" OWNER TO postgres;

--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 239
-- Name: Lokasyon_lokasyonID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Lokasyon_lokasyonID_seq" OWNED BY public."Lokasyon"."lokasyonID";


--
-- TOC entry 234 (class 1259 OID 16508)
-- Name: Marka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Marka" (
    "markaID" integer NOT NULL,
    "markaAdi" character varying(100) NOT NULL,
    "ulkeID" integer NOT NULL
);


ALTER TABLE public."Marka" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16507)
-- Name: Marka_markaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Marka_markaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Marka_markaID_seq" OWNER TO postgres;

--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 233
-- Name: Marka_markaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Marka_markaID_seq" OWNED BY public."Marka"."markaID";


--
-- TOC entry 236 (class 1259 OID 16523)
-- Name: Model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Model" (
    "modelID" integer NOT NULL,
    "markaID" integer NOT NULL,
    "modelAdi" character varying(100) NOT NULL,
    "kasaTipi" character varying(50)
);


ALTER TABLE public."Model" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16522)
-- Name: Model_modelID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Model_modelID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Model_modelID_seq" OWNER TO postgres;

--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 235
-- Name: Model_modelID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Model_modelID_seq" OWNED BY public."Model"."modelID";


--
-- TOC entry 242 (class 1259 OID 16572)
-- Name: Musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Musteri" (
    "musteriID" integer NOT NULL,
    "kullaniciID" integer NOT NULL,
    "ehliyetNo" character varying(20),
    "ehliyetTarihi" date,
    "musteriTipi" character varying(20),
    "toplamYolculuk" integer DEFAULT 0,
    "toplamHarcama" numeric(12,2) DEFAULT 0,
    "uyeOlmaTarihi" date DEFAULT CURRENT_DATE,
    CONSTRAINT "Musteri_musteriTipi_check" CHECK ((("musteriTipi")::text = ANY ((ARRAY['Bireysel'::character varying, 'Kurumsal'::character varying])::text[])))
);


ALTER TABLE public."Musteri" OWNER TO postgres;

--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE "Musteri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Musteri" IS 'Kalıtım alt sınıfı - Müşteri özellikleri';


--
-- TOC entry 241 (class 1259 OID 16571)
-- Name: Musteri_musteriID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Musteri_musteriID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Musteri_musteriID_seq" OWNER TO postgres;

--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 241
-- Name: Musteri_musteriID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Musteri_musteriID_seq" OWNED BY public."Musteri"."musteriID";


--
-- TOC entry 267 (class 1259 OID 16937)
-- Name: Odeme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Odeme" (
    "odemeID" integer NOT NULL,
    "kiralamaID" integer,
    "cagirmaID" integer,
    "yontemID" integer NOT NULL,
    "promosyonKoduID" integer,
    tutar numeric(12,2) NOT NULL,
    indirim numeric(10,2) DEFAULT 0,
    "netTutar" numeric(12,2) NOT NULL,
    "odemeTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    durum character varying(20) DEFAULT 'Beklemede'::character varying,
    "islemNo" character varying(100),
    aciklama text,
    CONSTRAINT "Odeme_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Beklemede'::character varying, 'Tamamlandi'::character varying, 'Basarisiz'::character varying, 'Iade'::character varying])::text[]))),
    CONSTRAINT odeme_check CHECK ((("kiralamaID" IS NOT NULL) OR ("cagirmaID" IS NOT NULL)))
);


ALTER TABLE public."Odeme" OWNER TO postgres;

--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE "Odeme"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Odeme" IS 'Ödeme işlemleri - kiralama veya çağırma için';


--
-- TOC entry 228 (class 1259 OID 16465)
-- Name: OdemeYontemi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OdemeYontemi" (
    "yontemID" integer NOT NULL,
    "yontemAdi" character varying(50) NOT NULL,
    "komisyonOrani" numeric(5,2) DEFAULT 0,
    "aktifMi" boolean DEFAULT true
);


ALTER TABLE public."OdemeYontemi" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16464)
-- Name: OdemeYontemi_yontemID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OdemeYontemi_yontemID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."OdemeYontemi_yontemID_seq" OWNER TO postgres;

--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 227
-- Name: OdemeYontemi_yontemID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OdemeYontemi_yontemID_seq" OWNED BY public."OdemeYontemi"."yontemID";


--
-- TOC entry 266 (class 1259 OID 16936)
-- Name: Odeme_odemeID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Odeme_odemeID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Odeme_odemeID_seq" OWNER TO postgres;

--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 266
-- Name: Odeme_odemeID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Odeme_odemeID_seq" OWNED BY public."Odeme"."odemeID";


--
-- TOC entry 230 (class 1259 OID 16476)
-- Name: PromosyonKodu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PromosyonKodu" (
    "promosyonKoduID" integer NOT NULL,
    kod character varying(50) NOT NULL,
    aciklama text,
    "indirimTipi" character varying(20) NOT NULL,
    "indirimMiktari" numeric(10,2) NOT NULL,
    "minTutar" numeric(10,2) DEFAULT 0,
    "maxIndirim" numeric(10,2),
    "baslangicTarihi" date NOT NULL,
    "bitisTarihi" date NOT NULL,
    "kullanimSayisi" integer DEFAULT 0,
    "maxKullanimSayisi" integer,
    "aktifMi" boolean DEFAULT true,
    CONSTRAINT "PromosyonKodu_indirimTipi_check" CHECK ((("indirimTipi")::text = ANY ((ARRAY['Yuzde'::character varying, 'Tutar'::character varying])::text[])))
);


ALTER TABLE public."PromosyonKodu" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16475)
-- Name: PromosyonKodu_promosyonKoduID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PromosyonKodu_promosyonKoduID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."PromosyonKodu_promosyonKoduID_seq" OWNER TO postgres;

--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 229
-- Name: PromosyonKodu_promosyonKoduID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PromosyonKodu_promosyonKoduID_seq" OWNED BY public."PromosyonKodu"."promosyonKoduID";


--
-- TOC entry 263 (class 1259 OID 16850)
-- Name: Rezervasyon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Rezervasyon" (
    "rezervasyonID" integer NOT NULL,
    "musteriID" integer NOT NULL,
    "aracID" integer,
    "kategoriID" integer NOT NULL,
    "teslimLokasyonID" integer NOT NULL,
    "iadeLokasyonID" integer NOT NULL,
    "rezervasyonTarihi" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "baslangicTarihi" timestamp without time zone NOT NULL,
    "bitisTarihi" timestamp without time zone NOT NULL,
    "tahminiTutar" numeric(10,2),
    durum character varying(20) DEFAULT 'Beklemede'::character varying,
    "iptalTarihi" timestamp without time zone,
    "iptalNedeni" text,
    notlar text,
    CONSTRAINT "Rezervasyon_durum_check" CHECK (((durum)::text = ANY ((ARRAY['Beklemede'::character varying, 'Onaylandi'::character varying, 'Iptal'::character varying, 'Tamamlandi'::character varying])::text[])))
);


ALTER TABLE public."Rezervasyon" OWNER TO postgres;

--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE "Rezervasyon"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Rezervasyon" IS 'Gelecek tarihli araç rezervasyonları';


--
-- TOC entry 262 (class 1259 OID 16849)
-- Name: Rezervasyon_rezervasyonID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Rezervasyon_rezervasyonID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Rezervasyon_rezervasyonID_seq" OWNER TO postgres;

--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 262
-- Name: Rezervasyon_rezervasyonID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Rezervasyon_rezervasyonID_seq" OWNED BY public."Rezervasyon"."rezervasyonID";


--
-- TOC entry 222 (class 1259 OID 16404)
-- Name: Sehir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sehir" (
    "sehirID" integer NOT NULL,
    "ulkeID" integer NOT NULL,
    "sehirAdi" character varying(100) NOT NULL,
    "plakaKodu" character varying(3)
);


ALTER TABLE public."Sehir" OWNER TO postgres;

--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE "Sehir"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Sehir" IS 'Şehir bilgileri';


--
-- TOC entry 221 (class 1259 OID 16403)
-- Name: Sehir_sehirID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Sehir_sehirID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Sehir_sehirID_seq" OWNER TO postgres;

--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 221
-- Name: Sehir_sehirID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Sehir_sehirID_seq" OWNED BY public."Sehir"."sehirID";


--
-- TOC entry 252 (class 1259 OID 16695)
-- Name: Sigorta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sigorta" (
    "sigortaID" integer NOT NULL,
    "aracID" integer NOT NULL,
    "sirketAdi" character varying(100) NOT NULL,
    "policeNo" character varying(50) NOT NULL,
    "sigortaTipi" character varying(20),
    "baslangicTarihi" date NOT NULL,
    "bitisTarihi" date NOT NULL,
    "primTutari" numeric(10,2) NOT NULL,
    "aktifMi" boolean DEFAULT true,
    CONSTRAINT "Sigorta_sigortaTipi_check" CHECK ((("sigortaTipi")::text = ANY ((ARRAY['Kasko'::character varying, 'Trafik'::character varying, 'Kasko+Trafik'::character varying])::text[])))
);


ALTER TABLE public."Sigorta" OWNER TO postgres;

--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE "Sigorta"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Sigorta" IS 'Araç sigorta bilgileri';


--
-- TOC entry 251 (class 1259 OID 16694)
-- Name: Sigorta_sigortaID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Sigorta_sigortaID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Sigorta_sigortaID_seq" OWNER TO postgres;

--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 251
-- Name: Sigorta_sigortaID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Sigorta_sigortaID_seq" OWNED BY public."Sigorta"."sigortaID";


--
-- TOC entry 244 (class 1259 OID 16592)
-- Name: Surucu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Surucu" (
    "surucuID" integer NOT NULL,
    "kullaniciID" integer NOT NULL,
    "ehliyetNo" character varying(20) NOT NULL,
    "ehliyetSinifi" character varying(10) NOT NULL,
    "ehliyetTarihi" date NOT NULL,
    src character varying(20),
    "srcTarihi" date,
    "deneyimYil" integer,
    "musaitMi" boolean DEFAULT true,
    "toplamYolculuk" integer DEFAULT 0,
    "ortalamaPuan" numeric(3,2) DEFAULT 0,
    "onayDurumu" character varying(20) DEFAULT 'Beklemede'::character varying,
    CONSTRAINT "Surucu_onayDurumu_check" CHECK ((("onayDurumu")::text = ANY ((ARRAY['Beklemede'::character varying, 'Onaylandi'::character varying, 'Reddedildi'::character varying])::text[])))
);


ALTER TABLE public."Surucu" OWNER TO postgres;

--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE "Surucu"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Surucu" IS 'Kalıtım alt sınıfı - Sürücü özellikleri';


--
-- TOC entry 243 (class 1259 OID 16591)
-- Name: Surucu_surucuID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Surucu_surucuID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Surucu_surucuID_seq" OWNER TO postgres;

--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 243
-- Name: Surucu_surucuID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Surucu_surucuID_seq" OWNED BY public."Surucu"."surucuID";


--
-- TOC entry 220 (class 1259 OID 16391)
-- Name: Ulke; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ulke" (
    "ulkeID" integer NOT NULL,
    "ulkeAdi" character varying(100) NOT NULL,
    "ulkeKodu" character varying(3) NOT NULL,
    "telefonKodu" character varying(10) NOT NULL
);


ALTER TABLE public."Ulke" OWNER TO postgres;

--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE "Ulke"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Ulke" IS 'Ülke bilgileri';


--
-- TOC entry 219 (class 1259 OID 16390)
-- Name: Ulke_ulkeID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Ulke_ulkeID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Ulke_ulkeID_seq" OWNER TO postgres;

--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 219
-- Name: Ulke_ulkeID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Ulke_ulkeID_seq" OWNED BY public."Ulke"."ulkeID";


--
-- TOC entry 246 (class 1259 OID 16616)
-- Name: Yonetici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Yonetici" (
    "yoneticiID" integer NOT NULL,
    "kullaniciID" integer NOT NULL,
    departman character varying(50),
    "yetkiSeviyesi" character varying(20),
    "iseBaslamaTarihi" date,
    CONSTRAINT "Yonetici_yetkiSeviyesi_check" CHECK ((("yetkiSeviyesi")::text = ANY ((ARRAY['Dusuk'::character varying, 'Orta'::character varying, 'Yuksek'::character varying, 'Admin'::character varying])::text[])))
);


ALTER TABLE public."Yonetici" OWNER TO postgres;

--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE "Yonetici"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."Yonetici" IS 'Kalıtım alt sınıfı - Yönetici özellikleri';


--
-- TOC entry 245 (class 1259 OID 16615)
-- Name: Yonetici_yoneticiID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Yonetici_yoneticiID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Yonetici_yoneticiID_seq" OWNER TO postgres;

--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 245
-- Name: Yonetici_yoneticiID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Yonetici_yoneticiID_seq" OWNED BY public."Yonetici"."yoneticiID";


--
-- TOC entry 272 (class 1259 OID 17046)
-- Name: fatura_sira_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fatura_sira_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fatura_sira_seq OWNER TO postgres;

--
-- TOC entry 5006 (class 2604 OID 16444)
-- Name: Adres adresID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres" ALTER COLUMN "adresID" SET DEFAULT nextval('public."Adres_adresID_seq"'::regclass);


--
-- TOC entry 5033 (class 2604 OID 16636)
-- Name: Arac aracID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac" ALTER COLUMN "aracID" SET DEFAULT nextval('public."Arac_aracID_seq"'::regclass);


--
-- TOC entry 5050 (class 2604 OID 16821)
-- Name: AracCagirma cagirmaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracCagirma" ALTER COLUMN "cagirmaID" SET DEFAULT nextval('public."AracCagirma_cagirmaID_seq"'::regclass);


--
-- TOC entry 5015 (class 2604 OID 16500)
-- Name: AracKategori kategoriID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKategori" ALTER COLUMN "kategoriID" SET DEFAULT nextval('public."AracKategori_kategoriID_seq"'::regclass);


--
-- TOC entry 5037 (class 2604 OID 16676)
-- Name: AracKonum konumID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKonum" ALTER COLUMN "konumID" SET DEFAULT nextval('public."AracKonum_konumID_seq"'::regclass);


--
-- TOC entry 5042 (class 2604 OID 16721)
-- Name: BakimKayit bakimID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BakimKayit" ALTER COLUMN "bakimID" SET DEFAULT nextval('public."BakimKayit_bakimID_seq"'::regclass);


--
-- TOC entry 5070 (class 2604 OID 17052)
-- Name: Ceza cezaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ceza" ALTER COLUMN "cezaID" SET DEFAULT nextval('public."Ceza_cezaID_seq"'::regclass);


--
-- TOC entry 5056 (class 2604 OID 16897)
-- Name: Degerlendirme degerlendirmeID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme" ALTER COLUMN "degerlendirmeID" SET DEFAULT nextval('public."Degerlendirme_degerlendirmeID_seq"'::regclass);


--
-- TOC entry 5065 (class 2604 OID 17006)
-- Name: DestekTalebi talepID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DestekTalebi" ALTER COLUMN "talepID" SET DEFAULT nextval('public."DestekTalebi_talepID_seq"'::regclass);


--
-- TOC entry 5018 (class 2604 OID 16541)
-- Name: EkHizmet hizmetID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EkHizmet" ALTER COLUMN "hizmetID" SET DEFAULT nextval('public."EkHizmet_hizmetID_seq"'::regclass);


--
-- TOC entry 5062 (class 2604 OID 16980)
-- Name: Fatura faturaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura" ALTER COLUMN "faturaID" SET DEFAULT nextval('public."Fatura_faturaID_seq"'::regclass);


--
-- TOC entry 5043 (class 2604 OID 16739)
-- Name: HasarKayit hasarID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HasarKayit" ALTER COLUMN "hasarID" SET DEFAULT nextval('public."HasarKayit_hasarID_seq"'::regclass);


--
-- TOC entry 5073 (class 2604 OID 17076)
-- Name: IslemLog logID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IslemLog" ALTER COLUMN "logID" SET DEFAULT nextval('public."IslemLog_logID_seq"'::regclass);


--
-- TOC entry 5047 (class 2604 OID 16761)
-- Name: Kiralama kiralamaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama" ALTER COLUMN "kiralamaID" SET DEFAULT nextval('public."Kiralama_kiralamaID_seq"'::regclass);


--
-- TOC entry 5003 (class 2604 OID 16422)
-- Name: Kullanici kullaniciID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici" ALTER COLUMN "kullaniciID" SET DEFAULT nextval('public."Kullanici_kullaniciID_seq"'::regclass);


--
-- TOC entry 5021 (class 2604 OID 16555)
-- Name: Lokasyon lokasyonID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lokasyon" ALTER COLUMN "lokasyonID" SET DEFAULT nextval('public."Lokasyon_lokasyonID_seq"'::regclass);


--
-- TOC entry 5016 (class 2604 OID 16511)
-- Name: Marka markaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Marka" ALTER COLUMN "markaID" SET DEFAULT nextval('public."Marka_markaID_seq"'::regclass);


--
-- TOC entry 5017 (class 2604 OID 16526)
-- Name: Model modelID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Model" ALTER COLUMN "modelID" SET DEFAULT nextval('public."Model_modelID_seq"'::regclass);


--
-- TOC entry 5023 (class 2604 OID 16575)
-- Name: Musteri musteriID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri" ALTER COLUMN "musteriID" SET DEFAULT nextval('public."Musteri_musteriID_seq"'::regclass);


--
-- TOC entry 5058 (class 2604 OID 16940)
-- Name: Odeme odemeID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme" ALTER COLUMN "odemeID" SET DEFAULT nextval('public."Odeme_odemeID_seq"'::regclass);


--
-- TOC entry 5008 (class 2604 OID 16468)
-- Name: OdemeYontemi yontemID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OdemeYontemi" ALTER COLUMN "yontemID" SET DEFAULT nextval('public."OdemeYontemi_yontemID_seq"'::regclass);


--
-- TOC entry 5011 (class 2604 OID 16479)
-- Name: PromosyonKodu promosyonKoduID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PromosyonKodu" ALTER COLUMN "promosyonKoduID" SET DEFAULT nextval('public."PromosyonKodu_promosyonKoduID_seq"'::regclass);


--
-- TOC entry 5053 (class 2604 OID 16853)
-- Name: Rezervasyon rezervasyonID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon" ALTER COLUMN "rezervasyonID" SET DEFAULT nextval('public."Rezervasyon_rezervasyonID_seq"'::regclass);


--
-- TOC entry 5002 (class 2604 OID 16407)
-- Name: Sehir sehirID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir" ALTER COLUMN "sehirID" SET DEFAULT nextval('public."Sehir_sehirID_seq"'::regclass);


--
-- TOC entry 5040 (class 2604 OID 16698)
-- Name: Sigorta sigortaID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sigorta" ALTER COLUMN "sigortaID" SET DEFAULT nextval('public."Sigorta_sigortaID_seq"'::regclass);


--
-- TOC entry 5027 (class 2604 OID 16595)
-- Name: Surucu surucuID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Surucu" ALTER COLUMN "surucuID" SET DEFAULT nextval('public."Surucu_surucuID_seq"'::regclass);


--
-- TOC entry 5001 (class 2604 OID 16394)
-- Name: Ulke ulkeID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ulke" ALTER COLUMN "ulkeID" SET DEFAULT nextval('public."Ulke_ulkeID_seq"'::regclass);


--
-- TOC entry 5032 (class 2604 OID 16619)
-- Name: Yonetici yoneticiID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici" ALTER COLUMN "yoneticiID" SET DEFAULT nextval('public."Yonetici_yoneticiID_seq"'::regclass);


--
-- TOC entry 5393 (class 0 OID 16441)
-- Dependencies: 226
-- Data for Name: Adres; Type: TABLE DATA; Schema: public; Owner: postgres
--

