import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import '../../core/l10n.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  final _search = TextEditingController();
  CompanyQuery _query = const CompanyQuery();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setStatus(String? status) => setState(() => _query = CompanyQuery(q: _query.q, hiringStatus: status));

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companiesProvider(_query));
    final duplicates = ref.watch(duplicatesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navCompanies),
        actions: [
          IconButton(
            tooltip: context.l10n.addCompany,
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/companies/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SsSpace.gutter, SsSpace.sm, SsSpace.gutter, 0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: context.l10n.searchCompanies,
              ),
              onChanged: (v) =>
                  setState(() => _query = CompanyQuery(q: v, hiringStatus: _query.hiringStatus)),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SsSpace.gutter, vertical: SsSpace.sm),
              children: [
                _FilterChip(context.l10n.all, _query.hiringStatus == null, () => _setStatus(null)),
                for (final s in hiringStatuses)
                  _FilterChip(
                    hiringStatusLabel(context.l10n, s),
                    _query.hiringStatus == s,
                    () => _setStatus(s),
                  ),
              ],
            ),
          ),
          if (duplicates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(SsSpace.gutter, 0, SsSpace.gutter, SsSpace.sm),
              child: SsCard(
                onTap: () => context.push('/companies/duplicates'),
                child: Row(
                  children: [
                    const Icon(Icons.call_merge, color: SsColors.warning, size: 20),
                    const SizedBox(width: SsSpace.md),
                    Expanded(child: Text(context.l10n.duplicatesToReview(duplicates.length))),
                    const Icon(Icons.chevron_right, color: SsColors.textTertiary),
                  ],
                ),
              ),
            ),
          Expanded(
            child: companies.when(
              loading: () => const SsLoading(),
              error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(companiesProvider)),
              data: (list) => list.isEmpty
                  ? _Empty(filtered: _query != const CompanyQuery())
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(companiesProvider(_query).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(SsSpace.gutter, 0, SsSpace.gutter, SsSpace.xxxl),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: SsSpace.sm),
                        itemBuilder: (_, i) => _CompanyTile(list[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: SsSpace.sm),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    ),
  );
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile(this.c);
  final CompanySummary c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = [
      c.countryCode,
      c.headquarters,
      if (c.industries.isNotEmpty) c.industries.map((i) => industryLabel(context.l10n, i)).join(', '),
    ].whereType<String>().join(' · ');
    return SsCard(
      onTap: () => context.push('/companies/${c.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.name, style: theme.textTheme.titleMedium)),
              if (c.provenance.isVerified) const Icon(Icons.verified, size: 18, color: SsColors.success),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: SsSpace.xxs),
            Text(meta, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: SsSpace.sm),
          Wrap(
            spacing: SsSpace.sm,
            runSpacing: SsSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HiringStatusBadge(c.hiringStatus),
              Text(
                '${context.l10n.contactsCount(c.contactsCount)} · ${context.l10n.openVacanciesCount(c.openVacanciesCount)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    if (filtered) {
      return SsMessageState(icon: Icons.search_off, title: context.l10n.noCompaniesMatch);
    }
    return SsMessageState(
      icon: Icons.apartment_outlined,
      title: context.l10n.noCompaniesYet,
      message: context.l10n.noCompaniesBody,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(onPressed: () => context.push('/companies/new'), child: Text(context.l10n.addCompany)),
          const SizedBox(height: SsSpace.sm),
          OutlinedButton(onPressed: () => context.go('/discover'), child: Text(context.l10n.openDiscover)),
        ],
      ),
    );
  }
}
