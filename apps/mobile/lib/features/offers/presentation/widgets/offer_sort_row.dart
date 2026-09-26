import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/sort_chip.dart';
import '../../domain/entities/offer_sort.dart';
import '../extensions/offer_sort_label.dart';

/// Right-aligned "Sırala: Önerilen" chip above the list.
class OfferSortRow extends StatelessWidget {
  const OfferSortRow({super.key, required this.sort, required this.onSort});

  final OfferSort sort;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: SortChip(
          label: l10n.sortLabel(sort.label(l10n)),
          onPressed: onSort,
        ),
      ),
    );
  }
}
