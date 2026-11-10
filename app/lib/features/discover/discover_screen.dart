import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../companies/company_models.dart';
import '../companies/company_repository.dart';
import '../companies/company_widgets.dart';
import '../companies/research_sheet.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Employers'),
              Tab(text: 'Vacancies'),
            ],
          ),
        ),
        body: const TabBarView(children: [_EmployersTab(), _VacanciesTab()]),
      ),
    );
  }
}

class _EmployersTab extends ConsumerWidget {
  const _EmployersTab();

  Future<void> _researchSite(BuildContext context, WidgetRef ref) async {
    final input = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _ResearchDialog(),
    );
    if (input == null || !context.mounted) return;
    final (name, url) = input;
    final repo = ref.read(companyRepositoryProvider);
    String companyId;
    try {
      companyId = (await repo.create({
        'name': name,
        'websites': [
          {'url': url, 'kind': 'main'},
        ],
        'source_url': url,
      })).id;
    } on DuplicateCompanyException catch (d) {
      companyId = d.candidates.first.id; // research the company that is already saved
      if (context.mounted) showInfo(context, 'Using the saved company "${d.candidates.first.name}"');
    } catch (e) {
      if (context.mounted) showError(context, e);
      return;
    }
    invalidateCompanyData(ref, companyId);
    if (!context.mounted) return;
    await showResearchSheet(context, url: url, companyId: companyId, companyName: name);
    if (context.mounted) context.push('/companies/$companyId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final targets = ref.watch(targetsProvider);
    return SsPage(
      onRefresh: () async => invalidateCompanyData(ref),
      children: [
        const SizedBox(height: SsSpace.sm),
        SsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.travel_explore, color: SsColors.accent),
                  const SizedBox(width: SsSpace.md),
                  Expanded(child: Text('Research an employer website', style: theme.textTheme.titleSmall)),
                ],
              ),
              const SizedBox(height: SsSpace.sm),
              Text(
                'Reads the company\'s own public pages for recruitment e-mails, careers pages and '
                'open-application policies. Works even when no vacancy is advertised.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: SsSpace.md),
              FilledButton.icon(
                onPressed: () => _researchSite(context, ref),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Research a website'),
              ),
            ],
          ),
        ),
        SsSectionHeader(
          'Research targets from your brief',
          trailing: targets.maybeWhen(
            data: (t) => t.any((x) => x.companyId == null)
                ? TextButton(
                    onPressed: () async {
                      try {
                        await ref.read(companyRepositoryProvider).importTargets();
                        invalidateCompanyData(ref);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
                    child: const Text('Add all'),
                  )
                : null,
            orElse: () => null,
          ),
        ),
        targets.when(
          loading: () => const SsLoading(),
          error: (e, _) => Text('$e', style: const TextStyle(color: SsColors.danger)),
          data: (list) => SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final t in list)
                  ListTile(
                    title: Text(t.name),
                    subtitle: Text(t.companyId == null ? 'Not in your companies yet' : 'In your companies'),
                    trailing: t.companyId == null
                        ? null
                        : const Icon(Icons.chevron_right, color: SsColors.textTertiary),
                    onTap: t.companyId == null ? null : () => context.push('/companies/${t.companyId}'),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: SsSpace.sm),
          child: Text(
            'Only the names come from your brief. Country, website and hiring status stay empty '
            'until you research them. This is a starting list, not the whole market.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SsSectionHeader('Web search'),
        const _SearchCard(),
      ],
    );
  }
}

class _ResearchDialog extends StatefulWidget {
  const _ResearchDialog();

  @override
  State<_ResearchDialog> createState() => _ResearchDialogState();
}

class _ResearchDialogState extends State<_ResearchDialog> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final url = _url.text.trim();
    final urlError = validateUrl(url);
    if (name.isEmpty || urlError != null) {
      setState(() => _error = name.isEmpty ? 'Enter the company name' : urlError);
      return;
    }
    Navigator.pop(context, (name, url));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Research a website'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Company name'),
            ),
            const SizedBox(height: SsSpace.md),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Official website',
                hintText: 'https://',
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Research')),
      ],
    );
  }
}

class _SearchCard extends ConsumerStatefulWidget {
  const _SearchCard();

