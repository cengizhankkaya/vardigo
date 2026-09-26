import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../shared/design_system/components/primary_button.dart';
import '../../shared/design_system/theme/theme.dart';
import '../../shared/design_system/tokens/app_dimens.dart';

/// Shown for an address with no screen, e.g. a mistyped deep link.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({
    super.key,
    required this.location,
    required this.onHome,
  });

  final String location;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.routeNotFoundTitle,
                textAlign: TextAlign.center,
                style: text.title20,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.routeNotFoundBody(location),
                textAlign: TextAlign.center,
                style: text.label14.copyWith(
                  color: context.appColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: l10n.backToRoleSelect, onPressed: onHome),
            ],
          ),
        ),
      ),
    );
  }
}
