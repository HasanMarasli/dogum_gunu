# Canlı öncesi son denetim — 2026-11-21

Denetçi: testci. Kod değiştirilmedi. Sürüm: 1.0.3+3 (commitlenmemiş çalışma ağacı).
Ekran görüntüleri: `/private/tmp/claude-501/-Users-hasanmarasli--claude-spares-spare-Dz5NyH/a5dc6163-d1e2-45bc-b9ee-766d883649ae/scratchpad/qa/` (geçici klasör; kalıcı gerekirse docs/qa/ altına taşınmalı).

## 1. Komut sonuçları

| Komut | Sonuç |
|---|---|
| `flutter analyze` (tam proje) | 22 sorun: 21 info + 1 error. `lib/` içinde yalnızca `deprecated_member_use` info (material.dart / GlobalMaterialLocalizations / GlobalCupertinoLocalizations, yeni SDK uyarısı). Tek error `tasarim/render/render_test.dart:58` (`setKoyuMod` yok) — `tasarim/` klasörü `.git/info/exclude` ile git dışı, uygulamaya derlenmiyor. |
| `flutter build apk --debug` | Başarılı |
| `flutter build ios --simulator --debug` | Başarılı |
| `flutter build appbundle --release` | Başarılı, 54.4 MB |
| `flutter build apk --release` (ek) | Başarılı, 55.1 MB; emülatörde kurulup başlatıldı, çökme yok |

AAB: `/Users/hasanmarasli/Developer/Projeler/flutter/dogum_gunu/build/app/outputs/bundle/release/app-release.aab` (54.400.492 bayt).

İmza (`keytool -printcert -jarfile`): debug imzası DEĞİL.
- Sahip/Yayıncı: CN=Muhammet Hasan Marasli, O=Muhammet Hasan Marasli, C=TR
- Geçerlilik: 2026-10-21 → 2054-03-08
- SHA-256: 91:4A:36:56:29:72:D3:19:C1:95:3A:AE:91:15:3B:2F:D0:73:23:65:78:D5:2F:13:09:94:43:25:73:B7:FD:55
- Release APK'nın apksigner sertifikası aynı SHA-256.

