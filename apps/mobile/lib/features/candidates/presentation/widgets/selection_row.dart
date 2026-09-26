import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/sort_chip.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../domain/candidate.dart';
import '../candidate_labels.dart';

/// "2 kişi seçildi" and the sort chip. [onSort] is null while sending.
class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.selectedCount,
    required this.sort,
    required this.onSort,
  });

  final int selectedCount;
  final CandidateSort sort;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.selectedCount(selectedCount),
            style: AppTextStyles.title16Semibold,
          ),
        ),
        SortChip(label: l10n.sortLabel(sort.label(l10n)), onPressed: onSort),
      ],
    );
  }
}
