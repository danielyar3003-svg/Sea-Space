/// DEMO MODE ONLY: in-memory version of the Phase 3 endpoints (companies, contacts, fleet,
/// vacancies, research targets). It starts empty and never invents companies or contacts.
/// Website research and web search need the real server and say so.
library;

import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

class DemoCompanies {
  DemoCompanies({required this.id, required this.now, required this.json, required this.log});

  final String Function() id;
  final String Function() now;
  final http.Response Function(Object? body, [int status]) json;
  final void Function(String action, String entity) log;

  final _companies = <Json>[];
  final _contacts = <Json>[];
  final _vessels = <Json>[];
  final _vacancies = <Json>[];
  final _apps = <Json>[];
  final _followUps = <Json>[];

  static const targets = [
    'Cornelis Vrolijk',
    'Aker BioMarine',
    'Nergård',
    'Samherji',
    'Qrill Company',
    'HAV Agency',
  ];

  static final vesselTypes = [
    for (final (code, name, positions) in [
      ('stern_trawler', 'Stern trawler', ['Trawl Deckhand', 'Deckhand', 'AB']),
      (
        'factory_trawler',
        'Factory trawler',
        ['Trawl Deckhand', 'Fish Factory Worker', 'Processing Crew', 'AB'],
      ),
      ('krill_trawler', 'Krill trawler', ['Fish Factory Worker', 'Processing Crew', 'Deckhand', 'AB']),
      ('pelagic_trawler', 'Pelagic trawler', ['Trawl Deckhand', 'Deckhand', 'AB']),
      ('longliner', 'Longliner', ['Deckhand', 'Fish Factory Worker', 'AB']),
      ('purse_seiner', 'Purse seiner', ['Deckhand', 'AB']),
      ('fish_carrier', 'Fish carrier / reefer', ['AB', 'Deckhand']),
      ('processing_vessel', 'Processing / mother ship', ['Processing Crew', 'Fish Factory Worker']),
      ('other', 'Other', <String>[]),
    ])
      {'id': 'vt-$code', 'code': code, 'name': name, 'category': 'fishing', 'typical_positions': positions},
  ];

  static String norm(String s) => s
      .toLowerCase()
      .replaceAll('å', 'a')
      .replaceAll('ø', 'o')
      .replaceAll('æ', 'ae')
      .replaceAll(RegExp(r'\b(as|asa|a/s|b\.?v\.?|hf|ehf|gmbh|ltd|company)\.?$'), '')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Json? _company(String cid) {
    for (final c in _companies) {
      if (c['id'] == cid) return c;
    }
    return null;
  }

  Json _detail(Json c) => {
    ...c,
    'contacts_count': _contacts.where((x) => x['company_id'] == c['id']).length,
    'open_vacancies_count': _vacancies
        .where((v) => v['company_id'] == c['id'] && v['status'] == 'active')
        .length,
    'vessels': [
      for (final v in _vessels)
        for (final l in (v['links'] as List).cast<Json>())
          if (l['company_id'] == c['id']) l,
    ],
  };

  http.Response? handle(http.Request req, List<String> rest, Json body) {
    final m = req.method;
    final q = req.url.queryParameters;
    switch (rest.first) {
      case 'companies':
        return _companiesRoute(m, rest, body, q);
      case 'contacts':
        return _contactsRoute(m, rest, body, q);
      case 'vessel-types':
        return json(vesselTypes);
      case 'vessels':
        return _vesselsRoute(m, rest, body);
      case 'vacancies':
        return _vacanciesRoute(m, rest, body, q);
      case 'discovery':
        return _discoveryRoute(m, rest, body);
      case 'applications':
        return _appsRoute(m, rest, body);
      case 'follow-ups':
        return _followUpsRoute(m, rest, body, q);
    }
    return null;
  }

