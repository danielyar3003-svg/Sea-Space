import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../router/app_router.dart';
import 'experience_dialog.dart';
import 'profile_edit_screen.dart';
import 'profile_models.dart';
import 'profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(primaryProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (profile.value != null)
            IconButton(
              tooltip: 'Edit profile',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(Routes.profileEdit, extra: ProfileEditArgs(existing: profile.value)),
            ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const SsLoading(),
        error: (e, _) => SsErrorState(error: e, onRetry: () => ref.invalidate(primaryProfileProvider)),
        data: (p) => p == null ? const _NoProfile() : _ProfileView(profile: p),
      ),
    );
  }
}

class _NoProfile extends StatelessWidget {
  const _NoProfile();

  @override
  Widget build(BuildContext context) {
    return SsMessageState(
      icon: Icons.person_add_alt_outlined,
      title: 'Create your maritime profile',
      message:
          'Start from the suggested profile (you can change everything before saving), '
          'or start from a blank form.',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => context.push(
              Routes.profileEdit,
              extra: const ProfileEditArgs(template: CandidateProfile.suggestedInitial),
            ),
            child: const Text('Review suggested profile'),
          ),
          const SizedBox(height: SsSpace.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.profileEdit, extra: const ProfileEditArgs()),
            child: const Text('Start blank'),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends ConsumerWidget {
  const _ProfileView({required this.profile});
  final CandidateProfile profile;

  Future<void> _editExperience(BuildContext context, WidgetRef ref, [Experience? existing]) async {
    final result = await showDialog<Experience>(
      context: context,
      builder: (_) => ExperienceDialog(initial: existing),
    );
    if (result == null) return;
    final repo = ref.read(profileRepositoryProvider);
    try {
      if (existing?.id == null) {
        await repo.addExperience(profile.id!, result);
      } else {
        await repo.updateExperience(profile.id!, existing!.id!, result);
      }
      ref.invalidate(primaryProfileProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _deleteExperience(BuildContext context, WidgetRef ref, Experience e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text(e.vesselName ?? e.position ?? 'Experience entry'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(profileRepositoryProvider).deleteExperience(profile.id!, e.id!);
      ref.invalidate(primaryProfileProvider);
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final years = profile.yearsOfExperience;
    final facts = <(String, String?)>[
      ('Nationality', profile.nationality),
      ('English', englishLevels[profile.englishLevel]),
      (
        'Sea experience',
        years == null ? null : '${profile.experienceIsApproximate ? '≈ ' : ''}${_fmt(years)} years',
      ),
    ];

    return SsPage(
      onRefresh: () => ref.refresh(primaryProfileProvider.future),
      children: [
        SsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(profile.fullName ?? 'Name not set', style: theme.textTheme.titleLarge),
                  ),
                  if (profile.isPrimary) const SsBadge('PRIMARY'),
                ],
              ),
              const SizedBox(height: SsSpace.xxs),
              Text(profile.label, style: theme.textTheme.bodySmall),
              const SizedBox(height: SsSpace.lg),
              for (final (k, v) in facts)
                Padding(
                  padding: const EdgeInsets.only(bottom: SsSpace.sm),
                  child: Row(
                    children: [
                      SizedBox(width: 130, child: Text(k, style: theme.textTheme.bodySmall)),
                      Expanded(
                        child: Text(
                          v ?? 'Not set',
                          style: v == null ? const TextStyle(color: SsColors.textTertiary) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              if (profile.summary != null && profile.summary!.isNotEmpty) ...[
                const SizedBox(height: SsSpace.sm),
                Text(profile.summary!),
              ],
            ],
          ),
        ),
        const SsSectionHeader('Target positions'),
        _Chips(profile.targetPositions, empty: 'No target positions yet.'),
        const SsSectionHeader('Experience areas'),
        _Chips(profile.experienceAreas, empty: 'No experience areas yet.'),
        SsSectionHeader(
          'Sea service',
          trailing: TextButton.icon(
            onPressed: () => _editExperience(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
        if (profile.experience.isEmpty)
          SsCard(child: Text('No vessels added yet.', style: theme.textTheme.bodySmall))
        else
          for (final e in profile.experience)
            Padding(
              padding: const EdgeInsets.only(bottom: SsSpace.sm),
              child: SsCard(
                onTap: () => _editExperience(context, ref, e),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.directions_boat_outlined, color: SsColors.accent, size: 20),
                    const SizedBox(width: SsSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.vesselName ?? 'Vessel not named', style: theme.textTheme.titleSmall),
                          Text(
                            [e.position, e.vesselType, _period(e)].whereType<String>().join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                          if (e.duties.isNotEmpty) ...[
                            const SizedBox(height: SsSpace.sm),
                            Text(e.duties.join(', '), style: theme.textTheme.bodyMedium),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteExperience(context, ref, e),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static String? _period(Experience e) {
    String f(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (e.startDate == null && e.endDate == null) return 'Dates not provided';
    return '${e.startDate == null ? '?' : f(e.startDate!)} – ${e.endDate == null ? 'present' : f(e.endDate!)}';
  }
}

class _Chips extends StatelessWidget {
  const _Chips(this.items, {required this.empty});
  final List<String> items;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Text(empty, style: Theme.of(context).textTheme.bodySmall);
    return Wrap(
      spacing: SsSpace.sm,
      runSpacing: SsSpace.sm,
      children: [for (final i in items) Chip(label: Text(i))],
    );
  }
}
