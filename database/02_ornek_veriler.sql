COPY public."Adres" ("adresID", "kullaniciID", "sehirID", "adresBasligi", "adresSatiri1", "adresSatiri2", "postaKodu", "varsayilanMi") FROM stdin;
1	1	1	Ev	Beşiktaş Mahallesi	Barbaros Bulvarı No:123 D:5	34353	t
2	2	2	Ev	Çankaya Mahallesi	Atatürk Bulvarı No:456	06420	t
3	3	3	İş	Alsancak Mahallesi	Kıbrıs Şehitleri Caddesi No:789	35220	t
4	4	4	Ev	Lara Mahallesi	Güzelyalı Caddesi No:321	07100	t
5	5	5	Ev	Osmangazi Mahallesi	Cumhuriyet Caddesi No:654	16200	t
\.


--
-- TOC entry 5415 (class 0 OID 16633)
-- Dependencies: 248
-- Data for Name: Arac; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Arac" ("aracID", plaka, "kategoriID", "modelID", "surucuID", yil, renk, "yakitTipi", "vitesTipi", "koltukSayisi", kilometre, "gunlukKiraUcreti", "cagirmaBaslangicUcreti", "cagirmaKmUcreti", durum, "ruhsatSeriNo", "ruhsatTarihi", "kayitTarihi") FROM stdin;
2	34DEF456	1	6	1	2021	Kırmızı	Dizel	Otomatik	5	32000	350.00	55.00	8.50	Musait	RST234567	\N	2025-12-02 15:38:10.355688
3	06GHI789	2	7	2	2019	Siyah	Dizel	Otomatik	5	68000	450.00	60.00	9.00	Musait	RST345678	\N	2025-12-02 15:38:10.355688
4	35JKL012	3	3	2	2022	Gri	Benzin	Otomatik	5	15000	800.00	80.00	12.00	Musait	RST456789	\N	2025-12-02 15:38:10.355688
5	07MNO345	4	4	3	2021	Lacivert	Dizel	Otomatik	7	42000	900.00	85.00	13.00	Musait	RST567890	\N	2025-12-02 15:38:10.355688
6	16PQR678	4	5	3	2020	Beyaz	Dizel	Otomatik	7	55000	950.00	90.00	13.50	Musait	RST678901	\N	2025-12-02 15:38:10.355688
7	34STU901	1	10	4	2023	Mavi	Benzin	Manuel	5	8000	320.00	52.00	8.20	Musait	RST789012	\N	2025-12-02 15:38:10.355688
8	34VWX234	2	11	4	2022	Gümüş	Hibrit	Otomatik	5	25000	600.00	70.00	10.00	Musait	RST890123	\N	2025-12-02 15:38:10.355688
10	35BCD890	3	2	2	2023	Siyah	Dizel	Otomatik	5	12000	850.00	82.00	12.50	Musait	RST012345	\N	2025-12-02 15:38:10.355688
1	34ABC123	1	1	1	2020	Beyaz	Benzin	Manuel	5	45000	300.00	50.00	8.00	Musait	RST123456	\N	2025-12-02 15:38:10.355688
9	06YZA567	1	12	1	2021	Beyaz	Benzin	Manuel	5	38000	310.00	51.00	8.10	Musait	RST901234	\N	2025-12-02 15:38:10.355688
\.


--
-- TOC entry 5428 (class 0 OID 16818)
-- Dependencies: 261
-- Data for Name: AracCagirma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AracCagirma" ("cagirmaID", "musteriID", "surucuID", "aracID", "baslangicLat", "baslangicLng", "bitisLat", "bitisLng", "baslangicAdres", "bitisAdres", "talepTarihi", "kabulTarihi", "baslangicTarihi", "bitisTarihi", mesafe, sure, "baslangicUcret", "kmUcreti", "toplamTutar", durum) FROM stdin;
\.


--
-- TOC entry 5399 (class 0 OID 16497)
-- Dependencies: 232
-- Data for Name: AracKategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AracKategori" ("kategoriID", "kategoriAdi", aciklama, "minKoltukSayisi", "maxKoltukSayisi") FROM stdin;
1	Ekonomi	Yakıt tasarruflu, şehir içi kullanım için ideal	4	5
2	Konfor	Rahat yolculuk, orta segment	5	5
3	Lüks	Premium özellikler, üst segment	4	5
4	SUV	Arazi ve şehir kullanımı, geniş iç hacim	5	7
5	Minivan	Aile ve grup yolculukları için	7	9
\.


--
-- TOC entry 5417 (class 0 OID 16673)
-- Dependencies: 250
-- Data for Name: AracKonum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AracKonum" ("konumID", "aracID", latitude, longitude, hiz, yon, "guncellemeTarihi", adres) FROM stdin;
1	1	41.00820000	28.97840000	0	180	2025-12-02 15:38:10.355688	İstanbul, Beşiktaş
2	2	41.03700000	28.98590000	0	90	2025-12-02 15:38:10.355688	İstanbul, Taksim
3	3	39.93340000	32.85970000	0	270	2025-12-02 15:38:10.355688	Ankara, Çankaya
4	4	38.41920000	27.12870000	0	45	2025-12-02 15:38:10.355688	İzmir, Alsancak
5	5	36.89690000	30.71330000	0	135	2025-12-02 15:38:10.355688	Antalya, Lara
6	6	40.18260000	29.06650000	0	0	2025-12-02 15:38:10.355688	Bursa, Osmangazi
7	7	41.02550000	28.97420000	0	90	2025-12-02 15:38:10.355688	İstanbul, Şişli
8	8	41.01580000	28.96620000	0	180	2025-12-02 15:38:10.355688	İstanbul, Mecidiyeköy
9	9	39.92080000	32.85410000	0	270	2025-12-02 15:38:10.355688	Ankara, Kızılay
10	10	38.42370000	27.14280000	0	45	2025-12-02 15:38:10.355688	İzmir, Konak
\.


