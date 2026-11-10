import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../companies/company_models.dart';
import '../companies/company_widgets.dart';
import 'crm_models.dart';
import 'crm_repository.dart';

Color statusColor(String s) => switch (s) {
  'hired' || 'offer' => SsColors.success,
  'interview' || 'replied' => SsColors.accent,
  'rejected' || 'no_vacancies' => SsColors.danger,
  'follow_up_needed' => SsColors.warning,
  'sent' || 'waiting_for_reply' => SsColors.accentStrong,
  _ => SsColors.textTertiary,
};

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) =>
      SsBadge(statusLabel(context.l10n, status).toUpperCase(), color: statusColor(status));
}

/// Compact card used on the board and in company pages.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard(this.app, {super.key, this.showCompany = true});
  final Application app;
  final bool showCompany;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final next = app.nextFollowUpAt;
    final overdue = next != null && next.isBefore(DateTime.now());
    return SsCard(
      onTap: () => context.push('/applications/${app.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            showCompany ? app.companyName : (app.position ?? l.applications),
            style: theme.textTheme.titleSmall,
          ),
          if (showCompany && app.position != null) Text(app.position!, style: theme.textTheme.bodySmall),
          const SizedBox(height: SsSpace.sm),
          Wrap(
            spacing: SsSpace.sm,
            runSpacing: SsSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!showCompany) StatusBadge(app.status),
              if (next != null)
                Text(
                  l.nextFollowUp(formatDate(next)),
                  style: TextStyle(fontSize: 12, color: overdue ? SsColors.warning : SsColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: pick a new status, optional history note and follow-up reminder.
Future<void> showChangeStatusSheet(BuildContext context, WidgetRef ref, Application app) async {
  final result = await showModalBottomSheet<(String, String?, int?)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SsColors.surface,
    builder: (_) => _ChangeStatusSheet(app: app),
  );
  if (result == null || !context.mounted) return;
  try {
    await ref
        .read(crmRepositoryProvider)
        .changeStatus(
          app.id,
          result.$1,
          note: result.$2,
          followUpInDays: result.$3,
          followUpTitle: context.l10n.followUpDefaultTitle,
        );
    invalidateCrm(ref, applicationId: app.id, companyId: app.companyId);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _ChangeStatusSheet extends StatefulWidget {
  const _ChangeStatusSheet({required this.app});
  final Application app;

  @override
  State<_ChangeStatusSheet> createState() => _ChangeStatusSheetState();
}

class _ChangeStatusSheetState extends State<_ChangeStatusSheet> {
  late String _status = widget.app.status;
  final _note = TextEditingController();
  int? _days;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SsSpace.lg,
        SsSpace.lg,
        SsSpace.lg,
        SsSpace.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.changeStatus, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SsSpace.md),
            Wrap(
              spacing: SsSpace.sm,
              runSpacing: SsSpace.sm,
              children: [
                for (final s in applicationStatuses)
                  ChoiceChip(
                    label: Text(statusLabel(l, s)),
                    selected: _status == s,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _status = s),
                  ),
              ],
            ),
            const SizedBox(height: SsSpace.lg),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: InputDecoration(labelText: l.statusNote),
            ),
            const SizedBox(height: SsSpace.md),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _days,
              decoration: InputDecoration(labelText: l.remindInDays),
              items: [
                DropdownMenuItem(value: null, child: Text(l.noReminder)),
                for (final d in [3, 7, 14, 30]) DropdownMenuItem(value: d, child: Text(l.daysValue('$d'))),
              ],
              onChanged: (v) => setState(() => _days = v),
            ),
            const SizedBox(height: SsSpace.lg),
            FilledButton(
              onPressed: _status == widget.app.status && _days == null
                  ? null
                  : () => Navigator.pop(context, (
                      _status,
                      _note.text.trim().isEmpty ? null : _note.text.trim(),
                      _days,
                    )),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to add a follow-up reminder with a due date.
Future<void> showAddFollowUp(
  BuildContext context,
  WidgetRef ref, {
  String? applicationId,
  required String companyId,
}) async {
  final l = context.l10n;
  final title = TextEditingController(text: l.followUpDefaultTitle);
  var due = DateTime.now().add(const Duration(days: 7));
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l.addFollowUp),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(labelText: l.followUpTitle),
              ),
              const SizedBox(height: SsSpace.md),
              OutlinedButton.icon(
                icon: const Icon(Icons.event, size: 18),
                label: Text('${l.dueDate}: ${formatDate(due)}'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    initialDate: due,
                  );
                  if (picked != null) {
                    setState(() => due = DateTime(picked.year, picked.month, picked.day, 9));
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.add)),
        ],
      ),
    ),
  );
  final text = title.text.trim();
  title.dispose();
  if (ok != true || text.isEmpty || !context.mounted) return;
  try {
    await ref
        .read(crmRepositoryProvider)
        .addFollowUp(title: text, dueAt: due, applicationId: applicationId, companyId: companyId);
    invalidateCrm(ref, applicationId: applicationId, companyId: companyId);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class FollowUpTile extends ConsumerWidget {
  const FollowUpTile(this.f, {super.key, this.showCompany = false});
  final FollowUp f;
  final bool showCompany;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: SsSpace.md),
      leading: Checkbox(
        value: f.done,
        onChanged: (v) async {
          try {
            await ref.read(crmRepositoryProvider).setFollowUpDone(f.id, v ?? false);
            invalidateCrm(ref, applicationId: f.applicationId, companyId: f.companyId);
          } catch (e) {
            if (context.mounted) showError(context, e);
          }
        },
      ),
      title: Text(
        f.title,
        style: f.done
            ? const TextStyle(decoration: TextDecoration.lineThrough, color: SsColors.textTertiary)
            : null,
      ),
      subtitle: Text(
        [if (showCompany && f.companyName != null) f.companyName!, formatDate(f.dueAt)].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: f.overdue && !f.done ? SsBadge(l.overdue, color: SsColors.warning) : null,
      onTap: f.applicationId == null
          ? (f.companyId == null ? null : () => context.push('/companies/${f.companyId}'))
          : () => context.push('/applications/${f.applicationId}'),
    );
  }
}

