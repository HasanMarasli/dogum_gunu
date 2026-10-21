# Doğum Günü Uygulaması — Claude Design Tasarım Promptları

Bu dosyada uygulamanın tüm ekranları ve popup'ları için Claude Design'a verilecek promptlar var. Promptlar İngilizce, ekranda görünecek metinler Türkçe.

## Nasıl kullanılır

1. Önce **Prompt 0 (Design System)** çalıştırılır. Diğer tüm ekranlar bu sistemi kullanır.
2. Sonra ekran promptları sırayla verilir. Her promptun altında o prompta eklenecek görseller yazıyor.
3. Görseller sadece 12 burç SVG'sidir (`assets/svg/burclar/`). Ayrıca ekran görüntüsü, logo ya da moodboard verilmeyecek.

## Görsel listesi (tümü)

| Dosya | Burç (TR) | Tarih aralığı |
|---|---|---|
| `assets/svg/burclar/aries.svg` | Koç | 21 Mart – 19 Nisan |
| `assets/svg/burclar/taurus.svg` | Boğa | 20 Nisan – 20 Mayıs |
| `assets/svg/burclar/gemini.svg` | İkizler | 21 Mayıs – 20 Haziran |
| `assets/svg/burclar/cancer.svg` | Yengeç | 21 Haziran – 22 Temmuz |
| `assets/svg/burclar/leo.svg` | Aslan | 23 Temmuz – 22 Ağustos |
| `assets/svg/burclar/virgo.svg` | Başak | 23 Ağustos – 22 Eylül |
| `assets/svg/burclar/libra.svg` | Terazi | 23 Eylül – 22 Ekim |
| `assets/svg/burclar/scorpio.svg` | Akrep | 23 Ekim – 21 Kasım |
| `assets/svg/burclar/sagittarius.svg` | Yay | 22 Kasım – 21 Aralık |
| `assets/svg/burclar/capricorn.svg` | Oğlak | 22 Aralık – 19 Ocak |
| `assets/svg/burclar/aquarius.svg` | Kova | 20 Ocak – 18 Şubat |
| `assets/svg/burclar/pisces.svg` | Balık | 19 Şubat – 20 Mart |

## Prompt / görsel eşleşmesi (özet)

| # | Ekran / Popup | Eklenecek görseller |
|---|---|---|
| 0 | Design System | 12 burç SVG'sinin hepsi |
| 1 | Splash | — |
| 2 | Onboarding 1 – Sevdiklerini ekle | — |
| 3 | Onboarding 2 – Burç bazlı hediye & sürpriz | `leo.svg`, `pisces.svg`, `aries.svg` |
| 4 | Onboarding 3 – Gizlilik odaklı | — |
| 5 | Onboarding 4 – Akıllı hatırlatma + bildirim izni | — |
| 6 | Ana Sayfa (dolu / boş / yükleniyor / izin kapalı banner) | `aries.svg`, `leo.svg`, `libra.svg`, `scorpio.svg`, `capricorn.svg` |
| 7 | Kart menüsü (Düzenle / Sil) | `leo.svg` |
| 8 | Silme onay dialogu | — |
| 9 | Yeni Kişi Ekle | — |
| 10 | Kişiyi Düzenle | — |
| 11 | Tarih seçici popup | — |
| 12 | Tavsiye (burç detayı) | `aries.svg` |
| 13 | Ayarlar | — |
| 14 | Snackbar'lar (başarı / hata / uyarı / bilgi) | — |

---

## Prompt 0 — Design System

**Görseller:** 12 burç SVG'sinin hepsi.

