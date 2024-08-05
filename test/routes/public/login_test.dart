import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';

import '../../shared.dart';

void mainFun() {
  group('Login', () {
    test('Success', () async {
      final email = "email@example.com";
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/login'),
        body: jsonEncode({"email": email, "password": password}),
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);

      expect(body["email"], email);
      expect(body["_id"], userId);
    });

    test('Failure: email missing', () async {
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/login'),
        body: jsonEncode({"password": password}),
      );

      expect(response.statusCode, 400);
    });

    test('Failure: email missing', () async {
      final email = "email@example.com";

      final response = await post(
        Uri.parse('$host/public/login'),
        body: jsonEncode({"email": email}),
      );

      expect(response.statusCode, 400);
    });

    test('Failure: user not existing', () async {
      final email = "email@gmail.com";
      final password = "password";

      final response = await post(
        Uri.parse('$host/public/login'),
        body: jsonEncode({"email": email, "password": password}),
      );

      expect(response.statusCode, 401);
    });

    test('Failure: incorrect password', () async {
      final email = "email@example.com";
      final password = "123456";

      final response = await post(
        Uri.parse('$host/public/login'),
        body: jsonEncode({"email": email, "password": password}),
      );

      expect(response.statusCode, 401);
    });
  });
}
