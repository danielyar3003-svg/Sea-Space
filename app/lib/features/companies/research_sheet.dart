import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';

const _kindLabels = {
  'company_profile': 'Website',
  'email': 'E-mail addresses',
  'careers_page': 'Careers pages',
  'contact_page': 'Contact pages',
  'speculative_policy': 'Speculative applications',
  'position_mention': 'Positions mentioned (keywords, not vacancies)',
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
                    Text('Website research', style: theme.textTheme.titleMedium),
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
                return const SsMessageState(
                  icon: Icons.travel_explore,
                  title: 'Reading the website…',
                  message: 'Only public pages allowed by robots.txt are read, one request at a time.',
                  action: SsLoading(),
                );
              }
              if (snap.hasError) {
                return SsMessageState(
                  icon: Icons.error_outline,
                  iconColor: SsColors.warning,
                  title: 'Research failed',
                  message: '${snap.error}',
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
                  Text(
                    'Read ${r.pagesChecked.length} page(s). Import only what you have checked; '
                    'imported data stays "unverified" until you verify it.',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (r.findings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: SsSpace.xl),
                      child: Text('Nothing relevant was found on these pages.'),
                    ),
                  for (final kind in _kindLabels.keys)
                    if (groups[kind] != null) ...[
                      SsSectionHeader(_kindLabels[kind]!),
                      for (final f in groups[kind]!) _findingTile(f, theme),
                    ],
                  if (r.pagesSkipped.isNotEmpty) ...[
                    const SsSectionHeader('Skipped pages'),
                    for (final s in r.pagesSkipped) Text(s, style: theme.textTheme.bodySmall),
                  ],
                  const SsSectionHeader('Limitations'),
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
      if (f.hints['recruitment_inbox'] == true) 'Recruitment inbox',
      if (f.hints['generic_inbox'] == true && f.hints['recruitment_inbox'] != true) 'Generic inbox',
      if (f.hints['domain_matches_site'] == false) 'Different domain from the website',
      if (f.hints['external_portal'] == true) 'External job portal',
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
                  Text('Source: ${f.sourceUrl}', style: theme.textTheme.bodySmall),
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
                    : TextButton(onPressed: () => _import(f), child: const Text('Import')),
              ),
          ],
        ),
      ),
    );
  }
}