```
Design a complete mobile design system for a birthday reminder app called "Doğum Günü" (Turkish for "Birthday"). It runs on iOS and Android (Flutter, Material 3). All UI text is in Turkish.

What the app does:
- The user adds people (name + birth date). The app reminds them before each birthday with local notifications.
- Each person is shown with their zodiac sign. A detail page offers zodiac-based gift ideas and surprise ideas.
- All data stays on the device. There is no account or login.

Visual tone: your call. Pick a direction that fits a personal birthday reminder app and keep it consistent across every screen.

Typography: choose a font family that supports Turkish characters (ç, ğ, ı, İ, ö, ş, ü). Define a type scale (display, title, body, label, caption).

Color system — this is the key requirement:
- The user can pick one of 6 accent palettes in Settings. Every screen must work with all 6. Seed colors:
  - Mor (purple): #5B55F6
  - Turkuaz (teal): #11998E
  - Turuncu (orange): #FB8C00
  - Mavi (blue): #2962FF
  - Mercan (coral): #FF5C8D
  - Limon Yeşili (lime): #6FBF73
- For each palette, define the tokens you need (primary, on-primary, primary container, gradient start/end if you use gradients, etc.).
- The app has both light mode and dark mode (the user switches with a toggle). Define light AND dark variants for all 6 palettes and for neutral surfaces, text and borders.
- Define semantic colors for success, error, warning and info. They should stay the same regardless of palette.

Zodiac icons:
- The 12 attached SVGs are single-color zodiac glyphs. They are tinted at runtime. Define how they appear: the container shape, size variants (small for list cards, large for the detail page) and colors in light/dark.

Components to define (light + dark):
- Buttons: primary filled, secondary/tonal, text button, destructive, icon button, floating action button (extended, with label)
- Text field (with label and hint), plus a tappable "date field" that opens a date picker
- List card for a person (zodiac badge, name, date, small tags, countdown pill)
- Stat tile (small number + label)
- Tag/chip
- Countdown pill: a normal state ("12 gün / kaldı") and a highlighted "Bugün" (today) state
- Section header (icon + title)
- Settings rows: selectable row with a "Geçerli" (current) badge, checkbox row, switch row
- Dialog, popup menu, bottom sheet
- Snackbar/toast in 4 variants: success, error, warning, info
- Inline banner (warning style, with an action)
- Page indicator dots (for onboarding)
- Empty state and loading state patterns

Deliver: color tokens for all 6 palettes × light/dark, typography scale, spacing and radius scale, elevation/shadow rules, and a component sheet.
```

---

## Prompt 1 — Splash

**Görseller:** —

```
Using the design system defined earlier, design the Splash screen of the "Doğum Günü" birthday reminder app. Show it with the Mor palette in light and dark mode, and add one small variant with a different palette to prove it adapts.

Purpose: shown for about 2 seconds while the app starts, then it moves on automatically (to Onboarding the first time, to the Home screen after that). There are no buttons.

Content (Turkish text, use exactly):
- App name: "Doğum Günü"
- Subtitle: "Sevdiklerini kutlamayı unutma"
- Three short value pills: "Sevdiklerini ekle", "Akıllı hatırlatma", "Gizlilik odaklı"
- A small loading indicator with the text "Hazırlanıyor…"

There is no app logo yet. Design a central emblem/mark for the app that fits the birthday + reminder concept.

Describe the intended motion (e.g. pulse, orbit, fade) in notes next to the frame. Keep it subtle and short.
```

---

## Prompt 2 — Onboarding 1/4: Sevdiklerini ekle

**Görseller:** —

```
Using the design system defined earlier, design step 1 of a 4-step onboarding for the "Doğum Günü" birthday reminder app. Show light and dark mode with the Mor palette.

Onboarding is shown only on the first launch, after Splash. All 4 steps share the same layout: illustration area, headline, short description, page indicator (4 dots, step 1 active), a primary "next" button, and a "skip" text button. Design that shared layout here so steps 2–4 can reuse it.

Message of this step: "Add your loved ones". The user only needs a name and a birth date to add someone. The list is sorted by whose birthday is coming up next.

Write a short Turkish headline (max ~5 words) and a Turkish description (1–2 short sentences) for this message. Also write the Turkish labels for the "next" and "skip" buttons.

Illustration: create an illustration or composition that shows adding a person with a birth date. Do not use photos of real people.
```

---

## Prompt 3 — Onboarding 2/4: Burç bazlı hediye ve sürpriz önerileri

**Görseller:** `leo.svg`, `pisces.svg`, `aries.svg`

```
Using the design system and the onboarding layout defined earlier, design step 2 of 4 of the onboarding (page indicator: step 2 active). Show light and dark mode with the Mor palette.

Message of this step: the app detects each person's zodiac sign from their birth date and suggests gift ideas and surprise ideas that fit that sign.

Write a short Turkish headline (max ~5 words) and a Turkish description (1–2 short sentences) for this message.

Illustration: use the attached zodiac glyphs (Aslan/Leo, Balık/Pisces, Koç/Aries) together with gift/surprise imagery. Example content you may show as small cards in the illustration:
- Hediye Önerileri: "Şık aksesuar (saat/bileklik)", "Etkinlik bileti (konser/tiyatro)"
- Sürpriz Önerileri: "Sürpriz mini parti", "Konseptli kutlama"
```

