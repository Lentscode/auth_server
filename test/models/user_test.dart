import 'package:auth_server/models/models.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

void main() {
  late User user;
  late User userFromMongo;
  late User userCopy;

  group('User', () {
    group('Creation', () {
      final email = "email@example.com";
      final hashedPassword = "hashedPassword";
      final salt = "salt";
      final id = ObjectId();
      final sessionId = 'sessionId';
      final expirationDate = DateTime.now();
      test('Default constructor', () {
        user = User(
          email: email,
          id: id,
          hashedPassword: hashedPassword,
          salt: salt,
        );

        expect(user.email, email);
        expect(user.hashedPassword, hashedPassword);
        expect(user.salt, salt);
        expect(user.id, id);
        expect(user.sessionId, isNull);
        expect(user.expirationDate, isNull);
      });

      test('fromMongo() constructor', () {
        final map = {
          "email": email,
          "password": hashedPassword,
          "salt": salt,
          "_id": id,
          "sessionId": sessionId,
          "expirationDate": expirationDate,
        };

        userFromMongo = User.fromMongo(map);

        expect(userFromMongo.email, email);
        expect(userFromMongo.hashedPassword, hashedPassword);
        expect(userFromMongo.salt, salt);
        expect(userFromMongo.id, id);
        expect(userFromMongo.sessionId, sessionId);
        expect(userFromMongo.expirationDate, expirationDate);
      });
    });

    group('Copying', () {
      final emailCopy = "email@gmail.com";
      final hashedPasswordCopy = "hashedPasswordCopy";
      final idCopy = ObjectId();
      final saltCopy = "saltCopy";
      final expirationDateCopy = DateTime.now();
      test('copyWith', () {
        userCopy = user.copyWith(
          email: emailCopy,
          hashedPassword: hashedPasswordCopy,
          id: idCopy,
          salt: saltCopy,
          expirationDate: expirationDateCopy,
        );

        expect(userCopy.email, emailCopy);
        expect(userCopy.hashedPassword, hashedPasswordCopy);
        expect(userCopy.id, idCopy);
        expect(userCopy.salt, saltCopy);
        expect(userCopy.expirationDate, expirationDateCopy);
        expect(userCopy.sessionId, isNull);
      });
    });

    group('Static methods', () {
      group('generateSalt', () {
        test('default', () {
          final salt1 = User.generateSalt();
          final salt2 = User.generateSalt();

          expect(salt1, isA<String>());
          expect(salt2, isA<String>());
          expect(salt1 == salt2, false);
        });

        test('length = 32', () {
          final salt1 = User.generateSalt(32);
          final salt2 = User.generateSalt(32);

          expect(salt1, isA<String>());
          expect(salt2, isA<String>());
          expect(salt1 == salt2, false);
        });
      });

      group('hashPassword', () {
        final password = "password";
        final salt = User.generateSalt();
        test('Creation', () {
          final hashedPassword = User.hashPassword(password, salt);

          expect(hashedPassword, isA<String>());
          expect(hashedPassword == password, false);
        });

        test('Same password and salt give the same result', () {
          final hashedPassword1 = User.hashPassword(password, salt);
          final hashedPassword2 = User.hashPassword(password, salt);

          expect(hashedPassword1 == hashedPassword2, true);
        });
      });
    });
  });
}
