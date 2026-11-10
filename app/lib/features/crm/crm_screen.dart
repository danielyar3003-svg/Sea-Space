import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'crm_models.dart';
import 'crm_repository.dart';
import 'crm_widgets.dart';

/// Tools → Applications: Kanban board, follow-ups and pipeline statistics.
class CrmScreen extends StatelessWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.crm),
          bottom: TabBar(
            tabs: [
              Tab(text: l.board),
              Tab(text: l.followUps),
            ],
          ),
        ),
        body: const TabBarView(children: [_BoardTab(), _FollowUpsTab()]),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stats = ref.watch(statsProvider).value;
    if (stats == null) return const SizedBox.shrink();
    final rate = stats.replyRate == null ? l.notEnoughData : '${(stats.replyRate! * 100).round()}%';
    final median = stats.medianDaysToReply == null
        ? l.notEnoughData
        : l.daysValue(stats.medianDaysToReply!.toStringAsFixed(1));
    final items = [
      (l.statTotal, '${stats.total}'),
      (l.statApplicationsSent, '${stats.sent}'),
      (l.statReplyRate, rate),
      (l.statMedianReply, median),
      (l.statInterviews, '${stats.interviews}'),
      (l.statOffers, '${stats.offers}'),
    ];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(SsSpace.gutter, SsSpace.sm, SsSpace.gutter, 0),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: SsSpace.sm),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: SsSpace.md, vertical: SsSpace.sm),
          decoration: BoxDecoration(
            color: SsColors.surface,
            borderRadius: SsRadius.brMd,
            border: Border.all(color: SsColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(items[i].$2, style: Theme.of(context).textTheme.titleMedium),
              Text(items[i].$1, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardTab extends ConsumerWidget {
  const _BoardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final apps = ref.watch(applicationsProvider);
    return apps.when(
      loading: () => const SsLoading(),
      error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(applicationsProvider)),
      data: (list) {
        if (list.isEmpty) {
          return SsMessageState(
            icon: Icons.view_kanban_outlined,
            title: l.noApplications,
            message: l.noApplicationsBody,
          );
        }
        final byStatus = {for (final s in applicationStatuses) s: <Application>[]};
        for (final a in list) {
          byStatus[a.status]?.add(a);
        }
        // Only stages that have applications, in pipeline order (the status sheet offers all 14).
        final columns = applicationStatuses.where((st) => byStatus[st]!.isNotEmpty).toList();
        final columnWidth = (MediaQuery.sizeOf(context).width - 2 * SsSpace.gutter).clamp(220.0, 280.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StatsRow(),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(SsSpace.gutter),
                itemCount: columns.length,
                separatorBuilder: (_, _) => const SizedBox(width: SsSpace.md),
                itemBuilder: (_, i) {
                  final s = columns[i];
                  final cards = byStatus[s]!;
                  return SizedBox(
                    width: columnWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: statusColor(s), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: SsSpace.sm),
                            Expanded(
                              child: Text(
                                statusLabel(l, s).toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('${cards.length}', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: SsSpace.sm),
                        Expanded(
                          child: ListView.separated(
                            itemCount: cards.length,
                            separatorBuilder: (_, _) => const SizedBox(height: SsSpace.sm),
                            itemBuilder: (_, j) => ApplicationCard(cards[j]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FollowUpsTab extends ConsumerStatefulWidget {
  const _FollowUpsTab();

  @override
  ConsumerState<_FollowUpsTab> createState() => _FollowUpsTabState();
}

class _FollowUpsTabState extends ConsumerState<_FollowUpsTab> {
  String _state = 'open';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = ref.watch(followUpsProvider(_state));
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SsSpace.gutter, vertical: SsSpace.sm),
            children: [
              for (final (value, label) in [
                ('open', l.followUpsOpen),
                ('overdue', l.followUpsOverdue),
                ('done', l.followUpsDone),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: SsSpace.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: _state == value,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _state = value),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.when(
            loading: () => const SsLoading(),
            error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(followUpsProvider)),
            data: (list) => list.isEmpty
                ? SsMessageState(icon: Icons.event_available_outlined, title: l.noFollowUpsHere)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(SsSpace.gutter, 0, SsSpace.gutter, SsSpace.xxxl),
                    children: [
                      SsCard(
                        padding: EdgeInsets.zero,
                        child: Column(children: [for (final f in list) FollowUpTile(f, showCompany: true)]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
