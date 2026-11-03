import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/storage_mode.dart';
import '../data/storage_repository.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return LocalStorageRepository();
});

class StorageSelectionNotifier extends StateNotifier<StorageMode> {
  final StorageRepository _repository;

  StorageSelectionNotifier(this._repository) : super(StorageMode.local) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final mode = await _repository.getSelectedStorageMode();
    state = mode;
  }

  Future<void> setStorageMode(StorageMode mode) async {
    state = mode;
    await _repository.saveStorageMode(mode);
  }
}

final storageSelectionProvider =
    StateNotifierProvider<StorageSelectionNotifier, StorageMode>((ref) {
  final repo = ref.watch(storageRepositoryProvider);
  return StorageSelectionNotifier(repo);
});

