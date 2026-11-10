import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import '../../core/l10n.dart';

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
        title: Text(context.l10n.duplicateTitle),
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
                Padding(
                  padding: EdgeInsets.only(top: SsSpace.sm),
                  child: Text(context.l10n.duplicateSameNameCountry),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          if (d.canOverride)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'create'),
              child: Text(context.l10n.createAnyway),
            ),
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
        title: Text(_isNew ? context.l10n.newCompany : context.l10n.editCompany),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SsSpace.sm),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(context.l10n.save),
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
              decoration: InputDecoration(labelText: context.l10n.companyNameRequired),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.required : null,
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
                    decoration: InputDecoration(
                      labelText: context.l10n.country,
                      hintText: 'NO',
                      counterText: '',
                    ),
                    validator: (v) =>
                        (v != null && v.trim().isNotEmpty && !RegExp(r'^[A-Za-z]{2}$').hasMatch(v.trim()))
                        ? context.l10n.twoLetters
                        : null,
                  ),
                ),
                const SizedBox(width: SsSpace.md),
                Expanded(
                  child: TextFormField(
                    controller: _hq,
                    decoration: InputDecoration(labelText: context.l10n.headquarters),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SsSpace.md),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _status,
              decoration: InputDecoration(labelText: context.l10n.hiringStatus),
              items: [
                for (final s in hiringStatuses)
                  DropdownMenuItem(value: s, child: Text(hiringStatusLabel(context.l10n, s))),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'unknown'),
            ),
            SsSectionHeader(context.l10n.industry),
            Wrap(
              spacing: SsSpace.sm,
              runSpacing: SsSpace.sm,
              children: [
                for (final code in industryCodes)
                  FilterChip(
                    label: Text(industryLabel(context.l10n, code)),
                    selected: _industries.contains(code),
                    onSelected: (on) => setState(() => on ? _industries.add(code) : _industries.remove(code)),
                  ),
              ],
            ),
            SsSectionHeader(context.l10n.recruitment),
            TextFormField(
              controller: _website,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: context.l10n.officialWebsite, hintText: 'https://'),
              validator: (v) => (v == null || v.trim().isEmpty) ? null : validateUrl(context, v.trim()),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _careers,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: context.l10n.careersPage, hintText: 'https://'),
              validator: (v) => (v == null || v.trim().isEmpty) ? null : validateUrl(context, v.trim()),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.recruitmentEmail,
                helperText: context.l10n.recruitmentEmailHelper,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty || v.contains('@')) ? null : context.l10n.invalidEmail,
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _policy,
              maxLines: 3,
              decoration: InputDecoration(labelText: context.l10n.speculativePolicy),
            ),
            SsSectionHeader(context.l10n.fleetAndNotes),
            TextFormField(
              controller: _fleet,
              maxLines: 3,
              decoration: InputDecoration(labelText: context.l10n.fleetSummary),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: InputDecoration(labelText: context.l10n.description),
            ),
          ],
        ),
      ),
    );
  }
}
