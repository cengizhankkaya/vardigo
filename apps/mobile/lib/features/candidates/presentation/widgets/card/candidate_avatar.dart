import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/colors.gen.dart';
import '../../../../../shared/design_system/components/app_icon.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../domain/candidate.dart';

/// Round photo from the API, with the green badge when online.
class CandidateAvatar extends ConsumerWidget {
  const CandidateAvatar(this.candidate, {super.key});

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
