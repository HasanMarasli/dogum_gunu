import 'dart:async';
import 'dart:math' as math;

import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dogum_gunu/sayfalar/dogum_gunu_ekle.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:dogum_gunu/sayfalar/ayarlar.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/en.dart';
import 'package:dogum_gunu/tercumeler/tr.dart' show tZodiac;

import '../tema/ekran.dart';
import '../tema/renkler.dart';
import '../widgets/bildirim_uyarisi.dart';
import '../widgets/burc_rozeti.dart';
import '../widgets/ozel_snackbar.dart';
import '../widgets/silme_dialogu.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> with WidgetsBindingObserver {
  bool isLoading = true;
  bool _iskeletGoster = false;
  bool _hata = false;
  static const String _uyariKapaliKey = 'notif_banner_closed';

  bool _izinVar = true;
  bool _uyariKapali = GetStorage().read<bool>(_uyariKapaliKey) ?? false;
  Timer? _iskeletZamanlayici;
  DogumGunuVeriYonetim dogumGunuVeriYonetim = Get.find<DogumGunuVeriYonetim>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Hızlı yüklemelerde iskelet hiç görünmesin diye 300 ms gecikme.
    _iskeletZamanlayici = Timer(const Duration(milliseconds: 300), () {
      if (mounted && isLoading) setState(() => _iskeletGoster = true);
    });
    _verileriCek().then((basarili) {
      // Bildirimlerdeki yaş ve dil güncel kalsın diye açılışta yeniden planlanır.
      if (basarili) DogumGunuVeriTabani.tumBildirimleriYenidenPlanla();
    });
    _izinKontrol();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _iskeletZamanlayici?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _izinKontrol();
      // Uygulama arka planda gün değiştirdiyse sayaçlar güncellensin.
      dogumGunuVeriYonetim.dogumGunuListe.refresh();
    }
  }

  Future<void> _izinKontrol() async {
    final izin = await BildirimYoneticisi().izinVarMi();
    if (mounted && izin != _izinVar) setState(() => _izinVar = izin);
  }

  /// Liste okunamazsa sonsuz iskelet yerine hata görünümü açılır.
  Future<bool> _verileriCek() async {
    var basarili = true;
    try {
      dogumGunuVeriYonetim.dogumGunuListe.value =
          await DogumGunuVeriTabani.tumVerileriGetir();
    } catch (_) {
      basarili = false;
    }

    if (!mounted) return basarili;
    setState(() {
      isLoading = false;
      _hata = !basarili;
    });
    return basarili;
  }

  Future<void> _tekrarDene() async {
    setState(() {
      isLoading = true;
      _hata = false;
    });
    final basarili = await _verileriCek();
    if (basarili) DogumGunuVeriTabani.tumBildirimleriYenidenPlanla();
  }

  /// Liste genişliğine göre sütun sayısı ve yatay dolgu. Tek sütunda içerik
  /// okunur genişlikte, çok sütunda geniş içerik sınırında ortalanır.
  ({double dolgu, int sutun}) _yerlesim(double genislik) {
    final genisDolgu = Ekran.yatayDolgu(genislik, azami: Ekran.genisIcerik);
    final sutun = Ekran.sutunSayisi(genislik - 2 * genisDolgu);
    if (sutun == 1) return (dolgu: Ekran.yatayDolgu(genislik), sutun: 1);
    return (dolgu: genisDolgu, sutun: sutun);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    // Yatay telefonda başlık ve sayaçlar solda sabit panelde, liste sağda.
    final alcak = context.alcakMi();

    return Scaffold(
      backgroundColor: r.bg,
      body: SafeArea(
        bottom: false,
        child: alcak
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: math.min(
                      320,
                      MediaQuery.sizeOf(context).width * 0.4,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ustBolum(20),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final y = _yerlesim(c.maxWidth);
                        return _govde(y.dolgu, y.sutun);
                      },
                    ),
                  ),
                ],
              )
            : LayoutBuilder(
                builder: (context, c) {
                  final y = _yerlesim(c.maxWidth);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ustBolum(y.dolgu),
                      Expanded(child: _govde(y.dolgu, y.sutun)),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: _YeniKisiButonu(
        onPressed: () => Get.to(() => const DogumGunuEkle()),
      ),
    );
  }

  /// Başlık, ayarlar düğmesi ve iki sayaç kartı.
  Widget _ustBolum(double dolgu) {
    final r = context.renk;
    final metin = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(dolgu, 16, dolgu - 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('home.title'.tr, style: metin.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'home.subtitle'.tr,
                      style: metin.bodyMedium?.copyWith(color: r.tx2),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'settings.title'.tr,
                onPressed: () async {
                  await Get.to(() => const Ayarlar());
                  _izinKontrol();
                },
                iconSize: 24,
                color: r.tx2,
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(dolgu, 20, dolgu, 4),
          child: Obx(() {
            final liste = dogumGunuVeriYonetim.dogumGunuListe;
            final yaklasan = _yaklasanSayisi();
            return Row(
              children: [
                Expanded(
                  child: _istatistikKart(
                    baslik: 'home.stats.total'.tr,
                    deger: liste.length,
                    altYazi: trSayi(
                      'home.stats.total.suffix',
                      liste.length,
                      {},
                    ),
                    vurgulu: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _istatistikKart(
                    baslik: 'home.stats.upcoming'.tr,
                    deger: yaklasan,
                    altYazi: 'home.stats.upcoming.suffix'.tr,
                    vurgulu: yaklasan > 0,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _govde(double dolgu, int sutun) {
    if (isLoading) {
      return _iskeletGoster ? _iskelet(dolgu, sutun) : const SizedBox.shrink();
    }
    if (_hata) return _hataGorunumu();
    return RefreshIndicator(
      onRefresh: () async {
        await _verileriCek();
        await _izinKontrol();
      },
      child: Obx(() {
        final liste = [...dogumGunuVeriYonetim.dogumGunuListe];
        liste.sort((a, b) => _kalanGun(a).compareTo(_kalanGun(b)));

        final banner = !_izinVar && !_uyariKapali;
        if (liste.isEmpty) {
          return _bosDurum(banner ? _izinUyarisi() : null, dolgu);
        }

        final satirSayisi = (liste.length / sutun).ceil();
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            dolgu,
            12,
            dolgu,
            104 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: satirSayisi + (banner ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (banner && index == 0) return _izinUyarisi();
            final satir = index - (banner ? 1 : 0);
            if (sutun == 1) return _dogumKart(liste[satir]);
            final ilk = satir * sutun;
            return _kartSatiri([
              for (var i = ilk; i < math.min(ilk + sutun, liste.length); i++)
                _dogumKart(liste[i], doldur: true),
            ], sutun);
          },
        );
      }),
    );
  }

  /// Izgara satırı: kartlar eşit genişlikte, [esitYukseklik] ise satırdaki en
  /// uzun kart kadar yüksek. Eksik kalan sütunlar boş bırakılır.
  Widget _kartSatiri(
    List<Widget> kartlar,
    int sutun, {
    bool esitYukseklik = true,
  }) {
    final satir = Row(
      crossAxisAlignment: esitYukseklik
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sutun; i++) ...[
          if (i > 0) const SizedBox(width: Ekran.sutunAraligi),
          Expanded(
            child: i < kartlar.length ? kartlar[i] : const SizedBox.shrink(),
          ),
        ],
      ],
    );
    return esitYukseklik ? IntrinsicHeight(child: satir) : satir;
  }

  Widget _izinUyarisi() {
    return BildirimUyarisi(
      baslik: 'home.notifOff.title'.tr,
      mesaj: 'home.notifOff.desc'.tr,
      eylem: 'home.notifOff.action'.tr,
      kapatEtiketi: 'home.notifOff.dismiss'.tr,
      onKapat: () {
        GetStorage().write(_uyariKapaliKey, true);
        setState(() => _uyariKapali = true);
      },
    );
  }

  Widget _istatistikKart({
    required String baslik,
    required int deger,
    required String altYazi,
    required bool vurgulu,
  }) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final renk = vurgulu ? scheme.onPrimaryContainer : r.tx;
    final ikincil = vurgulu
        ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
        : r.tx2;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: vurgulu ? scheme.primaryContainer : r.s2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            baslik,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: ikincil,
            ),
          ),
          const SizedBox(height: 2),
          isLoading || _hata
              ? Container(
                  height: 26,
                  width: 36,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: r.s3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              : Text(
                  '$deger',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 30,
                    height: 34 / 30,
                    color: renk,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            altYazi,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: ikincil,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iskelet(double dolgu, int sutun) {
    final r = context.renk;
    Widget blok(double w, double h, double yaricap) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: r.s3,
        borderRadius: BorderRadius.circular(yaricap),
      ),
    );
    const genislikler = [
      [0.68, 0.44],
      [0.56, 0.40],
      [0.72, 0.36],
      [0.50, 0.42],
      [0.62, 0.38],
    ];
    Widget kart(int i) => RepaintBoundary(
      child: _Nabiz(
        gecikme: Duration(milliseconds: 150 * i),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: r.s1,
            borderRadius: BorderRadius.circular(20),
            boxShadow: r.e1,
          ),
          child: Row(
            children: [
              blok(48, 48, 14),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      blok(c.maxWidth * genislikler[i][0], 14, 7),
                      const SizedBox(height: 8),
                      blok(c.maxWidth * genislikler[i][1], 12, 6),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          blok(44, 20, 8),
                          const SizedBox(width: 6),
                          blok(44, 20, 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              blok(60, 46, 16),
            ],
          ),
        ),
      ),
    );
    // Izgarada da ekranı dolduracak kadar satır gösterilir.
    final satirSayisi = sutun == 1 ? genislikler.length : 4;
    return Semantics(
      label: 'home.loading'.tr,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(dolgu, 12, dolgu, 0),
        itemCount: satirSayisi,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, s) => sutun == 1
            ? kart(s)
            : _kartSatiri(
                [
                  for (var k = 0; k < sutun; k++)
                    kart((s * sutun + k) % genislikler.length),
                ],
                sutun,
                esitYukseklik: false,
              ),
      ),
    );
  }

  /// Boş ve hata görünümünün metni geniş ekranda tek satıra yayılmasın.
  Widget _durumKutusu({required EdgeInsets padding, required Widget child}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Ekran.diyalogGenislik + padding.horizontal,
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _hataGorunumu() {
    final r = context.renk;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(
            child: _durumKutusu(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: r.errc,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: r.err,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'home.error.title'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'home.error.desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.5, color: r.tx2),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _tekrarDene,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text('home.error.retry'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bosDurum(Widget? uyari, double dolgu) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: uyari == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (uyari != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(dolgu, 12, dolgu, 0),
                  child: uyari,
                ),
              _durumKutusu(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.cake_rounded,
                        size: 44,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'home.empty.title'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'home.empty.desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.5, color: r.tx2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [doldur]: ızgara satırında kart, satırın yüksekliğini doldurur.
  Widget _dogumKart(DogumGunu dogum, {bool doldur = false}) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final kalanGun = _kalanGun(dogum);
    final bugun = kalanGun == 0;
    final yas = DogumGunu.yasGetir(dogum.dogumTarihi);
    final signId = DogumGunu.burcIdGetir(dogum.dogumTarihi);
    final localeCode = Get.locale?.languageCode ?? 'en';
    final translations =
        Tercumeler().keys[localeCode] ?? en; // fallback to en for safety
    final burc = tZodiac(signId, 'name', translations);

    // Kart içeriği ekran okuyucuda tek öğe olarak okunur; menü ayrı kalır.
    return Material(
      color: r.s1,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: r.e1,
          color: r.s1,
          border: Border.all(
            color: bugun
                ? scheme.primary.withValues(alpha: 0.55)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.only(right: 2),
        child: Row(
          crossAxisAlignment: doldur
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: MergeSemantics(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  onTap: () => Get.to(() => Tavsiye(dogumGunu: dogum)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'zodiac-${dogum.id}',
                          child: BurcRozeti(burcId: signId, boyut: 48),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dogum.isim,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 22 / 16,
                                  color: r.tx,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.cake_rounded,
                                    size: 16,
                                    color: r.tx3,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      DogumGunu.tarihYazdir(dogum.dogumTarihi),
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 18 / 13,
                                        color: r.tx2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (yas > 0)
                                    _etiket(
                                      trSayi('home.age', yas, {'age': '$yas'}),
                                    ),
                                  _etiket(burc),
                                  _etiket(
                                    'home.card.ideas'.tr,
                                    ikon: Icons.redeem_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          // Uzun dillerde/büyük yazıda isim alanını ezmesin; sığmazsa küçülür.
                          constraints: const BoxConstraints(
                            minWidth: 60,
                            maxWidth: 96,
                            minHeight: 46,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bugun
                                ? scheme.primary
                                : scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  bugun
                                      ? 'home.countdown.today'.tr
                                      : trSayi(
                                          'home.countdown.days',
                                          kalanGun,
                                          {'days': '$kalanGun'},
                                        ),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 15,
                                        height: 1.15,
                                        color: bugun
                                            ? scheme.onPrimary
                                            : scheme.onPrimaryContainer,
                                      ),
                                ),
                                if (!bugun)
                                  Text(
                                    'home.countdown.left'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      height: 1.2,
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _menuButonu(dogum),
          ],
        ),
      ),
    );
  }

  Widget _menuButonu(DogumGunu dogum) {
    final r = context.renk;
    return SizedBox(
      width: 48,
      height: 48,
      child: PopupMenuButton<String>(
        tooltip: 'home.menu.more'.tr,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert_rounded, size: 22, color: r.tx2),
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(minWidth: 196),
        onSelected: (value) {
          if (value == 'edit') {
            Get.to(() => DogumGunuEkle(duzenlenecek: dogum));
          }
          if (value == 'delete') _kisiSil(dogum);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            height: 48,
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 22, color: r.tx2),
                const SizedBox(width: 14),
                Text(
                  'home.menu.edit'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: r.tx,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 9),
          PopupMenuItem(
            value: 'delete',
            height: 48,
            child: Row(
              children: [
                Icon(Icons.delete_rounded, size: 22, color: r.err),
                const SizedBox(width: 14),
                Text(
                  'home.menu.delete'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: r.err,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiket(String yazi, {IconData? ikon}) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final vurgulu = ikon != null;
    final renk = vurgulu ? scheme.onPrimaryContainer : r.tx2;
    return Container(
      constraints: const BoxConstraints(minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: vurgulu ? scheme.primaryContainer : r.s2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 14, color: renk),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              yazi,
              style: TextStyle(
                color: renk,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _kalanGun(DogumGunu dogum) => DogumGunu.kalanGun(dogum.dogumTarihi);

  int _yaklasanSayisi() {
    return dogumGunuVeriYonetim.dogumGunuListe
        .where((e) => _kalanGun(e) <= 7)
        .length;
  }

  Future<void> _kisiSil(DogumGunu dogum) async {
    final onay = await silmeOnayiIste(context, dogum.isim);
    if (!onay) return;

    await DogumGunuVeriTabani.veriSil(dogum.id);
    await _verileriCek();
    OzelSnackbar.basari(
      baslik: 'home.delete.done.title'.tr,
      mesaj: 'home.delete.done.msg'.trParams({'name': dogum.isim}),
    );
  }
}

class _YeniKisiButonu extends StatelessWidget {
  const _YeniKisiButonu({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [r.g1, r.g2]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: r.e3,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 22,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 24, color: r.onGradyan),
                const SizedBox(width: 10),
                Text(
                  'home.button.newPerson'.tr,
                  style: TextStyle(
                    color: r.onGradyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İskelet kartlar için yumuşak opaklık nabzı.
class _Nabiz extends StatefulWidget {
  const _Nabiz({required this.child, required this.gecikme});

  final Widget child;
  final Duration gecikme;

  @override
  State<_Nabiz> createState() => _NabizState();
}

class _NabizState extends State<_Nabiz> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Timer? _baslat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hareket azaltma açıksa nabız durur, kart sabit görünür.
    if (MediaQuery.of(context).disableAnimations) {
      _baslat?.cancel();
      _ctrl.stop();
      _ctrl.value = 0;
    } else if (!_ctrl.isAnimating && !(_baslat?.isActive ?? false)) {
      _baslat = Timer(widget.gecikme, () {
        if (mounted) _ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _baslat?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 1.0,
        end: 0.45,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
