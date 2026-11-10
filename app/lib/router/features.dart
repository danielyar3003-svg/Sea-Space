import 'package:flutter/material.dart';

/// Secondary modules reachable from Home → Tools. `phase` is the roadmap phase in which
/// the module ships; until then its screen says so honestly instead of showing fake data.
class FeatureInfo {
  const FeatureInfo(this.id, this.title, this.icon, this.phase, this.description);

  final String id;
  final String title;
  final IconData icon;
  final int phase;
  final String description;
}

const features = <FeatureInfo>[
  FeatureInfo(
    'crm',
    'CRM Pipeline',
    Icons.view_kanban_outlined,
    4,
    'Kanban board of applications from Discovered to Hired, with timelines and follow-ups.',
  ),
  FeatureInfo(
    'contacts',
    'HR Contacts',
    Icons.badge_outlined,
    3,
    'Publicly listed crewing and recruitment contacts, with source and verification date.',
  ),
  FeatureInfo(
    'fleet',
    'Fleet',
    Icons.directions_boat_outlined,
    3,
    'Vessels linked to their owners and operators — which are not always the employer.',
  ),
  FeatureInfo(
    'assistant',
    'AI Assistant',
    Icons.auto_awesome_outlined,
    6,
    'Cover letters, replies, translations (EN / UK / RU). Nothing is sent without your approval.',
  ),
  FeatureInfo(
    'documents',
    'Documents',
    Icons.folder_outlined,
    7,
    'Private vault for CVs, Seaman\'s Book, STCW, medicals — with expiry reminders.',
  ),
  FeatureInfo(
    'salaries',
    'Salary Database',
    Icons.payments_outlined,
    7,
    'Compare offers and reported salaries, normalised to the same pay period.',
  ),
  FeatureInfo(
    'map',
    'Recruitment Map',
    Icons.map_outlined,
    7,
    'Employers, crewing offices and ports on a map.',
  ),
  FeatureInfo(
    'interview',
    'Interview Trainer',
    Icons.record_voice_over_outlined,
    7,
    'Practise maritime interviews in English with feedback.',
  ),
  FeatureInfo(
    'safety',
    'Scam Detector',
    Icons.shield_outlined,
    7,
    'Checks domains, payment requests and suspicious offers, with evidence.',
  ),
  FeatureInfo(
    'analytics',
    'Analytics',
    Icons.insights_outlined,
    7,
    'Response rates and pipeline statistics from your own data.',
  ),
];

FeatureInfo? featureById(String id) {
  for (final f in features) {
    if (f.id == id) return f;
  }
  return null;
}
