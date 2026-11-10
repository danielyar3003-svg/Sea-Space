/// DEMO MODE ONLY (`--dart-define=DEMO_MODE=true`).
///
/// An in-memory stand-in for the SEA SPACE API so the interface can be previewed without
/// Supabase or a server. It starts EMPTY (no invented companies or statistics), keeps data
/// only for the current app session, and the app shows a permanent "Demo mode" strip.
/// It is never used in normal builds.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../core/auth/auth_service.dart';

class DemoAuthService extends AuthService {
  bool _signedIn = false;

  @override
  bool get isSignedIn => _signedIn;
  @override
  String? get email => 'demo@seaspace.local';
  @override
  Future<String?> accessToken() async => _signedIn ? 'demo' : null;
  @override
  Future<void> signIn({required String email, required String password}) async {
    _signedIn = true;
    notifyListeners();
  }

  @override
  Future<bool> signUp({required String email, required String password}) async {
    await signIn(email: email, password: password);
    return false;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }
}

class DemoBackend {
  final _profiles = <Map<String, dynamic>>[];
  final _activity = <Map<String, dynamic>>[];
  var _seq = 0;

  String _id() => 'demo-${++_seq}';
  String _now() => DateTime.now().toUtc().toIso8601String();

  void _log(String action, String entity) =>
      _activity.insert(0, {'action': action, 'entity_type': entity, 'created_at': _now()});

  http.Client client() => MockClient((req) async {
    await Future<void>.delayed(const Duration(milliseconds: 250)); // feel of a network call
    return _handle(req);
  });

  http.Response _json(Object? body, [int status = 200]) => http.Response(
    body == null ? '' : jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  http.Response _notFound(String what) => _json({'detail': '$what not found'}, 404);

  Map<String, dynamic>? _profile(String id) {
    for (final p in _profiles) {
      if (p['id'] == id) return p;
    }
    return null;
  }

  http.Response _handle(http.Request req) {
    final seg = req.url.pathSegments;
    final m = req.method;
    final body = req.body.isEmpty ? <String, dynamic>{} : jsonDecode(req.body) as Map<String, dynamic>;

    if (req.url.path == '/health/ready') {
      return _json({
        'status': 'ready',
        'environment': 'demo (no server)',
        'integrations': {
          'supabase_auth': false,
          'token_encryption': false,
          'anthropic': false,
          'gmail_oauth': false,
          'gmail_pubsub': false,
        },
      });
    }
    if (seg.length < 3 || seg[0] != 'api' || seg[1] != 'v1') return _notFound('Route');
    final rest = seg.sublist(2);

    if (rest.first == 'dashboard') {
      return _json({
        'counts': {
          'companies': 0,
          'verified_contacts': 0,
          'applications_sent': 0,
          'replies_received': 0,
          'pending_follow_ups': 0,
          'interviews': 0,
          'offers': 0,
        },
        'upcoming_follow_ups': [],
        'new_companies': [],
        'recent_activity': _activity.take(10).toList(),
      });
    }

    if (rest.first == 'me' && m == 'DELETE') {
      _profiles.clear();
      _activity.clear();
      return _json(null, 204);
    }

    if (rest.first != 'profiles') return _notFound('Route');

    // /profiles
    if (rest.length == 1) {
      if (m == 'GET') return _json(_profiles);
      final p = {
        ...body,
        'id': _id(),
        'is_primary': _profiles.isEmpty,
        'experience': <Map<String, dynamic>>[],
        'created_at': _now(),
        'updated_at': _now(),
      };
      _profiles.add(p);
      _log('profile.created', 'candidate_profile');
      return _json(p, 201);
    }

    // /profiles/primary
    if (rest[1] == 'primary') {
      for (final p in _profiles) {
        if (p['is_primary'] == true) return _json(p);
      }
      return _json({'detail': 'No profile yet'}, 404);
    }

    final profile = _profile(rest[1]);
    if (profile == null) return _notFound('Profile');

    if (rest.length == 2) {
      if (m == 'GET') return _json(profile);
      if (m == 'PATCH') {
        profile.addAll(body);
        profile['updated_at'] = _now();
        _log('profile.updated', 'candidate_profile');
        return _json(profile);
      }
    }

    // /profiles/{id}/experience[/{eid}]
    if (rest.length >= 3 && rest[2] == 'experience') {
      final list = (profile['experience'] as List).cast<Map<String, dynamic>>();
      if (rest.length == 3 && m == 'POST') {
        final e = {
          ...body,
          'id': _id(),
          'profile_id': profile['id'],
          'created_at': _now(),
          'updated_at': _now(),
        };
        list.add(e);
        _log('experience.created', 'candidate_experience');
        return _json(e, 201);
      }
      if (rest.length == 4) {
        final i = list.indexWhere((e) => e['id'] == rest[3]);
        if (i < 0) return _notFound('Experience entry');
        if (m == 'DELETE') {
          list.removeAt(i);
          _log('experience.deleted', 'candidate_experience');
          return _json(null, 204);
        }
        list[i] = {...list[i], ...body, 'updated_at': _now()};
        _log('experience.updated', 'candidate_experience');
        return _json(list[i]);
      }
    }
    return _json({'detail': 'Not supported in demo mode'}, 405);
  }
}
