import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';
import 'token_record.dart';

abstract class ISecureTokenStorage {
  Future<void> saveTokenRecord(TokenRecord record);
  Future<TokenRecord?> getTokenRecord();
  Future<void> clearTokenRecord();
  bool get isVolatileSession;
}

/// Hardware-backed secure storage implementation using FlutterSecureStorage.
/// Serializes access and refresh tokens into a single atomic JSON record to prevent pair inconsistency.
class SecureTokenStorageImpl implements ISecureTokenStorage {
  final FlutterSecureStorage _storage;
  static const String _tokenRecordKey = 'cms_token_record';

  bool _isVolatileSession = false;
  TokenRecord? _volatileMemoryBackup;

  SecureTokenStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
              resetOnError: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
            wOptions: WindowsOptions(useBackwardCompatibility: false),
          );

  @override
  bool get isVolatileSession => _isVolatileSession;

  @override
  Future<void> saveTokenRecord(TokenRecord record) async {
    try {
      final jsonString = record.toJsonString();
      await _storage.write(key: _tokenRecordKey, value: jsonString);
      _isVolatileSession = false;
      _volatileMemoryBackup = null;
    } on PlatformException catch (e) {
      // Hardware KeyStore or Keychain error: keep volatile in-memory backup
      _isVolatileSession = true;
      _volatileMemoryBackup = record;
      throw StorageWriteException(
        'فشل حفظ بيانات الجلسة في التخزين الآمن (وضع الجلسة المؤقتة): ${e.message}',
      );
    } catch (e) {
      _isVolatileSession = true;
      _volatileMemoryBackup = record;
      throw StorageWriteException('فشل حفظ بيانات الجلسة في التخزين الآمن: $e');
    }
  }

  @override
  Future<TokenRecord?> getTokenRecord() async {
    if (_isVolatileSession && _volatileMemoryBackup != null) {
      return _volatileMemoryBackup;
    }

    try {
      final raw = await _storage.read(key: _tokenRecordKey);
      if (raw == null || raw.trim().isEmpty) {
        return null;
      }
      return TokenRecord.fromJsonString(raw);
    } on CorruptedTokenRecordException {
      // Purge corrupted key to prevent infinite crashes on startup
      await clearTokenRecord();
      rethrow;
    } on PlatformException catch (e) {
      throw StorageWriteException('تعذر قراءة التخزين الآمن: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      await clearTokenRecord();
      throw CorruptedTokenRecordException('فشل فك تشفير بيانات الجلسة: $e');
    }
  }

  @override
  Future<void> clearTokenRecord() async {
    _isVolatileSession = false;
    _volatileMemoryBackup = null;
    try {
      await _storage.delete(key: _tokenRecordKey);
    } catch (_) {
      // Best effort deletion
    }
  }
}
