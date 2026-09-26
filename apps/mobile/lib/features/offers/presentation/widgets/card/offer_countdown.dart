import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/presentation/widgets/app_icon.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/theme/tokens/app_spacing.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../domain/entities/offer.dart';

/// "Teklifin sonlanmasına 21 saat 32 dakika kaldı." with the time in bold;
/// red when little time is left.
class OfferCountdown extends StatelessWidget {
  const OfferCountdown({super.key, required this.offer, required this.now});

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
    final strong = context.appColors.textStrong;
    final alert = ColorScheme.of(context).error;
    final base = context.textStyles.caption12.copyWith(color: strong);
    return Row(
      children: [
        AppIcon(Assets.icons.alarm, color: urgent ? alert : null),
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
                    color: urgent ? alert : strong,
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
