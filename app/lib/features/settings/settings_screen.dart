import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

/// Real server status: which integrations are configured on the backend.
final serverStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async => await ref.watch(apiClientProvider).get('/health/ready') as Map<String, dynamic>,
);

const _integrationLabels = {
  'supabase_auth': 'Supabase authentication',
  'token_encryption': 'Token encryption key',
  'anthropic': 'Claude API (AI assistant)',
  'gmail_oauth': 'Gmail OAuth',
  'gmail_pubsub': 'Gmail push notifications (Pub/Sub)',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account permanently?'),
        content: const Text(
          'All your profiles, companies, applications and other data in SEA SPACE '
          'will be deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SsColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
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
      appBar: AppBar(title: const Text('Settings')),
      body: SsPage(
        onRefresh: () => ref.refresh(serverStatusProvider.future),
        children: [
          const SsSectionHeader('Account'),
          SsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alternate_email),
                  title: Text(auth?.email ?? '—'),
                  subtitle: const Text('Signed in'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign out'),
                  onTap: () => auth?.signOut(),
                ),
              ],
            ),
          ),
          const SsSectionHeader('Server'),
          SsCard(
            padding: EdgeInsets.zero,
            child: status.when(
              loading: () => const Padding(padding: EdgeInsets.all(SsSpace.xl), child: SsLoading()),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.cloud_off_outlined, color: SsColors.warning),
                title: const Text('Server unreachable'),
                subtitle: Text('${config.apiBaseUrl}\n$e'),
                isThreeLine: true,
              ),
              data: (s) {
                final integrations = (s['integrations'] as Map).cast<String, bool>();
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dns_outlined, color: SsColors.success),
                      title: const Text('API connected'),
                      subtitle: Text('${config.apiBaseUrl} · ${s['environment']}'),
                    ),
                    for (final e in integrations.entries) ...[
                      const Divider(),
                      ListTile(
                        dense: true,
                        title: Text(_integrationLabels[e.key] ?? e.key),
                        trailing: e.value
                            ? const SsBadge('CONFIGURED', color: SsColors.success)
                            : const SsBadge('NOT CONFIGURED', color: SsColors.textTertiary),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SsSectionHeader('Privacy'),
          SsCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: SsColors.danger),
              title: const Text('Delete account', style: TextStyle(color: SsColors.danger)),
              subtitle: Text('Permanently removes your SEA SPACE data', style: theme.textTheme.bodySmall),
              onTap: () => _deleteAccount(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
