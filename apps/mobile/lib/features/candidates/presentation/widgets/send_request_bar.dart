import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/primary_button.dart';

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
          loading: sending,
          onPressed: count == 0 ? null : onSend,
        ),
      ),
    );
  }
}
