import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/household_duty.dart';
import 'package:papetune/enums/work_style.dart';
import 'package:papetune/models/child_profile.dart';
import 'package:papetune/models/dad_profile.dart';
import 'package:papetune/providers/profile_provider.dart';
import 'package:papetune/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;
  late ProfileProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    provider = ProfileProvider(storage);
  });

  DadProfile makeProfile() => DadProfile(
        children: [
          ChildProfile(name: 'テスト太郎', birthDate: DateTime(2023, 1, 1)),
        ],
        workStyle: WorkStyle.remote,
        duties: {HouseholdDuty.cooking},
        sportDaysOfWeek: [1, 3],
      );

  group('ProfileProvider', () {
    test('starts with no profile', () {
      expect(provider.profile, isNull);
      expect(provider.hasProfile, isFalse);
    });

    test('saveProfile stores and notifies', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.saveProfile(makeProfile());

      expect(provider.profile, isNotNull);
      expect(provider.hasProfile, isTrue);
      expect(provider.profile!.workStyle, WorkStyle.remote);
      expect(notified, isTrue);
    });

    test('clearProfile removes and notifies', () async {
      await provider.saveProfile(makeProfile());

      var notified = false;
      provider.addListener(() => notified = true);
      await provider.clearProfile();

      expect(provider.profile, isNull);
      expect(provider.hasProfile, isFalse);
      expect(notified, isTrue);
    });

    test('profile persists across instances', () async {
      await provider.saveProfile(makeProfile());

      // Create new provider from same storage
      final prefs = await SharedPreferences.getInstance();
      final newStorage = StorageService(prefs);
      final newProvider = ProfileProvider(newStorage);

      expect(newProvider.hasProfile, isTrue);
      expect(newProvider.profile!.workStyle, WorkStyle.remote);
      expect(newProvider.profile!.children.length, 1);
    });
  });
}
