import 'package:flutter/material.dart';

/// Bir paletin tek moddaki (açık/koyu) vurgu renkleri.
class PaletTonlari {
  const PaletTonlari({
    required this.pr,
    required this.onPr,
    required this.pc,
    required this.onPc,
    required this.g1,
    required this.g2,
  });

  final Color pr;
  final Color onPr;
  final Color pc;
  final Color onPc;
  final Color g1;
  final Color g2;
}

class Palet {
  const Palet({
    required this.seed,
    required this.acik,
    required this.koyu,
  });

  final Color seed;
  final PaletTonlari acik;
  final PaletTonlari koyu;

  PaletTonlari tonlar(Brightness parlaklik) =>
      parlaklik == Brightness.dark ? koyu : acik;
}

/// Ayarlar'da seçilebilen 6 palet. Anahtarlar kayıtlı tercihlerle uyumludur.
const Map<String, Palet> paletler = {
  'purple': Palet(
    seed: Color(0xFF5B55F6),
    acik: PaletTonlari(
      pr: Color(0xFF5B55F6),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFE4E2FF),
      onPc: Color(0xFF1E1878),
      g1: Color(0xFF5B55F6),
      g2: Color(0xFF8E4FE6),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFC4C1FF),
      onPr: Color(0xFF26208F),
      pc: Color(0xFF3B35B8),
      onPc: Color(0xFFE4E2FF),
      g1: Color(0xFF4A44D6),
      g2: Color(0xFF7440C4),
    ),
  ),
  'teal': Palet(
    seed: Color(0xFF11998E),
    acik: PaletTonlari(
      pr: Color(0xFF0B7A71),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFC6EFE9),
      onPc: Color(0xFF00302B),
      g1: Color(0xFF0B7A71),
      g2: Color(0xFF0A8372),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFF6ED8CB),
      onPr: Color(0xFF00382F),
      pc: Color(0xFF00524A),
      onPc: Color(0xFFC6EFE9),
      g1: Color(0xFF0A6A62),
      g2: Color(0xFF0D7F6C),
    ),
  ),
  'orange': Palet(
    seed: Color(0xFFFB8C00),
    acik: PaletTonlari(
      pr: Color(0xFFA65300),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFFFE0C2),
      onPc: Color(0xFF371B00),
      g1: Color(0xFFB95900),
      g2: Color(0xFFD14329),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFFFB870),
      onPr: Color(0xFF4A2800),
      pc: Color(0xFF6E3C00),
      onPc: Color(0xFFFFE0C2),
      g1: Color(0xFFB35800),
      g2: Color(0xFFB83A22),
    ),
  ),
  'blue': Palet(
    seed: Color(0xFF2962FF),
    acik: PaletTonlari(
      pr: Color(0xFF2962FF),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFDCE3FF),
      onPc: Color(0xFF00195E),
      g1: Color(0xFF2962FF),
      g2: Color(0xFF4F46E5),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFB4C5FF),
      onPr: Color(0xFF002B85),
      pc: Color(0xFF1D45BF),
      onPc: Color(0xFFDCE3FF),
      g1: Color(0xFF1F4FE0),
      g2: Color(0xFF3E37C2),
    ),
  ),
  'coral': Palet(
    seed: Color(0xFFFF5C8D),
    acik: PaletTonlari(
      pr: Color(0xFFC2305C),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFFFD9E2),
      onPc: Color(0xFF3F0019),
      g1: Color(0xFFD13B67),
      g2: Color(0xFFC25037),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFFFB1C4),
      onPr: Color(0xFF5E1130),
      pc: Color(0xFF8A1F45),
      onPc: Color(0xFFFFD9E2),
      g1: Color(0xFFB8335C),
      g2: Color(0xFFB84D33),
    ),
  ),
  'lime': Palet(
    seed: Color(0xFF6FBF73),
    acik: PaletTonlari(
      pr: Color(0xFF2E7D32),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFD3F1D2),
      onPc: Color(0xFF06300B),
      g1: Color(0xFF38843C),
      g2: Color(0xFF4C822F),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFF8FD993),
      onPr: Color(0xFF0A3910),
      pc: Color(0xFF1F5A24),
      onPc: Color(0xFFD3F1D2),
      g1: Color(0xFF2C6E30),
      g2: Color(0xFF4A7E2C),
    ),
  ),
};

/// Palete göre değişmeyen nötr ve semantik renkler ile palet gradyanı.
/// `context.renk` ile erişilir.
class AppRenkler extends ThemeExtension<AppRenkler> {
  const AppRenkler({
    required this.g1,
    required this.g2,
    required this.bg,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.raised,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.bd,
    required this.bd2,
    required this.scrim,
    required this.e1,
    required this.e2,
    required this.e3,
    required this.suc,
    required this.onSuc,
    required this.succ,
    required this.onSucc,
    required this.err,
    required this.onErr,
    required this.errc,
    required this.onErrc,
    required this.warn,
    required this.onWarn,
    required this.warnc,
    required this.onWarnc,
    required this.info,
    required this.infoc,
    required this.onInfoc,
  });

  final Color g1;
  final Color g2;
  final Color bg;
  final Color s1;
  final Color s2;
  final Color s3;
  final Color raised;
  final Color tx;
  final Color tx2;
  final Color tx3;
  final Color bd;
  final Color bd2;
  final Color scrim;
  final List<BoxShadow> e1;
  final List<BoxShadow> e2;
  final List<BoxShadow> e3;
  final Color suc;
  final Color onSuc;
  final Color succ;
  final Color onSucc;
  final Color err;
  final Color onErr;
  final Color errc;
  final Color onErrc;
  final Color warn;
  final Color onWarn;
  final Color warnc;
  final Color onWarnc;
  final Color info;
  final Color infoc;
  final Color onInfoc;

