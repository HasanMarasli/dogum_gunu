# Doğum Günü Hatırlatıcı — Proje Kuralları (Orkestratör ve alt ajanlar)

Global kurallar (`~/.claude/CLAUDE.md`) geçerlidir; bu dosya proje özelindeki alt ajanlı çalışma düzenini tanımlar.

## Uygulama

Doğum günlerini hatırlatan, kişinin burcunu gösteren ve yaşa/ilişkiye/burca göre hediye ve sürpriz öneren
Flutter uygulaması. Android + iOS. Paket: `com.muhammet.hasan.marasli.DogumGunu`.

- State/navigasyon/çeviri: **GetX** (`get`), yerel depolama `get_storage`, veritabanı `sqflite`.
- Bildirimler: `flutter_local_notifications` + `timezone`.
- Değişken uygulama ikonu: Dart `lib/models/ikon_yoneticisi.dart` ↔ native `IkonYoneticisi.kt` / iOS alternate icons.
- **Diller: tr, en, es.** Yerelleştirme GetX çevirileriyle (`lib/tercumeler/`) yapılır; `.arb` gerekmez (kullanıcı kararı,
  2026-11-21). Kullanıcıya görünen her yeni metin üç dile birden eklenir.

## Değişmez kurallar (kullanıcı kararları, 2026-11-21)

1. **Yalnızca doğum tarihi alınır** (saat ve yer yok) → astrolojide yalnızca Güneş burcu kullanılır. Ay/gezegen
   burçları, yükselen burç, evler ve açılar hesaplanmaz ve gösterilmez.
2. Ücretli API yok; hesaplar çevrimdışı.
3. Mağazaya yükleme, yayına alma ve form gönderme kullanıcının açık onayı olmadan yapılmaz.
4. Commit yalnızca kullanıcı "commit et" / `/commit` dediğinde, orkestratör tarafından atılır.

## Ajanlar ve klasör sorumlulukları

Her dosya **tek** ajana aittir. Başka alana dokunmak gerekirse ajan orkestratöre bildirir.

| Ajan | Model | Yazabildiği yerler |
|---|---|---|
| `tasarimci` | opus | `lib/sayfalar/`, `lib/widgets/`, `lib/tema/`, `assets/fonts/`, `assets/svg/`, `assets/logo/` |
| `mobil-gelistirici` | opus | `lib/models/` (öneri dosyaları hariç), `lib/veriTabani/`, `lib/main.dart`, `pubspec.yaml` (`version:` hariç), `analysis_options.yaml` |
| `native-gelistirici` | opus | `android/`, `ios/` |
| `astrolog` | opus | `lib/astroloji/` (yeni, burç içerikleri), `docs/astroloji/` (yeni) |
| `hediye-uzmani` | sonnet | `lib/models/oneri_havuzu.dart`, `lib/models/oneri_motoru.dart`, `lib/tercumeler/oneri_*.dart` |
| `metin-yazari` | sonnet | `lib/tercumeler/tr.dart`, `en.dart`, `es.dart`, `tercumeler.dart`, `docs/play-store-listing.md`, `docs/magaza/` |
| `yayin-sorumlusu` | sonnet | `pubspec.yaml` `version:` satırı, `docs/surum-notlari/`, `docs/yayin/` |
| `testci` | sonnet | Kod yazmaz; yalnızca `docs/qa/` |
| Orkestratör (ana oturum) | — | `CLAUDE.md`, `.claude/`; görev dağıtımı, sonuç kontrolü, commit |

Ortak istisna: yeni kullanıcı metni gereken ajan, anahtarı **tr/en/es** üçüne birden ekleyebilir; çeviri kalitesini
metin-yazari sonradan denetler.

## Ajanlar arası iletişim

Ajanlar birbirine doğrudan mesaj atamaz; iletişim orkestratör üzerinden yürür. Bir ajan raporunda
"**Diğer ajanlara iletilecekler**" başlığı altında hangi ajana ne söylenmesi gerektiğini yazar; orkestratör bunu
ilgili ajana görev olarak iletir. Sık bağlantılar:

- astrolog ↔ hediye-uzmani: burca/elemente göre öneriler.
- astrolog → mobil-gelistirici: `DogumGunu` burç fonksiyonlarındaki kural/tarih düzeltmeleri.
- mobil-gelistirici ↔ native-gelistirici: platform kanalı değişiklikleri.
- metin-yazari ↔ hediye-uzmani / native-gelistirici: öneri ve native metin çevirileri.
- testci → herkes: bulgular; yayin-sorumlusu derlemeden önce testci raporuna bakar.

## Çalışma döngüsü

1. Kullanıcı isteğini görevlere böl; belirsizlik varsa önce kullanıcıya sor.
2. Her görevi sorumlu ajana ver (dosyalar, kabul kriteri, bağlam).
3. Bağımsız görevleri paralel, bağımlı olanları sırayla çalıştır.
4. Değişiklikten sonra testci denetler; bulgu varsa ilgili ajana geri döner.
5. Orkestratör sonucu kontrol eder ve kullanıcıya raporlar; commit için onay bekler.

## Doğrulama

- Flutter SDK: `/Users/hasanmarasli/flutter/bin/flutter`.
- `flutter analyze`, `flutter build apk --debug`, `flutter build ios --simulator --debug`.
- Otomatik test yazılmaz; manuel senaryolar `docs/qa/` altına.
