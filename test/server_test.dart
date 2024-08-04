import 'dart:convert';
import 'dart:io';

import 'package:auth_server/utils/utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;
  late String credentials;
  late String userId;

  setUpAll(() async {
    final env = DotEnv()..load();
    credentials = env["MONGO_CREDENTIALS_TEST"] ?? "";

    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart', '--test'],
      environment: {'PORT': port, "MONGO_CREDENTIALS": credentials},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDownAll(() async {
    final db = await Db.create(credentials);
    await db.open();
    final auth = Auth(db.collection("users"));

    await auth.deleteUserById(userId);
    return p.kill();
  });

  test('Registration', () async {
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
}
