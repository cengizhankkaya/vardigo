import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/error_view.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_dimens.dart';
import '../../../appearance/presentation/widgets/theme_mode_picker.dart';
import '../controllers/session_controller.dart';
import '../../domain/entities/session.dart';
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            const SizedBox(height: 40),
            Text(l10n.roleTitle, style: context.textStyles.title20),
            const SizedBox(height: 4),
            Text(l10n.roleSubtitle, style: context.textStyles.caption13),
            const SizedBox(height: 24),
            RoleCard(
              title: l10n.roleEmployer,
              hint: l10n.roleEmployerHint,
              loading: _loggingIn == Role.employer,
              onTap: () => _continueAs(Role.employer),
            ),
            const SizedBox(height: 12),
            RoleCard(
              title: l10n.roleWorker,
              hint: l10n.roleWorkerHint,
              loading: _loggingIn == Role.worker,
              onTap: () => _continueAs(Role.worker),
            ),
            if (error != null && failedRole != null)
              ErrorView(error: error, onRetry: () => _continueAs(failedRole)),
            const SizedBox(height: 32),
            const ThemeModePicker(),
            if (kDebugMode) ...[
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => const GalleryRoute().push<void>(context),
                child: Text(
                  l10n.openGallery,
                  style: context.textStyles.label14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
