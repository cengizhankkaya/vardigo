import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/colors.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../preview/design_preview_screen.dart';
import '../../../shared/design_system/components/error_view.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/design_system/tokens/app_shadows.dart';
import '../../../shared/design_system/tokens/app_text_styles.dart';
import '../../candidates/presentation/candidates_screen.dart';
import '../../offers/presentation/offers_screen.dart';
import '../application/session_controller.dart';
import '../domain/session.dart';

/// Demo entry: pick the employer or the job seeker account.
class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

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
    final session = ref.read(sessionProvider.notifier);
    try {
      await session.login(role);
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => role == Role.employer
            ? const CandidatesScreen()
            : const OffersScreen(),
      ),
    );
    session.logout();
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
            Text(l10n.roleTitle, style: AppTextStyles.title20),
            const SizedBox(height: 4),
            Text(l10n.roleSubtitle, style: AppTextStyles.caption13),
            const SizedBox(height: 24),
            _RoleCard(
              title: l10n.roleEmployer,
              hint: l10n.roleEmployerHint,
              loading: _loggingIn == Role.employer,
              onTap: () => _continueAs(Role.employer),
            ),
            const SizedBox(height: 12),
            _RoleCard(
              title: l10n.roleWorker,
              hint: l10n.roleWorkerHint,
              loading: _loggingIn == Role.worker,
              onTap: () => _continueAs(Role.worker),
            ),
            if (error != null && failedRole != null)
              ErrorView(error: error, onRetry: () => _continueAs(failedRole)),
            if (kDebugMode) ...[
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DesignPreviewScreen(),
                  ),
                ),
                child: Text(l10n.openGallery, style: AppTextStyles.label14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.hint,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: ColorName.slate200),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title18),
                    const SizedBox(height: 4),
                    Text(hint, style: AppTextStyles.caption12),
                  ],
                ),
              ),
              if (loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: ColorName.slate500),
            ],
          ),
        ),
      ),
    );
  }
}
