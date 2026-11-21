# İspanyolca (es) dil desteği — manuel test senaryoları

Not: Emülatör/simülatör sonuçları gerçek cihaz sonucu değildir; bildirim senaryoları mümkünse gerçek cihazda doğrulanmalıdır.

## 1. Dil seçimi
1. Ayarlar > dil listesi: Türkçe, English, Español satırları görünür; seçili olan işaretli (kod "ES").
2. Español seç: tüm ekranlar anında İspanyolca; ekranda `home.title` gibi anahtar adı görünmemeli.
3. Uygulamayı kapat-aç: seçim korunur.
4. TR ve EN'e geri dön: metinler eksiksiz, İspanyolca kalıntı yok.

## 2. Cihaz dili ile ilk açılış (kayıtlı seçim yokken; uygulama verisi temizle/yeniden kur)
- Cihaz dili İspanyolca (es-ES, es-MX, es-419): uygulama İspanyolca açılır, Ayarlar'da Español seçili görünür.
- Cihaz dili Türkçe: Türkçe. Cihaz dili Fransızca/Almanca: İngilizce.
- Android 13+ uygulama başına dil ayarı (Ayarlar > Uygulamalar > Dil) ile es seçilebiliyor mu kontrol et (res/values-es).

## 3. Tarih formatları (es)
- Ana sayfa kartı ve tavsiye sayfası: tarih "2 de noviembre de 1994" biçiminde mi, yoksa "2 noviembre 1994" mü (beklenen: "de" ile).
- Tarih seçici: ay adları büyük harfle ("Noviembre"), gün adı büyük harfle ("Miércoles"), hafta başlığı kısaltmaları, ay-yıl başlığı.
- Onboarding sahte kartlar: "d MMMM", "d MMM" biçimleri taşmadan görünür.
- Dilden dile geçişte aynı ekranlar yeniden çizilince tarihler yeni dilde.

## 4. On yıl etiketleri (tarih seçici, yıl ızgarası)
- es: 1910-1990 için "años 10 ... años 90"; 1900 için "años 1900"; 2000 ve 2010 için "años 2000", "años 2010".
- en: "1990s"; tr: "1990'lar" (ek uyumu eski haliyle aynı).
- Etiket tek satır, ölçeklenir, taşma yok (küçük ekran + büyük yazı tipi).

## 5. Burç adları ve sınır günleri (es)
Her burç için ad ve aralık metni kontrol edilir: Aries, Tauro, Géminis, Cáncer, Leo, Virgo, Libra, Escorpio, Sagitario, Capricornio, Acuario, Piscis. Sınır doğum tarihleri: 20 Mar / 21 Mar, 19 Nis / 20 Nis, 20 May / 21 May, 20 Haz / 21 Haz, 22 Tem / 23 Tem, 22 Ağu / 23 Ağu, 22 Eyl / 23 Eyl, 22 Eki / 23 Eki, 21 Kas / 22 Kas, 21 Ara / 22 Ara, 19 Oca / 20 Oca, 18 Şub / 19 Şub. Tarih seçicideki burç, ana sayfa kartı ve tavsiye sayfası aynı burcu göstermeli.

## 6. Uç tarihler
- 29 Şubat 2000 / 2004 doğumlu kişi ekle (es): tarih "29 de febrero de ..." ; geri sayım ve bildirimler (artık olmayan yıllarda 28 Şubat/1 Mart davranışı mevcut mantıkla aynı).
- Bugün doğan: kartta "Hoy", yaş doğru; tavsiye sayfasında hediye listesi dolu.
- Bu yıl doğan bebek (0 yaş): "0 años" ve bildirim gönderilmemesi.
- 1 yaş: "1 año"; 100+ yaş: öneri listesi boş değil, metinler İspanyolca.

## 7. Çoğul/tekil
- Kalan gün 1: "1 día" ve tavsiyede "Falta 1 día"; 2+: "N días", "Faltan N días".
- Toplam kişi 1: "1 persona"; 0 veya 2+: "personas".
- Yaş 1: "1 año".

## 8. Bildirimler (es)
1. Es seçiliyken kişi ekle, hatırlatıcı gününe göre bildirim zamanla: başlık "Recordatorio de Cumpleaños"; gövde "¡Ana cumple 30 años en 7 días!", "... mañana!", "... hoy!".
2. Dili es iken TR/EN'e çevir: planlı bildirimler yeni dilde yeniden planlanır (Ayarlar'dan dil değişince); bildirimi tetikleyip metni doğrula.
3. Bildirim kanalı adı/açıklaması (Android: Ayarlar > Uygulama > Bildirimler) İspanyolca.
4. Bildirim izni reddedildiğinde: ana sayfa uyarısı ve Ayarlar uyarısı İspanyolca, "Abrir ajustes" çalışır.
5. Saat dilimi: cihaz saat dilimi değiştirilince bildirimler 09:00 yerel saatte.

## 9. Onboarding ve splash
- Es ile tüm 4 adım: başlık, açıklama, "Paso 1 de 4", "TODOS A LAS 09:00" tek satır; sahte kartlardaki tarih/burç adı İspanyolca.
- Splash: üç pill metni tek satır, taşma yok (küçük ekran 320 dp genişlik, yazı tipi %130-160).
- Düğmeler: "Omitir", "Siguiente", "Permitir notificaciones", "Ahora no".

## 10. Native yerelleştirme
- Android: uygulama adı ana ekranda cihaz dili es iken "Cumpleaños".
- iOS: Info.plist CFBundleLocalizations (en, tr, es); ayarlar uygulamasında dil seçici es'i gösterir. Sistem iletişim kutuları (tarih/saat seçici, kopyala-yapıştır) İspanyolca.

## 11. Tema, ekran boyutu
- Açık/koyu tema ve 9 tema renginde es metin taşması: Ayarlar tema adları (Morado, Turquesa, Naranja, Azul, Coral, Verde lima, Celeste, Orquídea, Dorado).
- Küçük ekran (360x640) ve büyük yazı: Ayarlar bildirim açıklaması, kişi ekle ipuçları, silme diyaloğu, tarih seçici.

## 12. Veri korunması
- TR/EN ile eklenmiş kişiler uygulama güncellemesi sonrası es modunda aynen görünür (isim, tarih, ilişki etiketi es'e çevrilmiş).

## 13. Öneri içerikleri (es)
- Bebek, çocuk, genç, yetişkin, 65+ ve her ilişki türü için hediye ve sürpriz listeleri: İspanyolca, anahtar adı görünmez.
- "Sugerir otras" yeni öneri getirir; bütçe filtreleri (Económico, Intermedio, Premium) listeyi boşaltmaz.
