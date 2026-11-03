enum StorageMode {
  local,
  cloud,
  hybrid;

  String get title {
    switch (this) {
      case StorageMode.local:
        return 'Local Storage';
      case StorageMode.cloud:
        return 'Cloud Storage';
      case StorageMode.hybrid:
        return 'Hybrid Storage';
    }
  }

  String get tag {
    switch (this) {
      case StorageMode.local:
        return 'LOCAL STORAGE';
      case StorageMode.cloud:
        return 'CLOUD STORAGE';
      case StorageMode.hybrid:
        return 'HYBRID STORAGE';
    }
  }

  String get description {
    switch (this) {
      case StorageMode.local:
        return 'Your health data stays on your device. Zero server upload, maximum on-device privacy.';
      case StorageMode.cloud:
        return 'Your authorized data is securely synchronized to your account with zero-knowledge encryption.';
      case StorageMode.hybrid:
        return 'Choose which data categories stay local and which synchronize across authorized devices.';
    }
  }
}