  http.Response _companiesRoute(String m, List<String> rest, Json body, Map<String, String> q) {
    if (rest.length == 1 && m == 'GET') {
      var list = [..._companies]..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      if (q['q'] case final s? when s.isNotEmpty) {
        list = list.where((c) => (c['name'] as String).toLowerCase().contains(s.toLowerCase())).toList();
      }
      if (q['hiring_status'] case final s?) list = list.where((c) => c['hiring_status'] == s).toList();
      return json([for (final c in list) _detail(c)]);
    }
    if (rest.length == 1 && m == 'POST') {
      final n = norm(body['name'] as String);
      final dups = _companies.where((c) => norm(c['name'] as String) == n).toList();
      if (dups.isNotEmpty && body['allow_duplicate'] != true) {
        return json({
          'detail': {
            'message': 'A similar company already exists',
            'can_override': true,
            'candidates': [
              for (final d in dups)
                {
                  'id': d['id'],
                  'name': d['name'],
                  'country_code': d['country_code'],
                  'reason': 'Same name',
                  'score': 1,
                },
            ],
          },
        }, 409);
      }
      final cid = id();
      final c = <String, dynamic>{
        'id': cid,
        'name': body['name'],
        'country_code': body['country_code'],
        'headquarters': body['headquarters'],
        'hiring_status': body['hiring_status'] ?? 'unknown',
        'verification_status': body['source_url'] == null ? 'user_provided' : 'unverified',
        'source_url': body['source_url'],
        'last_verified_at': null,
        'confidence': null,
        'industries': [...((body['industries'] as List?) ?? const []).cast<String>()]..sort(),
        'speculative_policy': body['speculative_policy'],
        'careers_url': body['careers_url'],
        'recruitment_email': body['recruitment_email'],
        'fleet_summary': body['fleet_summary'],
        'description': body['description'],
        'latitude': null,
        'longitude': null,
        'websites': [
          for (final w in ((body['websites'] as List?) ?? const []).cast<Json>())
            {'id': id(), 'url': w['url'], 'kind': w['kind'] ?? 'main'},
        ],
        'sources': <Json>[],
        'notes': <Json>[],
        'created_at': now(),
        'updated_at': now(),
      };
      _companies.add(c);
      log('company.created', 'company');
      return json(_detail(c), 201);
    }
    if (rest.length == 2 && rest[1] == 'duplicates') return json([]);
    final c = _company(rest[1]);
    if (c == null) return json({'detail': 'Company not found'}, 404);
    if (rest.length == 2) {
      if (m == 'GET') return json(_detail(c));
      if (m == 'DELETE') {
        _companies.remove(c);
        return json(null, 204);
      }
      if (m == 'PATCH') {
        c.addAll(body);
        c['updated_at'] = now();
        return json(_detail(c));
      }
    }
    switch (rest[2]) {
      case 'timeline':
        return json(
          [
            for (final a in _apps.where((a) => a['company_id'] == c['id']))
              for (final h in (a['history'] as List).cast<Json>())
                {
                  'at': h['changed_at'],
                  'kind': h['from_status'] == null ? 'application_created' : 'status_changed',
                  'title': h['from_status'] == null ? (a['position'] ?? 'Application') : h['to_status'],
                  'detail': h['note'],
                  'application_id': a['id'],
                },
            {
              'at': c['created_at'],
              'kind': 'company_added',
              'title': c['name'],
              'detail': null,
              'application_id': null,
            },
          ]..sort((x, y) => (y['at'] as String).compareTo(x['at'] as String)),
        );
      case 'verify':
        c
          ..['verification_status'] = 'verified'
          ..['source_url'] = body['source_url']
          ..['last_verified_at'] = now();
        (c['sources'] as List).insert(0, {
          'id': id(),
          'url': body['source_url'],
          'title': 'Verified by user',
          'source_type': 'user_entry',
          'retrieved_at': now(),
        });
        return json(_detail(c));
      case 'notes':
        if (m == 'POST') {
          (c['notes'] as List).insert(0, {
            'id': id(),
            'body': body['body'],
            'created_at': now(),
            'updated_at': now(),
          });
          log('company.note_added', 'company');
          return json({}, 201);
        }
        (c['notes'] as List).removeWhere((n) => (n as Json)['id'] == rest[3]);
        return json(null, 204);
      case 'websites':
        (c['websites'] as List).add({'id': id(), 'url': body['url'], 'kind': body['kind'] ?? 'main'});
        return json({}, 201);
      case 'contacts':
        final contact = <String, dynamic>{
          ...body,
          'id': id(),
          'company_id': c['id'],
          'contact_kind': body['contact_kind'] ?? 'person',
          'contact_status': 'new',
          'email_status': body['email'] == null ? null : (body['email_status'] ?? 'user_provided'),
          'verification_status': body['source_url'] == null ? 'user_provided' : 'unverified',
          'last_verified_at': null,
          'confidence': null,
          'created_at': now(),
          'updated_at': now(),
        };
        _contacts.add(contact);
        log('contact.created', 'contact');
        return json(contact, 201);
      case 'merge':
        final target = _company(body['into_id'] as String);
        if (target == null) return json({'detail': 'Company not found'}, 404);
        for (final x in [..._contacts, ..._vacancies]) {
          if (x['company_id'] == c['id']) x['company_id'] = target['id'];
        }
        (target['notes'] as List).addAll(c['notes'] as List);
        _companies.remove(c);
        return json(_detail(target));
    }
    return json({'detail': 'Not supported in demo mode'}, 405);
  }

