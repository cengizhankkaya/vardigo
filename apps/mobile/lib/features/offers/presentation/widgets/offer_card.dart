import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/providers.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/app_icon.dart';
import '../../../../shared/design_system/components/error_view.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../application/offers_controller.dart';
import '../../domain/offer.dart';

/// One interview request: logo, title and pay, place, answer buttons,
/// details and the countdown.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.now,
    required this.busy,
    required this.expanded,
    required this.onAccept,
    required this.onReject,
    required this.onToggleDetails,
  });

  final Offer offer;
  final DateTime now;
  final bool busy;
  final bool expanded;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onToggleDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ColorName.stroke),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Summary(offer),
          const SizedBox(height: 12),
          if (offer.isPending)
            _AnswerButtons(busy: busy, onAccept: onAccept, onReject: onReject)
          else
            _StatusLabel(offer.status),
          const SizedBox(height: 12),
          _DetailsButton(expanded: expanded, onTap: onToggleDetails),
          if (expanded) _Details(offer),
          if (offer.isPending) ...[
            const SizedBox(height: 10),
            _Countdown(offer: offer, now: now),
          ],
        ],
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary(this.offer);

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(apiConfigProvider).assetUrl(offer.logoPath);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: AppSizes.avatar,
            child: SvgPicture.network(
              logoUrl,
              httpClient: ref.watch(svgHttpClientProvider),
              fit: BoxFit.cover,
              placeholderBuilder: (_) =>
                  const ColoredBox(color: ColorName.slate100),
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: ColorName.slate100),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.cardPhotoText),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.title,
                      style: AppTextStyles.title18,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppIcon(Assets.icons.money, size: 24),
                  const SizedBox(width: AppSpacing.iconText),
                  Text(
                    context.l10n.payAmount(offer.pay),
                    style: AppTextStyles.title18.copyWith(
                      color: ColorName.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(offer.place, style: AppTextStyles.caption12),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  AppIcon(Assets.icons.pin, size: 14),
                  const SizedBox(width: AppSpacing.iconText),
                  Text(offer.district, style: AppTextStyles.caption12Medium),
                  Container(
                    width: 1,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: ColorName.slate200,
                  ),
                  AppIcon(Assets.icons.date, size: 14),
                  const SizedBox(width: AppSpacing.iconText),
                  Text(offer.when, style: AppTextStyles.caption12Medium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons({
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Assets.icons.close,
            label: l10n.notInterested,
            foreground: ColorName.error,
            background: ColorName.errorSoft,
            onTap: busy ? null : onReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Assets.icons.check,
            label: l10n.interested,
            foreground: ColorName.white,
            background: ColorName.green,
            onTap: busy ? null : onAccept,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.border,
  });

  final SvgGenImage icon;
  final String label;
  final Color foreground;
  final Color? background;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            height: AppSizes.actionButton,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.actionButton),
              border: border == null ? null : Border.all(color: border!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(icon, size: 16, color: foreground),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label14.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ActionButton(
      icon: Assets.icons.eye,
      label: expanded ? l10n.hideDetails : l10n.viewDetails,
      foreground: ColorName.sub,
      background: null,
      border: ColorName.stroke,
      onTap: onTap,
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details(this.offer);

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(offerDetailProvider(offer.id));
    final style = AppTextStyles.caption12Medium;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: detail.when(
        data: (d) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailPlace(d.district, d.city ?? '', d.note ?? ''),
              style: style,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.detailPayWhen(l10n.payAmount(d.pay), d.when),
              style: style,
            ),
          ],
        ),
        loading: () => const LinearProgressIndicator(minHeight: 2),
        error: (error, _) => Text(
          errorText(context, error),
          style: style.copyWith(color: ColorName.error),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel(this.status);

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (text, color, background) = switch (status) {
      OfferStatus.accepted => (
        l10n.statusAccepted,
        ColorName.greenDark,
        ColorName.greenLighter,
      ),
      OfferStatus.rejected => (
        l10n.statusRejected,
        ColorName.error,
        ColorName.errorSoft,
      ),
      _ => (l10n.statusExpired, ColorName.sub, ColorName.weak50),
    };
    return Container(
      height: AppSizes.actionButton,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Text(text, style: AppTextStyles.label14.copyWith(color: color)),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.offer, required this.now});

  final Offer offer;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final left = offer.remainingAt(now);
    final time = l10n.hoursMinutes(left.inHours, left.inMinutes % 60);
    final sentence = l10n.countdown(time);
    final start = sentence.indexOf(time);
    final urgent = offer.isUrgentAt(now);
    final base = AppTextStyles.caption12.copyWith(color: ColorName.strong);
    return Row(
      children: [
        AppIcon(Assets.icons.alarm, color: urgent ? ColorName.error : null),
        const SizedBox(width: AppSpacing.iconText),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: base,
              children: [
                TextSpan(text: sentence.substring(0, start)),
                TextSpan(
                  text: time,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: urgent ? ColorName.error : ColorName.strong,
                  ),
                ),
                TextSpan(text: sentence.substring(start + time.length)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
