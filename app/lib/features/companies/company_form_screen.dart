import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';

/// Create or edit a company. Nothing here marks data as verified: that needs /verify.
class CompanyFormScreen extends ConsumerStatefulWidget {
  const CompanyFormScreen({super.key, this.existing});
  final CompanyDetail? existing;

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _country = TextEditingController(text: widget.existing?.countryCode);
  late final _hq = TextEditingController(text: widget.existing?.headquarters);
  late final _website = TextEditingController(
    text: widget.existing?.websites.where((w) => w.kind == 'main').firstOrNull?.url,
  );
  late final _careers = TextEditingController(text: widget.existing?.careersUrl);
  late final _email = TextEditingController(text: widget.existing?.recruitmentEmail);
  late final _policy = TextEditingController(text: widget.existing?.speculativePolicy);
  late final _fleet = TextEditingController(text: widget.existing?.fleetSummary);
  late final _description = TextEditingController(text: widget.existing?.description);
  late String _status = widget.existing?.hiringStatus ?? 'unknown';
  late final Set<String> _industries = {...?widget.existing?.industries};
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    for (final c in [_name, _country, _hq, _website, _careers, _email, _policy, _fleet, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Map<String, dynamic> _body() => {
    'name': _name.text.trim(),
    'country_code': _t(_country)?.toUpperCase(),
    'headquarters': _t(_hq),
    'hiring_status': _status,
    'careers_url': _t(_careers),
    'recruitment_email': _t(_email),
    'speculative_policy': _t(_policy),
    'fleet_summary': _t(_fleet),
    'description': _t(_description),
    'industries': _industries.toList(),
  };

  Future<void> _save({bool allowDuplicate = false}) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(companyRepositoryProvider);
    try {
      if (_isNew) {
        final body = {
          ..._body(),
          if (_t(_website) != null)
            'websites': [
              {'url': _t(_website), 'kind': 'main'},
            ],
          'allow_duplicate': allowDuplicate,
        };
        final created = await repo.create(body);
        invalidateCompanyData(ref);
        if (mounted) context.pushReplacement('/companies/${created.id}');
      } else {
        await repo.update(widget.existing!.id, _body());
        final site = _t(_website);
        if (site != null && !widget.existing!.websites.any((w) => w.url == site)) {
          await repo.addWebsite(widget.existing!.id, site, 'main');
        }
        invalidateCompanyData(ref, widget.existing!.id);
        if (mounted) context.pop();
      }
    } on DuplicateCompanyException catch (d) {
      // Stop the spinner while the user decides.
      if (mounted) setState(() => _saving = false);
      if (mounted) await _showDuplicates(d);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showDuplicates(DuplicateCompanyException d) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('This company may already exist'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in d.candidates)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${c.name}${c.country == null ? '' : ' (${c.country})'}'),
                  subtitle: Text(c.reason),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => Navigator.pop(ctx, 'open:${c.id}'),
                ),
              if (!d.canOverride)
                const Padding(
                  padding: EdgeInsets.only(top: SsSpace.sm),
                  child: Text('A company with the same name and country is already saved.'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          if (d.canOverride)
            FilledButton(onPressed: () => Navigator.pop(ctx, 'create'), child: const Text('Create anyway')),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'create') {
      await _save(allowDuplicate: true);
    } else if (choice.startsWith('open:')) {
      context.pushReplacement('/companies/${choice.substring(5)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New company' : 'Edit company'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SsSpace.sm),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: SsPage(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Company name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: SsSpace.md),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _country,
                    maxLength: 2,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Country', hintText: 'NO', counterText: ''),
                    validator: (v) =>
                        (v != null && v.trim().isNotEmpty && !RegExp(r'^[A-Za-z]{2}$').hasMatch(v.trim()))
                        ? '2 letters'
                        : null,
                  ),
                ),
                const SizedBox(width: SsSpace.md),
                Expanded(
                  child: TextFormField(
                    controller: _hq,
                    decoration: const InputDecoration(labelText: 'Headquarters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SsSpace.md),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Hiring status'),
              items: [
                for (final e in hiringStatusLabels.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'unknown'),
            ),
            const SsSectionHeader('Industry'),
            Wrap(
              spacing: SsSpace.sm,
              runSpacing: SsSpace.sm,
              children: [
                for (final e in industryLabels.entries)
                  FilterChip(
                    label: Text(e.value),
                    selected: _industries.contains(e.key),
                    onSelected: (on) =>
                        setState(() => on ? _industries.add(e.key) : _industries.remove(e.key)),
                  ),
              ],
            ),
            const SsSectionHeader('Recruitment'),
            TextFormField(
              controller: _website,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Official website', hintText: 'https://'),
              validator: (v) => (v == null || v.trim().isEmpty) ? null : validateUrl(v.trim()),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _careers,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Careers page', hintText: 'https://'),
              validator: (v) => (v == null || v.trim().isEmpty) ? null : validateUrl(v.trim()),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Recruitment e-mail',
                helperText: 'Only an address published by the company',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty || v.contains('@')) ? null : 'Not an e-mail address',
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _policy,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Speculative application policy'),
            ),
            const SsSectionHeader('Fleet & notes'),
            TextFormField(
              controller: _fleet,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Fleet summary'),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}
