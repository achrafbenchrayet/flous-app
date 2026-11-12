import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SecurityService {
  SecurityService._();

  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  static String hashPassword(String password, String salt) {
    var key = utf8.encode(password + salt);
    var bytes = sha256.convert(key).bytes;
    for (int i = 0; i < 5000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Encode(bytes);
  }

  static bool verifyPassword(String enteredPassword, String storedHash, String storedSalt) {
    final computedHash = hashPassword(enteredPassword, storedSalt);
    return computedHash == storedHash;
  }
}
