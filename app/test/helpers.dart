import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sea_space/app.dart';
import 'package:sea_space/core/auth/auth_service.dart';
import 'package:sea_space/core/network/api_client.dart';
import 'package:sea_space/core/providers.dart';

class FakeAuthService extends AuthService {
  FakeAuthService({bool signedIn = true}) : _signedIn = signedIn; // ignore: prefer_initializing_formals
  bool _signedIn;

  @override
  bool get isSignedIn => _signedIn;
  @override
  String? get email => 'sailor@example.com';
  @override
  Future<String?> accessToken() async => _signedIn ? 'test-token' : null;
  @override
  Future<void> signIn({required String email, required String password}) async {
    _signedIn = true;
    notifyListeners();
  }

  @override
  Future<bool> signUp({required String email, required String password}) async => true;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }
}

typedef Handler = http.Response Function(http.Request request);

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

const emptyDashboard = {
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
  'recent_activity': [],
};

Future<void> pumpApp(
  WidgetTester tester, {
  AuthService? auth,
  Handler? handler,
  Size size = const Size(400, 860),
  List<http.Request>? log,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final client = MockClient((req) async {
    log?.add(req);
    return (handler ?? (_) => json(emptyDashboard))(req);
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        apiClientProvider.overrideWithValue(
          ApiClient(
            baseUrl: 'http://api.test',
            tokenProvider: () async => auth?.accessToken(),
            httpClient: client,
          ),
        ),
      ],
      child: const SeaSpaceApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tap a destination in the bottom navigation bar.
Future<void> tapNav(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}
