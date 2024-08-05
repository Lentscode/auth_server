import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';

import '../../shared.dart';

void main() {
  group('Registration', () {
    test('Success', () async {
      final email = "email@example.com";
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/register'),
        body: jsonEncode({"email": email, "password": password}),
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);

      expect(body["email"], email);
      expect(body["_id"], isA<String>());

      userId = body["_id"];
    });

    test('Failure: missing email', () async {
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/register'),
        body: jsonEncode({"password": password}),
      );

      expect(response.statusCode, 400);
    });

    test('Failure: missing password', () async {
      final email = "email@example.com";

      final response = await post(
        Uri.parse('$host/public/register'),
        body: jsonEncode({"email": email}),
      );

      expect(response.statusCode, 400);
    });

    test('Failure: user existing', () async {
      final email = "email@example.com";
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/register'),
        body: jsonEncode({"email": email, "password": password}),
      );

      expect(response.statusCode, 403);
    });
  });
}