---

## Prompt 4 — Onboarding 3/4: Gizlilik odaklı

**Görseller:** —

```
Using the design system and the onboarding layout defined earlier, design step 3 of 4 of the onboarding (page indicator: step 3 active). Show light and dark mode with the Mor palette.

Message of this step: privacy. All data is stored only on the user's device. There is no account, no sign-up and no cloud sync.

Write a short Turkish headline (max ~5 words) and a Turkish description (1–2 short sentences) for this message. Do not promise anything beyond what is stated above.

Illustration: create an illustration that conveys "your data stays on your phone".
```

---

## Prompt 5 — Onboarding 4/4: Akıllı hatırlatma + bildirim izni

**Görseller:** —

```
Using the design system and the onboarding layout defined earlier, design step 4 of 4, the last step of the onboarding (page indicator: step 4 active). Show light and dark mode with the Mor palette.

Message of this step: smart reminders. The app sends a local notification at 09:00 on the selected days before each birthday. Available options (the user can change them later in Settings): "7 gün önce", "2 gün önce", "1 gün önce", "Doğum günü sabahı". All are on by default.

This step also asks for notification permission:
- Primary button: asks for notification permission (the OS permission prompt appears after it), then goes to the Home screen.
- Secondary text button: continue without allowing, goes to the Home screen.
- The "skip" button from earlier steps is not shown here.

Write the Turkish headline (max ~5 words), a Turkish description (1–2 short sentences) and the Turkish labels for both buttons.

Illustration: show a sample notification card, e.g. title "Doğum Günü Hatırlatıcı", text "Ayşe Yılmaz Bugün 30 Yaşında!".
```

---

## Prompt 6 — Ana Sayfa (Home)

**Görseller:** `aries.svg`, `leo.svg`, `libra.svg`, `scorpio.svg`, `capricorn.svg`

```
Using the design system defined earlier, design the Home screen of the "Doğum Günü" birthday reminder app. Show light and dark mode with the Mor palette, plus one populated frame with a different palette.

Header:
- Title: "Doğum Günleri"
- Subtitle: "Sevdiklerini hatırlat, mutlu et"
- A settings icon button (opens Settings)

Two stat tiles:
- "Toplam" — number — "kayıt"
- "Yaklaşan" — number — "önümüzdeki 7 gün"

List of people, sorted by days left until the next birthday (closest first). Each card shows:
- Zodiac badge with the person's zodiac glyph (attached SVGs). This badge animates into the large icon on the detail page (shared element / hero transition), so keep it visually related.
- Name
- Birth date, e.g. "12 Nisan 1994" (with a small cake icon or similar)
- Two small tags: age ("31 yaş") and zodiac name ("Koç")
- Countdown pill: "12 gün" + "kaldı"; on the birthday itself it shows only "Bugün" in a highlighted (success) style
- A "more" (⋮) button that opens a menu with Düzenle / Sil
- Tapping the card opens the detail (Tavsiye) page

Primary action: an extended floating action button "Yeni Kişi" (with a plus icon) that opens the Add Person screen.
The list supports pull-to-refresh.

Sample data for the populated state:
1. Elif Kaya — 21 Ekim 1996 — 30 yaş — Terazi — "Bugün"
2. Mehmet Demir — 25 Ekim 1990 — 36 yaş — Akrep — 4 gün kaldı
3. Ayşe Yılmaz — 12 Nisan 1994 — 32 yaş — Koç — 173 gün kaldı
4. Can Öztürk — 3 Ağustos 1988 — 38 yaş — Aslan — 286 gün kaldı
5. Zeynep Arslan — 5 Ocak 2001 — 25 yaş — Oğlak — 76 gün kaldı
(Re-sort the sample by days left. Stat tiles: Toplam 5 kayıt, Yaklaşan 2.)
Use the attached glyphs: Koç (aries), Aslan (leo), Terazi (libra), Akrep (scorpio), Oğlak (capricorn).

Design these states as separate frames:
A) Populated list (above)
B) Empty state: title "Henüz kayıt yok", description "Sevdiklerinin doğum günlerini ekleyip hatırlatmaları açabilirsin." Stat tiles show 0. The FAB is still visible.
C) Loading state (first load from local database)
D) Notification permission denied: a warning banner above the list explaining that notifications are off so reminders will not arrive, with an action that opens the system settings. Write the Turkish banner text and action label (short).
```

---

