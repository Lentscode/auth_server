import 'dart:io';

import 'package:auth_server/utils/utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

import 'routes/public/login.dart' as login;
import 'routes/public/register.dart' as register;
import 'shared.dart';

void main() {
  late Process p;
  late String credentials;

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

  register.main();
  login.main();
}
