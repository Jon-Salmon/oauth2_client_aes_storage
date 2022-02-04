library oauth2_client_aes_storage;

import 'package:encrypt/encrypt.dart';
import 'package:oauth2_client/src/base_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedStorage implements BaseStorage {
  static const secureStorageKey = "oauth_client_aes_key";
  static const sharedPreferencePrefix = "oauth_client_aes_";
  static const sharedPreferenceIvPrefix = "oauth_client_aes_iv_";
  static const keySize = 32;

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  EncryptedStorage();

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String?> read(String key) async {
    var storedKey = await _secureStorage.read(key: secureStorageKey);

    if (storedKey == null) {
      return null;
    }

    final store = await _getPrefs();
    final encryptedValue = store.getString(sharedPreferencePrefix + key);
    final iv = store.getString(sharedPreferenceIvPrefix + key);
    if (encryptedValue == null || iv == null) {
      return null;
    }

    final encrypter = Encrypter(AES(Key.fromBase64(storedKey)));
    return encrypter.decrypt(Encrypted.fromBase64(encryptedValue), iv: IV.fromBase64(iv));
  }

  @override
  Future<void> write(String key, String value) async {
    var storedKey = await _secureStorage.read(key: secureStorageKey);
    Key? aesKey;

    if (storedKey == null) {
      aesKey = Key.fromSecureRandom(keySize);
      await _secureStorage.write(key: secureStorageKey, value: aesKey.base64);
    } else {
      aesKey = Key.fromBase64(storedKey);
    }

    final encrypter = Encrypter(AES(aesKey));
    final iv = IV.fromSecureRandom(16);
    final encryptedValue = encrypter.encrypt(value, iv: iv);

    final store = await _getPrefs();
    store.setString(sharedPreferencePrefix + key, encryptedValue.base64);
    store.setString(sharedPreferenceIvPrefix + key, iv.base64);
  }
}