--
-- TOC entry 5421 (class 0 OID 16718)
-- Dependencies: 254
-- Data for Name: BakimKayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BakimKayit" ("bakimID", "aracID", "bakimTipi", "bakimTarihi", "sonrakiBakimTarihi", kilometre, tutar, "servisYeri", aciklama, "faturaDosyasi") FROM stdin;
1	1	Periyodik Bakım	2024-06-15	2024-12-15	45000	1500.00	Volkswagen Yetkili Servis	Yağ değişimi, filtre değişimi	\N
2	2	Lastik Değişimi	2024-05-20	\N	32000	3200.00	Lastik Dünyası	4 adet yaz lastiği	\N
3	3	Periyodik Bakım	2024-07-10	2025-01-10	68000	2100.00	Renault Yetkili Servis	Komple bakım	\N
4	4	Fren Sistemi	2024-08-05	\N	15000	2500.00	Mercedes Yetkili Servis	Fren balatası değişimi	\N
5	5	Periyodik Bakım	2024-06-25	2024-12-25	42000	3500.00	Mercedes Yetkili Servis	Büyük bakım	\N
\.


--
-- TOC entry 5441 (class 0 OID 17049)
-- Dependencies: 274
-- Data for Name: Ceza; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Ceza" ("cezaID", "kiralamaID", "cezaTipi", "gecGunSayisi", "gunlukCezaTutari", "toplamCezaTutari", aciklama, "olusturmaTarihi", "odendiMi") FROM stdin;
\.


--
-- TOC entry 5432 (class 0 OID 16894)
-- Dependencies: 265
-- Data for Name: Degerlendirme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Degerlendirme" ("degerlendirmeID", "cagirmaID", "musteriID", "surucuID", puan, yorum, "degerlendirmeTarihi", "surucuYanit", "yanitTarihi") FROM stdin;
\.


--
-- TOC entry 5438 (class 0 OID 17003)
-- Dependencies: 271
-- Data for Name: DestekTalebi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DestekTalebi" ("talepID", "kullaniciID", "yoneticiID", konu, mesaj, oncelik, durum, "olusturmaTarihi", "guncellemeTarihi", "kapatmaTarihi") FROM stdin;
\.


--
-- TOC entry 5405 (class 0 OID 16538)
-- Dependencies: 238
-- Data for Name: EkHizmet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EkHizmet" ("hizmetID", "hizmetAdi", aciklama, "gunlukUcret", "stokAdedi", "aktifMi") FROM stdin;
1	GPS Navigasyon	Araç içi GPS cihazı	50.00	20	t
2	Bebek Koltuğu	0-4 yaş bebek koltuğu	75.00	15	t
3	Çocuk Koltuğu	4-12 yaş çocuk koltuğu	60.00	12	t
4	Ek Sürücü	İkinci sürücü ekleme	100.00	999	t
5	Tam Kasko	Ek sigorta paketi	150.00	999	t
6	WiFi Hotspot	Araç içi internet	80.00	10	t
\.


--
-- TOC entry 5436 (class 0 OID 16977)
-- Dependencies: 269
-- Data for Name: Fatura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Fatura" ("faturaID", "odemeID", "faturaNo", "faturaTarihi", "firmaAdi", "vergiNo", "vergiDairesi", adres, "kdvOrani", "kdvTutari", "araToplam", "genelToplam", "faturaTipi", "pdfDosyasi") FROM stdin;
\.


--
-- TOC entry 5423 (class 0 OID 16736)
-- Dependencies: 256
-- Data for Name: HasarKayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."HasarKayit" ("hasarID", "aracID", "kiralamaID", "cagirmaID", "hasarTarihi", "hasarTipi", "hasarAciklamasi", "sorumluKisi", "tamirTutari", "sigortaKapsamindaMi", durumu, fotograflar) FROM stdin;
\.


--
-- TOC entry 5443 (class 0 OID 17073)
-- Dependencies: 276
-- Data for Name: IslemLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."IslemLog" ("logID", "tabloAdi", "islemTipi", "kayitID", "eskiVeri", "yeniVeri", "kullaniciID", "islemZamani") FROM stdin;
\.


--
-- TOC entry 5425 (class 0 OID 16758)
-- Dependencies: 258
-- Data for Name: Kiralama; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kiralama" ("kiralamaID", "musteriID", "aracID", "teslimLokasyonID", "iadeLokasyonID", "baslangicTarihi", "bitisTarihi", "teslimTarihi", "iadeTarihi", "gunlukUcret", "toplamTutar", durum, "teslimKM", "iadeKM", notlar) FROM stdin;
1	6	1	2	2	2025-12-08 10:00:00	2025-12-09 10:00:00	\N	\N	300.00	300.00	Iptal	\N	\N	\N
2	6	9	4	4	2025-12-08 10:00:00	2025-12-09 10:00:00	\N	\N	310.00	310.00	Iptal	\N	\N	\N
\.


--
-- TOC entry 5426 (class 0 OID 16797)
-- Dependencies: 259
-- Data for Name: KiralamaEkHizmet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."KiralamaEkHizmet" ("kiralamaID", "hizmetID", adet, "gunlukUcret", "toplamTutar") FROM stdin;
\.


--
-- TOC entry 5391 (class 0 OID 16419)
-- Dependencies: 224
-- Data for Name: Kullanici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kullanici" ("kullaniciID", "tcNo", ad, soyad, telefon, email, sifre, "dogumTarihi", cinsiyet, "profilFoto", "kayitTarihi", "sonGirisTarihi", "aktifMi") FROM stdin;
1	12345678901	Ahmet	Yılmaz	05551234567	ahmet.yilmaz@email.com	hashed_password_1	1990-05-15	Erkek	\N	2025-12-02 15:38:10.355688	\N	t
2	12345678902	Ayşe	Demir	05551234568	ayse.demir@email.com	hashed_password_2	1992-08-20	Kadın	\N	2025-12-02 15:38:10.355688	\N	t
3	12345678903	Mehmet	Kaya	05551234569	mehmet.kaya@email.com	hashed_password_3	1988-03-10	Erkek	\N	2025-12-02 15:38:10.355688	\N	t
4	12345678904	Fatma	Çelik	05551234570	fatma.celik@email.com	hashed_password_4	1995-11-25	Kadın	\N	2025-12-02 15:38:10.355688	\N	t
5	12345678905	Ali	Öztürk	05551234571	ali.ozturk@email.com	hashed_password_5	1987-07-30	Erkek	\N	2025-12-02 15:38:10.355688	\N	t
6	12345678906	Zeynep	Şahin	05551234572	zeynep.sahin@email.com	hashed_password_6	1993-01-12	Kadın	\N	2025-12-02 15:38:10.355688	\N	t
7	12345678907	Mustafa	Aydın	05551234573	mustafa.aydin@email.com	hashed_password_7	1985-09-18	Erkek	\N	2025-12-02 15:38:10.355688	\N	t
8	12345678908	Emine	Kurt	05551234574	emine.kurt@email.com	hashed_password_8	1991-04-22	Kadın	\N	2025-12-02 15:38:10.355688	\N	t
9	12345678909	Hüseyin	Arslan	05551234575	huseyin.arslan@email.com	hashed_password_9	1989-12-05	Erkek	\N	2025-12-02 15:38:10.355688	\N	t
10	12345678910	Elif	Polat	05551234576	elif.polat@email.com	hashed_password_10	1994-06-14	Kadın	\N	2025-12-02 15:38:10.355688	\N	t
11	98765432101	Test	User	05559876543	test@test.com	$2b$10$rX8J6QOKlQP.qqh6TzKZEOxKqYHJ4vJNqKYHJ4vJNqKYHJ4vJNqKY	1995-05-15	Erkek	\N	2025-12-07 20:00:19.269786	\N	t
12	22222222222	Yeni	Kullanıcı	05552223344	yeni@test.com	$2b$10$SKrUMEHd9EAr90tykTnJzOLhx7hIFTfqPECsq2OIgo6ZuVEb6eZjO	1990-01-01	Erkek	\N	2025-12-07 20:51:14.977781	2025-12-08 19:59:47.424414	t
\.


