import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../companies/company_repository.dart';
import '../home/dashboard_repository.dart';
import 'crm_models.dart';

const _v1 = '/api/v1';

class CrmRepository {
  const CrmRepository(this._api);
  final ApiClient _api;

  Future<List<Application>> applications({String? companyId}) async => [
    for (final j
        in await _api.get('$_v1/applications${companyId == null ? '' : '?company_id=$companyId'}') as List)
      Application.fromJson(j as Map<String, dynamic>),
  ];

  Future<Application> get(String id) async =>
      Application.fromJson(await _api.get('$_v1/applications/$id') as Map<String, dynamic>);

  Future<Application> create({required String companyId, String? position, String? contactId}) async =>
      Application.fromJson(
        await _api.post('$_v1/applications', {
          'company_id': companyId,
          'position': ?position,
          'contact_id': ?contactId,
        }) as Map<String, dynamic>,
      );

  Future<Application> changeStatus(
    String id,
    String status, {
    String? note,
    int? followUpInDays,
    String? followUpTitle,
  }) async => Application.fromJson(
    await _api.patch('$_v1/applications/$id', {
      'status': status,
      'status_note': ?note,
      'follow_up_in_days': ?followUpInDays,
      if (followUpInDays != null) 'follow_up_title': ?followUpTitle,
    }) as Map<String, dynamic>,
  );

  Future<void> delete(String id) => _api.delete('$_v1/applications/$id');

  Future<PipelineStats> stats() async =>
      PipelineStats.fromJson(await _api.get('$_v1/applications/stats') as Map<String, dynamic>);

  Future<List<FollowUp>> followUps(String state) async => [
    for (final j in await _api.get('$_v1/follow-ups?state=$state') as List)
      FollowUp.fromJson(j as Map<String, dynamic>),
  ];

  Future<void> addFollowUp({
    required String title,
    required DateTime dueAt,
    String? applicationId,
    String? companyId,
  }) => _api.post('$_v1/follow-ups', {
    'title': title,
    'due_at': dueAt.toUtc().toIso8601String(),
    'application_id': ?applicationId,
    'company_id': ?companyId,
  });

  Future<void> setFollowUpDone(String id, bool done) =>
      _api.patch('$_v1/follow-ups/$id', {'completed': done});

  Future<void> deleteFollowUp(String id) => _api.delete('$_v1/follow-ups/$id');

  Future<List<TimelineEvent>> timeline(String companyId) async => [
    for (final j in await _api.get('$_v1/companies/$companyId/timeline') as List)
      TimelineEvent.fromJson(j as Map<String, dynamic>),
  ];
}

final crmRepositoryProvider = Provider<CrmRepository>((ref) => CrmRepository(ref.watch(apiClientProvider)));

final applicationsProvider = FutureProvider.autoDispose<List<Application>>(
  (ref) => ref.watch(crmRepositoryProvider).applications(),
);

final companyApplicationsProvider = FutureProvider.autoDispose.family<List<Application>, String>(
  (ref, companyId) => ref.watch(crmRepositoryProvider).applications(companyId: companyId),
);

final applicationProvider = FutureProvider.autoDispose.family<Application, String>(
  (ref, id) => ref.watch(crmRepositoryProvider).get(id),
);

final statsProvider = FutureProvider.autoDispose<PipelineStats>(
  (ref) => ref.watch(crmRepositoryProvider).stats(),
);

final followUpsProvider = FutureProvider.autoDispose.family<List<FollowUp>, String>(
  (ref, state) => ref.watch(crmRepositoryProvider).followUps(state),
);

final timelineProvider = FutureProvider.autoDispose.family<List<TimelineEvent>, String>(
  (ref, companyId) => ref.watch(crmRepositoryProvider).timeline(companyId),
);

/// Refresh everything that shows pipeline data after a change.
void invalidateCrm(WidgetRef ref, {String? applicationId, String? companyId}) {
  ref.invalidate(applicationsProvider);
  ref.invalidate(statsProvider);
  ref.invalidate(followUpsProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(companyApplicationsProvider);
  if (applicationId != null) ref.invalidate(applicationProvider(applicationId));
  if (companyId != null) {
    ref.invalidate(timelineProvider(companyId));
    ref.invalidate(companyDetailProvider(companyId));
  }
}
