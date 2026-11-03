class UserProfileModel {
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final List<String> allergies;
  final List<String> medicalConditions;

  const UserProfileModel({
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.allergies = const [],
    this.medicalConditions = const [],
  });

  UserProfileModel copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    List<String>? allergies,
    List<String>? medicalConditions,
  }) {
    return UserProfileModel(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }

  static const defaultMock = UserProfileModel(
    fullName: 'Alex Morgan',
    gender: 'Non-binary',
    heightCm: 175,
    weightKg: 68.5,
    allergies: ['Penicillin', 'Peanuts'],
    medicalConditions: ['Mild Asthma'],
  );
}

