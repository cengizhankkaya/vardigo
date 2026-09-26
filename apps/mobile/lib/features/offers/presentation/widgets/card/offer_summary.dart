import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../app/providers.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/components/app_icon.dart';
import '../../../../../shared/design_system/components/inline_divider.dart';
import '../../../../../shared/design_system/theme/theme.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../domain/offer.dart';

/// Logo, title and pay, place, then district | date.
class OfferSummary extends StatelessWidget {
  const OfferSummary(this.offer, {super.key});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Logo(offer.logoPath),
        const SizedBox(width: AppSpacing.cardPhotoText),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleAndPay(title: offer.title, pay: offer.pay),
              Text(offer.place, style: context.textStyles.caption12),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  AppIcon(Assets.icons.pin, size: 14),
                  const SizedBox(width: AppSpacing.iconText),
                  Text(
                    offer.district,
                    style: context.textStyles.caption12Medium,
                  ),
                  const InlineDivider(),
                  AppIcon(Assets.icons.date, size: 14),
                  const SizedBox(width: AppSpacing.iconText),
                  Text(offer.when, style: context.textStyles.caption12Medium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Business logo (SVG) from the API.
class _Logo extends ConsumerWidget {
  const _Logo(this.path);

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = ColoredBox(color: context.appColors.placeholder);
    return ClipOval(
      child: SizedBox.square(
        dimension: AppSizes.avatar,
        child: SvgPicture.network(
          ref.watch(apiConfigProvider).assetUrl(path),
          httpClient: ref.watch(svgHttpClientProvider),
          fit: BoxFit.cover,
          placeholderBuilder: (_) => placeholder,
          errorBuilder: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _TitleAndPay extends StatelessWidget {
  const _TitleAndPay({required this.title, required this.pay});

  final String title;
  final String pay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textStyles.title18,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppIcon(Assets.icons.money, size: 24),
        const SizedBox(width: AppSpacing.iconText),
        Text(
          context.l10n.payAmount(pay),
          style: context.textStyles.title18.copyWith(
            color: context.semanticColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