--
-- TOC entry 5407 (class 0 OID 16552)
-- Dependencies: 240
-- Data for Name: Lokasyon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Lokasyon" ("lokasyonID", "lokasyonAdi", "sehirID", adres, latitude, longitude, telefon, email, "calismaSaatleri", tip, "aktifMi") FROM stdin;
1	İstanbul Havalimanı Şubesi	1	İstanbul Havalimanı Terminal 1	41.27530000	28.75190000	02121234567	istanbul@arackiralama.com	7/24	Havalimani	t
2	Ankara Esenboğa Şubesi	2	Esenboğa Havalimanı	40.12810000	32.99510000	03121234567	ankara@arackiralama.com	7/24	Havalimani	t
3	İzmir Adnan Menderes Şubesi	3	Adnan Menderes Havalimanı	38.29240000	27.15700000	02321234567	izmir@arackiralama.com	7/24	Havalimani	t
4	Antalya Havalimanı Şubesi	4	Antalya Havalimanı	36.89870000	30.80050000	02421234567	antalya@arackiralama.com	7/24	Havalimani	t
5	İstanbul Taksim Şubesi	1	Taksim Meydanı No:45	41.03700000	28.98590000	02121234568	taksim@arackiralama.com	08:00-22:00	Sube	t
\.


--
-- TOC entry 5401 (class 0 OID 16508)
-- Dependencies: 234
-- Data for Name: Marka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Marka" ("markaID", "markaAdi", "ulkeID") FROM stdin;
1	Volkswagen	2
2	Mercedes-Benz	2
3	BMW	2
4	Renault	3
5	Peugeot	3
6	Fiat	4
7	Ford	5
8	Toyota	6
9	Hyundai	7
\.


--
-- TOC entry 5403 (class 0 OID 16523)
-- Dependencies: 236
-- Data for Name: Model; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Model" ("modelID", "markaID", "modelAdi", "kasaTipi") FROM stdin;
1	1	Golf	Hatchback
2	1	Passat	Sedan
3	2	C-Class	Sedan
4	2	GLE	SUV
5	3	X5	SUV
6	4	Clio	Hatchback
7	4	Megane	Sedan
8	5	3008	SUV
9	6	Egea	Sedan
10	7	Focus	Hatchback
11	8	Corolla	Sedan
12	9	i20	Hatchback
\.


--
-- TOC entry 5409 (class 0 OID 16572)
-- Dependencies: 242
-- Data for Name: Musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Musteri" ("musteriID", "kullaniciID", "ehliyetNo", "ehliyetTarihi", "musteriTipi", "toplamYolculuk", "toplamHarcama", "uyeOlmaTarihi") FROM stdin;
1	1	B123456789	2010-05-20	Bireysel	0	0.00	2025-12-02
2	2	B987654321	2012-08-15	Bireysel	0	0.00	2025-12-02
3	3	B456789123	2008-03-25	Kurumsal	0	0.00	2025-12-02
4	4	B789123456	2015-11-10	Bireysel	0	0.00	2025-12-02
5	11	\N	\N	Bireysel	0	0.00	2025-12-07
6	12	\N	\N	Bireysel	0	0.00	2025-12-07
\.


--
-- TOC entry 5434 (class 0 OID 16937)
-- Dependencies: 267
-- Data for Name: Odeme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Odeme" ("odemeID", "kiralamaID", "cagirmaID", "yontemID", "promosyonKoduID", tutar, indirim, "netTutar", "odemeTarihi", durum, "islemNo", aciklama) FROM stdin;
\.


--
-- TOC entry 5395 (class 0 OID 16465)
-- Dependencies: 228
-- Data for Name: OdemeYontemi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OdemeYontemi" ("yontemID", "yontemAdi", "komisyonOrani", "aktifMi") FROM stdin;
1	Kredi Kartı	2.50	t
2	Nakit	0.00	t
3	Dijital Cüzdan	1.50	t
4	Banka Transferi	0.50	t
\.


--
-- TOC entry 5397 (class 0 OID 16476)
-- Dependencies: 230
-- Data for Name: PromosyonKodu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PromosyonKodu" ("promosyonKoduID", kod, aciklama, "indirimTipi", "indirimMiktari", "minTutar", "maxIndirim", "baslangicTarihi", "bitisTarihi", "kullanimSayisi", "maxKullanimSayisi", "aktifMi") FROM stdin;
1	ILKKIRALAMA	İlk kiralama için %20 indirim	Yuzde	20.00	200.00	100.00	2024-01-01	2025-12-31	0	1000	t
2	YAZ2024	Yaz kampanyası %15 indirim	Yuzde	15.00	300.00	150.00	2024-06-01	2024-09-30	0	500	t
3	INDIRIM50	50 TL indirim	Tutar	50.00	250.00	50.00	2024-01-01	2025-12-31	0	2000	t
\.


