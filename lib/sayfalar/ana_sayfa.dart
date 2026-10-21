import 'dart:async';

import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/sayfalar/dogum_gunu_ekle.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:dogum_gunu/sayfalar/ayarlar.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';

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
  bool _izinVar = true;
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
    _verileriCek();
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
    if (state == AppLifecycleState.resumed) _izinKontrol();
  }

  Future<void> _izinKontrol() async {
    final izin = await BildirimYoneticisi().izinVarMi();
    if (mounted && izin != _izinVar) setState(() => _izinVar = izin);
  }

  Future<void> _verileriCek() async {
    dogumGunuVeriYonetim.dogumGunuListe.value =
        await DogumGunuVeriTabani.tumVerileriGetir();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final metin = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: r.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
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
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Obx(() {
                final liste = dogumGunuVeriYonetim.dogumGunuListe;
                final yaklasan = _yaklasanSayisi();
                return Row(
                  children: [
                    Expanded(
                      child: _istatistikKart(
                        baslik: 'home.stats.total'.tr,
                        deger: liste.length,
                        altYazi: 'home.stats.total.suffix'.tr,
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
            Expanded(
              child: isLoading
                  ? (_iskeletGoster ? _iskelet() : const SizedBox.shrink())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _verileriCek();
                        await _izinKontrol();
                      },
                      child: Obx(
                        () {
                          final liste = [
                            ...dogumGunuVeriYonetim.dogumGunuListe
                          ];
                          liste.sort(
                              (a, b) => _kalanGun(a).compareTo(_kalanGun(b)));

                          final banner = !_izinVar;
                          if (liste.isEmpty && !banner) return _bosDurum();

                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20, 12, 20,
                                104 + MediaQuery.of(context).padding.bottom),
                            itemCount: liste.length + (banner ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (banner && index == 0) {
                                return BildirimUyarisi(
                                  baslik: 'home.notifOff.title'.tr,
                                  mesaj: 'home.notifOff.desc'.tr,
                                  eylem: 'home.notifOff.action'.tr,
                                );
                              }
                              return _dogumKart(
                                  liste[index - (banner ? 1 : 0)]);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _YeniKisiButonu(
        onPressed: () => Get.to(() => const DogumGunuEkle()),
      ),
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
    final ikincil =
        vurgulu ? scheme.onPrimaryContainer.withValues(alpha: 0.85) : r.tx2;
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
                fontWeight: FontWeight.w600, fontSize: 13, color: ikincil),
          ),
          const SizedBox(height: 2),
          isLoading
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13, color: ikincil),
          ),
        ],
      ),
    );
  }

  Widget _iskelet() {
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
    return Semantics(
      label: 'home.loading'.tr,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: genislikler.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _Nabiz(
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
                        Row(children: [
                          blok(44, 20, 8),
                          const SizedBox(width: 6),
                          blok(44, 20, 8),
                        ]),
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
      ),
    );
  }

  Widget _bosDurum() {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(Icons.cake_rounded,
                      size: 44, color: scheme.onPrimaryContainer),
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
        ),
      ),
    );
  }

  Widget _dogumKart(DogumGunu dogum) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final kalanGun = _kalanGun(dogum);
    final bugun = kalanGun == 0;
    final yas = DateTime.now().year - dogum.dogumTarihi.year;
    final signId = DogumGunu.burcIdGetir(dogum.dogumTarihi);
    final localeCode = Get.locale?.languageCode ?? 'tr';
    final translations =
        Tercumeler().keys[localeCode] ?? tr; // fallback to tr for safety
    final burc = tZodiac(signId, 'name', translations);

    return Material(
      color: r.s1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.to(() => Tavsiye(dogumGunu: dogum)),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: r.e1,
            color: r.s1,
            border: Border.all(
              color: bugun ? r.suc.withValues(alpha: 0.55) : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 2, 12),
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
                        Icon(Icons.cake_rounded, size: 16, color: r.tx3),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            DogumGunu.tarihYazdir(dogum.dogumTarihi),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13, height: 18 / 13, color: r.tx2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _etiket('home.age'.trParams({'age': yas.toString()})),
                        _etiket(burc),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: bugun ? r.suc : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bugun
                          ? 'home.countdown.today'.tr
                          : 'home.countdown.days'
                              .trParams({'days': kalanGun.toString()}),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                            height: 1.15,
                            color: bugun ? r.onSuc : scheme.onPrimaryContainer,
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
              _menuButonu(dogum),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButonu(DogumGunu dogum) {
    final r = context.renk;
    return SizedBox(
      width: 36,
      height: 44,
      child: PopupMenuButton<String>(
        tooltip: 'home.menu.more'.tr,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert_rounded, size: 22, color: r.tx2),
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(minWidth: 196),
        onSelected: (value) {
          if (value == 'delete') _kisiSil(dogum);
        },
        itemBuilder: (context) => [
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

  Widget _etiket(String yazi) {
    final r = context.renk;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: r.s2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          yazi,
          style: TextStyle(
            color: r.tx2,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// 29 Şubat doğumlular artık olmayan yıllarda 28 Şubat'ta kutlanır.
  DateTime _buYilkiDogumGunu(DateTime dogum, int yil) {
    if (dogum.month == 2 && dogum.day == 29) {
      final artik = (yil % 4 == 0 && yil % 100 != 0) || yil % 400 == 0;
      return DateTime(yil, 2, artik ? 29 : 28);
    }
    return DateTime(yil, dogum.month, dogum.day);
  }

  int _kalanGun(DogumGunu dogum) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    var sonrakiDogum = _buYilkiDogumGunu(dogum.dogumTarihi, bugun.year);
    if (sonrakiDogum.isBefore(bugun)) {
      sonrakiDogum = _buYilkiDogumGunu(dogum.dogumTarihi, bugun.year + 1);
    }
    // Yaz saati geçişlerinde saat farkı gün hesabını bozmasın.
    return (sonrakiDogum.difference(bugun).inHours / 24).round();
  }

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
      height: 56,
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
            padding: const EdgeInsets.only(left: 18, right: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 24, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'home.button.newPerson'.tr,
                  style: const TextStyle(
                    color: Colors.white,
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
  void initState() {
    super.initState();
    _baslat = Timer(widget.gecikme, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
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
      opacity: Tween(begin: 1.0, end: 0.45)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