## Prompt 7 — Kart menüsü (Düzenle / Sil)

**Görseller:** `leo.svg`

```
Using the design system defined earlier, design the popup menu that opens from the "more" (⋮) button on a person card on the Home screen. Show light and dark mode with the Mor palette, open over a person card (sample: Can Öztürk — 3 Ağustos 1988 — Aslan; use the attached Leo glyph).

Menu items:
- "Düzenle" (edit icon) — opens the Edit Person screen
- "Sil" (delete icon) — destructive style; opens the delete confirmation dialog

You may choose between an anchored popup menu and a bottom sheet; explain the choice briefly.
```

---

## Prompt 8 — Silme onay dialogu

**Görseller:** —

```
Using the design system defined earlier, design the delete confirmation dialog of the "Doğum Günü" app. Show light and dark mode with the Mor palette, over a dimmed Home screen.

Content (use exactly):
- Title: "Kaydı sil"
- Message: "Ayşe Yılmaz kaydını silmek istediğine emin misin?" (the name is dynamic)
- Cancel button: "Vazgeç"
- Destructive confirm button: "Sil"

After confirming, the person is removed and a success snackbar appears with title "Silindi" and message "Ayşe Yılmaz kaldırıldı ve bildirimleri iptal edildi." (The snackbar itself is designed in the Snackbar prompt; show it here only as a small after-state frame.)
```

---

## Prompt 9 — Yeni Kişi Ekle (Add Person)

**Görseller:** —

```
Using the design system defined earlier, design the Add Person screen of the "Doğum Günü" app. Show light and dark mode with the Mor palette.

Content (use exactly):
- Screen title: "Yeni Kişi Ekle" (with a back button)
- Intro text: "Sevdiklerini listene ekle, bildirimleri otomatik alsın."
- Section title: "Kişi Bilgileri"
- Name field — label: "Kişi adı", hint: "Örn: Ayşe Yılmaz"
- Birth date field — placeholder: "Doğum tarihini seçin", action label: "Seç". Tapping it opens the date picker. After a date is picked it shows the date (e.g. "12 Nisan 1994") and the action label changes to "Değiştir".
- Primary button: "Kaydet ve Hatırlat"

Behaviour:
- If the name or date is missing when saving: error snackbar, title "Hata", message "Lütfen isim ve tarih seçin!"
- If a person with the same name already exists: warning snackbar, title "Hata", message "Bu isimle bir kayıt zaten var."
- On success: the screen closes, back to Home, success snackbar title "Başarılı", message "Doğum günü başarıyla eklendi."

Design these frames:
A) Empty form
B) Filled form (name + date picked)
C) Keyboard open while typing the name (make sure the save button stays reachable)
```

---

## Prompt 10 — Kişiyi Düzenle (Edit Person)

**Görseller:** —

```
Using the design system defined earlier, design the Edit Person screen of the "Doğum Günü" app. Show light and dark mode with the Mor palette.

It is the Add Person screen opened with the person's existing data filled in. Keep the layout and fields identical to Add Person (name field, birth date field with "Değiştir", primary button). It can be opened from two places: the "Düzenle" item in the person card menu on Home, and an edit button on the detail (Tavsiye) page.

Differences from Add Person:
- Screen title: write a Turkish title meaning "Edit person"
- Intro text: write a short Turkish line, or remove it if it does not fit
- Primary button: write a Turkish label meaning "Save changes"
- Sample prefilled data: "Ayşe Yılmaz", "12 Nisan 1994"

Validation is the same as Add Person (missing fields → error snackbar; duplicate name → warning snackbar). Write a Turkish success message for the snackbar after saving changes.

Do not add any fields or actions that are not listed above.
```

---

## Prompt 11 — Tarih seçici popup

**Görseller:** —

```
Using the design system defined earlier, design the birth date picker that opens from the date field on the Add Person / Edit Person screens. Show light and dark mode with the Mor palette.

Requirements:
- Selectable range: 1 January 1900 – 31 December 2100. Users usually pick dates decades in the past, so moving quickly between years must be easy (e.g. a year selection view).
- Turkish month and day names (Ocak, Şubat… / Pzt, Sal…).
- Actions: cancel and confirm (write the Turkish labels).

Design these frames:
A) Day selection view with a selected date (12 Nisan 1994)
B) Year selection view
You may choose a dialog or a bottom sheet; explain the choice briefly.
```

---

## Prompt 12 — Tavsiye (Burç detayı / hediye önerileri)