--
-- TOC entry 5430 (class 0 OID 16850)
-- Dependencies: 263
-- Data for Name: Rezervasyon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Rezervasyon" ("rezervasyonID", "musteriID", "aracID", "kategoriID", "teslimLokasyonID", "iadeLokasyonID", "rezervasyonTarihi", "baslangicTarihi", "bitisTarihi", "tahminiTutar", durum, "iptalTarihi", "iptalNedeni", notlar) FROM stdin;
\.


--
-- TOC entry 5389 (class 0 OID 16404)
-- Dependencies: 222
-- Data for Name: Sehir; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Sehir" ("sehirID", "ulkeID", "sehirAdi", "plakaKodu") FROM stdin;
1	1	İstanbul	34
2	1	Ankara	06
3	1	İzmir	35
4	1	Antalya	07
5	1	Bursa	16
6	2	Berlin	\N
7	3	Paris	\N
8	5	New York	\N
\.


--
-- TOC entry 5419 (class 0 OID 16695)
-- Dependencies: 252
-- Data for Name: Sigorta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Sigorta" ("sigortaID", "aracID", "sirketAdi", "policeNo", "sigortaTipi", "baslangicTarihi", "bitisTarihi", "primTutari", "aktifMi") FROM stdin;
1	1	Anadolu Sigorta	POL2024001	Kasko+Trafik	2024-01-01	2025-01-01	3500.00	t
2	2	Allianz Sigorta	POL2024002	Kasko+Trafik	2024-02-15	2025-02-15	4200.00	t
3	3	Axa Sigorta	POL2024003	Kasko+Trafik	2024-01-20	2025-01-20	4500.00	t
4	4	Sompo Sigorta	POL2024004	Kasko+Trafik	2024-03-10	2025-03-10	7500.00	t
5	5	HDI Sigorta	POL2024005	Kasko+Trafik	2024-02-01	2025-02-01	8200.00	t
\.


--
-- TOC entry 5411 (class 0 OID 16592)
-- Dependencies: 244
-- Data for Name: Surucu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Surucu" ("surucuID", "kullaniciID", "ehliyetNo", "ehliyetSinifi", "ehliyetTarihi", src, "srcTarihi", "deneyimYil", "musaitMi", "toplamYolculuk", "ortalamaPuan", "onayDurumu") FROM stdin;
1	5	B111222333	B	2005-07-10	SRC12345	2018-03-15	18	t	0	0.00	Onaylandi
2	6	B444555666	B	2010-01-20	SRC67890	2019-06-20	13	t	0	0.00	Onaylandi
3	7	B777888999	D	2003-09-05	SRC11111	2017-12-10	20	t	0	0.00	Onaylandi
4	8	B222333444	B	2012-04-18	SRC22222	2020-08-25	11	t	0	0.00	Onaylandi
\.


--
-- TOC entry 5387 (class 0 OID 16391)
-- Dependencies: 220
-- Data for Name: Ulke; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Ulke" ("ulkeID", "ulkeAdi", "ulkeKodu", "telefonKodu") FROM stdin;
1	Türkiye	TR	+90
2	Almanya	DE	+49
3	Fransa	FR	+33
4	İtalya	IT	+39
5	Amerika Birleşik Devletleri	US	+1
6	Japonya	JP	+81
7	Güney Kore	KR	+82
\.


--
-- TOC entry 5413 (class 0 OID 16616)
-- Dependencies: 246
-- Data for Name: Yonetici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Yonetici" ("yoneticiID", "kullaniciID", departman, "yetkiSeviyesi", "iseBaslamaTarihi") FROM stdin;
1	9	Operasyon	Yuksek	2015-01-15
2	10	Müşteri Hizmetleri	Orta	2018-03-20
\.


--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 225
-- Name: Adres_adresID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Adres_adresID_seq"', 5, true);


--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 260
-- Name: AracCagirma_cagirmaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."AracCagirma_cagirmaID_seq"', 1, false);


--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 231
-- Name: AracKategori_kategoriID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."AracKategori_kategoriID_seq"', 5, true);


--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 249
-- Name: AracKonum_konumID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."AracKonum_konumID_seq"', 10, true);


--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 247
-- Name: Arac_aracID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Arac_aracID_seq"', 10, true);


--
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 253
-- Name: BakimKayit_bakimID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."BakimKayit_bakimID_seq"', 5, true);


--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 273
-- Name: Ceza_cezaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Ceza_cezaID_seq"', 1, false);


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 264
-- Name: Degerlendirme_degerlendirmeID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Degerlendirme_degerlendirmeID_seq"', 1, false);


--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 270
-- Name: DestekTalebi_talepID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DestekTalebi_talepID_seq"', 1, false);


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 237
-- Name: EkHizmet_hizmetID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."EkHizmet_hizmetID_seq"', 6, true);


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 268
-- Name: Fatura_faturaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Fatura_faturaID_seq"', 1, false);


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 255
-- Name: HasarKayit_hasarID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."HasarKayit_hasarID_seq"', 1, false);


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 275
-- Name: IslemLog_logID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."IslemLog_logID_seq"', 1, false);


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 257
-- Name: Kiralama_kiralamaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kiralama_kiralamaID_seq"', 2, true);


--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 223
-- Name: Kullanici_kullaniciID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kullanici_kullaniciID_seq"', 12, true);


--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 239
-- Name: Lokasyon_lokasyonID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Lokasyon_lokasyonID_seq"', 5, true);


--
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 233
-- Name: Marka_markaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Marka_markaID_seq"', 9, true);


--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 235
-- Name: Model_modelID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Model_modelID_seq"', 12, true);


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 241
-- Name: Musteri_musteriID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Musteri_musteriID_seq"', 8, true);


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 227
-- Name: OdemeYontemi_yontemID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OdemeYontemi_yontemID_seq"', 4, true);


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 266
-- Name: Odeme_odemeID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Odeme_odemeID_seq"', 1, false);


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 229
-- Name: PromosyonKodu_promosyonKoduID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PromosyonKodu_promosyonKoduID_seq"', 3, true);


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 262
-- Name: Rezervasyon_rezervasyonID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rezervasyon_rezervasyonID_seq"', 1, false);


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 221
-- Name: Sehir_sehirID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Sehir_sehirID_seq"', 8, true);


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 251
-- Name: Sigorta_sigortaID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Sigorta_sigortaID_seq"', 5, true);


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 243
-- Name: Surucu_surucuID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Surucu_surucuID_seq"', 4, true);


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 219
-- Name: Ulke_ulkeID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Ulke_ulkeID_seq"', 7, true);


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 245
-- Name: Yonetici_yoneticiID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Yonetici_yoneticiID_seq"', 2, true);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 272
-- Name: fatura_sira_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fatura_sira_seq', 1, false);


