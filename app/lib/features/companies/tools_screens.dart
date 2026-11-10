import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import 'contact_dialog.dart';

/// Tools → HR Contacts: every contact across companies, filterable by verification.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  String _filter = 'all';

  static const _filters = {
    'all': 'All',
    'verified': 'Verified',
    'unverified': 'Unverified',
    'generic': 'Recruitment inboxes',
    'people': 'People',
    'inferred': 'Guessed e-mails',
  };

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider(_filter));
    return Scaffold(
      appBar: AppBar(title: const Text('HR Contacts')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SsSpace.gutter, vertical: SsSpace.sm),
              children: [
                for (final e in _filters.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: SsSpace.sm),
                    child: ChoiceChip(
                      label: Text(e.value),
                      selected: _filter == e.key,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _filter = e.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: contacts.when(
              loading: () => const SsLoading(),
              error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(contactsProvider)),
              data: (list) => list.isEmpty
                  ? const SsMessageState(
                      icon: Icons.badge_outlined,
                      title: 'No contacts here',
                      message: 'Contacts are added on a company page, or imported from website research.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(SsSpace.gutter, 0, SsSpace.gutter, SsSpace.xxxl),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: SsSpace.sm),
                      itemBuilder: (_, i) => ContactCard(
                        contact: list[i],
                        showCompany: true,
                        onTap: () => context.push('/companies/${list[i].companyId}'),
                        onChanged: () => invalidateCompanyData(ref, list[i].companyId),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tools → Fleet: vessels with their owner and operator companies.
class FleetScreen extends ConsumerWidget {
  const FleetScreen({super.key});

  Future<void> _addVessel(BuildContext context, WidgetRef ref) async {
    final types = await ref.read(vesselTypesProvider.future);
    if (!context.mounted) return;
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _VesselDialog(types: types),
    );
    if (body == null || !context.mounted) return;
    try {
      await ref.read(companyRepositoryProvider).addVessel(body);
      invalidateCompanyData(ref);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _link(BuildContext context, WidgetRef ref, Vessel v) async {
    final repo = ref.read(companyRepositoryProvider);
    final companies = await repo.list(const CompanyQuery());
    if (!context.mounted) return;
    if (companies.isEmpty) {
      showInfo(context, 'Add the company first under Companies.');
      return;
    }
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _LinkDialog(companies: companies),
    );
    if (result == null || !context.mounted) return;
    try {
      await repo.linkVessel(v.id, result.$1, result.$2);
      invalidateCompanyData(ref, result.$1);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vessels = ref.watch(vesselsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Fleet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addVessel(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add vessel'),
      ),
      body: vessels.when(
        loading: () => const SsLoading(),
        error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(vesselsProvider)),
        data: (list) => list.isEmpty
            ? const SsMessageState(
                icon: Icons.directions_boat_outlined,
                title: 'No vessels yet',
                message:
                    'Add vessels and link their owner and operator. The operator is often, '
                    'but not always, the company that hires the crew.',
              )
            : SsPage(
                children: [
                  for (final v in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SsSpace.sm),
                      child: SsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_boat_outlined, color: SsColors.accent, size: 20),
                                const SizedBox(width: SsSpace.sm),
                                Expanded(child: Text(v.name, style: theme.textTheme.titleSmall)),
                                VerificationBadge(v.provenance),
                              ],
                            ),
                            const SizedBox(height: SsSpace.sm),
                            FactRow('IMO', v.imoNumber),
                            FactRow('Flag', v.flagCountryCode),
                            FactRow('Type', v.type?.name),
                            for (final l in v.links)
                              FactRow(l.role == 'owner' ? 'Owner' : 'Operator', l.companyName),
                            if (v.potentialPositions.isNotEmpty)
                              FactRow('Typical positions', v.potentialPositions.join(', ')),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _link(context, ref, v),
                                icon: const Icon(Icons.link, size: 18),
                                label: const Text('Link owner / operator'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 72),
                ],
              ),
      ),
    );
  }
}

class _VesselDialog extends StatefulWidget {
  const _VesselDialog({required this.types});
  final List<VesselType> types;

  @override
  State<_VesselDialog> createState() => _VesselDialogState();
}

class _VesselDialogState extends State<_VesselDialog> {
  final _name = TextEditingController();
  final _imo = TextEditingController();
  final _flag = TextEditingController();
  final _source = TextEditingController();
  String? _typeId;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _imo, _flag, _source]) {
      c.dispose();
    }
    super.dispose();
  }

  static bool _validImo(String v) {
    if (!RegExp(r'^\d{7}$').hasMatch(v)) return false;
    var sum = 0;
    for (var i = 0; i < 6; i++) {
      sum += int.parse(v[i]) * (7 - i);
    }
    return sum % 10 == int.parse(v[6]);
  }

  void _save() {
    final imo = _imo.text.trim();
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Vessel name is required');
      return;
    }
    if (imo.isNotEmpty && !_validImo(imo)) {
      setState(() => _error = 'IMO number is not valid (7 digits with a check digit)');
      return;
    }
    final src = _source.text.trim();
    if (src.isNotEmpty && validateUrl(src) != null) {
      setState(() => _error = 'Source: ${validateUrl(src)}');
      return;
    }
    Navigator.pop(context, {
      'name': _name.text.trim(),
      if (imo.isNotEmpty) 'imo_number': imo,
      if (_flag.text.trim().isNotEmpty) 'flag_country_code': _flag.text.trim().toUpperCase(),
      'vessel_type_id': ?_typeId,
      if (src.isNotEmpty) 'source_url': src,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add vessel'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Vessel name *'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _imo,
                keyboardType: TextInputType.number,
                maxLength: 7,
                decoration: const InputDecoration(labelText: 'IMO number', counterText: ''),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _flag,
                maxLength: 2,
                decoration: const InputDecoration(labelText: 'Flag (2 letters)', counterText: ''),
              ),
              const SizedBox(height: SsSpace.md),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _typeId,
                decoration: const InputDecoration(labelText: 'Vessel type'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unknown')),
                  for (final t in widget.types) DropdownMenuItem(value: t.id, child: Text(t.name)),
                ],
                onChanged: (v) => setState(() => _typeId = v),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _source,
                decoration: const InputDecoration(labelText: 'Source (registry page)', hintText: 'https://'),
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

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.companies});
  final List<CompanySummary> companies;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late String _company = widget.companies.first.id;
  String _role = 'operator';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link company'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _company,
              decoration: const InputDecoration(labelText: 'Company'),
              items: [for (final c in widget.companies) DropdownMenuItem(value: c.id, child: Text(c.name))],
              onChanged: (v) => setState(() => _company = v ?? _company),
            ),
            const SizedBox(height: SsSpace.md),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'owner', label: Text('Owner')),
                ButtonSegment(value: 'operator', label: Text('Operator')),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, (_company, _role)), child: const Text('Link')),
      ],
    );
  }
}

/// Review possible duplicate companies and merge them.
class DuplicatesScreen extends ConsumerWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairs = ref.watch(duplicatesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Possible duplicates')),
      body: pairs.when(
        loading: () => const SsLoading(),
        error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(duplicatesProvider)),
        data: (list) => list.isEmpty
            ? const SsMessageState(icon: Icons.check_circle_outline, title: 'No duplicates found')
            : SsPage(
                children: [
                  for (final (a, b, reason) in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SsSpace.sm),
                      child: SsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reason, style: theme.textTheme.bodySmall),
                            const SizedBox(height: SsSpace.sm),
                            for (final c in [a, b])
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text('${c.name}${c.countryCode == null ? '' : ' (${c.countryCode})'}'),
                                trailing: const Icon(Icons.chevron_right, color: SsColors.textTertiary),
                                onTap: () => context.push('/companies/${c.id}'),
                              ),
                            Text(
                              'Open the one to remove and choose "Merge into another company".',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
