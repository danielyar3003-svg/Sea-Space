import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';

const emailStatusLabels = {
  'public_verified': 'Published · verified',
  'public_unverified': 'Published · not yet verified',
  'inferred': 'Guessed (not published)',
  'user_provided': 'Entered by you',
};

/// Add a contact. The user states where the address comes from; a guessed address is
/// stored as "inferred" and can never become verified.
class ContactDialog extends StatefulWidget {
  const ContactDialog({super.key});

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _email = TextEditingController();
  final _source = TextEditingController();
  bool _generic = false;
  String _origin = 'user_provided';
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _title, _email, _source]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    final email = _t(_email);
    if (_t(_name) == null && email == null) {
      setState(() => _error = 'Enter a name or an e-mail address');
      return;
    }
    if (email != null && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Not an e-mail address');
      return;
    }
    final src = _t(_source);
    if (_origin == 'public_unverified' && (src == null || validateUrl(src) != null)) {
      setState(() => _error = 'Add the link of the page where the address is published');
      return;
    }
    Navigator.pop(context, {
      'contact_kind': _generic ? 'generic_inbox' : 'person',
      'full_name': _t(_name),
      'job_title': _t(_title),
      'email': email,
      if (email != null) 'email_status': _origin,
      'source_url': ?src,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add contact'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Generic recruitment inbox'),
                subtitle: const Text('e.g. jobs@, crew@ — not a named person'),
                value: _generic,
                onChanged: (v) => setState(() => _generic = v),
              ),
              if (!_generic) ...[
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: SsSpace.md),
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Job title', hintText: 'Crewing Manager'),
                ),
                const SizedBox(height: SsSpace.md),
              ],
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: SsSpace.md),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _origin,
                decoration: const InputDecoration(labelText: 'Where is this address from?'),
                items: [
                  for (final k in ['public_unverified', 'user_provided', 'inferred'])
                    DropdownMenuItem(value: k, child: Text(emailStatusLabels[k]!)),
                ],
                onChanged: (v) => setState(() => _origin = v ?? 'user_provided'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _source,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Source page', hintText: 'https://'),
              ),
              if (_origin == 'inferred')
                const Padding(
                  padding: EdgeInsets.only(top: SsSpace.sm),
                  child: Text(
                    'Guessed addresses are kept separate and can never be marked verified.',
                    style: TextStyle(color: SsColors.warning),
                  ),
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

/// One contact with its provenance and actions.
class ContactCard extends ConsumerWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onChanged,
    this.showCompany = false,
    this.onTap,
  });
  final Contact contact;
  final VoidCallback onChanged;
  final bool showCompany;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = contact;
    final repo = ref.read(companyRepositoryProvider);
    final lines = [
      if (showCompany) c.companyName,
      c.jobTitle,
      if (c.fullName != null) c.email,
    ].whereType<String>();
    return SsCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(c.isGeneric ? Icons.inbox_outlined : Icons.person_outline, size: 20, color: SsColors.accent),
          const SizedBox(width: SsSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(c.fullName ?? c.email ?? c.displayName, style: theme.textTheme.titleSmall),
                for (final l in lines) Text(l, style: theme.textTheme.bodySmall),
                const SizedBox(height: SsSpace.sm),
                Wrap(
                  spacing: SsSpace.sm,
                  runSpacing: SsSpace.xs,
                  children: [
                    VerificationBadge(c.provenance),
                    if (c.emailStatus == 'inferred') const SsBadge('GUESSED E-MAIL', color: SsColors.warning),
                    if (c.domainMatchesCompany == false)
                      const SsBadge('DIFFERENT DOMAIN', color: SsColors.warning),
                  ],
                ),
                if (c.provenance.sourceUrl != null) ...[
                  const SizedBox(height: SsSpace.xs),
                  Text('Source: ${c.provenance.sourceUrl}', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (a) async {
              try {
                if (a == 'verify') {
                  final url = await textInputDialog(
                    context,
                    title: 'Verify contact',
                    label: 'Page where this contact is published',
                    hint: 'https://',
                    initial: c.provenance.sourceUrl,
                    action: 'Verify',
                    validator: validateUrl,
                  );
                  if (url == null) return;
                  await repo.verifyContact(c.id, url);
                } else if (a == 'delete') {
                  if (!context.mounted || !await confirmDialog(context, 'Delete contact?', c.displayName)) {
                    return;
                  }
                  await repo.deleteContact(c.id);
                }
                onChanged();
              } catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
            itemBuilder: (_) => [
              if (!c.provenance.isVerified && c.emailStatus != 'inferred')
                const PopupMenuItem(value: 'verify', child: Text('Mark as verified…')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
