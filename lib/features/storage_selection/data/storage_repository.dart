import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/models/storage_mode.dart';

abstract class StorageRepository {
  Future<StorageMode> getSelectedStorageMode();
  Future<void> saveStorageMode(StorageMode mode);
}

class LocalStorageRepository implements StorageRepository {
  final FlutterSecureStorage _secureStorage;
  static const _storageModeKey = 'medivision_storage_mode';

  LocalStorageRepository({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<StorageMode> getSelectedStorageMode() async {
    try {
      final value = await _secureStorage.read(key: _storageModeKey);
      if (value != null) {
        return StorageMode.values.firstWhere(
          (m) => m.name == value,
          orElse: () => StorageMode.local,
        );
      }
    } catch (_) {
      // Fallback if secure storage unavailable on platform
    }
    return StorageMode.local;
  }

  @override
  Future<void> saveStorageMode(StorageMode mode) async {
    try {
      await _secureStorage.write(key: _storageModeKey, value: mode.name);
    } catch (_) {
      // Fail safely for mock/sandbox environments
    }
  }
}

