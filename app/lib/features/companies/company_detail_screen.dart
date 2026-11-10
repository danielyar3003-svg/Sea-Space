import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../crm/crm_models.dart';
import '../crm/crm_repository.dart';
import '../crm/crm_widgets.dart';
import '../profile/profile_repository.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import 'contact_dialog.dart';
import 'research_sheet.dart';
import '../../core/l10n.dart';

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
          title: context.l10n.markVerified,
          label: context.l10n.verifiedPageLabel,
          hint: 'https://',
          action: context.l10n.verify,
          validator: (v) => validateUrl(context, v),
        );
        if (url != null && context.mounted) {
          await _run(context, ref, () => repo.verify(_id, url), done: context.l10n.markedVerified);
        }
      case _Action.research:
        await _research(context);
      case _Action.merge:
        await _merge(context, ref);
      case _Action.delete:
        if (await confirmDialog(
              context,
              context.l10n.deleteCompanyTitle(company.name),
              context.l10n.deleteCompanyBody,
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
      title: context.l10n.researchWebsite,
      label: context.l10n.companyWebsite,
      hint: 'https://',
      initial: url,
      action: context.l10n.research,
      validator: (v) => validateUrl(context, v),
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
        title: Text(context.l10n.mergeInto(company.name)),
        children: [
          if (others.isEmpty)
            Padding(padding: EdgeInsets.all(SsSpace.lg), child: Text(context.l10n.noOtherCompanies)),
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
      context.l10n.mergeConfirmTitle(target.name),
      context.l10n.mergeConfirmBody(target.name, company.name),
      action: context.l10n.merge,
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
            itemBuilder: (_) => [
              PopupMenuItem(value: _Action.edit, child: Text(context.l10n.edit)),
              PopupMenuItem(value: _Action.research, child: Text(context.l10n.researchWebsite)),
              PopupMenuItem(value: _Action.verify, child: Text(context.l10n.markVerifiedMenu)),
              PopupMenuItem(value: _Action.merge, child: Text(context.l10n.mergeMenu)),
              PopupMenuItem(value: _Action.delete, child: Text(context.l10n.delete)),
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
                FactRow(context.l10n.country, company.countryCode),
                FactRow(context.l10n.headquarters, company.headquarters),
                FactRow(
                  context.l10n.industry,
                  company.industries.isEmpty
                      ? null
                      : company.industries.map((i) => industryLabel(context.l10n, i)).join(', '),
                ),
                FactRow(context.l10n.careersPage, company.careersUrl, selectable: true),
                FactRow(context.l10n.recruitmentEmail, company.recruitmentEmail, selectable: true),
                FactRow(context.l10n.speculativeShort, company.speculativePolicy),
                if (p.lastVerifiedAt != null) FactRow(context.l10n.verifiedOn, formatDate(p.lastVerifiedAt!)),
                if (p.sourceUrl != null) FactRow(context.l10n.source, p.sourceUrl, selectable: true),
              ],
            ),
          ),
          const SizedBox(height: SsSpace.md),
          OutlinedButton.icon(
            onPressed: () => _research(context),
            icon: const Icon(Icons.travel_explore, size: 18),
            label: Text(context.l10n.researchCompanyWebsite),
          ),
          SsSectionHeader(
            context.l10n.hrContacts,
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
              label: Text(context.l10n.add),
            ),
          ),
          contacts.when(
            loading: () => const Padding(padding: EdgeInsets.all(SsSpace.lg), child: SsLoading()),
            error: (e, _) => Text('$e', style: const TextStyle(color: SsColors.danger)),
            data: (list) => list.isEmpty
                ? SsCard(child: Text(context.l10n.noContactsYet, style: theme.textTheme.bodySmall))
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
          SsSectionHeader(
            context.l10n.applications,
            trailing: TextButton.icon(
              onPressed: () async {
                final profile = await ref.read(primaryProfileProvider.future).catchError((_) => null);
                if (!context.mounted) return;
                await showTrackApplication(
                  context,
                  ref,
                  companyId: _id,
                  contacts: contacts.value ?? const [],
                  suggestedPositions: profile?.targetPositions ?? const [],
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.trackApplication),
            ),
          ),
          ref
              .watch(companyApplicationsProvider(_id))
              .when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text(errorText(context, e), style: const TextStyle(color: SsColors.danger)),
                data: (apps) => apps.isEmpty
                    ? Text(context.l10n.noApplicationsForCompany, style: theme.textTheme.bodySmall)
                    : Column(
                        children: [
                          for (final a in apps)
                            Padding(
                              padding: const EdgeInsets.only(bottom: SsSpace.sm),
                              child: ApplicationCard(a, showCompany: false),
                            ),
                        ],
                      ),
              ),
          SsSectionHeader(context.l10n.fleet),
          if (company.vessels.isEmpty)
            SsCard(child: Text(context.l10n.noVesselsLinked, style: theme.textTheme.bodySmall))
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
                            ? context.l10n.owner
                            : context.l10n.operatorCrewing(
                                v.isCrewingEmployer == null
                                    ? context.l10n.unknownLower
                                    : (v.isCrewingEmployer! ? context.l10n.yes : context.l10n.no),
                              ),
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
            context.l10n.notes,
            trailing: TextButton.icon(
              onPressed: () async {
                final text = await textInputDialog(
                  context,
                  title: context.l10n.addNote,
                  label: context.l10n.note,
                  maxLines: 5,
                );
                if (text != null && context.mounted) await _run(context, ref, () => repo.addNote(_id, text));
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.add),
            ),
          ),
          if (company.notes.isEmpty)
            Text(context.l10n.noNotes, style: theme.textTheme.bodySmall)
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
                        tooltip: context.l10n.deleteNote,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _run(context, ref, () => repo.deleteNote(_id, n.id)),
                      ),
                    ],
                  ),
                ),
              ),
          SsSectionHeader(context.l10n.timeline),
          ref
              .watch(timelineProvider(_id))
              .when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text(errorText(context, e), style: const TextStyle(color: SsColors.danger)),
                data: (events) => events.isEmpty
                    ? Text(context.l10n.noTimeline, style: theme.textTheme.bodySmall)
                    : SsCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final e in events.take(30))
                              ListTile(
                                dense: true,
                                title: Text(timelineLabel(context.l10n, e.kind)),
                                subtitle: Text(
                                  e.kind == 'status_changed' ? statusLabel(context.l10n, e.title) : e.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(formatDate(e.at), style: theme.textTheme.bodySmall),
                              ),
                          ],
                        ),
                      ),
              ),
          SsSectionHeader(context.l10n.websitesSources),
          SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (company.websites.isEmpty && company.sources.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(SsSpace.lg),
                    child: Text(context.l10n.noSources, style: theme.textTheme.bodySmall),
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
