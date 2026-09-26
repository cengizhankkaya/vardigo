import 'package:flutter/material.dart';

import '../../../../../gen/colors.gen.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../domain/offer.dart';
import 'offer_answer_buttons.dart';
import 'offer_countdown.dart';
import 'offer_details.dart';
import 'offer_status_label.dart';
import 'offer_summary.dart';

/// One interview request: logo, title and pay, place, answer buttons,
/// details and the countdown. Answered and expired offers show their status
/// instead of the buttons and the countdown.
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
          OfferSummary(offer),
          const SizedBox(height: 12),
          if (offer.isPending)
            OfferAnswerButtons(
              busy: busy,
              onAccept: onAccept,
              onReject: onReject,
            )
          else
            OfferStatusLabel(offer.status),
          const SizedBox(height: 12),
          OfferDetailsButton(expanded: expanded, onTap: onToggleDetails),
          if (expanded) OfferDetails(offerId: offer.id),
          if (offer.isPending) ...[
            const SizedBox(height: 10),
            OfferCountdown(offer: offer, now: now),
          ],
        ],
      ),
    );
  }
}
