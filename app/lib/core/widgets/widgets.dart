/// Reusable SEA SPACE components.
library;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Bordered surface card — the basic building block of every screen.
class SsCard extends StatelessWidget {
  const SsCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? const EdgeInsets.all(SsSpace.lg), child: child);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// Small uppercase section label with optional trailing action.
class SsSectionHeader extends StatelessWidget {
  const SsSectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SsSpace.xl, bottom: SsSpace.sm),
      child: Row(
        children: [
          Expanded(child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Metric tile. Shows a real number from the database — never a placeholder value.
class SsStatTile extends StatelessWidget {
  const SsStatTile({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SsCard(
      padding: const EdgeInsets.all(SsSpace.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$value',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Icon(icon, size: 18, color: SsColors.textTertiary),
            ],
          ),
          const SizedBox(height: SsSpace.xxs),
          Text(label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Status pill (e.g. "Verified", "Planned").
class SsBadge extends StatelessWidget {
  const SsBadge(this.label, {super.key, this.color = SsColors.accent});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SsSpace.sm, vertical: SsSpace.xxs + 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: SsRadius.brSm,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    );
  }
}

/// Centered message used for empty, error and "not configured" states.
class SsMessageState extends StatelessWidget {
  const SsMessageState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconColor = SsColors.textTertiary,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SsSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(SsSpace.md),
                decoration: BoxDecoration(
                  color: SsColors.surfaceRaised,
                  borderRadius: SsRadius.brMd,
                  border: Border.all(color: SsColors.border),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: SsSpace.lg),
              Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: SsSpace.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: SsColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: SsSpace.xl), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class SsLoading extends StatelessWidget {
  const SsLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.4)));
}

class SsErrorState extends StatelessWidget {
  const SsErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SsMessageState(
      icon: Icons.cloud_off_outlined,
      iconColor: SsColors.warning,
      title: 'Something went wrong',
      message: error.toString(),
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Try again'),
      ),
    );
  }
}

/// Constrains page content on wide screens and applies the standard gutter.
class SsPage extends StatelessWidget {
  const SsPage({super.key, required this.children, this.onRefresh});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(SsSpace.gutter, SsSpace.sm, SsSpace.gutter, SsSpace.xxxl),
      children: [
        for (final c in children)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SsSpace.maxContentWidth),
              child: SizedBox(width: double.infinity, child: c),
            ),
          ),
      ],
    );
    return onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
