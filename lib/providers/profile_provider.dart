import 'package:flutter/foundation.dart';

import '../models/dad_profile.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storage;
  DadProfile? _profile;

  ProfileProvider(this._storage) {
    _profile = _storage.loadProfile();
  }

  DadProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  Future<void> saveProfile(DadProfile profile) async {
    _profile = profile;
    await _storage.saveProfile(profile);
    notifyListeners();
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _storage.clearProfile();
    notifyListeners();
  }
}
