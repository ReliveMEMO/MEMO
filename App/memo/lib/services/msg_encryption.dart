import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class MsgEncryption {
  static String secretKey = 'abcdefghijklmnopqrstuvwx123456';

  String? decrypt(String encryptedMsg) {
    try {
      if ((encryptedMsg.startsWith('"') && encryptedMsg.endsWith('"')) ||
          (encryptedMsg.startsWith("'") && encryptedMsg.endsWith("'"))) {
        encryptedMsg = encryptedMsg.substring(1, encryptedMsg.length - 1);
      }
      // Split the IV and encrypted data
      final parts = encryptedMsg.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted text format');
      }

      String ivHex = parts[0].trim(); // Ensure no extra characters
      final encryptedData = parts[1].trim();

      // Pad or truncate the key to 32 bytes
      if (secretKey.length < 32) {
        secretKey = secretKey.padRight(32, '0');
      } else if (secretKey.length > 32) {
        secretKey = secretKey.substring(0, 32);
      }

      // Convert IV to a valid hexadecimal format
      final iv = IV.fromBase16(ivHex);
      final key = Key.fromUtf8(secretKey);

      // Initialize AES encrypter
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Decrypt the encrypted data
      final decrypted = encrypter.decrypt(
        Encrypted.fromBase16(encryptedData),
        iv: iv,
      );
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return null;
    }
  }
}
