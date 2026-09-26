import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/sort_chip.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/candidate.dart';
import '../extensions/candidate_sort_label.dart';

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
            style: context.textStyles.title16Semibold,
          ),
        ),
        SortChip(label: l10n.sortLabel(sort.label(l10n)), onPressed: onSort),
      ],
    );
  }
}
