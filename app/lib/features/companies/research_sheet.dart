import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import '../../core/l10n.dart';

Map<String, String> _kindLabels(BuildContext context) => {
  'company_profile': context.l10n.findingWebsite,
  'email': context.l10n.findingEmails,
  'careers_page': context.l10n.findingCareers,
  'contact_page': context.l10n.findingContacts,
  'speculative_policy': context.l10n.findingSpeculative,
  'position_mention': context.l10n.findingPositions,
};

/// Runs website research and lets the user import findings one by one.
Future<void> showResearchSheet(
  BuildContext context, {
  required String url,
  required String companyId,
  required String companyName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: SsColors.surface,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _ResearchSheet(url: url, companyId: companyId, companyName: companyName),
    ),
  );
}

class _ResearchSheet extends ConsumerStatefulWidget {
  const _ResearchSheet({required this.url, required this.companyId, required this.companyName});
  final String url;
  final String companyId;
  final String companyName;

  @override
  ConsumerState<_ResearchSheet> createState() => _ResearchSheetState();
}

class _ResearchSheetState extends ConsumerState<_ResearchSheet> {
  late final Future<ResearchReport> _report = ref
      .read(companyRepositoryProvider)
      .researchWebsite(widget.url, companyId: widget.companyId);
  final _imported = <String>{};
  final _busy = <String>{};

  Future<void> _import(Finding f) async {
    final key = '${f.kind}|${f.value}';
    setState(() => _busy.add(key));
    try {
      await ref.read(companyRepositoryProvider).importFinding(widget.companyId, f);
      _imported.add(key);
      invalidateCompanyData(ref, widget.companyId);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(SsSpace.lg, SsSpace.lg, SsSpace.sm, SsSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.websiteResearch, style: theme.textTheme.titleMedium),
                    Text(widget.url, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<ResearchReport>(
            future: _report,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return SsMessageState(
                  icon: Icons.travel_explore,
                  title: context.l10n.readingWebsite,
                  message: context.l10n.readingWebsiteBody,
                  action: SsLoading(),
                );
              }
              if (snap.hasError) {
                return SsMessageState(
                  icon: Icons.error_outline,
                  iconColor: SsColors.warning,
                  title: context.l10n.researchFailed,
                  message: errorText(context, snap.error!),
                );
              }
              final r = snap.data!;
              final groups = <String, List<Finding>>{};
              for (final f in r.findings) {
                groups.putIfAbsent(f.kind, () => []).add(f);
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(SsSpace.lg, SsSpace.sm, SsSpace.lg, SsSpace.xxxl),
                children: [
                  Text(context.l10n.pagesReadNotice(r.pagesChecked.length), style: theme.textTheme.bodySmall),
                  if (r.findings.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: SsSpace.xl),
                      child: Text(context.l10n.nothingFound),
                    ),
                  for (final kind in _kindLabels(context).keys)
                    if (groups[kind] != null) ...[
                      SsSectionHeader(_kindLabels(context)[kind]!),
                      for (final f in groups[kind]!) _findingTile(f, theme),
                    ],
                  if (r.pagesSkipped.isNotEmpty) ...[
                    SsSectionHeader(context.l10n.skippedPages),
                    for (final s in r.pagesSkipped) Text(s, style: theme.textTheme.bodySmall),
                  ],
                  SsSectionHeader(context.l10n.limitations),
                  for (final l in r.limitations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SsSpace.xs),
                      child: Text('• $l', style: theme.textTheme.bodySmall),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _findingTile(Finding f, ThemeData theme) {
    final key = '${f.kind}|${f.value}';
    final done = _imported.contains(key);
    final hints = [
      if (f.hints['recruitment_inbox'] == true) context.l10n.hintRecruitmentInbox,
      if (f.hints['generic_inbox'] == true && f.hints['recruitment_inbox'] != true)
        context.l10n.hintGenericInbox,
      if (f.hints['domain_matches_site'] == false) context.l10n.hintDifferentDomain,
      if (f.hints['external_portal'] == true) context.l10n.hintExternalPortal,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: SsSpace.sm),
      child: SsCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(f.value, style: theme.textTheme.bodyMedium),
                  if (hints.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: SsSpace.xs),
                      child: Text(
                        hints.join(' · '),
                        style: const TextStyle(color: SsColors.warning, fontSize: 12),
                      ),
                    ),
                  if (f.excerpt.isNotEmpty && f.excerpt != f.value)
                    Padding(
                      padding: const EdgeInsets.only(top: SsSpace.xs),
                      child: Text(
                        '“${f.excerpt}”',
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: SsSpace.xs),
                  Text(context.l10n.sourceLabel(f.sourceUrl), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (f.importable)
              Padding(
                padding: const EdgeInsets.only(left: SsSpace.sm),
                child: done
                    ? const Icon(Icons.check_circle, color: SsColors.success)
                    : _busy.contains(key)
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(onPressed: () => _import(f), child: Text(context.l10n.import)),
              ),
          ],
        ),
      ),
    );
  }
}
