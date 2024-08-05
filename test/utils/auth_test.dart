import 'package:auth_server/config/set_up.dart' as lib;
import 'package:auth_server/models/models.dart';
import 'package:auth_server/utils/utils.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

void main() {
  late final Auth auth;
  late final String email;
  late final String password;
  late final String id;
  late final User user;
  late final String sessionId;

  setUpAll(() async {
    await lib.setUp();
    auth = lib.getIt.get<Auth>();
    email = "email@example.com";
    password = "password";
  });

  tearDownAll(() async {
    await auth.deleteUserById(id);
  });

  group('Auth', () {
    group('Creation', () {
      test('userCollection is a [DbCollection]', () {
        expect(auth.userCollection, isA<DbCollection>());
      });
    });

    group('sessionId()', () {
      test('Returns a [String]', () {
        final uuid = auth.sessionId();

        expect(uuid, isA<String>());
      });
    });

    group('registerWithEmailAndPassword', () {
      test('Success', () async {
        final user = await auth.registerWithEmailAndPassword(email, password);

        expect(user.email, email);
        expect(user.id, isA<ObjectId>());
        expect(user.hashedPassword, isA<String>());
        expect(user.sessionId, isNull);

        id = user.id.oid;
      });
    });

    group('getUserByEmail', () {
      test('Success', () async {
        final user = await auth.getUserByEmail(email);

        expect(user, isNotNull);
        expect(user!.email, email);
      });

      test('Failure: email not used', () async {
        final user = await auth.getUserByEmail("email@google.com");

        expect(user, isNull);
      });
    });

    group('loginWithEmailAndPassword', () {
      test('Success', () async {
        final result = await auth.loginWithEmailAndPassword(email, password);

        expect(result, isNotNull);
        expect(result!.email, email);

        user = result;
      });

      test('Failure: wrong email', () async {
        final user = await auth.loginWithEmailAndPassword("email@google.com", password);

        expect(user, isNull);
      });

      test('Failure: wrong password', () async {
        final user = await auth.loginWithEmailAndPassword(email, "123456");

        expect(user, isNull);
      });
    });

    group('createSessionIdOfUser', () {
      test('Success', () async {
        final userUpdated = await auth.createSessionIdOfUser(user);

        expect(userUpdated.sessionId, isA<String>());
      });

      test('Success with expiration date', () async {
        final userUpdated = await auth.createSessionIdOfUser(user, DateTime.now().add(Duration(days: 1)));

        expect(userUpdated.sessionId, isA<String>());
        expect(userUpdated.expirationDate, isA<DateTime>());

        sessionId = userUpdated.sessionId!;
      });
    });

    group('getUserBySessionId', () {
      test('Success', () async {
        final user = await auth.getUserBySessionID(sessionId);

        expect(user, isNotNull);
        expect(user!.email, email);
        expect(user.sessionId, sessionId);
        expect(user.expirationDate, isA<DateTime>());
      });

      test('Failure: incorrect sessionId', () async {
        final user = await auth.getUserBySessionID("sessionId");

        expect(user, isNull);
      });
    });

    group('createCookie', () {
      test('Success', () {
        final cookie = auth.createCookie(sessionId);

        expect(cookie.contains("sessionId=$sessionId"), true);
        expect(cookie.contains("path=/protected"), true);
        expect(cookie.contains("HttpOnly"), true);
        expect(cookie.contains("Secure"), true);
        expect(cookie.contains("SameSite=Strict"), true);
      });
    });
  });
}
