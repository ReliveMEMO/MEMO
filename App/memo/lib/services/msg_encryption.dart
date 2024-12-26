import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class MsgEncryption {
  static String secretKey = 'abcdefghijklmnopqrstuvwx123456';

  String? decrypt(String encryptedMsg) {
    final parts = encryptedMsg.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid encrypted text format');
    }

    String ivHex = parts[0];

    final encryptedData = parts[1];

    if (secretKey.length < 32) {
      secretKey = secretKey.padRight(32, '0');
    }

    if (ivHex.length % 2 != 0) {
      ivHex = '0' + ivHex; // Prepend a '0' to make the length even
    }

    final iv = IV.fromBase16(ivHex);

    final key = Key.fromUtf8(secretKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
    return decrypted;
  }
}
