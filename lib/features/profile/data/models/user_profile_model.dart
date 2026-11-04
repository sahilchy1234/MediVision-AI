class UserProfileModel {
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final List<String> allergies;
  final List<String> medicalConditions;
  final bool enableWomensHealth;

  const UserProfileModel({
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.enableWomensHealth = true,
  });

  bool get isFemale =>
      (gender?.toLowerCase() == 'female') || (enableWomensHealth && (gender == null || gender?.toLowerCase() == 'female'));

  UserProfileModel copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    List<String>? allergies,
    List<String>? medicalConditions,
    bool? enableWomensHealth,
  }) {
    return UserProfileModel(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      enableWomensHealth: enableWomensHealth ?? this.enableWomensHealth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'enableWomensHealth': enableWomensHealth,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    if (json['dateOfBirth'] != null) {
      dob = DateTime.tryParse(json['dateOfBirth'].toString());
    }

    final rawConditions = json['medicalConditions'] ?? json['existingConditions'];
    final conditionsList = (rawConditions as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['Asthma (Controlled)'];

    final rawAllergies = json['allergies'] as List<dynamic>?;
    final allergiesList = rawAllergies?.map((e) => e.toString()).toList() ??
        ['Penicillin'];

    return UserProfileModel(
      fullName: json['fullName'] as String? ?? 'Alex Morgan MD',
      dateOfBirth: dob ?? DateTime(1995, 4, 12),
      gender: json['gender'] as String? ?? 'Female',
      heightCm: json['heightCm'] != null
          ? (json['heightCm'] as num).toDouble()
          : 168.0,
      weightKg: json['weightKg'] != null
          ? (json['weightKg'] as num).toDouble()
          : 58.0,
      allergies: allergiesList,
      medicalConditions: conditionsList,
      enableWomensHealth: json['enableWomensHealth'] as bool? ?? true,
    );
  }

  static const defaultMock = UserProfileModel(
    fullName: 'Alex Morgan MD',
    gender: 'Female',
    heightCm: 168,
    weightKg: 58.0,
    allergies: ['Penicillin', 'Sulfa'],
    medicalConditions: ['Asthma (Controlled)'],
    enableWomensHealth: true,
  );
}