Sürüm (release birleşik manifest; bundletool/aapt2 AAB'yi doğrudan okuyamadı): package `com.muhammet.hasan.marasli.DogumGunu`, versionCode 3, versionName 1.0.3, minSdk 24, targetSdk 36. pubspec `1.0.3+3` ile uyumlu.

## 2. Cihaz/simülatör denetimi

Gerçek cihaz YOK; hepsi simülatör/emülatör.

- iPhone 16 Pro simülatör (iOS, TR): onboarding, bildirim izni, boş ana sayfa, kişi ekle, tarih seçici, ana sayfa (kişili), tavsiye, ayarlar, koyu tema, yatay ayarlar. Çökme/taşma yok.
- iPad Pro 11" simülatör: onboarding, izin reddi sonrası uyarı bandı, boş ana sayfa, yatay ayarlar (3 sütun). Çökme/taşma yok. (Kişili iPad ekranları alınmadı.)
- Android emülatör `qa_dogumgunu` (Pixel 7 profili, API 35, Google Play, ARM64, Pixel Launcher; denetçinin oluşturduğu yeni AVD, işi bitince kapatıldı): debug ve release APK, onboarding, ana sayfa (EN, kişili), yatay ana sayfa. `FATAL`/RenderFlex taşma günlüğü yok. Android tablet boyutu ve Android ayarlar/tavsiye ekran görüntüleri alınmadı (zaman).
- Simülatörde klavye yapıştırması (`text`) çalışmadı; ad alanı tuş tuş girildi ("Al"). Uygulama hatası değil.

### Android ikon değişimi (Pixel Launcher, Android 15 emülatör)
- Ana ekran sabit (hotseat) kısayolu varken veritabanına bugün doğan kişi eklendi; uygulama açılıp arka plana atıldı (onStop → `ikonuGuncelle`).
- Sonuç: kısayol KAYBOLMADI; ikon kutlama (hediye) ikonuna döndü, dokununca uygulama `DogumGunuIkonu` alias'ıyla açıldı. Kişi silinip uygulama yeniden açılıp arka plana atılınca ikon varsayılana geri döndü, kısayol yine yerinde.
- Yalnızca Pixel Launcher denendi. Samsung One UI, Xiaomi MIUI/HyperOS, OnePlus, Huawei gibi üretici launcher'ları denenmedi; bu launcher'ların bir kısmı aktif alias değişince kısayolu silebilir (kullanıcı kararı: etkilenen cihaz azsa kalsın). Bilinen uyarı: `adb shell am start -n .../.MainActivity` alias kapalıyken "Activity class does not exist" verir (yalnızca adb/dış çağıran; launcher etkilenmedi).
- Not: `adb am broadcast` ile `IkonAlici` tetikleme uygulama "stopped" iken etki etmedi (sistem davranışı); gece yarısı alarmı ve BOOT/TIME_SET yolu bu denetimde gözlenmedi.

### Bildirim planı (Android, gerçek zamanlı doğrulama)
İki kişi (21 Kasım 1990, 29 Şubat 2000) ile plugin önbelleği okundu: 16 planlı bildirim, hepsi 09:00, saat dilimi Europe/Istanbul. Bugünkü (09:00 geçmiş) bildirimler atlandı; 2027 ve 2028 için 7/2/1/0 gün öncesi doğru. 29 Şubat'lı kişi 2027'de 28 Şubat, 2028'de 29 Şubat'ta ("27'ye giriyor"/"28'e giriyor") doğru yaş. Kişi silinip uygulama açılınca silinen kişinin 8 bildirimi iptal edildi (açılış planlaması splash sonrası çalışır; ilk deneme çok erken okunduğu için eski veri göründü). Yerel metinler İngilizce doğru.

## 3. Bulgular (önem sırasıyla)

Karar için engelleyici (KRİTİK/YÜKSEK) bulgu yok.

ORTA
1. `analysis_options.yaml` (mobil-gelistirici): `tasarim/` analiz dışı bırakılmadığı için `flutter analyze` 1 error ile çıkar (`tasarim/render/render_test.dart:58`, `setKoyuMod`). Uygulama derlemesini etkilemez; CI/komut çıkış kodu kırmızı olur. Öneri: `analyzer: exclude: [tasarim/**]` veya testin güncellenmesi (tasarimci, dosya git dışı).
2. Üretici launcher'larında ikon değişimi kısayolu silebilir (yukarıda). Sorumlu: native-gelistirici; kullanıcı kabul etti. Mağaza notu / SSS'de belirtilebilir (metin-yazari).

DÜŞÜK
3. `lib/models/bildirim_yoneticisi.dart:~306` (`_bildirimIdUret`): kimlik `base + gun + sira*1000`; farklı kişilerin kimlikleri çarpışırsa `istenen.putIfAbsent` bir bildirimi sessizce düşürür. Olasılık ihmal edilebilir (GUID son 8 hane). Sorumlu: mobil-gelistirici.
4. `bildirim_yoneticisi.dart` `AndroidScheduleMode.inexactAllowWhileIdle`: Doze'da 09:00 bildirimi dakikalar–onlarca dakika kayabilir (bilinçli tercih, exact alarm izni yok). Mağaza metni "tam 09:00" vaadi vermemeli (metin-yazari).
5. iOS 60 bildirim sınırı: çok kişili listede en yakın 60 planlanır, kalanı uygulama açıldıkça (günlük imza) eklenir. Uzun süre açılmayan çok kişili kullanıcıda uzak tarihler gecikebilir. Sorumlu: mobil-gelistirici (bilgi).
6. `lib/sayfalar/ana_sayfa.dart:307` ve `ayarlar.dart:183`: `IntrinsicHeight` liste öğesi başına; satır başına ≤3 kart olduğundan maliyet düşük, yüzlerce kişide ölçülmedi. Sorumlu: tasarimci (izleme).
7. Tablet/iPad ekranlarında içerik dar sütunda ortalanıyor, alt kısım geniş boş (onboarding iPad). Kozmetik. Sorumlu: tasarimci.
8. `tasarim/` klasörü ve `.DS_Store` temizliği: `.DS_Store` git rm yapıldı (staged silme); commit sırasında açıkça eklenmeli.
9. Build uyarıları: Flutter "Built-in Kotlin" ve iOS "Swift Package Manager" eklenti uyarıları (üçüncü taraf eklentiler); şimdilik hata değil.

Kod incelemesi sonuçları (hata yok):
- Çeviri anahtarları: kodda kullanılan 141 sabit anahtar + dinamik aileler (`relation.*`, `theme.*`, `gender.*`, `advice.budget.*`, `notification.body.before(.one)`) tr/en/es üçünde de tanımlı; üç dilde 445'er anahtar, dil başına eksik yok.
- Debug artığı: `lib/`, `android/app/src`, `ios/Runner` içinde `print/debugPrint/TODO/FIXME` yok.
- Bildirim yöneticisi: sıralı kuyruk, imza (dil, günler, tarih, sürüm, saat dilimi, kişi özeti), özet karşılaştırması, silinen/sınır dışı bildirimlerin iptali, hata durumunda imza yazmama mantığı tutarlı; yarış durumu görülmedi.
- Tema modu: Sistem/Açık/Koyu geçişi iOS'ta çalıştı (koyu tema doğrulandı); "Sistem"e dönüş kodla (`setTemaModu`) kayıt siliyor.

## 4. Yayına hazır mı?

Android: EVET (koşullu). İmzalı AAB doğru sertifika ve 1.0.3 (3) ile üretildi, release APK emülatörde çöküşsüz çalıştı, bildirim planı ve ikon değişimi Pixel Launcher'da doğru. Engelleyici bulgu yok. Koşullar: gerçek cihazda bir Android bildirimi (09:00) ve ayarlar/tavsiye/tablet ekranlarının hızlı elle kontrolü; Play Console yüklemesi kullanıcı onayıyla.

iOS: Derleme (simülatör debug) ve iPhone/iPad ekran kontrolleri geçti; imzalı IPA/archive bu denetimde üretilmedi, gerçek cihaz ve TestFlight denemesi yapılmadı. Mağazaya göndermeden önce archive + gerçek cihazda bildirim ve alternatif ikon denemesi gerekir.

## 5. Manuel test senaryoları

Ön koşul: temiz kurulum, her senaryo TR/EN/ES için bir kez; açık ve koyu tema.

Bildirimler
1. Yeni kişi ekle (örn. 5 gün sonra doğum günü): izin ver. Beklenen: 7 gün öncesi atlanır (geçmiş), 2/1/0 gün öncesi 09:00'da planlı. Cihaz saatini 2 gün öncesine alıp 09:00'da bildirim geldiğini doğrula.
2. Kişi düzenle (tarih değiştir): eski tarihe ait bildirim gelmemeli, yenisi planlanmalı.
3. Kişiyi sil: bildirimleri iptal olmalı (Android: Ayarlar > Uygulama > Alarmlar; iOS: bekleyen bildirim yok).
4. Ayarlar'da gün seçeneklerini kapat/aç: sadece seçili günler planlanır.
5. İzin reddi (onboarding "Şimdilik değil" / sistemden kapatma): ana sayfada "Bildirimler kapalı" bandı, "Ayarları aç" sistem ayarlarını açar; izin açılıp uygulamaya dönülünce bant kaybolur ve bildirimler planlanır.
6. Dil değiştir (tr→en→es): bekleyen bildirim metinleri yeni dilde yeniden planlanır.
7. Saat dilimi değiştir (örn. İstanbul → Londra), uygulamayı aç: bildirimler yeni yerel 09:00'a göre yeniden planlanır.
8. Cihazı yeniden başlat: bildirimler korunur (Android BOOT receiver).
9. 61+ bildirim: iOS'ta 15+ kişi ekle; en yakın 60 planlı, uygulama kapatılıp açılınca uygun şekilde sürer. Android'de 100+ kişi: çökme yok.

Uç tarihler
10. 29 Şubat doğumlu: artık olmayan yılda 28 Şubat'ta kutlanır/ "kaç gün kaldı" doğru; artık yılda 29 Şubat. Burç Balık.
11. Bugün doğan: "Bugün" rozeti, bildirim 09:00 geçmişse gelecek yıla; 0 yaş (bu yıl doğan) için "0 yaşında" bildirimi gelmez.
12. Burç sınırları: 20/21 Mart, 19/20 Nisan … her sınır gününü gir; tavsiye ekranındaki aralıkla uyumlu (21 Kasım = Akrep, 22 Kasım = Yay).
13. Çok yaşlı (1900 ve 100+ yaş) ve çok genç (bu yıl doğan) kişi: öneri listesi boş kalmaz, metin taşmaz.

Veritabanı
14. Eski sürümden (1.0.2) güncelle: mevcut kişiler korunur, ana sayfada görünür, bildirimler yeniden planlanır.

Dil ve görünüm
15. Her dilde ana sayfa, kişi ekle, tavsiye, ayarlar: ekranda anahtar adı (ör. `home.xxx`) görünmemeli; uzun isim ve ES metinler taşmamalı.
16. Tema: Sistem/Açık/Koyu; 9 tema rengi; telefon dili ile ilk açılış (tr/es dışı → İngilizce).
17. Yazı boyutu %160 ve küçük ekran (iPhone SE): taşma yok.
18. Dönüş: telefon yatay, tablet dikey/yatay: ana sayfa 2–3 sütun, ayarlar yan yana; döndürme sırasında durum korunur.

Android ikon
19. Pixel Launcher + ana ekranda kısayol: bugün doğan kişi ekle, uygulamayı arka plana at: ikon kutlama ikonu olur, kısayol kalır, dokununca açılır. Kişiyi sil: ikon eski haline döner.
20. Aynı senaryo Samsung/Xiaomi/OnePlus launcher'larında: kısayolun silinip silinmediği kaydedilir (bilinen risk).
21. Gece yarısı: cihaz saatini 23:59'a al, bekle: ertesi gün doğum günü olan kişi için ikon 00:00 sonrası birkaç dakika içinde değişir; TIME_SET ve yeniden başlatma sonrası ikon doğru.
22. iOS: bugün doğan kişi varken uygulamayı aç: sistem "ikon değişti" bildirimi, ana ekranda alternatif ikon; kişi silinince ön plana dönüşte eski ikon.
