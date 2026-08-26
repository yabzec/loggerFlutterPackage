import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:logger/logger.dart';

void main() {
  group('LogLevel', () {
    test('maps to the level numbers the API and viewer expect', () {
      expect(LogLevel.info.levelNumber, 0);
      expect(LogLevel.warn.levelNumber, 1);
      expect(LogLevel.error.levelNumber, 2);
      expect(LogLevel.critical.levelNumber, 3);
    });
  });

  group('Logger', () {
    test('defaults to the production endpoint', () {
      expect(Logger.defaultBaseUrl, 'https://logger.yabzec.uk');
    });

    test('sends nothing in debug mode', () async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response('OK', 200);
      });

      final logger = Logger(
        'test_subject',
        'test_title',
        clientId: 'id.access',
        clientSecret: 'secret',
        httpClient: client,
      );

      await logger.info('ignored while debugging');

      // `_log` short-circuits on kDebugMode, which is true under `flutter test`,
      // so this documents the guard rather than asserting on a request body.
      expect(kDebugMode, isTrue);
      expect(requests, 0);
    });
  });
}
