import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Secondary modules reachable from Home → Tools. `phase` is the roadmap phase in which
/// the module ships; until then its screen says so honestly instead of showing fake data.
class FeatureInfo {
  const FeatureInfo(this.id, this.title, this.icon, this.phase, this.description);

  final String id;
  final String Function(AppLocalizations l) title;
  final IconData icon;
  final int phase;
  final String Function(AppLocalizations l) description;
}

final features = <FeatureInfo>[
  FeatureInfo('crm', (l) => l.featCrm, Icons.view_kanban_outlined, 4, (l) => l.featCrmDesc),
  FeatureInfo('contacts', (l) => l.featContacts, Icons.badge_outlined, 3, (l) => l.featContactsDesc),
  FeatureInfo('fleet', (l) => l.featFleet, Icons.directions_boat_outlined, 3, (l) => l.featFleetDesc),
  FeatureInfo(
    'assistant',
    (l) => l.featAssistant,
    Icons.auto_awesome_outlined,
    6,
    (l) => l.featAssistantDesc,
  ),
  FeatureInfo('documents', (l) => l.featDocuments, Icons.folder_outlined, 7, (l) => l.featDocumentsDesc),
  FeatureInfo('salaries', (l) => l.featSalaries, Icons.payments_outlined, 7, (l) => l.featSalariesDesc),
  FeatureInfo('map', (l) => l.featMap, Icons.map_outlined, 7, (l) => l.featMapDesc),
  FeatureInfo(
    'interview',
    (l) => l.featInterview,
    Icons.record_voice_over_outlined,
    7,
    (l) => l.featInterviewDesc,
  ),
  FeatureInfo('safety', (l) => l.featSafety, Icons.shield_outlined, 7, (l) => l.featSafetyDesc),
  FeatureInfo('analytics', (l) => l.featAnalytics, Icons.insights_outlined, 7, (l) => l.featAnalyticsDesc),
];

FeatureInfo? featureById(String id) {
  for (final f in features) {
    if (f.id == id) return f;
  }
  return null;
}
