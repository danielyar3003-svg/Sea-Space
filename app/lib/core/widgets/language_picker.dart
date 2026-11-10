import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n.dart';
import '../theme/tokens.dart';

/// Opens the language choice: device language, English, Ukrainian, Russian.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) async {
  final current = ref.read(localeProvider)?.languageCode;
  final l = context.l10n;
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l.language),
      children: [
        for (final (code, label) in [
          ('system', l.languageSystem),
          ...supportedLanguages.entries.map((e) => (e.key, e.value)),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, code),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                if ((current ?? 'system') == code) const Icon(Icons.check, size: 18, color: SsColors.accent),
              ],
            ),
          ),
      ],
    ),
  );
  if (choice == null) return;
  await ref.read(localeProvider.notifier).set(choice == 'system' ? null : choice);
}

/// Name of the language currently shown.
String currentLanguageName(BuildContext context, WidgetRef ref) {
  final code = ref.watch(localeProvider)?.languageCode;
  return code == null ? context.l10n.languageSystem : supportedLanguages[code]!;
}

/// Compact button for screens without settings (e.g. login).
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = Localizations.localeOf(context).languageCode;
    return TextButton.icon(
      onPressed: () => showLanguagePicker(context, ref),
      icon: const Icon(Icons.language, size: 18),
      label: Text(supportedLanguages[code] ?? code),
    );
  }
}
