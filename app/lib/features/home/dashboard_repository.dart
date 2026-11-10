import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class DashboardCounts {
  const DashboardCounts({
    required this.companies,
    required this.verifiedContacts,
    required this.applicationsSent,
    required this.repliesReceived,
    required this.pendingFollowUps,
    required this.interviews,
    required this.offers,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> j) => DashboardCounts(
    companies: j['companies'] as int,
    verifiedContacts: j['verified_contacts'] as int,
    applicationsSent: j['applications_sent'] as int,
    repliesReceived: j['replies_received'] as int,
    pendingFollowUps: j['pending_follow_ups'] as int,
    interviews: j['interviews'] as int,
    offers: j['offers'] as int,
  );

  final int companies;
  final int verifiedContacts;
  final int applicationsSent;
  final int repliesReceived;
  final int pendingFollowUps;
  final int interviews;
  final int offers;
}

class DashboardEntry {
  const DashboardEntry(this.title, this.subtitle, this.at);
  final String title;
  final String? subtitle;
  final DateTime at;
}

class DashboardSummary {
  const DashboardSummary({
    required this.counts,
    required this.followUps,
    required this.newCompanies,
    required this.activity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    List<Map<String, dynamic>> list(String k) => (j[k] as List).cast<Map<String, dynamic>>();
    return DashboardSummary(
      counts: DashboardCounts.fromJson(j['counts'] as Map<String, dynamic>),
      followUps: [
        for (final f in list('upcoming_follow_ups'))
          DashboardEntry(f['title'] as String, null, DateTime.parse(f['due_at'] as String)),
      ],
      newCompanies: [
        for (final c in list('new_companies'))
          DashboardEntry(
            c['name'] as String,
            c['country_code'] as String?,
            DateTime.parse(c['created_at'] as String),
          ),
      ],
      activity: [
        for (final a in list('recent_activity'))
          DashboardEntry(
            _humanize(a['action'] as String),
            a['entity_type'] as String?,
            DateTime.parse(a['created_at'] as String),
          ),
      ],
    );
  }

  final DashboardCounts counts;
  final List<DashboardEntry> followUps;
  final List<DashboardEntry> newCompanies;
  final List<DashboardEntry> activity;

  static String _humanize(String action) {
    final words = action.replaceAll('.', ' ').replaceAll('_', ' ');
    return words.isEmpty ? action : words[0].toUpperCase() + words.substring(1);
  }
}

final dashboardProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final json = await ref.watch(apiClientProvider).get('/api/v1/dashboard/summary');
  return DashboardSummary.fromJson(json as Map<String, dynamic>);
});
