import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/design_system/components/error_view.dart';
import '../../../shared/design_system/components/primary_button.dart';
import '../../../shared/design_system/components/sort_chip.dart';
import '../../../shared/design_system/components/square_icon_button.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/design_system/tokens/app_shadows.dart';
import '../../../shared/design_system/tokens/app_text_styles.dart';
import '../application/candidates_controller.dart';
import '../domain/candidate.dart';
import 'widgets/candidate_card.dart';

/// Employer screen "Eşleşen Personeller".
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
            _Header(
              totalPerfect: totals?.totalPerfect,
              totalSimilar: totals?.totalSimilar,
              tab: state.tab,
              onTab: controller.selectTab,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(candidateListProvider(state.query).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    16,
                  ),
                  children: [
                    _SelectionRow(state: state, onSort: controller.cycleSort),
                    const SizedBox(height: 8),
                    ...list.when(
                      skipLoadingOnRefresh: true,
                      data: (data) => data.candidates.isEmpty
                          ? [_Empty(context.l10n.candidatesEmpty)]
                          : [
                              for (final candidate in data.candidates)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.candidateCardGap,
                                  ),
                                  child: CandidateCard(
                                    candidate: candidate,
                                    selected: state.selected.contains(
                                      candidate.id,
                                    ),
                                    onToggle: state.submitting
                                        ? null
                                        : () => controller.toggle(candidate.id),
                                  ),
                                ),
                            ],
                      loading: () => const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                      error: (error, _) => [
                        ErrorView(
                          error: error,
                          onRetry: () => ref.invalidate(
                            candidateListProvider(state.query),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _Footer(state: state, onSend: () => _send(context, ref)),
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
    final message = switch (result) {
      SubmitSucceeded(:final count) => l10n.requestsSent(count),
      SubmitFailed(uncertain: true) => l10n.sendUncertain,
      SubmitFailed(:final error) => errorText(context, error),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalPerfect,
    required this.totalSimilar,
    required this.tab,
    required this.onTab,
  });

  final int? totalPerfect;
  final int? totalSimilar;
  final CandidateTab tab;
  final ValueChanged<CandidateTab> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeTotal = tab == CandidateTab.perfect
        ? totalPerfect
        : totalSimilar;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        16,
        AppSpacing.page,
        8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SquareIconButton(
                icon: Assets.icons.back,
                label: l10n.back,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      activeTotal == null
                          ? ''
                          : l10n.candidatesFound(activeTotal),
                      style: AppTextStyles.caption13,
                    ),
                    Text(
                      l10n.candidatesTitle,
                      style: AppTextStyles.title16Medium,
                    ),
                  ],
                ),
              ),
              SquareIconButton(
                icon: Assets.icons.help,
                label: l10n.help,
                onPressed: () => _showHelp(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Tabs(
            tab: tab,
            perfectLabel: l10n.tabPerfect(totalPerfect ?? 0),
            similarLabel: l10n.tabSimilar(totalSimilar ?? 0),
            onTab: onTab,
          ),
        ],
      ),
    );
  }

  static void _showHelp(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: ColorName.white,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.helpTitle, style: AppTextStyles.title18),
          const SizedBox(height: 8),
          Text(
            context.l10n.candidatesHelp,
            style: AppTextStyles.label14.copyWith(
              color: ColorName.sub,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tab,
    required this.perfectLabel,
    required this.similarLabel,
    required this.onTab,
  });

  final CandidateTab tab;
  final String perfectLabel;
  final String similarLabel;
  final ValueChanged<CandidateTab> onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorName.slate100,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          _pill(CandidateTab.perfect, perfectLabel),
          _pill(CandidateTab.similar, similarLabel),
        ],
      ),
    );
  }

  Widget _pill(CandidateTab value, String label) {
    final active = value == tab;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTab(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? ColorName.primary : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: active ? AppShadows.candidateTabActive : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption12Medium.copyWith(
                color: active ? ColorName.white : ColorName.slate500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.state, required this.onSort});

  final CandidatesState state;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sortName = switch (state.sort) {
      CandidateSort.recommended => l10n.sortRecommended,
      CandidateSort.near => l10n.sortNear,
      CandidateSort.rating => l10n.sortRating,
    };
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.selectedCount(state.selected.length),
            style: AppTextStyles.title16Semibold,
          ),
        ),
        SortChip(
          label: l10n.sortLabel(sortName),
          onPressed: state.submitting ? null : onSort,
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.label14.copyWith(
          color: ColorName.sub,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onSend});

  final CandidatesState state;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final count = state.selected.length;
    return Container(
      decoration: const BoxDecoration(
        color: ColorName.weak,
        border: Border(top: BorderSide(color: ColorName.stroke)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          icon: Assets.icons.send,
          label: context.l10n.sendRequest(count),
          loading: state.submitting,
          onPressed: count == 0 ? null : onSend,
        ),
      ),
    );
  }
}
