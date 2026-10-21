import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tema/renkler.dart';

/// Tek renkli burç glifi; rengi çalışma anında verilir.
class BurcIkonu extends StatelessWidget {
  const BurcIkonu({
    super.key,
    required this.burcId,
    required this.boyut,
    required this.renk,
  });

  final String burcId;
  final double boyut;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/burclar/$burcId.svg',
      width: boyut,
      height: boyut,
      colorFilter: ColorFilter.mode(renk, BlendMode.srcIn),
    );
  }
}

/// Yuvarlatılmış kare içinde burç glifi. Glif, kutunun ~%55'i kadardır.
/// [gradyan] true ise palet gradyanı + beyaz glif (bugün / detay sayfası).
class BurcRozeti extends StatelessWidget {
  const BurcRozeti({
    super.key,
    required this.burcId,
    this.boyut = 48,
    this.gradyan = false,
    this.halka = false,
  });

  final String burcId;
  final double boyut;
  final bool gradyan;
  final bool halka;

  double get _yaricap {
    if (boyut >= 96) return 28;
    if (boyut >= 56) return 16;
    if (boyut >= 48) return 14;
    if (boyut >= 40) return 12;
    return boyut * 0.31;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = context.renk;
    return Container(
      width: boyut,
      height: boyut,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradyan ? null : scheme.primaryContainer,
        gradient: gradyan ? r.gradyan : null,
        borderRadius: BorderRadius.circular(_yaricap),
        boxShadow: halka
            ? [BoxShadow(color: scheme.primaryContainer, spreadRadius: 6)]
            : null,
      ),
      child: BurcIkonu(
        burcId: burcId,
        boyut: boyut * 0.55,
        renk: gradyan ? Colors.white : scheme.onPrimaryContainer,
      ),
    );
  }
}
