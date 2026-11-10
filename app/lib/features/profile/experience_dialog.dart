import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'profile_models.dart';

/// Add / edit one sea-service entry. Dates are optional and never filled in automatically.
class ExperienceDialog extends StatefulWidget {
  const ExperienceDialog({super.key, this.initial});
  final Experience? initial;

  @override
  State<ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<ExperienceDialog> {
  late final _vessel = TextEditingController(text: widget.initial?.vesselName);
  late final _type = TextEditingController(text: widget.initial?.vesselType);
  late final _position = TextEditingController(text: widget.initial?.position);
  late final _employer = TextEditingController(text: widget.initial?.employerName);
  late final _duties = TextEditingController(text: widget.initial?.duties.join(', '));
  late DateTime? _start = widget.initial?.startDate;
  late DateTime? _end = widget.initial?.endDate;
  String? _error;

  @override
  void dispose() {
    for (final c in [_vessel, _type, _position, _employer, _duties]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _pick(bool start) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: now,
      initialDate: (start ? _start : _end) ?? now,
    );
    if (picked != null) setState(() => start ? _start = picked : _end = picked);
  }

  void _save() {
    if (_start != null && _end != null && _end!.isBefore(_start!)) {
      setState(() => _error = 'End date is before start date.');
      return;
    }
    Navigator.pop(
      context,
      Experience(
        id: widget.initial?.id,
        vesselName: _t(_vessel),
        vesselType: _t(_type),
        position: _t(_position),
        employerName: _t(_employer),
        duties: _duties.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        startDate: _start,
        endDate: _end,
        notes: widget.initial?.notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String label(DateTime? d, String empty) => d == null
        ? empty
        : '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    return AlertDialog(
      title: Text(widget.initial?.id == null ? 'Add sea service' : 'Edit sea service'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vessel,
                decoration: const InputDecoration(labelText: 'Vessel name'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Vessel type'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _employer,
                decoration: const InputDecoration(labelText: 'Employer'),
              ),
              const SizedBox(height: SsSpace.md),
              TextField(
                controller: _duties,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Duties (comma separated)'),
              ),
              const SizedBox(height: SsSpace.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(true),
                      child: Text(label(_start, 'Start date')),
                    ),
                  ),
                  const SizedBox(width: SsSpace.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(false),
                      child: Text(label(_end, 'End date')),
                    ),
                  ),
                ],
              ),
              if (_start != null || _end != null)
                TextButton(
                  onPressed: () => setState(() => _start = _end = null),
                  child: const Text('Clear dates'),
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
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
