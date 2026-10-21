import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../tercumeler/tercumeler.dart';
import '../tercumeler/tr.dart';

class ZodiacDetailCard extends StatelessWidget {
  const ZodiacDetailCard({super.key, required this.signId});

  final String signId;

  @override
  Widget build(BuildContext context) {
    final localeCode = Get.locale?.languageCode ?? 'tr';
    final translations =
        Tercumeler().keys[localeCode] ?? tr; // fallback to tr if not found

    final name = tZodiac(signId, 'name', translations);
    final shortText = tZodiac(signId, 'short', translations);
    final giftItems = tZodiacList(signId, 'gifts', translations);
    final surpriseItems = tZodiacList(signId, 'surprises', translations);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              shortText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (giftItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Hediye Önerileri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...giftItems.map(
                (item) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ],
            if (surpriseItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sürpriz Önerileri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...surpriseItems.map(
                (item) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
