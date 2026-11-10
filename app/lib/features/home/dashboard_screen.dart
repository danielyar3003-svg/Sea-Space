import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../router/app_router.dart';
import '../../router/features.dart';
import '../profile/profile_repository.dart';
import 'dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: summary.when(
        loading: () => const SsLoading(),
        error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(dashboardProvider)),
        data: (data) => SsPage(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          children: [
            _StatsGrid(counts: data.counts),
            if (_needsProfile(ref)) const _GettingStarted(),
            _EntrySection(
              'Upcoming follow-ups',
              data.followUps,
              Icons.event_outlined,
              empty: 'No follow-ups scheduled.',
            ),
            _EntrySection(
              'New companies',
              data.newCompanies,
              Icons.apartment_outlined,
              empty: 'No companies yet.',
            ),
            _EntrySection(
              'Recent activity',
              data.activity,
              Icons.history,
              empty: 'Your activity will appear here.',
            ),
            const SsSectionHeader('Tools'),
            const _ToolsGrid(),
          ],
        ),
      ),
    );
  }
}

/// True only when the server confirmed there is no profile yet (not while loading or on error).
bool _needsProfile(WidgetRef ref) {
  final profile = ref.watch(primaryProfileProvider);
  return profile.hasValue && profile.value == null;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.counts});
  final DashboardCounts counts;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      SsStatTile(label: 'Companies', value: counts.companies, icon: Icons.apartment_outlined),
      SsStatTile(
        label: 'Verified HR contacts',
        value: counts.verifiedContacts,
        icon: Icons.verified_outlined,
      ),
      SsStatTile(label: 'Applications sent', value: counts.applicationsSent, icon: Icons.send_outlined),
      SsStatTile(label: 'Replies', value: counts.repliesReceived, icon: Icons.mark_email_read_outlined),
      SsStatTile(label: 'Pending follow-ups', value: counts.pendingFollowUps, icon: Icons.schedule),
      SsStatTile(label: 'Interviews', value: counts.interviews, icon: Icons.forum_outlined),
      SsStatTile(label: 'Offers', value: counts.offers, icon: Icons.workspace_premium_outlined),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 560 ? 3 : 2);
        const gap = SsSpace.md;
        final w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: w, child: t)],
        );
      },
    );
  }
}

class _GettingStarted extends StatelessWidget {
  const _GettingStarted();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SsSpace.lg),
      child: SsCard(
        onTap: () => context.go(Routes.profile),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, color: SsColors.accent),
            const SizedBox(width: SsSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start with your profile', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: SsSpace.xxs),
                  Text(
                    'Your experience and target positions drive company research and outreach.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SsColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _EntrySection extends StatelessWidget {
  const _EntrySection(this.title, this.entries, this.icon, {required this.empty});

  final String title;
  final List<DashboardEntry> entries;
  final IconData icon;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SsSectionHeader(title),
        SsCard(
          padding: EdgeInsets.zero,
          child: entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(SsSpace.lg),
                  child: Text(empty, style: theme.textTheme.bodySmall),
                )
              : Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        dense: true,
                        leading: Icon(icon, size: 20),
                        title: Text(entries[i].title),
                        subtitle: entries[i].subtitle == null ? null : Text(entries[i].subtitle!),
                        trailing: Text(_date(entries[i].at), style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  static String _date(DateTime d) {
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}';
  }
}

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 900 ? 5 : (c.maxWidth >= 560 ? 4 : 2);
        const gap = SsSpace.sm;
        final w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final f in features)
              SizedBox(
                width: w,
                child: SsCard(
                  padding: const EdgeInsets.symmetric(horizontal: SsSpace.md, vertical: SsSpace.md),
                  onTap: () => context.push(Routes.tool(f.id)),
                  child: Row(
                    children: [
                      Icon(f.icon, size: 18, color: SsColors.accent),
                      const SizedBox(width: SsSpace.sm),
                      Expanded(
                        child: Text(
                          f.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
