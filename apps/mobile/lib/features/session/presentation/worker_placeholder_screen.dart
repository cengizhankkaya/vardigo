import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/design_system/components/square_icon_button.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/design_system/tokens/app_text_styles.dart';

/// Stand-in for the job seeker screen until it is built.
class WorkerPlaceholderScreen extends StatelessWidget {
  const WorkerPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquareIconButton(
                icon: Assets.icons.back,
                label: context.l10n.back,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.offersComingSoon,
                style: AppTextStyles.title16Medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
