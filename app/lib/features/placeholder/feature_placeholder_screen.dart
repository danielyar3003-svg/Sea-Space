import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

/// Honest placeholder for modules scheduled in later roadmap phases.
/// It never shows sample data.
class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.phase,
    required this.description,
    this.standalone = false,
  });

  final String title;
  final IconData icon;
  final int phase;
  final String description;

  /// True when opened outside the tab shell (shows a back button).
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: standalone),
      body: SsMessageState(
        icon: icon,
        title: phase > 0 ? 'Coming in Phase $phase' : title,
        message: description,
        action: phase > 0 ? const SsBadge('NOT YET AVAILABLE', color: SsColors.textSecondary) : null,
      ),
    );
  }
}
