import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/brand_logo.dart';
import '../../../../core/presentation/widgets/error_view.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../appearance/presentation/widgets/theme_mode_switch.dart';
import '../../domain/entities/role.dart';
import '../controllers/session_controller.dart';
import '../widgets/role_card.dart';

/// Demo entry: pick the employer or the job seeker account.
class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key, this.from});

  /// Address to continue to after logging in, when a guard sent us here.
  final String? from;

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  Role? _loggingIn;
  Object? _error;

  /// The account whose login failed; "Tekrar dene" tries it again.
  Role? _failedRole;

  /// `flutter run --dart-define=START_AS=employer` (or `worker`) opens that
  /// account right away; handy for checking a screen.
  static const _startAs = String.fromEnvironment('START_AS');

  @override
  void initState() {
    super.initState();
    for (final role in Role.values) {
      if (role.name == _startAs) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _continueAs(role));
      }
    }
  }

  Future<void> _continueAs(Role role) async {
    if (_loggingIn != null) return;
    setState(() {
      _loggingIn = role;
      _error = null;
      _failedRole = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(role);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _failedRole = role;
        });
      }
      return;
    } finally {
      if (mounted) setState(() => _loggingIn = null);
    }
    if (!mounted) return;
    final from = widget.from;
    final target = from != null && requiredRoleFor(Uri.parse(from)) == role
        ? from
        : homeLocationFor(role);
    // Coming back here ends the session (see appRouterProvider).
    await context.push<void>(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    final failedRole = _failedRole;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = ColorScheme.of(context).primary;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.65),
                    radius: 0.95,
                    colors: [
                      primary.withValues(alpha: dark ? 0.16 : 0.065),
                      primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -145,
            bottom: -110,
            child: IgnorePointer(
              child: BrandLogo(
                key: const ValueKey('login-brand-watermark'),
                size: 520,
                opacity: dark ? 0.055 : 0.035,
                decorative: true,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  12,
                  AppSpacing.page,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 36).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: ThemeModeSwitch(),
                          ),
                          const SizedBox(height: 12),
                          const BrandLogo(size: 184),
                          const SizedBox(height: 32),
                          Text(
                            l10n.roleTitle,
                            textAlign: TextAlign.center,
                            style: context.textStyles.title20.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.roleSubtitle,
                            textAlign: TextAlign.center,
                            style: context.textStyles.caption13.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          RoleCard(
                            title: l10n.roleEmployer,
                            hint: l10n.roleEmployerHint,
                            icon: Icons.business_center_outlined,
                            loading: _loggingIn == Role.employer,
                            onTap: _loggingIn == null
                                ? () => _continueAs(Role.employer)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          RoleCard(
                            title: l10n.roleWorker,
                            hint: l10n.roleWorkerHint,
                            icon: Icons.person_outline_rounded,
                            loading: _loggingIn == Role.worker,
                            onTap: _loggingIn == null
                                ? () => _continueAs(Role.worker)
                                : null,
                          ),
                          if (error != null && failedRole != null)
                            ErrorView(
                              error: error,
                              onRetry: () => _continueAs(failedRole),
                            ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 32),
                            TextButton(
                              onPressed: () =>
                                  const GalleryRoute().push<void>(context),
                              child: Text(
                                l10n.openGallery,
                                style: context.textStyles.label14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
