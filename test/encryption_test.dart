import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_uts_pb/common/Encryption.dart';

void main(){
  group('Encryption', () {
    const testString = 'Hello, Dart!';
    const key = 'user pass';
    EncryptionKey encryptionKey = EncryptionKey(
        key: Encryption.md5Generate(key)
    );

    test('Encryption and decryption work correctly', () {
      final encryptedText = Encryption.encryptText(testString, encryptionKey);
      expect(encryptedText, isNotNull);
      expect(encryptedText, isNotEmpty);

      final decryptedText = Encryption.decryptText(encryptedText, encryptionKey);
      expect(decryptedText, equals(testString));
    });

    test('Decryption fails with incorrect data', () {
      const invalidEncryptedText = 'InvalidBase64Text';
      expect(
            () => Encryption.decryptText(invalidEncryptedText, encryptionKey),
        throwsA(isA<FormatException>()),
      );
    });
  });

}