--
-- TOC entry 5110 (class 2606 OID 16453)
-- Name: Adres Adres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres"
    ADD CONSTRAINT "Adres_pkey" PRIMARY KEY ("adresID");


--
-- TOC entry 5165 (class 2606 OID 16833)
-- Name: AracCagirma AracCagirma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracCagirma"
    ADD CONSTRAINT "AracCagirma_pkey" PRIMARY KEY ("cagirmaID");


--
-- TOC entry 5118 (class 2606 OID 16506)
-- Name: AracKategori AracKategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKategori"
    ADD CONSTRAINT "AracKategori_pkey" PRIMARY KEY ("kategoriID");


--
-- TOC entry 5146 (class 2606 OID 16688)
-- Name: AracKonum AracKonum_aracID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKonum"
    ADD CONSTRAINT "AracKonum_aracID_key" UNIQUE ("aracID");


--
-- TOC entry 5148 (class 2606 OID 16686)
-- Name: AracKonum AracKonum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKonum"
    ADD CONSTRAINT "AracKonum_pkey" PRIMARY KEY ("konumID");


--
-- TOC entry 5140 (class 2606 OID 16654)
-- Name: Arac Arac_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac"
    ADD CONSTRAINT "Arac_pkey" PRIMARY KEY ("aracID");


--
-- TOC entry 5142 (class 2606 OID 16656)
-- Name: Arac Arac_plaka_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac"
    ADD CONSTRAINT "Arac_plaka_key" UNIQUE (plaka);


--
-- TOC entry 5154 (class 2606 OID 16729)
-- Name: BakimKayit BakimKayit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BakimKayit"
    ADD CONSTRAINT "BakimKayit_pkey" PRIMARY KEY ("bakimID");


--
-- TOC entry 5189 (class 2606 OID 17062)
-- Name: Ceza Ceza_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ceza"
    ADD CONSTRAINT "Ceza_pkey" PRIMARY KEY ("cezaID");


--
-- TOC entry 5172 (class 2606 OID 16910)
-- Name: Degerlendirme Degerlendirme_cagirmaID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme"
    ADD CONSTRAINT "Degerlendirme_cagirmaID_key" UNIQUE ("cagirmaID");


--
-- TOC entry 5174 (class 2606 OID 16908)
-- Name: Degerlendirme Degerlendirme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme"
    ADD CONSTRAINT "Degerlendirme_pkey" PRIMARY KEY ("degerlendirmeID");


--
-- TOC entry 5187 (class 2606 OID 17020)
-- Name: DestekTalebi DestekTalebi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DestekTalebi"
    ADD CONSTRAINT "DestekTalebi_pkey" PRIMARY KEY ("talepID");


--
-- TOC entry 5124 (class 2606 OID 16550)
-- Name: EkHizmet EkHizmet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EkHizmet"
    ADD CONSTRAINT "EkHizmet_pkey" PRIMARY KEY ("hizmetID");


--
-- TOC entry 5181 (class 2606 OID 16996)
-- Name: Fatura Fatura_faturaNo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT "Fatura_faturaNo_key" UNIQUE ("faturaNo");


--
-- TOC entry 5183 (class 2606 OID 16994)
-- Name: Fatura Fatura_odemeID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT "Fatura_odemeID_key" UNIQUE ("odemeID");


--
-- TOC entry 5185 (class 2606 OID 16992)
-- Name: Fatura Fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT "Fatura_pkey" PRIMARY KEY ("faturaID");


--
-- TOC entry 5156 (class 2606 OID 16751)
-- Name: HasarKayit HasarKayit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HasarKayit"
    ADD CONSTRAINT "HasarKayit_pkey" PRIMARY KEY ("hasarID");


--
-- TOC entry 5191 (class 2606 OID 17084)
-- Name: IslemLog IslemLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IslemLog"
    ADD CONSTRAINT "IslemLog_pkey" PRIMARY KEY ("logID");


--
-- TOC entry 5163 (class 2606 OID 16806)
-- Name: KiralamaEkHizmet KiralamaEkHizmet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KiralamaEkHizmet"
    ADD CONSTRAINT "KiralamaEkHizmet_pkey" PRIMARY KEY ("kiralamaID", "hizmetID");


--
-- TOC entry 5158 (class 2606 OID 16776)
-- Name: Kiralama Kiralama_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama"
    ADD CONSTRAINT "Kiralama_pkey" PRIMARY KEY ("kiralamaID");


--
-- TOC entry 5102 (class 2606 OID 16439)
-- Name: Kullanici Kullanici_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici"
    ADD CONSTRAINT "Kullanici_email_key" UNIQUE (email);


--
-- TOC entry 5104 (class 2606 OID 16435)
-- Name: Kullanici Kullanici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici"
    ADD CONSTRAINT "Kullanici_pkey" PRIMARY KEY ("kullaniciID");


--
-- TOC entry 5106 (class 2606 OID 16437)
-- Name: Kullanici Kullanici_tcNo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici"
    ADD CONSTRAINT "Kullanici_tcNo_key" UNIQUE ("tcNo");


--
-- TOC entry 5126 (class 2606 OID 16565)
-- Name: Lokasyon Lokasyon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lokasyon"
    ADD CONSTRAINT "Lokasyon_pkey" PRIMARY KEY ("lokasyonID");


--
-- TOC entry 5120 (class 2606 OID 16516)
-- Name: Marka Marka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Marka"
    ADD CONSTRAINT "Marka_pkey" PRIMARY KEY ("markaID");


--
-- TOC entry 5122 (class 2606 OID 16531)
-- Name: Model Model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Model"
    ADD CONSTRAINT "Model_pkey" PRIMARY KEY ("modelID");


--
-- TOC entry 5128 (class 2606 OID 16585)
-- Name: Musteri Musteri_kullaniciID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri"
    ADD CONSTRAINT "Musteri_kullaniciID_key" UNIQUE ("kullaniciID");


