import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../tema/renkler.dart';

/// Bildirim izni kapalıyken gösterilen uyarı kartı.
/// Eylem, uygulamanın sistem bildirim ayarlarını açar.
class BildirimUyarisi extends StatelessWidget {
  const BildirimUyarisi({
    super.key,
    required this.baslik,
    required this.mesaj,
    required this.eylem,
    this.onKapat,
    this.kapatEtiketi,
  });

  final String baslik;
  final String mesaj;
  final String eylem;

  /// Verilirse kartta kapatma düğmesi görünür.
  final VoidCallback? onKapat;
  final String? kapatEtiketi;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
        decoration: BoxDecoration(
          color: r.warnc,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications_off_rounded, size: 24, color: r.warn),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baslik,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: r.onWarnc,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mesaj,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: r.onWarnc,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onKapat != null)
                  IconButton(
                    tooltip: kapatEtiketi,
                    onPressed: onKapat,
                    color: r.onWarnc,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: r.warn,
                  foregroundColor: r.onWarn,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 14),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(eylem),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
