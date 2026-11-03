import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile_model.dart';

class ProfileNotifier extends StateNotifier<UserProfileModel> {
  ProfileNotifier() : super(UserProfileModel.defaultMock);

  void updateProfile(UserProfileModel profile) {
    state = profile;
  }

  void updateFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void updateDateOfBirth(DateTime dob) {
    state = state.copyWith(dateOfBirth: dob);
  }

  void updateMetrics({
    String? gender,
    double? heightCm,
    double? weightKg,
    List<String>? allergies,
    List<String>? conditions,
  }) {
    state = state.copyWith(
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      allergies: allergies,
      medicalConditions: conditions,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfileModel>((ref) {
  return ProfileNotifier();
});

