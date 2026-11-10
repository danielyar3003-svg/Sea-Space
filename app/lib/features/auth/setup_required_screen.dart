import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/l10n.dart';

/// Shown when the app was built without Supabase settings. Sign-in cannot work,
/// so the app says so instead of pretending to be connected.
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mono = Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    return Scaffold(
      body: SsMessageState(
        icon: Icons.settings_suggest_outlined,
        iconColor: SsColors.warning,
        title: context.l10n.authNotConfigured,
        message: context.l10n.authNotConfiguredBody,
        action: SsCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              'flutter run \\\n'
              '  --dart-define=API_BASE_URL=https://api.example.com \\\n'
              '  --dart-define=SUPABASE_URL=https://<project>.supabase.co \\\n'
              '  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable key>',
              style: mono,
            ),
          ),
        ),
      ),
    );
  }
}