  Json _contactOut(Json x) => {...x, 'company_name': _company(x['company_id'] as String)?['name']};

  http.Response _contactsRoute(String m, List<String> rest, Json body, Map<String, String> q) {
    if (rest.length == 1) {
      Iterable<Json> list = _contacts;
      if (q['company_id'] case final cid?) list = list.where((x) => x['company_id'] == cid);
      list = switch (q['filter']) {
        'verified' => list.where((x) => x['verification_status'] == 'verified'),
        'unverified' => list.where((x) => x['verification_status'] != 'verified'),
        'generic' => list.where((x) => x['contact_kind'] == 'generic_inbox'),
        'people' => list.where((x) => x['contact_kind'] == 'person'),
        'inferred' => list.where((x) => x['email_status'] == 'inferred'),
        _ => list,
      };
      return json([for (final x in list) _contactOut(x)]);
    }
    final x = _contacts.where((c) => c['id'] == rest[1]).firstOrNull;
    if (x == null) return json({'detail': 'Contact not found'}, 404);
    if (rest.length == 3 && rest[2] == 'verify') {
      if (x['email_status'] == 'inferred') {
        return json({'detail': 'An inferred e-mail cannot be verified.'}, 422);
      }
      x
        ..['verification_status'] = 'verified'
        ..['source_url'] = body['source_url']
        ..['last_verified_at'] = now();
      if (x['email'] != null) x['email_status'] = 'public_verified';
      return json(_contactOut(x));
    }
    if (m == 'DELETE') {
      _contacts.remove(x);
      return json(null, 204);
    }
    x.addAll(body);
    return json(_contactOut(x));
  }

  http.Response _vesselsRoute(String m, List<String> rest, Json body) {
    if (rest.length == 1 && m == 'GET') return json(_vessels);
    if (rest.length == 1 && m == 'POST') {
      final type = vesselTypes.where((t) => t['id'] == body['vessel_type_id']).firstOrNull;
      final v = <String, dynamic>{
        ...body,
        'id': id(),
        'vessel_type': type,
        'verification_status': body['source_url'] == null ? 'user_provided' : 'unverified',
        'last_verified_at': null,
        'confidence': null,
        'links': <Json>[],
        'potential_positions': type?['typical_positions'] ?? const <String>[],
        'created_at': now(),
        'updated_at': now(),
      };
      _vessels.add(v);
      log('vessel.created', 'vessel');
      return json(v, 201);
    }
    final v = _vessels.where((x) => x['id'] == rest[1]).firstOrNull;
    if (v == null) return json({'detail': 'Vessel not found'}, 404);
    if (rest.length == 3 && rest[2] == 'links') {
      final c = _company(body['company_id'] as String);
      if (c == null) return json({'detail': 'Company not found'}, 404);
      (v['links'] as List).add({
        'id': id(),
        'role': body['role'],
        'vessel_id': v['id'],
        'vessel_name': v['name'],
        'company_id': c['id'],
        'company_name': c['name'],
        'valid_from': null,
        'valid_to': null,
        'is_crewing_employer': null,
        'verification_status': 'user_provided',
        'source_url': null,
      });
      return json(v, 201);
    }
    if (m == 'DELETE') {
      _vessels.remove(v);
      return json(null, 204);
    }
    return json(v);
  }

