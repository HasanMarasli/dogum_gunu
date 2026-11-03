import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../tema/renkler.dart';
import 'burc_rozeti.dart';

/// Doğum tarihi seçici (alt sayfa). Onaylanırsa seçilen tarihi döner.
Future<DateTime?> dogumTarihiSec(BuildContext context, {DateTime? baslangic}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    barrierColor: context.renk.scrim,
    builder: (_) => _TarihSecici(baslangic: baslangic),
  );
}

class _TarihSecici extends StatefulWidget {
  const _TarihSecici({this.baslangic});

  final DateTime? baslangic;

  @override
  State<_TarihSecici> createState() => _TarihSeciciState();
}

class _TarihSeciciState extends State<_TarihSecici> {
  static const int _minYil = 1900;
  static const double _yilSatir = 52;

  late final DateTime _bugun;
  // Yeni kişide seçim boş başlar; bir gün seçilmeden Tamam pasiftir.
  DateTime? _secili;
  late int _gorunenYil;
  late int _gorunenAy;
  bool _yillar = false;
  bool _aylar = false;
  late int _onYil;

  final ScrollController _yilKaydirma = ScrollController();
  final ScrollController _seritKaydirma = ScrollController();

  String get _dil => Get.locale?.languageCode ?? 'tr';

  @override
  void initState() {
    super.initState();
    final simdi = DateTime.now();
    _bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final b = widget.baslangic;
    _secili = b == null ? null : DateTime(b.year, b.month, b.day);
    final acilis = _secili ?? _bugun;
    _gorunenYil = acilis.year;
    _gorunenAy = acilis.month;
    _onYil = _onYilOf(acilis.year);
    _yilKaydirma.addListener(_yilKaydirildi);
    // Yeni kişide sıra yıl → ay → gün; böylece geçmiş tarihe hızlı varılır.
    if (b == null) {
      _yillar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _yilaKaydir(_gorunenYil, ortala: true);
        _seridiOrtala(_onYil, animasyon: false);
      });
    }
  }

  @override
  void dispose() {
    _yilKaydirma.dispose();
    _seritKaydirma.dispose();
    super.dispose();
  }

  int _onYilOf(int yil) => (yil ~/ 10) * 10;

  int get _maxYil => _bugun.year;

  bool _gelecekMi(DateTime t) => t.isAfter(_bugun);

  void _ayKaydir(int n) {
    var ay = _gorunenAy + n;
    var yil = _gorunenYil;
    if (ay < 1) {
      ay = 12;
      yil--;
    } else if (ay > 12) {
      ay = 1;
      yil++;
    }
    if (yil < _minYil || DateTime(yil, ay).isAfter(_bugun)) return;
    setState(() {
      _gorunenAy = ay;
      _gorunenYil = yil;
    });
  }

  void _yilGorunumuAc() {
    setState(() {
      _yillar = !_yillar;
      _aylar = false;
      _onYil = _onYilOf(_gorunenYil);
    });
    if (_yillar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _yilaKaydir(_gorunenYil, ortala: true);
        _seridiOrtala(_onYil, animasyon: false);
      });
    }
  }

  // Her on yıl tam iki satırdır (5 sütun).
  double _yilOfseti(int yil) => ((yil - _minYil) ~/ 5) * _yilSatir;

  void _yilaKaydir(int yil, {bool ortala = false, bool animasyon = false}) {
    if (!_yilKaydirma.hasClients) return;
    final pos = _yilKaydirma.position;
    var hedef = _yilOfseti(yil);
    if (ortala) hedef -= pos.viewportDimension / 2 - _yilSatir / 2;
    hedef = hedef.clamp(0.0, pos.maxScrollExtent);
    if (animasyon) {
      _yilKaydirma.animateTo(hedef,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _yilKaydirma.jumpTo(hedef);
    }
  }

  void _seridiOrtala(int onYil, {bool animasyon = true}) {
    if (!_seritKaydirma.hasClients) return;
    const genislik = 84.0;
    final i = (onYil - _minYil) ~/ 10;
    final pos = _seritKaydirma.position;
    final hedef = (i * genislik - pos.viewportDimension / 2 + genislik / 2)
        .clamp(0.0, pos.maxScrollExtent);
    if (animasyon) {
      _seritKaydirma.animateTo(hedef,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _seritKaydirma.jumpTo(hedef);
    }
  }

  void _yilKaydirildi() {
    final pos = _yilKaydirma.position;
    final satir = ((pos.pixels + pos.viewportDimension / 4) ~/ _yilSatir);
    var onYil = _onYilOf(_minYil + satir * 5).clamp(_minYil, _maxYil);
    // Liste uçlara dayandığında şerit ilk/son on yılı göstersin.
    if (pos.pixels >= pos.maxScrollExtent - 1) onYil = _onYilOf(_maxYil);
    if (pos.pixels <= 0) onYil = _minYil;
    if (onYil != _onYil) {
      setState(() => _onYil = onYil);
      _seridiOrtala(onYil);
    }
  }

  String _onYilEtiketi(int yil) {
    if (_dil != 'tr') return '${yil}s';
    const ekler = [
      'ler',
      'lar',
      'ler',
      'lar',
      'lar',
      'ler',
      'lar',
      'ler',
      'ler',
      'lar'
    ];
    return "$yil'${ekler[(yil ~/ 10) % 10]}";
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;
    final secili = _secili;
    final burcId = secili == null ? null : DogumGunu.burcIdGetir(secili);
    final burc = burcId == null
        ? ''
        : tZodiac(burcId, 'name', Tercumeler().keys[_dil] ?? tr);
    final gunAdi = secili == null
        ? ''
        : toBeginningOfSentenceCase(DateFormat('EEEE', _dil).format(secili));

    final ilkAyda = _gorunenYil == _minYil && _gorunenAy == 1;
    final sonAyda = _gorunenYil == _bugun.year && _gorunenAy == _bugun.month;

    return Container(
      decoration: BoxDecoration(
        color: r.raised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: r.bd2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: r.bd)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'picker.title'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: r.tx2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secili == null
                              ? 'picker.empty'.tr
                              : DogumGunu.tarihYazdir(secili),
                          style: metin.headlineMedium?.copyWith(
                            color: secili == null ? r.tx3 : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secili == null ? 'picker.hint'.tr : '$gunAdi · $burc',
                          style: metin.bodyMedium?.copyWith(color: r.tx2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  burcId == null
                      ? Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: r.s2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child:
                              Icon(Icons.cake_rounded, size: 28, color: r.tx3),
                        )
                      : BurcRozeti(burcId: burcId, boyut: 56),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  TextButton(
                    onPressed: _yilGorunumuAc,
                    style: TextButton.styleFrom(
                      backgroundColor: _yillar ? scheme.primaryContainer : r.s2,
                      foregroundColor:
                          _yillar ? scheme.onPrimaryContainer : r.tx,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.only(left: 12, right: 6),
                      textStyle: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_yillar || _aylar
                            ? '$_gorunenYil'
                            : toBeginningOfSentenceCase(DateFormat(
                                    'MMMM y', _dil)
                                .format(DateTime(_gorunenYil, _gorunenAy)))),
                        Icon(
                          _yillar
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!_yillar && !_aylar) ...[
                    IconButton(
                      tooltip: 'picker.prevMonth'.tr,
                      onPressed: ilkAyda ? null : () => _ayKaydir(-1),
                      color: r.tx2,
                      disabledColor: r.bd2,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    IconButton(
                      tooltip: 'picker.nextMonth'.tr,
                      onPressed: sonAyda ? null : () => _ayKaydir(1),
                      color: r.tx2,
                      disabledColor: r.bd2,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: 308,
              child: _yillar
                  ? _yilGorunumu(r, scheme)
                  : _aylar
                      ? _ayGorunumu(r, scheme)
                      : _gunGorunumu(r, scheme),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: r.bd2, width: 1.5),
                      foregroundColor: scheme.primary,
                      textStyle: metin.labelLarge,
                    ),
                    child: Text('picker.cancel'.tr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: secili == null
                        ? null
                        : () => Navigator.of(context).pop(secili),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text('picker.ok'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ayGorunumu(AppRenkler r, ColorScheme scheme) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 66,
        mainAxisSpacing: 8,
        crossAxisSpacing: 6,
      ),
      itemCount: 12,
      itemBuilder: (context, i) {
        final ay = i + 1;
        final tarih = DateTime(_gorunenYil, ay);
        final gelecek = tarih.isAfter(_bugun);
        final secili = _secili?.year == _gorunenYil && _secili?.month == ay;
        final gorunen = ay == _gorunenAy && !secili;
        return Material(
          color: secili
              ? scheme.primary
              : gorunen
                  ? scheme.primaryContainer
                  : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: gelecek
                ? null
                : () => setState(() {
                      _gorunenAy = ay;
                      _aylar = false;
                    }),
            child: Center(
              child: Text(
                toBeginningOfSentenceCase(
                    DateFormat('MMMM', _dil).format(tarih)),
                style: TextStyle(
                  fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                  color: secili
                      ? scheme.onPrimary
                      : gelecek
                          ? r.bd2
                          : gorunen
                              ? scheme.onPrimaryContainer
                              : r.tx,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _gunGorunumu(AppRenkler r, ColorScheme scheme) {
    // Pazartesi ile başlayan hafta, sabit 6 satır.
    final ilkGun = DateTime(_gorunenYil, _gorunenAy, 1);
    final bosluk = (ilkGun.weekday + 6) % 7;
    final gunSayisi = DateTime(_gorunenYil, _gorunenAy + 1, 0).day;
    final haftaGunleri = List.generate(
      7,
      (i) => DateFormat('E', _dil).format(DateTime(2024, 1, 1 + i)),
    );

    return Column(
      children: [
        Row(
          children: [
            for (final g in haftaGunleri)
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: Center(
                    child: Text(
                      g,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: r.tx3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 46,
            ),
            itemCount: 42,
            itemBuilder: (context, i) {
              final gun = i - bosluk + 1;
              if (gun < 1 || gun > gunSayisi) return const SizedBox.shrink();
              final tarih = DateTime(_gorunenYil, _gorunenAy, gun);
              final secili = tarih == _secili;
              final bugun = tarih == _bugun;
              final gelecek = _gelecekMi(tarih);
              return Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: secili ? scheme.primary : Colors.transparent,
                    shape: CircleBorder(
                      side: bugun && !secili
                          ? BorderSide(color: scheme.primary, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: gelecek
                          ? null
                          : () => setState(() => _secili = tarih),
                      child: Center(
                        child: Text(
                          '$gun',
                          style: TextStyle(
                            fontWeight:
                                secili ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                            color: secili
                                ? scheme.onPrimary
                                : gelecek
                                    ? r.bd2
                                    : bugun
                                        ? scheme.primary
                                        : r.tx,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _yilGorunumu(AppRenkler r, ColorScheme scheme) {
    final onYillar = [
      for (var y = _minYil; y <= _maxYil; y += 10) y,
    ];
    final yilSayisi = _maxYil - _minYil + 1;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            controller: _seritKaydirma,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 10, top: 2),
            itemCount: onYillar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final y = onYillar[i];
              final aktif = y == _onYil;
              return SizedBox(
                width: 76,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _onYil = y);
                    _yilaKaydir(y, animasyon: true);
                    _seridiOrtala(y);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(
                      color: aktif ? Colors.transparent : r.bd2,
                    ),
                    backgroundColor:
                        aktif ? scheme.primaryContainer : Colors.transparent,
                    foregroundColor: aktif ? scheme.onPrimaryContainer : r.tx2,
                    textStyle: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  child: Text(_onYilEtiketi(y)),
                ),
              );
            },
          ),
        ),
        Divider(color: r.bd),
        Expanded(
          child: GridView.builder(
            controller: _yilKaydirma,
            padding: const EdgeInsets.symmetric(vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisExtent: 44,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
            ),
            itemCount: yilSayisi,
            itemBuilder: (context, i) {
              final y = _minYil + i;
              final secili = y == _secili?.year;
              final gorunen = y == _gorunenYil && !secili;
              final buYil = y == _bugun.year;
              return Material(
                color: secili
                    ? scheme.primary
                    : gorunen
                        ? scheme.primaryContainer
                        : Colors.transparent,
                shape: StadiumBorder(
                  side: buYil && !secili
                      ? BorderSide(color: scheme.primary, width: 1.5)
                      : BorderSide.none,
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => setState(() {
                    _gorunenYil = y;
                    if (DateTime(y, _gorunenAy).isAfter(_bugun)) {
                      _gorunenAy = _bugun.month;
                    }
                    _yillar = false;
                    _aylar = true;
                  }),
                  child: Center(
                    child: Text(
                      '$y',
                      style: TextStyle(
                        fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 16,
                        color: secili
                            ? scheme.onPrimary
                            : gorunen
                                ? scheme.onPrimaryContainer
                                : buYil
                                    ? scheme.primary
                                    : r.tx,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
