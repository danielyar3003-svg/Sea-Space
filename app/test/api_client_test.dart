import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sea_space/core/network/api_client.dart';

import 'helpers.dart';

ApiClient client(MockClientHandler h) =>
    ApiClient(baseUrl: 'http://api.test', tokenProvider: () async => null, httpClient: MockClient(h));

void main() {
  test('maps FastAPI validation errors to readable messages', () async {
    final api = client(
      (_) async => json({
        'detail': [
          {
            'loc': ['body', 'english_level'],
            'msg': 'Input should be a valid level',
          },
        ],
      }, 422),
    );
    expect(
      () => api.post('/x', {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.validation)
            .having((e) => e.message, 'message', 'english_level: Input should be a valid level'),
      ),
    );
  });

  test('maps status codes and network failures', () async {
    expect(
      () => client((_) async => json({'detail': 'nope'}, 401)).get('/x'),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.unauthorized)),
    );
    expect(
      () => client((_) async => throw http.ClientException('down')).get('/x'),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.network)),
    );
  });

  test('204 returns null', () async {
    expect(await client((_) async => http.Response('', 204)).delete('/x'), isNull);
  });
}
