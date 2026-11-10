import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import 'contact_dialog.dart';
import 'research_sheet.dart';

class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.companyId});
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(companyDetailProvider(companyId));
    return detail.when(
      loading: () => Scaffold(appBar: AppBar(), body: const SsLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: SsErrorState(error: e, onRetry: () => ref.invalidate(companyDetailProvider(companyId))),
      ),
      data: (c) => _CompanyView(company: c),
    );
  }
}

enum _Action { edit, verify, research, merge, delete }

class _CompanyView extends ConsumerWidget {
  const _CompanyView({required this.company});
  final CompanyDetail company;

  String get _id => company.id;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    String? done,
  }) async {
    try {
      await action();
      invalidateCompanyData(ref, _id);
      if (done != null && context.mounted) showInfo(context, done);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, _Action a) async {
    final repo = ref.read(companyRepositoryProvider);
    switch (a) {
      case _Action.edit:
        context.push('/companies/$_id/edit', extra: company);
      case _Action.verify:
        final url = await textInputDialog(
          context,
          title: 'Mark as verified',
          label: 'Page where you checked these details',
          hint: 'https://',
          action: 'Verify',
          validator: validateUrl,
        );
        if (url != null && context.mounted) {
          await _run(context, ref, () => repo.verify(_id, url), done: 'Marked as verified');
        }
      case _Action.research:
        await _research(context);
      case _Action.merge:
        await _merge(context, ref);
      case _Action.delete:
        if (await confirmDialog(
              context,
              'Delete ${company.name}?',
              'The company is removed from your list.',
            ) &&
            context.mounted) {
          await _run(context, ref, () => repo.delete(_id));
          if (context.mounted) context.pop();
        }
    }
  }

  Future<void> _research(BuildContext context) async {
    final known = [...company.websites.map((w) => w.url), ?company.careersUrl];
    String? url = known.isEmpty ? null : known.first;
    url = await textInputDialog(
      context,
      title: 'Research website',
      label: 'Company website',
      hint: 'https://',
      initial: url,
      action: 'Research',
      validator: validateUrl,
    );
    if (url == null || !context.mounted) return;
    await showResearchSheet(context, url: url, companyId: _id, companyName: company.name);
  }

  Future<void> _merge(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(companyRepositoryProvider);
    final all = await repo.list(const CompanyQuery());
    if (!context.mounted) return;
    final others = all.where((c) => c.id != _id).toList();
    final target = await showDialog<CompanySummary>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Merge ${company.name} into…'),
        children: [
          if (others.isEmpty)
            const Padding(padding: EdgeInsets.all(SsSpace.lg), child: Text('No other companies.')),
          for (final o in others)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, o),
              child: Text('${o.name}${o.countryCode == null ? '' : ' (${o.countryCode})'}'),
            ),
        ],
      ),
    );
    if (target == null || !context.mounted) return;
    if (!await confirmDialog(
      context,
      'Merge into ${target.name}?',
      'Contacts, notes, sources, vacancies and vessel links move to ${target.name}. '
          '${company.name} is then hidden.',
      action: 'Merge',
    )) {
      return;
    }
    if (!context.mounted) return;
    await _run(context, ref, () => repo.merge(_id, target.id));
    if (context.mounted) context.pushReplacement('/companies/${target.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contacts = ref.watch(companyContactsProvider(_id));
    final repo = ref.read(companyRepositoryProvider);
    final p = company.provenance;

    return Scaffold(
      appBar: AppBar(
        title: Text(company.name, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<_Action>(
            onSelected: (a) => _onAction(context, ref, a),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _Action.edit, child: Text('Edit')),
              PopupMenuItem(value: _Action.research, child: Text('Research website')),
              PopupMenuItem(value: _Action.verify, child: Text('Mark as verified…')),
              PopupMenuItem(value: _Action.merge, child: Text('Merge into another company…')),
              PopupMenuItem(value: _Action.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: SsPage(
        onRefresh: () async => invalidateCompanyData(ref, _id),
        children: [
          SsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: SsSpace.sm,
                  runSpacing: SsSpace.xs,
                  children: [HiringStatusBadge(company.hiringStatus), VerificationBadge(p)],
                ),
                const SizedBox(height: SsSpace.md),
                FactRow('Country', company.countryCode),
                FactRow('Headquarters', company.headquarters),
                FactRow(
                  'Industry',
                  company.industries.isEmpty
                      ? null
                      : company.industries.map((i) => industryLabels[i] ?? i).join(', '),
                ),
                FactRow('Careers page', company.careersUrl, selectable: true),
                FactRow('Recruitment e-mail', company.recruitmentEmail, selectable: true),
                FactRow('Speculative', company.speculativePolicy),
                if (p.lastVerifiedAt != null) FactRow('Verified on', formatDate(p.lastVerifiedAt!)),
                if (p.sourceUrl != null) FactRow('Source', p.sourceUrl, selectable: true),
              ],
            ),
          ),
          const SizedBox(height: SsSpace.md),
          OutlinedButton.icon(
            onPressed: () => _research(context),
            icon: const Icon(Icons.travel_explore, size: 18),
            label: const Text('Research company website'),
          ),
          SsSectionHeader(
            'HR contacts',
            trailing: TextButton.icon(
              onPressed: () async {
                final body = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => const ContactDialog(),
                );
                if (body != null && context.mounted) {
                  await _run(context, ref, () => repo.addContact(_id, body));
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ),
          contacts.when(
            loading: () => const Padding(padding: EdgeInsets.all(SsSpace.lg), child: SsLoading()),
            error: (e, _) => Text('$e', style: const TextStyle(color: SsColors.danger)),
            data: (list) => list.isEmpty
                ? SsCard(child: Text('No contacts yet.', style: theme.textTheme.bodySmall))
                : Column(
                    children: [
                      for (final c in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: SsSpace.sm),
                          child: ContactCard(contact: c, onChanged: () => invalidateCompanyData(ref, _id)),
                        ),
                    ],
                  ),
          ),
          const SsSectionHeader('Fleet'),
          if (company.vessels.isEmpty)
            SsCard(
              child: Text(
                'No vessels linked. Add them under Tools → Fleet.',
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            SsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final v in company.vessels)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.directions_boat_outlined, size: 20),
                      title: Text(v.vesselName),
                      subtitle: Text(
                        v.role == 'owner'
                            ? 'Owner'
                            : 'Operator · crewing employer: ${v.isCrewingEmployer == null ? 'unknown' : (v.isCrewingEmployer! ? 'yes' : 'no')}',
                      ),
                    ),
                ],
              ),
            ),
          if (company.fleetSummary != null) ...[
            const SizedBox(height: SsSpace.sm),
            Text(company.fleetSummary!, style: theme.textTheme.bodyMedium),
          ],
          SsSectionHeader(
            'Notes',
            trailing: TextButton.icon(
              onPressed: () async {
                final text = await textInputDialog(context, title: 'Add note', label: 'Note', maxLines: 5);
                if (text != null && context.mounted) await _run(context, ref, () => repo.addNote(_id, text));
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ),
          if (company.notes.isEmpty)
            Text('No notes.', style: theme.textTheme.bodySmall)
          else
            for (final n in company.notes)
              Padding(
                padding: const EdgeInsets.only(bottom: SsSpace.sm),
                child: SsCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.body),
                            const SizedBox(height: SsSpace.xs),
                            Text(formatDate(n.createdAt), style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete note',
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _run(context, ref, () => repo.deleteNote(_id, n.id)),
                      ),
                    ],
                  ),
                ),
              ),
          const SsSectionHeader('Websites & sources'),
          SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (company.websites.isEmpty && company.sources.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(SsSpace.lg),
                    child: Text('No sources recorded.', style: theme.textTheme.bodySmall),
                  ),
                for (final w in company.websites)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.language, size: 20),
                    title: SelectableText(w.url),
                    subtitle: Text(w.kind),
                  ),
                for (final s in company.sources)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.link, size: 20),
                    title: s.url == null ? Text(s.title ?? s.type) : SelectableText(s.url!),
                    subtitle: Text(
                      '${s.title ?? s.type.replaceAll('_', ' ')} · ${formatDate(s.retrievedAt)}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
