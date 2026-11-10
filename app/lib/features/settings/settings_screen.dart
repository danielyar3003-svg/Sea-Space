import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/l10n.dart';
import '../../core/widgets/language_picker.dart';

/// Real server status: which integrations are configured on the backend.
final serverStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async => await ref.watch(apiClientProvider).get('/health/ready') as Map<String, dynamic>,
);

Map<String, String> _integrationLabels(BuildContext context) => {
  'supabase_auth': context.l10n.integrationSupabase,
  'token_encryption': context.l10n.integrationEncryption,
  'anthropic': context.l10n.integrationAnthropic,
  'gmail_oauth': context.l10n.integrationGmail,
  'gmail_pubsub': context.l10n.integrationPubsub,
  'web_search': context.l10n.integrationSearch,
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteAccountTitle),
        content: Text(context.l10n.deleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SsColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiClientProvider).delete('/api/v1/me');
      await ref.read(authServiceProvider)?.signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final status = ref.watch(serverStatusProvider);
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: SsPage(
        onRefresh: () => ref.refresh(serverStatusProvider.future),
        children: [
          SsSectionHeader(context.l10n.language),
          SsCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(context.l10n.language),
              subtitle: Text(currentLanguageName(context, ref)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLanguagePicker(context, ref),
            ),
          ),
          SsSectionHeader(context.l10n.account),
          SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alternate_email),
                  title: Text(auth?.email ?? context.l10n.notEnoughData),
                  subtitle: Text(context.l10n.signedIn),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(context.l10n.signOut),
                  onTap: () => auth?.signOut(),
                ),
              ],
            ),
          ),
          SsSectionHeader(context.l10n.server),
          SsCard(
            padding: EdgeInsets.zero,
            child: status.when(
              loading: () => const Padding(padding: EdgeInsets.all(SsSpace.xl), child: SsLoading()),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.cloud_off_outlined, color: SsColors.warning),
                title: Text(context.l10n.serverUnreachable),
                subtitle: Text('${config.apiBaseUrl}\n$e'),
                isThreeLine: true,
              ),
              data: (s) {
                final integrations = (s['integrations'] as Map).cast<String, bool>();
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dns_outlined, color: SsColors.success),
                      title: Text(context.l10n.apiConnected),
                      subtitle: Text('${config.apiBaseUrl} · ${s['environment']}'),
                    ),
                    for (final e in integrations.entries) ...[
                      const Divider(),
                      ListTile(
                        dense: true,
                        title: Text(_integrationLabels(context)[e.key] ?? e.key),
                        trailing: e.value
                            ? SsBadge(context.l10n.configured, color: SsColors.success)
                            : SsBadge(context.l10n.notConfigured, color: SsColors.textTertiary),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          SsSectionHeader(context.l10n.privacy),
          SsCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: SsColors.danger),
              title: Text(context.l10n.deleteAccount, style: TextStyle(color: SsColors.danger)),
              subtitle: Text(context.l10n.deleteAccountSubtitle, style: theme.textTheme.bodySmall),
              onTap: () => _deleteAccount(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
