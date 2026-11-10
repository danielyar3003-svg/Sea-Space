import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers.dart';

Map<String, dynamic> _app(String status, {List<Map<String, dynamic>> history = const []}) => {
  'id': 'a1',
  'company_id': 'c1',
  'company_name': 'Nordhav AS',
  'position': 'Trawl Deckhand',
  'status': status,
  'vacancy_id': null,
  'contact_id': null,
  'contact_name': null,
  'profile_id': null,
  'notes': null,
  'sent_at': status == 'sent' ? '2026-11-10T10:00:00Z' : null,
  'last_reply_at': null,
  'next_follow_up_at': status == 'sent' ? '2026-11-17T10:00:00Z' : null,
  'created_at': '2026-11-10T10:00:00Z',
  'updated_at': '2026-11-10T10:00:00Z',
  'history': history,
  'follow_ups': [],
};

void main() {
  testWidgets('change status records a note and schedules a reminder', (tester) async {
    final log = <http.Request>[];
    var current = _app(
      'discovered',
      history: [
        {
          'id': 'h1',
          'from_status': null,
          'to_status': 'discovered',
          'note': 'Created',
          'changed_at': '2026-11-10T10:00:00Z',
        },
      ],
    );
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) {
        final p = req.url.path;
        if (p == '/api/v1/applications/a1' && req.method == 'PATCH') {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          current = _app(
            body['status'] as String,
            history: [
              {
                'id': 'h2',
                'from_status': 'discovered',
                'to_status': body['status'],
                'note': body['status_note'],
                'changed_at': '2026-11-10T11:00:00Z',
              },
              ...(current['history'] as List).cast<Map<String, dynamic>>(),
            ],
          );
          return json(current);
        }
        if (p == '/api/v1/applications/a1') return json(current);
        if (p == '/api/v1/applications') return json([current]);
        if (p == '/api/v1/applications/stats') {
          return json({
            'total': 1,
            'by_status': {},
            'sent': 0,
            'replied': 0,
            'reply_rate': null,
            'interviews': 0,
            'offers': 0,
            'hired': 0,
            'open_follow_ups': 0,
            'overdue_follow_ups': 0,
            'median_days_to_reply': null,
          });
        }
        if (p == '/api/v1/follow-ups') return json([]);
        return json(emptyDashboard);
      },
    );
    // Home → Tools → CRM
    await tester.scrollUntilVisible(find.text('CRM Pipeline'), 300);
    await tester.tap(find.text('CRM Pipeline'));
    await tester.pumpAndSettle();
    expect(find.text('Nordhav AS'), findsOneWidget);
    expect(find.text('—'), findsWidgets); // reply rate unknown, not 0%

    await tester.tap(find.text('Nordhav AS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change status'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sent'));
    await tester.enterText(find.widgetWithText(TextField, 'Note for the history (optional)'), 'CV by e-mail');
    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 d').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final patch = log.lastWhere((r) => r.method == 'PATCH');
    expect(jsonDecode(patch.body), {
      'status': 'sent',
      'status_note': 'CV by e-mail',
      'follow_up_in_days': 7,
      'follow_up_title': 'Follow up on application',
    });
    expect(find.text('Discovered → Sent'), findsOneWidget);
    expect(find.text('CV by e-mail'), findsOneWidget);
  });
}
