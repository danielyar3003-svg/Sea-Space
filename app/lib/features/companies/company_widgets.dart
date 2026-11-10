import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'company_models.dart';

class VerificationBadge extends StatelessWidget {
  const VerificationBadge(this.provenance, {super.key});
  final Provenance provenance;

  @override
  Widget build(BuildContext context) {
    final color = switch (provenance.status) {
      'verified' => SsColors.success,
      'inferred' => SsColors.warning,
      _ => SsColors.textTertiary,
    };
    return SsBadge((verificationLabels[provenance.status] ?? provenance.status).toUpperCase(), color: color);
  }
}

class HiringStatusBadge extends StatelessWidget {
  const HiringStatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'actively_hiring' => SsColors.success,
      'speculative_accepted' => SsColors.accent,
      'recruitment_agency' => SsColors.accentStrong,
      'no_current_vacancies' => SsColors.warning,
      _ => SsColors.textTertiary,
    };
    return SsBadge((hiringStatusLabels[status] ?? status).toUpperCase(), color: color);
  }
}

String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}';
}

/// Small helpers for consistent dialogs.
Future<bool> confirmDialog(
  BuildContext context,
  String title,
  String message, {
  String action = 'Delete',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
      ],
    ),
  );
  return ok == true;
}

Future<String?> textInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? hint,
  String? initial,
  String action = 'Save',
  int maxLines = 1,
  String? Function(String)? validator,
}) {
  final controller = TextEditingController(text: initial);
  String? error;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: label, hintText: hint, errorText: error),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              final e = v.isEmpty ? 'Required' : validator?.call(v);
              if (e != null) {
                setState(() => error = e);
                return;
              }
              Navigator.pop(ctx, v);
            },
            child: Text(action),
          ),
        ],
      ),
    ),
  );
}

String? validateUrl(String v) {
  final uri = Uri.tryParse(v);
  return (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty)
      ? 'Enter a full link starting with https://'
      : null;
}

void showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
}

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Label + value row used on detail screens.
class FactRow extends StatelessWidget {
  const FactRow(this.label, this.value, {super.key, this.selectable = false});
  final String label;
  final String? value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = value == null ? const TextStyle(color: SsColors.textTertiary) : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: SsSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(
            child: selectable && value != null
                ? SelectableText(value!, style: style)
                : Text(value ?? 'Unknown', style: style),
          ),
        ],
      ),
    );
  }
}