  @override
  ConsumerState<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<_SearchCard> {
  final _q = TextEditingController();
  bool _busy = false;
  String? _message;
  List<Finding> _results = const [];

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_q.text.trim().length < 2) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final json = await ref.read(apiClientProvider).post('/api/v1/discovery/search', {
        'query': _q.text.trim(),
      });
      final list = ((json as Map)['findings'] as List).cast<Map<String, dynamic>>();
      setState(() => _results = [for (final f in list) Finding.fromJson(f)]);
      if (_results.isEmpty) _message = 'No results.';
    } on ApiException catch (e) {
      setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _q,
            decoration: InputDecoration(
              hintText: 'e.g. krill trawler crew Norway',
              suffixIcon: _busy
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(icon: const Icon(Icons.search), onPressed: _search),
            ),
            onSubmitted: (_) => _search(),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: SsSpace.sm),
              child: Text(_message!, style: theme.textTheme.bodySmall),
            ),
          for (final r in _results)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.value),
              subtitle: Text('${r.sourceUrl}\n${r.excerpt}', maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          if (_results.isNotEmpty)
            Text(
              'Search snippets are leads only — open the page and check it.',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

// --- Vacancies ---------------------------------------------------------------------------------

class _VacanciesTab extends ConsumerStatefulWidget {
  const _VacanciesTab();

  @override
  ConsumerState<_VacanciesTab> createState() => _VacanciesTabState();
}

class _VacanciesTabState extends ConsumerState<_VacanciesTab> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final vacancies = ref.watch(vacanciesProvider(_status));
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final body = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const _VacancyDialog(),
          );
          if (body == null || !context.mounted) return;
          try {
            await ref.read(companyRepositoryProvider).addVacancy(body);
            invalidateCompanyData(ref);
          } catch (e) {
            if (context.mounted) showError(context, e);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add vacancy'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SsSpace.gutter, vertical: SsSpace.sm),
              children: [
                for (final (label, value) in [
                  ('All', null),
                  ('Active', 'active'),
                  ('Unverified', 'unverified'),
                  ('Expired', 'expired'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: SsSpace.sm),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _status == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _status = value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: vacancies.when(
              loading: () => const SsLoading(),
              error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(vacanciesProvider)),
              data: (list) => list.isEmpty
                  ? const SsMessageState(
                      icon: Icons.work_outline,
                      title: 'No vacancies saved',
                      message:
                          'Add a vacancy with the link to its posting. It stays "unverified" until '
                          'you confirm the posting is still open.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(SsSpace.gutter, 0, SsSpace.gutter, 96),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: SsSpace.sm),
                      itemBuilder: (_, i) => _vacancyCard(list[i], theme),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacancyCard(Vacancy v, ThemeData theme) {
    final repo = ref.read(companyRepositoryProvider);
    final color = switch (v.status) {
      'active' => SsColors.success,
      'expired' => SsColors.danger,
      _ => SsColors.textTertiary,
    };
    final meta = [
      v.employerName,
      v.countryCode,
      v.vesselType,
      v.rotation,
      if (v.deadline != null) 'Deadline ${formatDate(v.deadline!)}',
    ].whereType<String>().join(' · ');
    Future<void> act(Future<void> Function() f) async {
      try {
        await f();
        invalidateCompanyData(ref);
      } catch (e) {
        if (mounted) showError(context, e);
      }
    }

    return SsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.position, style: theme.textTheme.titleSmall),
                Text(meta, style: theme.textTheme.bodySmall),
                if (v.salaryText != null) Text(v.salaryText!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: SsSpace.sm),
                SsBadge(v.status.toUpperCase(), color: color),
                const SizedBox(height: SsSpace.xs),
                SelectableText(v.sourceUrl, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (a) => switch (a) {
              'verify' => act(() => repo.verifyVacancy(v.id)),
              'expire' => act(() => repo.expireVacancy(v.id)),
              _ => act(() => repo.deleteVacancy(v.id)),
            },
            itemBuilder: (_) => [
              if (v.status != 'expired')
                const PopupMenuItem(value: 'verify', child: Text('I checked: still open')),
              if (v.status != 'expired') const PopupMenuItem(value: 'expire', child: Text('Mark as expired')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _VacancyDialog extends StatefulWidget {
  const _VacancyDialog();

  @override
  State<_VacancyDialog> createState() => _VacancyDialogState();
}

class _VacancyDialogState extends State<_VacancyDialog> {
  final _employer = TextEditingController();
  final _position = TextEditingController();
  final _url = TextEditingController();
  final _country = TextEditingController();
  final _vesselType = TextEditingController();
  final _rotation = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_employer, _position, _url, _country, _vesselType, _rotation]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    if (_t(_employer) == null || _t(_position) == null) {
      setState(() => _error = 'Employer and position are required');
      return;
    }
    final urlErr = validateUrl(_url.text.trim());
    if (urlErr != null) {
      setState(() => _error = 'Link to the posting: $urlErr');
      return;
    }
    Navigator.pop(context, {
      'employer_name': _t(_employer),
      'position': _t(_position),
      'source_url': _t(_url),
      'country_code': _t(_country)?.toUpperCase(),
      'vessel_type': _t(_vesselType),
      'rotation': _t(_rotation),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add vacancy'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Position *'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _employer,
                decoration: const InputDecoration(labelText: 'Employer *'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Link to the posting *', hintText: 'https://'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _country,
                maxLength: 2,
                decoration: const InputDecoration(labelText: 'Country (2 letters)', counterText: ''),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _vesselType,
                decoration: const InputDecoration(labelText: 'Vessel type'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _rotation,
                decoration: const InputDecoration(labelText: 'Rotation'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: SsSpace.sm),
                  child: Text(_error!, style: const TextStyle(color: SsColors.danger)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