--
-- TOC entry 5130 (class 2606 OID 16583)
-- Name: Musteri Musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri"
    ADD CONSTRAINT "Musteri_pkey" PRIMARY KEY ("musteriID");


--
-- TOC entry 5112 (class 2606 OID 16474)
-- Name: OdemeYontemi OdemeYontemi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OdemeYontemi"
    ADD CONSTRAINT "OdemeYontemi_pkey" PRIMARY KEY ("yontemID");


--
-- TOC entry 5176 (class 2606 OID 16955)
-- Name: Odeme Odeme_islemNo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT "Odeme_islemNo_key" UNIQUE ("islemNo");


--
-- TOC entry 5178 (class 2606 OID 16953)
-- Name: Odeme Odeme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT "Odeme_pkey" PRIMARY KEY ("odemeID");


--
-- TOC entry 5114 (class 2606 OID 16495)
-- Name: PromosyonKodu PromosyonKodu_kod_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PromosyonKodu"
    ADD CONSTRAINT "PromosyonKodu_kod_key" UNIQUE (kod);


--
-- TOC entry 5116 (class 2606 OID 16493)
-- Name: PromosyonKodu PromosyonKodu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PromosyonKodu"
    ADD CONSTRAINT "PromosyonKodu_pkey" PRIMARY KEY ("promosyonKoduID");


--
-- TOC entry 5170 (class 2606 OID 16867)
-- Name: Rezervasyon Rezervasyon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "Rezervasyon_pkey" PRIMARY KEY ("rezervasyonID");


--
-- TOC entry 5100 (class 2606 OID 16412)
-- Name: Sehir Sehir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir"
    ADD CONSTRAINT "Sehir_pkey" PRIMARY KEY ("sehirID");


--
-- TOC entry 5150 (class 2606 OID 16711)
-- Name: Sigorta Sigorta_aracID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sigorta"
    ADD CONSTRAINT "Sigorta_aracID_key" UNIQUE ("aracID");


--
-- TOC entry 5152 (class 2606 OID 16709)
-- Name: Sigorta Sigorta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sigorta"
    ADD CONSTRAINT "Sigorta_pkey" PRIMARY KEY ("sigortaID");


--
-- TOC entry 5132 (class 2606 OID 16609)
-- Name: Surucu Surucu_kullaniciID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Surucu"
    ADD CONSTRAINT "Surucu_kullaniciID_key" UNIQUE ("kullaniciID");


--
-- TOC entry 5134 (class 2606 OID 16607)
-- Name: Surucu Surucu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Surucu"
    ADD CONSTRAINT "Surucu_pkey" PRIMARY KEY ("surucuID");


--
-- TOC entry 5096 (class 2606 OID 16400)
-- Name: Ulke Ulke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ulke"
    ADD CONSTRAINT "Ulke_pkey" PRIMARY KEY ("ulkeID");


--
-- TOC entry 5098 (class 2606 OID 16402)
-- Name: Ulke Ulke_ulkeKodu_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ulke"
    ADD CONSTRAINT "Ulke_ulkeKodu_key" UNIQUE ("ulkeKodu");


--
-- TOC entry 5136 (class 2606 OID 16626)
-- Name: Yonetici Yonetici_kullaniciID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici"
    ADD CONSTRAINT "Yonetici_kullaniciID_key" UNIQUE ("kullaniciID");


--
-- TOC entry 5138 (class 2606 OID 16624)
-- Name: Yonetici Yonetici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici"
    ADD CONSTRAINT "Yonetici_pkey" PRIMARY KEY ("yoneticiID");


--
-- TOC entry 5143 (class 1259 OID 17034)
-- Name: idx_arac_durum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_arac_durum ON public."Arac" USING btree (durum);


--
-- TOC entry 5144 (class 1259 OID 17033)
-- Name: idx_arac_plaka; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_arac_plaka ON public."Arac" USING btree (plaka);


--
-- TOC entry 5166 (class 1259 OID 17040)
-- Name: idx_cagirma_durum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cagirma_durum ON public."AracCagirma" USING btree (durum);


--
-- TOC entry 5167 (class 1259 OID 17038)
-- Name: idx_cagirma_musteri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cagirma_musteri ON public."AracCagirma" USING btree ("musteriID");


--
-- TOC entry 5168 (class 1259 OID 17039)
-- Name: idx_cagirma_surucu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cagirma_surucu ON public."AracCagirma" USING btree ("surucuID");


--
-- TOC entry 5159 (class 1259 OID 17036)
-- Name: idx_kiralama_arac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kiralama_arac ON public."Kiralama" USING btree ("aracID");


--
-- TOC entry 5160 (class 1259 OID 17037)
-- Name: idx_kiralama_durum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kiralama_durum ON public."Kiralama" USING btree (durum);


--
-- TOC entry 5161 (class 1259 OID 17035)
-- Name: idx_kiralama_musteri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kiralama_musteri ON public."Kiralama" USING btree ("musteriID");


--
-- TOC entry 5107 (class 1259 OID 17031)
-- Name: idx_kullanici_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kullanici_email ON public."Kullanici" USING btree (email);


--
-- TOC entry 5108 (class 1259 OID 17032)
-- Name: idx_kullanici_tcno; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kullanici_tcno ON public."Kullanici" USING btree ("tcNo");


--
-- TOC entry 5179 (class 1259 OID 17041)
-- Name: idx_odeme_durum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_odeme_durum ON public."Odeme" USING btree (durum);


--
-- TOC entry 5235 (class 2620 OID 17044)
-- Name: Kiralama trigger_arac_durum_guncelle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_arac_durum_guncelle AFTER UPDATE OF durum ON public."Kiralama" FOR EACH ROW WHEN (((old.durum)::text IS DISTINCT FROM (new.durum)::text)) EXECUTE FUNCTION public.trg_arac_durum_guncelle();


--
-- TOC entry 5236 (class 2620 OID 17069)
-- Name: Kiralama trigger_gec_teslim_ceza; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_gec_teslim_ceza AFTER UPDATE OF "iadeTarihi" ON public."Kiralama" FOR EACH ROW WHEN (((new."iadeTarihi" IS NOT NULL) AND (old."iadeTarihi" IS NULL))) EXECUTE FUNCTION public.trg_gec_teslim_ceza_hesapla();


