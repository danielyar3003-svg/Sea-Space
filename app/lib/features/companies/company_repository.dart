import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../home/dashboard_repository.dart';
import 'company_models.dart';

const _v1 = '/api/v1';

/// Thrown when the server thinks a new company duplicates an existing one.
class DuplicateCompanyException implements Exception {
  const DuplicateCompanyException(this.candidates, {required this.canOverride});
  final List<({String id, String name, String? country, String reason})> candidates;
  final bool canOverride;
}

class CompanyQuery {
  const CompanyQuery({this.q = '', this.hiringStatus});
  final String q;
  final String? hiringStatus;

  String get queryString {
    final params = <String, String>{if (q.trim().isNotEmpty) 'q': q.trim(), 'hiring_status': ?hiringStatus};
    return params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
  }

  @override
  bool operator ==(Object other) =>
      other is CompanyQuery && other.q == q && other.hiringStatus == hiringStatus;
  @override
  int get hashCode => Object.hash(q, hiringStatus);
}

class CompanyRepository {
  const CompanyRepository(this._api);
  final ApiClient _api;

  Future<List<CompanySummary>> list(CompanyQuery q) async => [
    for (final j in await _api.get('$_v1/companies${q.queryString}') as List)
      CompanySummary.fromJson(j as Map<String, dynamic>),
  ];

  Future<CompanyDetail> get(String id) async =>
      CompanyDetail.fromJson(await _api.get('$_v1/companies/$id') as Map<String, dynamic>);

  Future<CompanyDetail> create(Map<String, dynamic> body) async {
    try {
      return CompanyDetail.fromJson(await _api.post('$_v1/companies', body) as Map<String, dynamic>);
    } on ApiException catch (e) {
      final d = e.details;
      if (e.kind == ApiErrorKind.conflict && d != null && d['candidates'] is List) {
        throw DuplicateCompanyException([
          for (final c in (d['candidates'] as List).cast<Map<String, dynamic>>())
            (
              id: c['id'] as String,
              name: c['name'] as String,
              country: c['country_code'] as String?,
              reason: c['reason'] as String,
            ),
        ], canOverride: d['can_override'] as bool? ?? false);
      }
      rethrow;
    }
  }

  Future<CompanyDetail> update(String id, Map<String, dynamic> body) async =>
      CompanyDetail.fromJson(await _api.patch('$_v1/companies/$id', body) as Map<String, dynamic>);

  Future<void> delete(String id) => _api.delete('$_v1/companies/$id');

  Future<CompanyDetail> verify(String id, String sourceUrl) async => CompanyDetail.fromJson(
    await _api.post('$_v1/companies/$id/verify', {'source_url': sourceUrl}) as Map<String, dynamic>,
  );

  Future<CompanyDetail> merge(String id, String intoId) async => CompanyDetail.fromJson(
    await _api.post('$_v1/companies/$id/merge', {'into_id': intoId}) as Map<String, dynamic>,
  );

  Future<List<(CompanySummary, CompanySummary, String)>> duplicates() async {
    final out = <(CompanySummary, CompanySummary, String)>[];
    for (final p in (await _api.get('$_v1/companies/duplicates') as List).cast<Map<String, dynamic>>()) {
      CompanySummary s(Map<String, dynamic> m) => CompanySummary(
        id: m['id'] as String,
        name: m['name'] as String,
        countryCode: m['country_code'] as String?,
        hiringStatus: 'unknown',
        provenance: const Provenance(status: 'unverified'),
      );
      final a = p['a'] as Map<String, dynamic>;
      out.add((s(a), s(p['b'] as Map<String, dynamic>), a['reason'] as String));
    }
    return out;
  }

  Future<void> addNote(String id, String body) => _api.post('$_v1/companies/$id/notes', {'body': body});
  Future<void> deleteNote(String id, String noteId) => _api.delete('$_v1/companies/$id/notes/$noteId');
  Future<void> addWebsite(String id, String url, String kind) =>
      _api.post('$_v1/companies/$id/websites', {'url': url, 'kind': kind});

  // Contacts
  Future<List<Contact>> contacts({String filter = 'all', String? companyId}) async => [
    for (final j in await _api.get(
      '$_v1/contacts?filter=$filter${companyId == null ? '' : '&company_id=$companyId'}',
    ) as List)
      Contact.fromJson(j as Map<String, dynamic>),
  ];
  Future<void> addContact(String companyId, Map<String, dynamic> body) =>
      _api.post('$_v1/companies/$companyId/contacts', body);
  Future<void> verifyContact(String id, String sourceUrl) =>
      _api.post('$_v1/contacts/$id/verify', {'source_url': sourceUrl});
  Future<void> deleteContact(String id) => _api.delete('$_v1/contacts/$id');

