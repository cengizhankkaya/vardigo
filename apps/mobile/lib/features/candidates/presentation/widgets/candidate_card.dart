import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/app_icon.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../domain/candidate.dart';

/// One candidate: photo, name, rating / attendance / distance, pay line and
/// a checkbox. The whole card toggles the selection.
class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.selected,
    required this.onToggle,
  });

  final Candidate candidate;
  final bool selected;
  final VoidCallback? onToggle;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: candidate.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? ColorName.primaryLighter : ColorName.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: selected ? null : Border.all(color: ColorName.slate200),
            boxShadow: selected ? AppShadows.cardSelected : AppShadows.card,
          ),
          // Selected cards have no border, so their content sits 1 px further
          // out; the padding keeps both states aligned.
          padding: EdgeInsets.all(selected ? 1 : 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card - 1),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Avatar(candidate),
                          const SizedBox(width: AppSpacing.cardPhotoText),
                          Expanded(child: _Details(candidate)),
                          const SizedBox(width: 8),
                          _Checkbox(selected: selected),
                        ],
                      ),
                      if (candidate.expectedPay != null) ...[
                        const SizedBox(height: 12),
                        _PayLine(candidate),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  const Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _stripeWidth,
                    child: ColoredBox(color: ColorName.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends ConsumerWidget {
  const _Avatar(this.candidate);

  final Candidate candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(apiConfigProvider).assetUrl(candidate.photoPath);
    const placeholder = ColoredBox(color: ColorName.slate100);
    return SizedBox.square(
      dimension: AppSizes.avatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: SizedBox.square(
              dimension: AppSizes.avatar,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (_, _, _) => placeholder,
              ),
            ),
          ),
          if (candidate.online)
            Positioned(
              right: -4,
              bottom: -2,
              child: AppIcon(Assets.icons.online, size: AppSizes.onlineBadge),
            ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details(this.candidate);

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          candidate.name,
          style: AppTextStyles.title18,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            _Metric(
              AppIcon(Assets.icons.star, color: ColorName.warning),
              candidate.rating,
            ),
            const _Divider(),
            _Metric(AppIcon(Assets.icons.shield), candidate.attendance),
            const _Divider(),
            _Metric(AppIcon(Assets.icons.pin, size: 14), candidate.distance),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.text);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.iconText),
        Text(text, style: AppTextStyles.caption12Medium),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: ColorName.slate200,
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? ColorName.primary : ColorName.white,
        borderRadius: BorderRadius.circular(AppRadius.checkbox),
        border: Border.all(
          color: selected ? ColorName.primary : ColorName.slate300,
        ),
      ),
      child: selected
          ? AppIcon(Assets.icons.check, size: 14, color: ColorName.white)
          : null,
    );
  }
}

class _PayLine extends StatelessWidget {
  const _PayLine(this.candidate);

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fits = candidate.payCompatible ?? false;
    final color = fits ? ColorName.green : ColorName.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ColorName.slate50,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Row(
        children: [
          AppIcon(Assets.icons.money, color: color),
          const SizedBox(width: AppSpacing.iconText),
          Expanded(
            child: Text(
              fits ? l10n.payMatches : l10n.payMismatch,
              style: AppTextStyles.caption12Medium.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            l10n.payPerMonth(candidate.expectedPay!),
            style: AppTextStyles.caption12Medium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