  http.Response _vacanciesRoute(String m, List<String> rest, Json body, Map<String, String> q) {
    if (rest.length == 1 && m == 'GET') {
      final s = q['status'];
      return json(_vacancies.where((v) => s == null || v['status'] == s).toList());
    }
    if (rest.length == 1 && m == 'POST') {
      if (_vacancies.any((v) => v['source_url'] == body['source_url'])) {
        return json({'detail': 'A vacancy with this source URL is already saved'}, 409);
      }
      final v = <String, dynamic>{
        ...body,
        'id': id(),
        'status': 'unverified',
        'discovered_at': now(),
        'last_verified_at': null,
        'created_at': now(),
      };
      _vacancies.insert(0, v);
      log('vacancy.created', 'vacancy');
      return json(v, 201);
    }
    final v = _vacancies.where((x) => x['id'] == rest[1]).firstOrNull;
    if (v == null) return json({'detail': 'Vacancy not found'}, 404);
    if (rest.length == 3 && rest[2] == 'verify') {
      v
        ..['status'] = 'active'
        ..['last_verified_at'] = now();
      return json(v);
    }
    if (m == 'DELETE') {
      _vacancies.remove(v);
      return json(null, 204);
    }
    v.addAll(body);
    return json(v);
  }

  http.Response _discoveryRoute(String m, List<String> rest, Json body) {
    switch (rest.length > 1 ? rest[1] : '') {
      case 'targets':
        if (rest.length == 3 && m == 'POST') {
          for (final t in targets) {
            if (!_companies.any((c) => norm(c['name'] as String) == norm(t))) {
              _companiesRoute('POST', ['companies'], {'name': t}, const {});
            }
          }
        }
        return json([
          for (final t in targets)
            {
              'name': t,
              'company_id': _companies.where((c) => norm(c['name'] as String) == norm(t)).firstOrNull?['id'],
            },
        ]);
      case 'website':
        return json({
          'detail':
              'Website research reads real company websites and needs the SEA SPACE server. '
              'It is not available in demo mode.',
        }, 503);
      case 'search':
        return json({'detail': 'Web search is not configured (demo mode).'}, 503);
    }
    return json({'detail': 'Not supported in demo mode'}, 405);
  }

  static const _sentOrLater = {
    'sent',
    'waiting_for_reply',
    'follow_up_needed',
    'replied',
    'interview',
    'offer',
    'hired',
    'rejected',
    'no_vacancies',
    'keep_in_touch',
  };
  static const _replied = {'replied', 'interview', 'offer', 'hired', 'rejected', 'no_vacancies'};

  Json _appOut(Json a) {
    final open = _followUps.where((f) => f['application_id'] == a['id'] && f['completed_at'] == null).toList()
      ..sort((x, y) => (x['due_at'] as String).compareTo(y['due_at'] as String));
    return {
      ...a,
      'company_name': _company(a['company_id'] as String)?['name'] ?? '',
      'next_follow_up_at': open.isEmpty ? null : open.first['due_at'],
      'follow_ups': [for (final f in _followUps.where((f) => f['application_id'] == a['id'])) _fuOut(f)],
    };
  }

  Json _fuOut(Json f) => {
    ...f,
    'company_name': _company(f['company_id'] as String)?['name'],
    'overdue': f['completed_at'] == null && DateTime.parse(f['due_at'] as String).isBefore(DateTime.now()),
  };

  void _setStatus(Json a, String status, String? note) {
    if (status == a['status']) return;
    (a['history'] as List).insert(0, {
      'id': id(),
      'from_status': a['status'],
      'to_status': status,
      'note': note,
      'changed_at': now(),
    });
    a['status'] = status;
    if (_sentOrLater.contains(status)) a['sent_at'] ??= now();
    if (_replied.contains(status)) a['last_reply_at'] ??= now();
    a['updated_at'] = now();
  }

