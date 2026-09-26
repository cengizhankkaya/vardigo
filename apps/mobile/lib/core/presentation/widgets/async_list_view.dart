import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';
import '../../theme/tokens/app_dimens.dart';

/// Pull-to-refresh list for a loaded value: [header] on top, then the items,
/// or the loading, empty or error state in their place. A refresh keeps the
/// old items on screen until the new ones arrive.
class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    super.key,
    required this.value,
    required this.itemsBuilder,
    required this.itemGap,
    required this.emptyText,
    required this.onRefresh,
    required this.onRetry,
    this.header = const [],
  });

  final AsyncValue<T> value;
  final List<Widget> Function(T data) itemsBuilder;
  final double itemGap;
  final String emptyText;
  final RefreshCallback onRefresh;
  final VoidCallback onRetry;
  final List<Widget> header;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          16,
        ),
        children: [
          ...header,
          ...value.when(
            skipLoadingOnRefresh: true,
            data: (data) {
              final items = itemsBuilder(data);
              if (items.isEmpty) return [EmptyView(emptyText)];
              return [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(bottom: itemGap),
                    child: item,
                  ),
              ];
            },
            loading: () => const [LoadingView()],
            error: (error, _) => [ErrorView(error: error, onRetry: onRetry)],
          ),
        ],
      ),
    );
  }
}
