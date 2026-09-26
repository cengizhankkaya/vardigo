import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/presentation/failure_message/error_text.dart';
import '../../../../../core/theme/theme.dart';
import '../../controllers/offers_controller.dart';

/// City, branch note, pay and time from the detail endpoint. It loads only
/// when opened, so it reads its own provider.
class OfferDetails extends ConsumerWidget {
  const OfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(offerDetailProvider(offerId));
    final style = context.textStyles.caption12Medium;
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
          style: style.copyWith(color: ColorScheme.of(context).error),
        ),
      ),
    );
  }
}