  http.Response _appsRoute(String m, List<String> rest, Json body) {
    if (rest.length == 1 && m == 'GET') return json([for (final a in _apps.reversed) _appOut(a)]);
    if (rest.length == 1 && m == 'POST') {
      final a = <String, dynamic>{
        'id': id(),
        'company_id': body['company_id'],
        'position': body['position'],
        'status': 'discovered',
        'vacancy_id': null,
        'contact_id': body['contact_id'],
        'contact_name': null,
        'profile_id': null,
        'notes': null,
        'sent_at': null,
        'last_reply_at': null,
        'created_at': now(),
        'updated_at': now(),
        'history': <Json>[
          {
            'id': id(),
            'from_status': null,
            'to_status': 'discovered',
            'note': 'Created',
            'changed_at': now(),
          },
        ],
      };
      _apps.add(a);
      log('application.created', 'application');
      return json(_appOut(a), 201);
    }
    if (rest[1] == 'stats') {
      final sent = _apps.where((a) => a['sent_at'] != null).length;
      final replied = _apps.where((a) => a['last_reply_at'] != null).length;
      final open = _followUps.where((f) => f['completed_at'] == null).toList();
      return json({
        'total': _apps.length,
        'by_status': {},
        'sent': sent,
        'replied': replied,
        'reply_rate': sent == 0 ? null : replied / sent,
        'interviews': _apps.where((a) => a['status'] == 'interview').length,
        'offers': _apps.where((a) => a['status'] == 'offer').length,
        'hired': _apps.where((a) => a['status'] == 'hired').length,
        'open_follow_ups': open.length,
        'overdue_follow_ups': open.where((f) => _fuOut(f)['overdue'] == true).length,
        'median_days_to_reply': null,
      });
    }
    final a = _apps.where((x) => x['id'] == rest[1]).firstOrNull;
    if (a == null) return json({'detail': 'Application not found'}, 404);
    if (m == 'DELETE') {
      _apps.remove(a);
      return json(null, 204);
    }
    if (m == 'PATCH') {
      if (body['status'] case final String s) _setStatus(a, s, body['status_note'] as String?);
      if (body['follow_up_in_days'] case final int d) {
        _followUps.add({
          'id': id(),
          'title': body['follow_up_title'] ?? 'Follow up on application',
          'application_id': a['id'],
          'company_id': a['company_id'],
          'completed_at': null,
          'due_at': DateTime.now().toUtc().add(Duration(days: d)).toIso8601String(),
        });
      }
    }
    return json(_appOut(a));
  }

  http.Response _followUpsRoute(String m, List<String> rest, Json body, Map<String, String> q) {
    if (rest.length == 1 && m == 'GET') {
      final list =
          _followUps
              .map(_fuOut)
              .where(
                (f) => switch (q['state']) {
                  'done' => f['completed_at'] != null,
                  'overdue' => f['overdue'] == true,
                  'all' => true,
                  _ => f['completed_at'] == null,
                },
              )
              .toList()
            ..sort((x, y) => (x['due_at'] as String).compareTo(y['due_at'] as String));
      return json(list);
    }
    if (rest.length == 1 && m == 'POST') {
      final app = _apps.where((a) => a['id'] == body['application_id']).firstOrNull;
      final f = <String, dynamic>{
        'id': id(),
        'title': body['title'],
        'due_at': body['due_at'],
        'completed_at': null,
        'application_id': body['application_id'],
        'company_id': app?['company_id'] ?? body['company_id'],
      };
      _followUps.add(f);
      return json(_fuOut(f), 201);
    }
    final f = _followUps.where((x) => x['id'] == rest[1]).firstOrNull;
    if (f == null) return json({'detail': 'Follow-up not found'}, 404);
    if (m == 'DELETE') {
      _followUps.remove(f);
      return json(null, 204);
    }
    if (body.containsKey('completed')) f['completed_at'] = body['completed'] == true ? now() : null;
    return json(_fuOut(f));
  }

  /// Counts for the dashboard in demo mode.
  Json counts() => {
    'companies': _companies.length,
    'verified_contacts': _contacts.where((c) => c['verification_status'] == 'verified').length,
    'applications_sent': _apps.where((a) => a['sent_at'] != null).length,
    'replies_received': _apps.where((a) => a['last_reply_at'] != null).length,
    'pending_follow_ups': _followUps.where((f) => f['completed_at'] == null).length,
    'interviews': _apps.where((a) => a['status'] == 'interview').length,
    'offers': _apps.where((a) => a['status'] == 'offer').length,
  };

  List<Json> newCompanies() => [
    for (final c in _companies.reversed.take(5))
      {
        'id': c['id'],
        'name': c['name'],
        'country_code': c['country_code'],
        'hiring_status': c['hiring_status'],
        'created_at': c['created_at'],
      },
  ];
}
