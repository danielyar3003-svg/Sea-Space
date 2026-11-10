import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../home/dashboard_repository.dart';
import 'profile_models.dart';
import 'profile_repository.dart';
import '../../core/l10n.dart';

class ProfileEditArgs {
  const ProfileEditArgs({this.existing, this.template});

  /// Profile being edited (PATCH). Null → a new profile is created.
  final CandidateProfile? existing;

  /// Pre-filled values for a new profile. Saved only when the user taps Save.
  final CandidateProfile? template;
}

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.args});
  final ProfileEditArgs? args;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  late final CandidateProfile _initial =
      widget.args?.existing ?? widget.args?.template ?? const CandidateProfile();
  late final _label = TextEditingController(text: _initial.label);
  late final _name = TextEditingController(text: _initial.fullName);
  late final _nationality = TextEditingController(text: _initial.nationality);
  late final _years = TextEditingController(
    text: _initial.yearsOfExperience == null ? '' : _initial.yearsOfExperience!.toString(),
  );
  late final _summary = TextEditingController(text: _initial.summary);
  late String? _english = _initial.englishLevel;
  late bool _approx = _initial.experienceIsApproximate;
  late final List<String> _positions = [..._initial.targetPositions];
  late final List<String> _areas = [..._initial.experienceAreas];
  late bool _addSuggestedVessel = widget.args?.template != null;
  bool _saving = false;

  bool get _isNew => widget.args?.existing == null;

  @override
  void dispose() {
    for (final c in [_label, _name, _nationality, _years, _summary]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final profile = CandidateProfile(
      label: _label.text.trim(),
      fullName: _t(_name),
      nationality: _t(_nationality),
      englishLevel: _english,
      yearsOfExperience: _t(_years) == null ? null : double.parse(_years.text.trim()),
      experienceIsApproximate: _approx,
      targetPositions: _positions,
      experienceAreas: _areas,
      summary: _t(_summary),
    );
    final repo = ref.read(profileRepositoryProvider);
    try {
      if (_isNew) {
        final created = await repo.create(profile);
        if (_addSuggestedVessel) {
          await repo.addExperience(created.id!, CandidateProfile.suggestedInitialExperience);
        }
      } else {
        await repo.update(widget.args!.existing!.id!, profile);
      }
      ref.invalidate(primaryProfileProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.couldNotSave(errorText(context, e)))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? context.l10n.newProfile : context.l10n.editProfile),
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
            if (widget.args?.template != null)
              Padding(
                padding: EdgeInsets.only(bottom: SsSpace.lg),
                child: SsCard(child: Text(context.l10n.prefilledNotice)),
              ),
            TextFormField(
              controller: _label,
              decoration: InputDecoration(
                labelText: context.l10n.profileName,
                helperText: context.l10n.profileNameHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.required : null,
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: context.l10n.fullName),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _nationality,
              decoration: InputDecoration(labelText: context.l10n.nationality),
            ),
            const SizedBox(height: SsSpace.md),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _english,
              decoration: InputDecoration(labelText: context.l10n.englishLevel),
              items: [
                DropdownMenuItem(value: null, child: Text(context.l10n.notSet)),
                for (final c in englishLevelCodes)
                  DropdownMenuItem(value: c, child: Text(englishLevelLabel(context.l10n, c)!)),
              ],
              onChanged: (v) => setState(() => _english = v),
            ),
            const SizedBox(height: SsSpace.md),
            TextFormField(
              controller: _years,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: context.l10n.yearsAtSea),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.trim());
                return (n == null || n < 0 || n > 70) ? context.l10n.yearsRange : null;
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _approx,
              onChanged: (v) => setState(() => _approx = v ?? true),
              title: Text(context.l10n.approximate),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SsSectionHeader(context.l10n.targetPositions),
            _ChipEditor(items: _positions, hint: context.l10n.addPosition, onChanged: () => setState(() {})),
            SsSectionHeader(context.l10n.experienceAreas),
            _ChipEditor(items: _areas, hint: context.l10n.addArea, onChanged: () => setState(() {})),
            SsSectionHeader(context.l10n.summary),
            TextFormField(
              controller: _summary,
              maxLines: 5,
              maxLength: 5000,
              decoration: InputDecoration(hintText: context.l10n.summaryHint),
            ),
            if (_isNew && widget.args?.template != null)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _addSuggestedVessel,
                onChanged: (v) => setState(() => _addSuggestedVessel = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  context.l10n.alsoAddVessel(CandidateProfile.suggestedInitialExperience.vesselName!),
                ),
                subtitle: Text(context.l10n.withoutDates),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipEditor extends StatefulWidget {
  const _ChipEditor({required this.items, required this.hint, required this.onChanged});
  final List<String> items;
  final String hint;
  final VoidCallback onChanged;

  @override
  State<_ChipEditor> createState() => _ChipEditorState();
}

class _ChipEditorState extends State<_ChipEditor> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    final v = _c.text.trim();
    if (v.isEmpty || widget.items.contains(v)) return;
    widget.items.add(v);
    _c.clear();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: SsSpace.sm,
          runSpacing: SsSpace.sm,
          children: [
            for (final i in widget.items)
              InputChip(
                label: Text(i),
                onDeleted: () {
                  widget.items.remove(i);
                  widget.onChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: SsSpace.sm),
        TextField(
          controller: _c,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: _add),
          ),
          onSubmitted: (_) => _add(),
        ),
      ],
    );
  }
}
