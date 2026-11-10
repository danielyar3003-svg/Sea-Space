import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'profile_models.dart';

class ProfileRepository {
  const ProfileRepository(this._api);
  final ApiClient _api;

  /// Returns null when the user has not created a profile yet.
  Future<CandidateProfile?> primary() async {
    try {
      final json = await _api.get('/api/v1/profiles/primary');
      return CandidateProfile.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.notFound) return null;
      rethrow;
    }
  }

  Future<CandidateProfile> create(CandidateProfile p) async =>
      CandidateProfile.fromJson(await _api.post('/api/v1/profiles', p.toJson()) as Map<String, dynamic>);

  Future<CandidateProfile> update(String id, CandidateProfile p) async =>
      CandidateProfile.fromJson(await _api.patch('/api/v1/profiles/$id', p.toJson()) as Map<String, dynamic>);

  Future<void> addExperience(String profileId, Experience e) =>
      _api.post('/api/v1/profiles/$profileId/experience', e.toJson());

  Future<void> updateExperience(String profileId, String id, Experience e) =>
      _api.put('/api/v1/profiles/$profileId/experience/$id', e.toJson());

  Future<void> deleteExperience(String profileId, String id) =>
      _api.delete('/api/v1/profiles/$profileId/experience/$id');
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

final primaryProfileProvider = FutureProvider.autoDispose<CandidateProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).primary(),
);
