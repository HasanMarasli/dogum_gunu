import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tema/renkler.dart';

/// Kişi silme onayı. Onaylanırsa true döner.
Future<bool> silmeOnayiIste(BuildContext context, String isim) async {
  final sonuc = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'home.delete.cancel'.tr,
    barrierColor: context.renk.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, __) => _SilmeDialogu(isim: isim),
    transitionBuilder: (context, anim, _, child) {
      final egri =
          CurvedAnimation(parent: anim, curve: const Cubic(0.2, 0, 0, 1));
      return FadeTransition(
        opacity: egri,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(egri),
          child: child,
        ),
      );
    },
  );
  return sonuc ?? false;
}

class _SilmeDialogu extends StatelessWidget {
  const _SilmeDialogu({required this.isim});

  final String isim;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;
    final mesaj = 'home.delete.confirm'.trParams({'name': '\u0000'});
    final parcalar = mesaj.split('\u0000');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 312),
          child: Material(
            color: r.raised,
            borderRadius: BorderRadius.circular(28),
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: r.e3,
                color: r.raised,
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: r.errc,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete_rounded, size: 26, color: r.err),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'home.delete.title'.tr,
                    textAlign: TextAlign.center,
                    style: metin.titleLarge?.copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 15, height: 1.5, color: r.tx2),
                      children: [
                        TextSpan(text: parcalar.first),
                        TextSpan(
                          text: isim,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: r.tx),
                        ),
                        if (parcalar.length > 1) TextSpan(text: parcalar[1]),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        autofocus: true,
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: Text('home.delete.cancel'.tr),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: r.err,
                          foregroundColor: r.onErr,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: Text('home.delete.confirmButton'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