--
-- TOC entry 5238 (class 2620 OID 17047)
-- Name: Odeme trigger_otomatik_fatura_olustur; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_otomatik_fatura_olustur AFTER INSERT OR UPDATE OF durum ON public."Odeme" FOR EACH ROW EXECUTE FUNCTION public.trg_otomatik_fatura_olustur();


--
-- TOC entry 5237 (class 2620 OID 17071)
-- Name: Degerlendirme trigger_surucu_puan_guncelle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_surucu_puan_guncelle AFTER INSERT OR UPDATE OF puan ON public."Degerlendirme" FOR EACH ROW EXECUTE FUNCTION public.trg_surucu_puan_guncelle();


--
-- TOC entry 5193 (class 2606 OID 16454)
-- Name: Adres adres_kullanici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres"
    ADD CONSTRAINT adres_kullanici_fk FOREIGN KEY ("kullaniciID") REFERENCES public."Kullanici"("kullaniciID") ON DELETE CASCADE;


--
-- TOC entry 5194 (class 2606 OID 16459)
-- Name: Adres adres_sehir_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres"
    ADD CONSTRAINT adres_sehir_fk FOREIGN KEY ("sehirID") REFERENCES public."Sehir"("sehirID");


--
-- TOC entry 5201 (class 2606 OID 16657)
-- Name: Arac arac_kategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac"
    ADD CONSTRAINT arac_kategori_fk FOREIGN KEY ("kategoriID") REFERENCES public."AracKategori"("kategoriID");


--
-- TOC entry 5202 (class 2606 OID 16662)
-- Name: Arac arac_model_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac"
    ADD CONSTRAINT arac_model_fk FOREIGN KEY ("modelID") REFERENCES public."Model"("modelID");


--
-- TOC entry 5203 (class 2606 OID 16667)
-- Name: Arac arac_surucu_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Arac"
    ADD CONSTRAINT arac_surucu_fk FOREIGN KEY ("surucuID") REFERENCES public."Surucu"("surucuID");


--
-- TOC entry 5204 (class 2606 OID 16689)
-- Name: AracKonum arackonum_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracKonum"
    ADD CONSTRAINT arackonum_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID") ON DELETE CASCADE;


--
-- TOC entry 5206 (class 2606 OID 16730)
-- Name: BakimKayit bakim_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BakimKayit"
    ADD CONSTRAINT bakim_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID") ON DELETE CASCADE;


--
-- TOC entry 5216 (class 2606 OID 16844)
-- Name: AracCagirma cagirma_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracCagirma"
    ADD CONSTRAINT cagirma_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID");


--
-- TOC entry 5217 (class 2606 OID 16834)
-- Name: AracCagirma cagirma_musteri_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracCagirma"
    ADD CONSTRAINT cagirma_musteri_fk FOREIGN KEY ("musteriID") REFERENCES public."Musteri"("musteriID");


--
-- TOC entry 5218 (class 2606 OID 16839)
-- Name: AracCagirma cagirma_surucu_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AracCagirma"
    ADD CONSTRAINT cagirma_surucu_fk FOREIGN KEY ("surucuID") REFERENCES public."Surucu"("surucuID");


--
-- TOC entry 5234 (class 2606 OID 17063)
-- Name: Ceza ceza_kiralama_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ceza"
    ADD CONSTRAINT ceza_kiralama_fk FOREIGN KEY ("kiralamaID") REFERENCES public."Kiralama"("kiralamaID");


--
-- TOC entry 5224 (class 2606 OID 16911)
-- Name: Degerlendirme degerlendirme_cagirma_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme"
    ADD CONSTRAINT degerlendirme_cagirma_fk FOREIGN KEY ("cagirmaID") REFERENCES public."AracCagirma"("cagirmaID") ON DELETE CASCADE;


--
-- TOC entry 5225 (class 2606 OID 16916)
-- Name: Degerlendirme degerlendirme_musteri_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme"
    ADD CONSTRAINT degerlendirme_musteri_fk FOREIGN KEY ("musteriID") REFERENCES public."Musteri"("musteriID");


--
-- TOC entry 5226 (class 2606 OID 16921)
-- Name: Degerlendirme degerlendirme_surucu_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Degerlendirme"
    ADD CONSTRAINT degerlendirme_surucu_fk FOREIGN KEY ("surucuID") REFERENCES public."Surucu"("surucuID");


--
-- TOC entry 5232 (class 2606 OID 17021)
-- Name: DestekTalebi destek_kullanici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DestekTalebi"
    ADD CONSTRAINT destek_kullanici_fk FOREIGN KEY ("kullaniciID") REFERENCES public."Kullanici"("kullaniciID");


--
-- TOC entry 5233 (class 2606 OID 17026)
-- Name: DestekTalebi destek_yonetici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DestekTalebi"
    ADD CONSTRAINT destek_yonetici_fk FOREIGN KEY ("yoneticiID") REFERENCES public."Yonetici"("yoneticiID");


--
-- TOC entry 5231 (class 2606 OID 16997)
-- Name: Fatura fatura_odeme_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT fatura_odeme_fk FOREIGN KEY ("odemeID") REFERENCES public."Odeme"("odemeID") ON DELETE CASCADE;


--
-- TOC entry 5207 (class 2606 OID 16752)
-- Name: HasarKayit hasar_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HasarKayit"
    ADD CONSTRAINT hasar_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID") ON DELETE CASCADE;


--
-- TOC entry 5208 (class 2606 OID 16931)
-- Name: HasarKayit hasar_cagirma_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HasarKayit"
    ADD CONSTRAINT hasar_cagirma_fk FOREIGN KEY ("cagirmaID") REFERENCES public."AracCagirma"("cagirmaID") ON DELETE SET NULL;


--
-- TOC entry 5209 (class 2606 OID 16926)
-- Name: HasarKayit hasar_kiralama_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HasarKayit"
    ADD CONSTRAINT hasar_kiralama_fk FOREIGN KEY ("kiralamaID") REFERENCES public."Kiralama"("kiralamaID") ON DELETE SET NULL;


--
-- TOC entry 5210 (class 2606 OID 16782)
-- Name: Kiralama kiralama_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama"
    ADD CONSTRAINT kiralama_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID");


