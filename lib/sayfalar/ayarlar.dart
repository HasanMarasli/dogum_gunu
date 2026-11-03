import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tema/renkler.dart';
import '../tercumeler/tercumeler.dart';
import '../tema/tema_yoneticisi.dart';
import '../widgets/bildirim_uyarisi.dart';
import '../widgets/ozel_snackbar.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> with WidgetsBindingObserver {
  static const String _gizlilikAdresi =
      'https://muhammethasanmarasli.com/gizlilik-politikasi/dogumGunu';
  static const String _iletisimAdresi = 'mailto:m.hasan.marasli@gmail.com';

  bool _izinVar = true;
  final Future<PackageInfo> _uygulamaBilgisi = PackageInfo.fromPlatform();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _izinKontrol();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final current = Get.locale ?? Get.deviceLocale ?? const Locale('tr');
    final tema = Get.find<TemaYoneticisi>();
    final bildirimAyar = Get.find<BildirimAyarlarYoneticisi>();

    return Scaffold(
      backgroundColor: r.bg,
      appBar: AppBar(
        backgroundColor: r.bg,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('settings.title'.tr),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _grup(
              baslik: 'settings.notifications.title'.tr,
              children: [
                if (!_izinVar)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                    child: BildirimUyarisi(
                      baslik: 'home.notifOff.title'.tr,
                      mesaj: 'settings.notifOff.desc'.tr,
                      eylem: 'home.notifOff.action'.tr,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                  child: Text(
                    'settings.notifications.subtitle'.tr,
                    style:
                        TextStyle(fontSize: 14, height: 20 / 14, color: r.tx2),
                  ),
                ),
                Obx(() {
                  final secili = bildirimAyar.seciliGunler;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final gun in BildirimAyarlarYoneticisi.tumSecenekler)
                        _secimSatiri(
                          yazi: _gunMetni(gun),
                          secili: secili.contains(gun),
                          onTap: () => _gunSecimiDegistir(bildirimAyar, gun),
                        ),
                      if (secili.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                          child: Text(
                            'settings.notifications.allOff'.tr,
                            style: TextStyle(
                                fontSize: 14, height: 20 / 14, color: r.err),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            _grup(
              baslik: 'settings.selectLanguage'.tr,
              children: [
                for (final entry in Tercumeler.diller.entries)
                  _dilSatiri(
                    kod: entry.value.languageCode.toUpperCase(),
                    ad: entry.key,
                    secili: entry.value.languageCode == current.languageCode,
                    onTap: () => _dilDegistir(entry.value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _grup(
              baslik: 'settings.appearance'.tr,
              children: [
                _koyuModSatiri(tema),
              ],
            ),
            const SizedBox(height: 20),
            _grup(
              baslik: 'settings.selectTheme'.tr,
              altBosluk: 12,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (final satir in [
                        tema.palettes.keys.take(3).toList(),
                        tema.palettes.keys.skip(3).toList(),
                      ]) ...[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < satir.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(child: _paletKarosu(tema, satir[i])),
                              ],
                            ],
                          ),
                        ),
                        if (satir.first == tema.palettes.keys.first)
                          const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _grup(
              baslik: 'settings.about.title'.tr,
              children: [
                _baglantiSatiri(
                  ikon: Icons.privacy_tip_rounded,
                  yazi: 'settings.about.privacy'.tr,
                  adres: _gizlilikAdresi,
                ),
                _baglantiSatiri(
                  ikon: Icons.mail_rounded,
                  yazi: 'settings.about.contact'.tr,
                  adres: _iletisimAdresi,
                ),
                FutureBuilder<PackageInfo>(
                  future: _uygulamaBilgisi,
                  builder: (context, bilgi) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Text(
                      'settings.about.version'
                          .trParams({'version': bilgi.data?.version ?? ''}),
                      style: TextStyle(fontSize: 14, color: r.tx2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _grup({
    required String baslik,
    required List<Widget> children,
    double altBosluk = 6,
  }) {
    final r = context.renk;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.only(bottom: altBosluk),
      decoration: BoxDecoration(
        color: r.s1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: r.e1,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                baslik,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: r.tx2,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _baglantiAc(String adres) async {
    var acildi = false;
    try {
      acildi = await launchUrl(Uri.parse(adres),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      acildi = false;
    }
    if (!acildi) {
      OzelSnackbar.uyari(
        baslik: 'settings.about.error.title'.tr,
        mesaj: 'settings.about.error.msg'.tr,
      );
    }
  }

  Widget _baglantiSatiri({
    required IconData ikon,
    required String yazi,
    required String adres,
  }) {
    final r = context.renk;
    return InkWell(
      onTap: () => _baglantiAc(adres),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(ikon, size: 24, color: r.tx2),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  yazi,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: r.tx,
                  ),
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 20, color: r.tx3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _geccerliRozeti() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          'settings.current'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _dilSatiri({
    required String kod,
    required String ad,
    required bool secili,
    required VoidCallback onTap,
  }) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: secili,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: r.s2,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      kod,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: r.tx2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    ad,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: r.tx,
                    ),
                  ),
                ),
                if (secili) ...[
                  _geccerliRozeti(),
                  const SizedBox(width: 14),
                  Icon(Icons.check_circle_rounded,
                      size: 22, color: scheme.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _koyuModSatiri(TemaYoneticisi tema) {
    final r = context.renk;
    return InkWell(
      onTap: () => tema.setKoyuMod(!tema.koyuMod),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.dark_mode_rounded, size: 24, color: r.tx2),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'settings.darkMode'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: r.tx,
                  ),
                ),
              ),
              Switch(
                value: tema.koyuMod,
                onChanged: tema.setKoyuMod,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paletKarosu(TemaYoneticisi tema, String key) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final palet = paletler[key]!;
    final tonlar = palet.tonlar(Theme.of(context).brightness);
    final secili = tema.currentKey == key;

    return Semantics(
      selected: secili,
      button: true,
      label: 'theme.$key'.tr,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: secili ? scheme.primary : r.bd,
            width: secili ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => tema.setTheme(key),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [tonlar.g1, tonlar.g2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: secili
                      ? const Icon(Icons.check_rounded,
                          size: 22, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  'theme.$key'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 16 / 13,
                    color: r.tx,
                  ),
                ),
                if (secili) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(minHeight: 22),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Text(
                        'settings.current'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _secimSatiri({
    required String yazi,
    required bool secili,
    required VoidCallback onTap,
  }) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      checked: secili,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: secili ? scheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: secili ? scheme.primary : r.bd2,
                      width: 2,
                    ),
                  ),
                  child: secili
                      ? Icon(Icons.check_rounded,
                          size: 16, color: scheme.onPrimary)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    yazi,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 22 / 16,
                      color: r.tx,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _dilDegistir(Locale locale) async {
    Get.find<DilSecimiController>().dilDegistir(locale.toString());
    // Planlı bildirim metinleri yeni dilde yeniden oluşturulsun.
    await DogumGunuVeriTabani.tumBildirimleriYenidenPlanla();
  }

  String _gunMetni(int gun) {
    switch (gun) {
      case 7:
        return 'settings.notifications.option.7'.tr;
      case 2:
        return 'settings.notifications.option.2'.tr;
      case 1:
        return 'settings.notifications.option.1'.tr;
      case 0:
        return 'settings.notifications.option.0'.tr;
      default:
        return 'settings.notifications.option.dynamic'
            .trParams({'days': gun.toString()});
    }
  }

  Future<void> _gunSecimiDegistir(
      BildirimAyarlarYoneticisi controller, int gun) async {
    controller.toggleGun(gun);
    await DogumGunuVeriTabani.tumBildirimleriYenidenPlanla();
  }
}