  // Fleet
  Future<List<VesselType>> vesselTypes() async => [
    for (final j in await _api.get('$_v1/vessel-types') as List)
      VesselType.fromJson(j as Map<String, dynamic>),
  ];
  Future<List<Vessel>> vessels({String? companyId}) async => [
    for (final j
        in await _api.get('$_v1/vessels${companyId == null ? '' : '?company_id=$companyId'}') as List)
      Vessel.fromJson(j as Map<String, dynamic>),
  ];
  Future<Vessel> addVessel(Map<String, dynamic> body) async =>
      Vessel.fromJson(await _api.post('$_v1/vessels', body) as Map<String, dynamic>);
  Future<void> linkVessel(String vesselId, String companyId, String role) =>
      _api.post('$_v1/vessels/$vesselId/links', {'company_id': companyId, 'role': role});
  Future<void> deleteVessel(String id) => _api.delete('$_v1/vessels/$id');

  // Vacancies
  Future<List<Vacancy>> vacancies({String? status}) async => [
    for (final j in await _api.get('$_v1/vacancies${status == null ? '' : '?status=$status'}') as List)
      Vacancy.fromJson(j as Map<String, dynamic>),
  ];
  Future<void> addVacancy(Map<String, dynamic> body) => _api.post('$_v1/vacancies', body);
  Future<void> verifyVacancy(String id) => _api.post('$_v1/vacancies/$id/verify');
  Future<void> expireVacancy(String id) => _api.patch('$_v1/vacancies/$id', {'status': 'expired'});
  Future<void> deleteVacancy(String id) => _api.delete('$_v1/vacancies/$id');

  // Discovery
  Future<ResearchReport> researchWebsite(String url, {String? companyId}) async => ResearchReport.fromJson(
    await _api.post('$_v1/discovery/website', {'url': url, 'company_id': ?companyId}) as Map<String, dynamic>,
  );
  Future<void> importFinding(String companyId, Finding f) => _api.post('$_v1/discovery/import', {
    'company_id': companyId,
    'kind': f.kind,
    'value': f.value,
    'source_url': f.sourceUrl,
    'excerpt': f.excerpt.length > 4900 ? f.excerpt.substring(0, 4900) : f.excerpt,
  });
  Future<List<ResearchTarget>> targets() async => [
    for (final j in await _api.get('$_v1/discovery/targets') as List)
      ResearchTarget.fromJson(j as Map<String, dynamic>),
  ];
  Future<void> importTargets() => _api.post('$_v1/discovery/targets/import');
}

final companyRepositoryProvider = Provider<CompanyRepository>(
  (ref) => CompanyRepository(ref.watch(apiClientProvider)),
);

final companiesProvider = FutureProvider.autoDispose.family<List<CompanySummary>, CompanyQuery>(
  (ref, q) => ref.watch(companyRepositoryProvider).list(q),
);

final companyDetailProvider = FutureProvider.autoDispose.family<CompanyDetail, String>(
  (ref, id) => ref.watch(companyRepositoryProvider).get(id),
);

final companyContactsProvider = FutureProvider.autoDispose.family<List<Contact>, String>(
  (ref, id) => ref.watch(companyRepositoryProvider).contacts(companyId: id),
);

final contactsProvider = FutureProvider.autoDispose.family<List<Contact>, String>(
  (ref, filter) => ref.watch(companyRepositoryProvider).contacts(filter: filter),
);

final vesselsProvider = FutureProvider.autoDispose<List<Vessel>>(
  (ref) => ref.watch(companyRepositoryProvider).vessels(),
);

final vesselTypesProvider = FutureProvider<List<VesselType>>(
  (ref) => ref.watch(companyRepositoryProvider).vesselTypes(),
);

final vacanciesProvider = FutureProvider.autoDispose.family<List<Vacancy>, String?>(
  (ref, status) => ref.watch(companyRepositoryProvider).vacancies(status: status),
);

final targetsProvider = FutureProvider.autoDispose<List<ResearchTarget>>(
  (ref) => ref.watch(companyRepositoryProvider).targets(),
);

final duplicatesProvider = FutureProvider.autoDispose<List<(CompanySummary, CompanySummary, String)>>(
  (ref) => ref.watch(companyRepositoryProvider).duplicates(),
);

/// Refresh everything that shows company data after a change.
void invalidateCompanyData(WidgetRef ref, [String? companyId]) {
  ref.invalidate(companiesProvider);
  ref.invalidate(contactsProvider);
  ref.invalidate(vesselsProvider);
  ref.invalidate(vacanciesProvider);
  ref.invalidate(targetsProvider);
  ref.invalidate(duplicatesProvider);
  ref.invalidate(dashboardProvider);
  if (companyId != null) {
    ref.invalidate(companyDetailProvider(companyId));
    ref.invalidate(companyContactsProvider(companyId));
  }
}
