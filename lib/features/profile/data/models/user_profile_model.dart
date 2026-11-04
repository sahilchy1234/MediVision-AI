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

    return UserProfileModel(
      fullName: json['fullName'] as String? ?? 'Health Member',
      dateOfBirth: dob,
      gender: json['gender'] as String?,
      heightCm: json['heightCm'] != null ? (json['heightCm'] as num).toDouble() : null,
      weightKg: json['weightKg'] != null ? (json['weightKg'] as num).toDouble() : null,
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      enableWomensHealth: json['enableWomensHealth'] as bool? ?? true,
    );
  }

  static const defaultMock = UserProfileModel(
    fullName: 'Elena Rostova',
    gender: 'Female',
    heightCm: 168,
    weightKg: 58.0,
    allergies: ['Penicillin'],
    medicalConditions: ['Mild Dysmenorrhea'],
    enableWomensHealth: true,
  );
}
