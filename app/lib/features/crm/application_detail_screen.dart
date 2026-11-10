import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../companies/company_widgets.dart';
import 'crm_models.dart';
import 'crm_repository.dart';
import 'crm_widgets.dart';

class ApplicationDetailScreen extends ConsumerWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});
  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(applicationProvider(applicationId));
    return app.when(
      loading: () => Scaffold(appBar: AppBar(), body: const SsLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: SsErrorState(error: e, onRetry: () => ref.invalidate(applicationProvider(applicationId))),
      ),
      data: (a) => _View(app: a),
    );
  }
}

class _View extends ConsumerWidget {
  const _View({required this.app});
  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.companyName, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'company') {
                context.push('/companies/${app.companyId}');
              } else if (v == 'delete' &&
                  await confirmDialog(context, l.deleteApplication, app.position ?? app.companyName) &&
                  context.mounted) {
                try {
                  await ref.read(crmRepositoryProvider).delete(app.id);
                  invalidateCrm(ref, companyId: app.companyId);
                  if (context.mounted) context.pop();
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'company', child: Text(l.openCompany)),
              PopupMenuItem(value: 'delete', child: Text(l.delete)),
            ],
          ),
        ],
      ),
      body: SsPage(
        onRefresh: () async => invalidateCrm(ref, applicationId: app.id, companyId: app.companyId),
        children: [
          SsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.position ?? l.applications, style: theme.textTheme.titleLarge),
                const SizedBox(height: SsSpace.sm),
                StatusBadge(app.status),
                const SizedBox(height: SsSpace.md),
                FactRow(l.contact, app.contactName ?? l.noContact),
                if (app.sentAt != null) FactRow(l.stSent, formatDate(app.sentAt!)),
                if (app.lastReplyAt != null) FactRow(l.stReplied, formatDate(app.lastReplyAt!)),
                const SizedBox(height: SsSpace.sm),
                FilledButton.icon(
                  onPressed: () => showChangeStatusSheet(context, ref, app),
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: Text(l.changeStatus),
                ),
              ],
            ),
          ),
          SsSectionHeader(
            l.followUps,
            trailing: TextButton.icon(
              onPressed: () => showAddFollowUp(context, ref, applicationId: app.id, companyId: app.companyId),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.add),
            ),
          ),
          if (app.followUps.isEmpty)
            Text(l.noFollowUps, style: theme.textTheme.bodySmall)
          else
            SsCard(
              padding: EdgeInsets.zero,
              child: Column(children: [for (final f in app.followUps) FollowUpTile(f)]),
            ),
          SsSectionHeader(l.history),
          SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final h in app.history)
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: statusColor(h.toStatus), shape: BoxShape.circle),
                    ),
                    title: Text(
                      h.fromStatus == null
                          ? '${l.created}: ${statusLabel(l, h.toStatus)}'
                          : '${statusLabel(l, h.fromStatus!)} → ${statusLabel(l, h.toStatus)}',
                    ),
                    subtitle: h.note == null || h.note == 'Created' ? null : Text(h.note!),
                    trailing: Text(formatDate(h.changedAt), style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
