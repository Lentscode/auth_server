import 'dart:convert';

import 'package:auth_server/utils/request_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('RequestUtils', () {
    group('getPayload', () {
      test('Success', () async {
        final request = Request(
          "POST",
          Uri.parse("$host/"),
          body: jsonEncode({
            "message": "message",
            "number": 42,
            "date": DateTime(2024).toIso8601String(),
          }),
        );

        final payload = await RequestUtils.getPayload(request);

        expect(payload["message"], "message");
        expect(payload["number"], 42);
        expect(DateTime.parse(payload["date"]), DateTime(2024));
      });
    });

    group('getSessionId', () {
      test('Success', () {
        final sessionId = "audhuaidiua";
        final cookie = "sessionId=$sessionId; HttpOnly; SameSite=Secure";

        final req = Request(
          "POST",
          Uri.parse("$host/"),
          headers: {"Cookie": cookie},
        );

        final result = RequestUtils.getSessionId(req);

        expect(result, sessionId);
      });

      test('Failure: missing cookie', () {
        final req = Request(
          "POST",
          Uri.parse("$host/"),
        );

        final result = RequestUtils.getSessionId(req);

        expect(result, isNull);
      });

      test('Failure: missing cookie key-value', () {
        final cookie = "HttpOnly; SameSite=Secure";

        final req = Request(
          "POST",
          Uri.parse("$host/"),
          headers: {"Cookie": cookie},
        );

        final result = RequestUtils.getSessionId(req);

        expect(result, isNull);
      });

      test('Failure: wrong cookie key', () {
        final sessionId = "audhuaidiua";
        final cookie = "wrongKey=$sessionId; HttpOnly; SameSite=Secure";

        final req = Request(
          "POST",
          Uri.parse("$host/"),
          headers: {"Cookie": cookie},
        );

        final result = RequestUtils.getSessionId(req);

        expect(result, isNull);
      });
    });
  });
}
