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

/// Ayarlar'da seçilebilen paletler. Anahtarlar kayıtlı tercihlerle uyumludur.
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
  'sky': Palet(
    seed: Color(0xFF0288D1),
    acik: PaletTonlari(
      pr: Color(0xFF0272B3),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFCDE9FA),
      onPc: Color(0xFF002F4A),
      g1: Color(0xFF0272B3),
      g2: Color(0xFF0B7FA8),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFF7FCBF5),
      onPr: Color(0xFF00344F),
      pc: Color(0xFF004F75),
      onPc: Color(0xFFCDE9FA),
      g1: Color(0xFF036A9E),
      g2: Color(0xFF0A7396),
    ),
  ),
  'orchid': Palet(
    seed: Color(0xFFA63FC9),
    acik: PaletTonlari(
      pr: Color(0xFF9333B5),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFF5DDFC),
      onPc: Color(0xFF36064A),
      g1: Color(0xFF9333B5),
      g2: Color(0xFFB5338F),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFE5B0F7),
      onPr: Color(0xFF4C0F63),
      pc: Color(0xFF6F2190),
      onPc: Color(0xFFF5DDFC),
      g1: Color(0xFF8A2FAB),
      g2: Color(0xFFA52F84),
    ),
  ),
  'gold': Palet(
    seed: Color(0xFFD9A400),
    acik: PaletTonlari(
      pr: Color(0xFF7F6000),
      onPr: Color(0xFFFFFFFF),
      pc: Color(0xFFFFE9A6),
      onPc: Color(0xFF2B2000),
      g1: Color(0xFF886700),
      g2: Color(0xFF8A6E00),
    ),
    koyu: PaletTonlari(
      pr: Color(0xFFF0CB57),
      onPr: Color(0xFF3B2D00),
      pc: Color(0xFF574200),
      onPc: Color(0xFFFFE9A6),
      g1: Color(0xFF8A6800),
      g2: Color(0xFF7E6F00),
    ),
  ),
};

/// Paletin tonundan türeyen zemin, yazı ve kenarlık renkleri ile palet gradyanı.
/// Başarı, hata ve uyarı anlam taşıdığı için her palette aynı kalır.
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
    required this.onInfo,
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
  final Color onInfo;
  final Color infoc;
  final Color onInfoc;

  LinearGradient get gradyan => LinearGradient(
        colors: [g1, g2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static AppRenkler olustur(Palet palet, Brightness parlaklik) {
    final p = palet.tonlar(parlaklik);
    final ton = HSLColor.fromColor(palet.seed).hue;
    Color notr(double doygunluk, double aydinlik) =>
        HSLColor.fromAHSL(1, ton, doygunluk, aydinlik).toColor();

    if (parlaklik == Brightness.dark) {
      return AppRenkler(
        g1: p.g1,
        g2: p.g2,
        bg: notr(0.28, 0.07),
        s1: notr(0.24, 0.11),
        s2: notr(0.22, 0.15),
        s3: notr(0.20, 0.19),
        raised: notr(0.22, 0.17),
        tx: notr(0.30, 0.94),
        tx2: notr(0.16, 0.74),
        tx3: notr(0.13, 0.63),
        bd: notr(0.16, 0.22),
        bd2: notr(0.14, 0.32),
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
        info: p.pr,
        onInfo: p.onPr,
        infoc: p.pc,
        onInfoc: p.onPc,
      );
    }
    return AppRenkler(
      g1: p.g1,
      g2: p.g2,
      bg: notr(0.50, 0.96),
      s1: notr(0.60, 0.99),
      s2: notr(0.45, 0.93),
      s3: notr(0.40, 0.89),
      raised: notr(0.60, 0.99),
      tx: notr(0.35, 0.10),
      tx2: notr(0.18, 0.33),
      tx3: notr(0.14, 0.36),
      bd: notr(0.32, 0.88),
      bd2: notr(0.22, 0.76),
      scrim: notr(0.35, 0.06).withAlpha(0x6B),
      e1: [
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x0F),
            blurRadius: 2,
            offset: const Offset(0, 1)),
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x0D),
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ],
      e2: [
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x17),
            blurRadius: 16,
            offset: const Offset(0, 6)),
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x0F),
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ],
      e3: [
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x29),
            blurRadius: 40,
            offset: const Offset(0, 16)),
        BoxShadow(
            color: notr(0.45, 0.13).withAlpha(0x14),
            blurRadius: 8,
            offset: const Offset(0, 3)),
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
      info: p.pr,
      onInfo: p.onPr,
      infoc: p.pc,
      onInfoc: p.onPc,
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
      onInfo: c(onInfo, other.onInfo),
      infoc: c(infoc, other.infoc),
      onInfoc: c(onInfoc, other.onInfoc),
    );
  }
}

extension AppRenklerContext on BuildContext {
  AppRenkler get renk => Theme.of(this).extension<AppRenkler>()!;
}
