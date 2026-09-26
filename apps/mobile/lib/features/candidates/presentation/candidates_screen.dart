import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/design_system/components/error_view.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/async_list_view.dart';
import '../application/candidates_controller.dart';
import '../domain/candidate.dart';
import 'widgets/candidates_header.dart';
import 'widgets/card/candidate_card.dart';
import 'widgets/selection_row.dart';
import 'widgets/send_request_bar.dart';

/// Employer screen "Eşleşen Personeller". Reads the providers and hands
/// plain values and callbacks to the widgets below it.
class CandidatesScreen extends ConsumerWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(candidatesControllerProvider);
    final controller = ref.read(candidatesControllerProvider.notifier);
    final list = ref.watch(candidateListProvider(state.query));
    ref.listen(candidateListProvider(state.query), (_, next) {
      if (next.value case final loaded?) {
        controller.applyInitialSelection(loaded);
      }
    });
    // Header counts stay visible while another tab loads.
    final totals =
        list.value ??
        ref
            .watch(
              candidateListProvider((
                tab: CandidateTab.perfect,
                sort: state.sort,
              )),
            )
            .value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CandidatesHeader(
              totalPerfect: totals?.totalPerfect,
              totalSimilar: totals?.totalSimilar,
              tab: state.tab,
              onTab: controller.selectTab,
            ),
            Expanded(
              child: AsyncListView<CandidateList>(
                value: list,
                header: [
                  SelectionRow(
                    selectedCount: state.selected.length,
                    sort: state.sort,
                    onSort: state.submitting ? null : controller.cycleSort,
                  ),
                  const SizedBox(height: 8),
                ],
                itemGap: AppSpacing.candidateCardGap,
                emptyText: context.l10n.candidatesEmpty,
                onRefresh: () =>
                    ref.refresh(candidateListProvider(state.query).future),
                onRetry: () =>
                    ref.invalidate(candidateListProvider(state.query)),
                itemsBuilder: (data) => [
                  for (final candidate in data.candidates)
                    CandidateCard(
                      candidate: candidate,
                      selected: state.selected.contains(candidate.id),
                      onToggle: state.submitting
                          ? null
                          : () => controller.toggle(candidate.id),
                    ),
                ],
              ),
            ),
            SendRequestBar(
              count: state.selected.length,
              sending: state.submitting,
              onSend: () => _send(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(candidatesControllerProvider.notifier)
        .submit();
    if (result == null || !context.mounted) return;
    final l10n = context.l10n;
    showAppSnackBar(context, switch (result) {
      SubmitSucceeded(:final count) => l10n.requestsSent(count),
      SubmitFailed(uncertain: true) => l10n.sendUncertain,
      SubmitFailed(:final error) => errorText(context, error),
    });
  }
}
