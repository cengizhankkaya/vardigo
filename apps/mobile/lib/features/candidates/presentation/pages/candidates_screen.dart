import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/extensions/snack_bar_context.dart';
import '../../../../core/presentation/failure_message/error_text.dart';
import '../../../../core/presentation/widgets/async_list_view.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/candidate_sort.dart';
import '../../domain/entities/candidate_tab.dart';
import '../controllers/candidate_query.dart';
import '../controllers/candidates_controller.dart';
import '../controllers/submit_result.dart';
import '../widgets/candidates_header.dart';
import '../widgets/card/candidate_card.dart';
import '../widgets/selection_row.dart';
import '../widgets/send_request_bar.dart';

/// Employer screen "Eşleşen Personeller". Reads the providers and hands
/// plain values and callbacks to the widgets below it.
class CandidatesScreen extends ConsumerStatefulWidget {
  const CandidatesScreen({super.key, this.initialTab, this.initialSort});

  /// From the route; null opens the defaults.
  final CandidateTab? initialTab;
  final CandidateSort? initialSort;

  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  /// This visit's controller, opened on the route's tab and sort.
  late final _controller = candidatesControllerProvider((
    tab: widget.initialTab ?? defaultCandidateQuery.tab,
    sort: widget.initialSort ?? defaultCandidateQuery.sort,
  ));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_controller);
    final controller = ref.read(_controller.notifier);
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
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final result = await ref.read(_controller.notifier).submit();
    if (result == null || !mounted) return;
    final l10n = context.l10n;
    context.showAppSnackBar(switch (result) {
      SubmitSucceeded(:final count) => l10n.requestsSent(count),
      SubmitFailed(uncertain: true) => l10n.sendUncertain,
      SubmitFailed(:final error) => errorText(context, error),
    });
  }
}
