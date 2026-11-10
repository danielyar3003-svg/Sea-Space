import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';
import 'company_repository.dart';
import 'company_widgets.dart';
import '../../core/l10n.dart';

Map<String, String> emailStatusLabels(BuildContext context) => {
  'public_verified': context.l10n.emailPublishedVerified,
  'public_unverified': context.l10n.emailPublishedUnverified,
  'inferred': context.l10n.emailGuessed,
  'user_provided': context.l10n.emailEnteredByYou,
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
      setState(() => _error = context.l10n.enterNameOrEmail);
      return;
    }
    if (email != null && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = context.l10n.invalidEmail);
      return;
    }
    final src = _t(_source);
    if (_origin == 'public_unverified' && (src == null || validateUrl(context, src) != null)) {
      setState(() => _error = context.l10n.addSourceLink);
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
      title: Text(context.l10n.addContact),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.genericInbox),
                subtitle: Text(context.l10n.genericInboxHint),
                value: _generic,
                onChanged: (v) => setState(() => _generic = v),
              ),
              if (!_generic) ...[
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: context.l10n.fullName),
                ),
                const SizedBox(height: SsSpace.md),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(labelText: context.l10n.jobTitle, hintText: 'Crewing Manager'),
                ),
                const SizedBox(height: SsSpace.md),
              ],
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: context.l10n.email),
              ),
              const SizedBox(height: SsSpace.md),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _origin,
                decoration: InputDecoration(labelText: context.l10n.emailOrigin),
                items: [
                  for (final k in ['public_unverified', 'user_provided', 'inferred'])
                    DropdownMenuItem(value: k, child: Text(emailStatusLabels(context)[k]!)),
                ],
                onChanged: (v) => setState(() => _origin = v ?? 'user_provided'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _source,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.l10n.sourcePage, hintText: 'https://'),
              ),
              if (_origin == 'inferred')
                Padding(
                  padding: EdgeInsets.only(top: SsSpace.sm),
                  child: Text(context.l10n.guessedWarning, style: TextStyle(color: SsColors.warning)),
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
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: _save, child: Text(context.l10n.add)),
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
                SelectableText(
                  c.fullName ?? c.email ?? c.displayName(context.l10n),
                  style: theme.textTheme.titleSmall,
                ),
                for (final l in lines) Text(l, style: theme.textTheme.bodySmall),
                const SizedBox(height: SsSpace.sm),
                Wrap(
                  spacing: SsSpace.sm,
                  runSpacing: SsSpace.xs,
                  children: [
                    VerificationBadge(c.provenance),
                    if (c.emailStatus == 'inferred')
                      SsBadge(context.l10n.guessedEmailBadge, color: SsColors.warning),
                    if (c.domainMatchesCompany == false)
                      SsBadge(context.l10n.differentDomainBadge, color: SsColors.warning),
                  ],
                ),
                if (c.provenance.sourceUrl != null) ...[
                  const SizedBox(height: SsSpace.xs),
                  Text(context.l10n.sourceLabel(c.provenance.sourceUrl!), style: theme.textTheme.bodySmall),
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
                    title: context.l10n.verifyContact,
                    label: context.l10n.contactPublishedPage,
                    hint: 'https://',
                    initial: c.provenance.sourceUrl,
                    action: context.l10n.verify,
                    validator: (v) => validateUrl(context, v),
                  );
                  if (url == null) return;
                  await repo.verifyContact(c.id, url);
                } else if (a == 'delete') {
                  if (!context.mounted ||
                      !await confirmDialog(
                        context,
                        context.l10n.deleteContactTitle,
                        c.displayName(context.l10n),
                      )) {
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
                PopupMenuItem(value: 'verify', child: Text(context.l10n.markVerifiedMenu)),
              PopupMenuItem(value: 'delete', child: Text(context.l10n.delete)),
            ],
          ),
        ],
      ),
    );
  }
}