--
-- TOC entry 5211 (class 2606 OID 16792)
-- Name: Kiralama kiralama_iade_lok_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama"
    ADD CONSTRAINT kiralama_iade_lok_fk FOREIGN KEY ("iadeLokasyonID") REFERENCES public."Lokasyon"("lokasyonID");


--
-- TOC entry 5212 (class 2606 OID 16777)
-- Name: Kiralama kiralama_musteri_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama"
    ADD CONSTRAINT kiralama_musteri_fk FOREIGN KEY ("musteriID") REFERENCES public."Musteri"("musteriID");


--
-- TOC entry 5213 (class 2606 OID 16787)
-- Name: Kiralama kiralama_teslim_lok_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kiralama"
    ADD CONSTRAINT kiralama_teslim_lok_fk FOREIGN KEY ("teslimLokasyonID") REFERENCES public."Lokasyon"("lokasyonID");


--
-- TOC entry 5214 (class 2606 OID 16812)
-- Name: KiralamaEkHizmet kiralamaek_hizmet_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KiralamaEkHizmet"
    ADD CONSTRAINT kiralamaek_hizmet_fk FOREIGN KEY ("hizmetID") REFERENCES public."EkHizmet"("hizmetID");


--
-- TOC entry 5215 (class 2606 OID 16807)
-- Name: KiralamaEkHizmet kiralamaek_kiralama_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KiralamaEkHizmet"
    ADD CONSTRAINT kiralamaek_kiralama_fk FOREIGN KEY ("kiralamaID") REFERENCES public."Kiralama"("kiralamaID") ON DELETE CASCADE;


--
-- TOC entry 5197 (class 2606 OID 16566)
-- Name: Lokasyon lokasyon_sehir_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lokasyon"
    ADD CONSTRAINT lokasyon_sehir_fk FOREIGN KEY ("sehirID") REFERENCES public."Sehir"("sehirID");


--
-- TOC entry 5195 (class 2606 OID 16517)
-- Name: Marka marka_ulke_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Marka"
    ADD CONSTRAINT marka_ulke_fk FOREIGN KEY ("ulkeID") REFERENCES public."Ulke"("ulkeID");


--
-- TOC entry 5196 (class 2606 OID 16532)
-- Name: Model model_marka_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Model"
    ADD CONSTRAINT model_marka_fk FOREIGN KEY ("markaID") REFERENCES public."Marka"("markaID") ON DELETE CASCADE;


--
-- TOC entry 5198 (class 2606 OID 16586)
-- Name: Musteri musteri_kullanici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri"
    ADD CONSTRAINT musteri_kullanici_fk FOREIGN KEY ("kullaniciID") REFERENCES public."Kullanici"("kullaniciID") ON DELETE CASCADE;


--
-- TOC entry 5227 (class 2606 OID 16961)
-- Name: Odeme odeme_cagirma_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT odeme_cagirma_fk FOREIGN KEY ("cagirmaID") REFERENCES public."AracCagirma"("cagirmaID");


--
-- TOC entry 5228 (class 2606 OID 16956)
-- Name: Odeme odeme_kiralama_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT odeme_kiralama_fk FOREIGN KEY ("kiralamaID") REFERENCES public."Kiralama"("kiralamaID");


--
-- TOC entry 5229 (class 2606 OID 16971)
-- Name: Odeme odeme_promosyon_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT odeme_promosyon_fk FOREIGN KEY ("promosyonKoduID") REFERENCES public."PromosyonKodu"("promosyonKoduID");


--
-- TOC entry 5230 (class 2606 OID 16966)
-- Name: Odeme odeme_yontem_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT odeme_yontem_fk FOREIGN KEY ("yontemID") REFERENCES public."OdemeYontemi"("yontemID");


--
-- TOC entry 5219 (class 2606 OID 16873)
-- Name: Rezervasyon rezervasyon_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT rezervasyon_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID");


--
-- TOC entry 5220 (class 2606 OID 16888)
-- Name: Rezervasyon rezervasyon_iade_lok_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT rezervasyon_iade_lok_fk FOREIGN KEY ("iadeLokasyonID") REFERENCES public."Lokasyon"("lokasyonID");


--
-- TOC entry 5221 (class 2606 OID 16878)
-- Name: Rezervasyon rezervasyon_kategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT rezervasyon_kategori_fk FOREIGN KEY ("kategoriID") REFERENCES public."AracKategori"("kategoriID");


--
-- TOC entry 5222 (class 2606 OID 16868)
-- Name: Rezervasyon rezervasyon_musteri_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT rezervasyon_musteri_fk FOREIGN KEY ("musteriID") REFERENCES public."Musteri"("musteriID");


--
-- TOC entry 5223 (class 2606 OID 16883)
-- Name: Rezervasyon rezervasyon_teslim_lok_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT rezervasyon_teslim_lok_fk FOREIGN KEY ("teslimLokasyonID") REFERENCES public."Lokasyon"("lokasyonID");


--
-- TOC entry 5192 (class 2606 OID 16413)
-- Name: Sehir sehir_ulke_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir"
    ADD CONSTRAINT sehir_ulke_fk FOREIGN KEY ("ulkeID") REFERENCES public."Ulke"("ulkeID") ON DELETE CASCADE;


--
-- TOC entry 5205 (class 2606 OID 16712)
-- Name: Sigorta sigorta_arac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sigorta"
    ADD CONSTRAINT sigorta_arac_fk FOREIGN KEY ("aracID") REFERENCES public."Arac"("aracID") ON DELETE CASCADE;


--
-- TOC entry 5199 (class 2606 OID 16610)
-- Name: Surucu surucu_kullanici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Surucu"
    ADD CONSTRAINT surucu_kullanici_fk FOREIGN KEY ("kullaniciID") REFERENCES public."Kullanici"("kullaniciID") ON DELETE CASCADE;


--
-- TOC entry 5200 (class 2606 OID 16627)
-- Name: Yonetici yonetici_kullanici_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici"
    ADD CONSTRAINT yonetici_kullanici_fk FOREIGN KEY ("kullaniciID") REFERENCES public."Kullanici"("kullaniciID") ON DELETE CASCADE;


-- Completed on 2025-12-08 22:47:35

--
-- PostgreSQL database dump complete
--

\unrestrict RBmz1CoPOYieohUYvpXKpVcflOOzfnLOtMxtzO4Fmv3P7jF21s8ePzeIcR12lwD