/// "Track application" for a company: choose a position (and optionally a contact).
Future<void> showTrackApplication(
  BuildContext context,
  WidgetRef ref, {
  required String companyId,
  required List<Contact> contacts,
  List<String> suggestedPositions = const [],
}) async {
  final l = context.l10n;
  final position = TextEditingController(text: suggestedPositions.isEmpty ? '' : suggestedPositions.first);
  String? contactId;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l.trackApplication),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: position,
                decoration: InputDecoration(labelText: l.position),
              ),
              if (suggestedPositions.length > 1) ...[
                const SizedBox(height: SsSpace.sm),
                Wrap(
                  spacing: SsSpace.xs,
                  runSpacing: SsSpace.xs,
                  children: [
                    for (final p in suggestedPositions)
                      ActionChip(label: Text(p), onPressed: () => setState(() => position.text = p)),
                  ],
                ),
              ],
              const SizedBox(height: SsSpace.md),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: contactId,
                decoration: InputDecoration(labelText: l.contact),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.noContact)),
                  for (final c in contacts)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(c.displayName(l), overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => contactId = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.add)),
        ],
      ),
    ),
  );
  final pos = position.text.trim();
  position.dispose();
  if (ok != true || !context.mounted) return;
  try {
    final app = await ref
        .read(crmRepositoryProvider)
        .create(companyId: companyId, position: pos.isEmpty ? null : pos, contactId: contactId);
    invalidateCrm(ref, companyId: companyId);
    if (context.mounted) context.push('/applications/${app.id}');
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}
