import 'package:auth_server/config/set_up.dart' as lib;
import 'package:auth_server/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    await lib.setUp();
  });

  group('setUp', () {
    test('Testing service locator', () {
      final auth = lib.getIt.get<Auth>();

      expect(auth, isA<Auth>());
    });
  });
}
