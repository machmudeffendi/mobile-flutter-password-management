import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class Encryption {
  static const _key = 'N21JeJCxthFHXyoSmhWmC9TdsL3YjjTo'; // 32 char
  static const _iv = 'Y2Q3VZtjYZddTNmV'; // 16 char

  static Encrypter _getEncrypter(String? val){
    String keyString = _key;
    if(val != null){
      val = md5Generate(val);
      keyString = val;
    }
    final key = Key.fromUtf8(keyString);
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  static IV _getIV(String? val) {
    String ivString = _iv;
    if(val != null){
      val = md5Generate(val);
      ivString = val;
    }
    return IV.fromUtf8(ivString);
  }

  static String encryptText(String plainText, EncryptionKey? key){
    final encrypter = _getEncrypter(key?.key);
    final iv = _getIV(key?.iv);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText, EncryptionKey? key){
    final encrypter = _getEncrypter(key?.key);
    final iv = _getIV(key?.iv);
    final encrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return encrypted;
  }

  static String md5Generate(String plainText){
    var bytes = utf8.encode(plainText);
    return md5.convert(bytes).toString();
  }
}

class EncryptionKey {
  String? key;
  String? iv;

  EncryptionKey({this.key, this.iv});
}