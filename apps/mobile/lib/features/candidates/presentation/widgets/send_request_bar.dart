import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/theme.dart';

/// Bottom bar with "Görüşme Talebi Gönder (N)"; disabled with no selection.
class SendRequestBar extends StatelessWidget {
  const SendRequestBar({
    super.key,
    required this.count,
    required this.sending,
    required this.onSend,
  });

  final int count;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bar,
        border: Border(top: BorderSide(color: colors.stroke)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          icon: Assets.icons.send,
          label: context.l10n.sendRequest(count),
          loading: sending,
          onPressed: count == 0 ? null : onSend,
        ),
      ),
    );
  }
}