**Görseller:** `aries.svg`

```
Using the design system defined earlier, design the person detail page ("Tavsiye") of the "Doğum Günü" app. Show light and dark mode with the Mor palette, plus one frame with a different palette.

It opens when a person card on Home is tapped, or when the user taps a birthday notification. The large zodiac icon at the top is the target of the hero transition from the small card badge.

Top bar:
- Back button
- Title: "Ayşe Yılmaz için" (dynamic name), with the zodiac name "Koç" as a subtitle
- An edit button that opens the Edit Person screen

Content (sample person: Ayşe Yılmaz, 12 Nisan 1994, Koç — use the attached Aries glyph):
- Large zodiac icon
- Zodiac name: "Koç"
- Zodiac date range: "21 Mart - 19 Nisan"
- Birth date: "12 Nisan 1994" (with a cake icon or similar)
- Short personality text: "Enerjik, atılgan ve doğrudan; hızlı karar alır ve aksiyon ister. Netlik ve hareket onu motive eder."
- Section "Hediye Önerileri" (gift icon):
  - Spor/aktivite ekipmanı
  - Karting/tırmanış gibi deneyim
  - Akıllı aksesuarlar (kulaklık, powerbank)
  - Kısa bir kurs/atölye bileti
- Section "Sürpriz Önerileri" (sparkle icon):
  - Spontane mini kaçamak
  - İpuçlu küçük görev oyunu
  - Adrenalin içeren etkinlik
- Info note at the bottom: "Doğum günü yaklaştığında otomatik hatırlatma alacaksın. Bu kartı kişiye özel notlar ve hediye fikirleri için kullanabilirsin."

All 12 signs use this same layout with different text (each sign has 3–4 gift items and 3 surprise items). Make sure the layout also works with longer item text.
```

---

## Prompt 13 — Ayarlar (Settings)

**Görseller:** —

```
Using the design system defined earlier, design the Settings screen of the "Doğum Günü" app. Show light and dark mode with the Mor palette, plus one frame with a different palette selected.

Screen title: "Ayarlar" (with a back button)

Sections, in this order:

1) Language — section title: "Dil seç"
   Options: "Türkçe" (TR), "English" (EN). The selected one shows a "Geçerli" badge. Tapping switches the app language immediately.

2) Appearance — a single Light/Dark switch (an on/off toggle for dark mode). Write the Turkish section title and the Turkish row label.

3) Theme color — section title: "Tema rengi"
   Options (each with a color swatch): "Mor", "Turkuaz", "Turuncu", "Mavi", "Mercan", "Limon Yeşili". The selected one shows a "Geçerli" badge. Changing it re-colors the whole app immediately. Consider a more compact layout than a long list (e.g. a swatch grid) if it fits better.

4) Notifications — section title: "Bildirim zamanı"
   Description: "Doğum gününden kaç gün önce hatırlatma gelsin? Seçtiklerin tüm kişiler için geçerli."
   Multi-select options (checkboxes, any combination):
   - "7 gün önce (hafta öncesi hatırlatma)"
   - "2 gün önce"
   - "1 gün önce"
   - "Doğum günü sabahı"

Design these frames:
A) Default state (Türkçe, light mode, Mor, all 4 notification options selected)
B) Dark mode on, a different theme color selected, some notification options unselected
C) Notification permission denied: a warning card at the top of the Notifications section explaining that notifications are off at system level, with an action that opens the system settings. Write the Turkish card text and action label (short).
```

---

## Prompt 14 — Snackbar'lar (bildirim mesajları)

**Görseller:** —

```
Using the design system defined earlier, design the in-app snackbar/toast messages of the "Doğum Günü" app. Show light and dark mode. Snackbars are floating, appear at the top of the screen, can be swiped away horizontally and close automatically after ~3 seconds. Each has an icon, a title and a message.

Four variants (use the semantic colors from the design system, not the theme palette):
1) Success — title "Başarılı", message "Doğum günü başarıyla eklendi."
2) Error — title "Hata", message "Lütfen isim ve tarih seçin!"
3) Warning — title "Hata", message "Bu isimle bir kayıt zaten var."
4) Info — no message is used in the app yet; show the variant with placeholder text.

Also show the delete success message in the success style: title "Silindi", message "Ayşe Yılmaz kaldırıldı ve bildirimleri iptal edildi."

Show each variant on top of a screen (e.g. Home or Add Person) and describe the enter/exit animation in a note.
```