  LinearGradient get gradyan => LinearGradient(
        colors: [g1, g2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static AppRenkler olustur(PaletTonlari p, Brightness parlaklik) {
    if (parlaklik == Brightness.dark) {
      return AppRenkler(
        g1: p.g1,
        g2: p.g2,
        bg: const Color(0xFF131010),
        s1: const Color(0xFF1C1817),
        s2: const Color(0xFF252120),
        s3: const Color(0xFF302A28),
        raised: const Color(0xFF2A2523),
        tx: const Color(0xFFF3EEE9),
        tx2: const Color(0xFFB8AEA6),
        tx3: const Color(0xFF968C84),
        bd: const Color(0xFF35302D),
        bd2: const Color(0xFF4D4541),
        scrim: const Color(0x99000000),
        e1: const [
          BoxShadow(
              color: Color(0x59000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
        e2: const [
          BoxShadow(
              color: Color(0x73000000), blurRadius: 16, offset: Offset(0, 6)),
          BoxShadow(
              color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
        e3: const [
          BoxShadow(
              color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 16)),
          BoxShadow(
              color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
        suc: const Color(0xFF6FD39B),
        onSuc: const Color(0xFF0B2E1C),
        succ: const Color(0xFF12382A),
        onSucc: const Color(0xFFC9F2D9),
        err: const Color(0xFFFF8F86),
        onErr: const Color(0xFF5C0F0F),
        errc: const Color(0xFF4D1614),
        onErrc: const Color(0xFFFFDAD6),
        warn: const Color(0xFFFFC46B),
        onWarn: const Color(0xFF3F2B07),
        warnc: const Color(0xFF3F2B07),
        onWarnc: const Color(0xFFFFE8C2),
        info: const Color(0xFF93C1FF),
        infoc: const Color(0xFF12294A),
        onInfoc: const Color(0xFFD6E6FF),
      );
    }
    return AppRenkler(
      g1: p.g1,
      g2: p.g2,
      bg: const Color(0xFFFAF7F4),
      s1: const Color(0xFFFFFFFF),
      s2: const Color(0xFFF4EFEA),
      s3: const Color(0xFFEAE3DC),
      raised: const Color(0xFFFFFFFF),
      tx: const Color(0xFF1E1916),
      tx2: const Color(0xFF5F5650),
      tx3: const Color(0xFF796E65),
      bd: const Color(0xFFE8E1DA),
      bd2: const Color(0xFFCFC5BC),
      scrim: const Color(0x6B140E0A),
      e1: const [
        BoxShadow(
            color: Color(0x0F301E12), blurRadius: 2, offset: Offset(0, 1)),
        BoxShadow(
            color: Color(0x0D301E12), blurRadius: 3, offset: Offset(0, 1)),
      ],
      e2: const [
        BoxShadow(
            color: Color(0x17301E12), blurRadius: 16, offset: Offset(0, 6)),
        BoxShadow(
            color: Color(0x0F301E12), blurRadius: 3, offset: Offset(0, 1)),
      ],
      e3: const [
        BoxShadow(
            color: Color(0x29301E12), blurRadius: 40, offset: Offset(0, 16)),
        BoxShadow(
            color: Color(0x14301E12), blurRadius: 8, offset: Offset(0, 3)),
      ],
      suc: const Color(0xFF1E7A45),
      onSuc: const Color(0xFFFFFFFF),
      succ: const Color(0xFFDDF3E5),
      onSucc: const Color(0xFF0B3B20),
      err: const Color(0xFFC62828),
      onErr: const Color(0xFFFFFFFF),
      errc: const Color(0xFFFDE4E2),
      onErrc: const Color(0xFF5C0F0F),
      warn: const Color(0xFF9A5B00),
      onWarn: const Color(0xFFFFFFFF),
      warnc: const Color(0xFFFFEFD0),
      onWarnc: const Color(0xFF4A2C00),
      info: const Color(0xFF1660C4),
      infoc: const Color(0xFFDEEBFC),
      onInfoc: const Color(0xFF0A2C5C),
    );
  }

  @override
  AppRenkler copyWith() => this;

  @override
  AppRenkler lerp(ThemeExtension<AppRenkler>? other, double t) {
    if (other is! AppRenkler) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppRenkler(
      g1: c(g1, other.g1),
      g2: c(g2, other.g2),
      bg: c(bg, other.bg),
      s1: c(s1, other.s1),
      s2: c(s2, other.s2),
      s3: c(s3, other.s3),
      raised: c(raised, other.raised),
      tx: c(tx, other.tx),
      tx2: c(tx2, other.tx2),
      tx3: c(tx3, other.tx3),
      bd: c(bd, other.bd),
      bd2: c(bd2, other.bd2),
      scrim: c(scrim, other.scrim),
      e1: t < 0.5 ? e1 : other.e1,
      e2: t < 0.5 ? e2 : other.e2,
      e3: t < 0.5 ? e3 : other.e3,
      suc: c(suc, other.suc),
      onSuc: c(onSuc, other.onSuc),
      succ: c(succ, other.succ),
      onSucc: c(onSucc, other.onSucc),
      err: c(err, other.err),
      onErr: c(onErr, other.onErr),
      errc: c(errc, other.errc),
      onErrc: c(onErrc, other.onErrc),
      warn: c(warn, other.warn),
      onWarn: c(onWarn, other.onWarn),
      warnc: c(warnc, other.warnc),
      onWarnc: c(onWarnc, other.onWarnc),
      info: c(info, other.info),
      infoc: c(infoc, other.infoc),
      onInfoc: c(onInfoc, other.onInfoc),
    );
  }
}

extension AppRenklerContext on BuildContext {
  AppRenkler get renk => Theme.of(this).extension<AppRenkler>()!;
}
