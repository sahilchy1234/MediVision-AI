import 'cycle_data_model.dart';

class DailySymptomLog {
  final String id;
  final DateTime date;
  final PeriodFlow flow;
  final int crampsSeverity; // 0 to 5 (0: none, 5: debilitating)
  final int pelvicPainSeverity; // 0 to 5 (non-menstrual pelvic pain)
  final String mood; // 'Calm', 'Energetic', 'Sensitive', 'Irritable', 'Anxious', 'Fatigued'
  final List<String> physicalSymptoms;
  final List<String> pcosObservations;
  final double? basalBodyTemp; // in Celsius e.g. 36.7
  final String? cervicalMucus; // 'Dry', 'Sticky', 'Creamy', 'Egg-white (Fertile)'
  final double sleepHours;
  final String? notes;

  const DailySymptomLog({
    required this.id,
    required this.date,
    this.flow = PeriodFlow.none,
    this.crampsSeverity = 0,
    this.pelvicPainSeverity = 0,
    this.mood = 'Calm',
    this.physicalSymptoms = const [],
    this.pcosObservations = const [],
    this.basalBodyTemp,
    this.cervicalMucus,
    this.sleepHours = 7.5,
    this.notes,
  });

  DailySymptomLog copyWith({
    String? id,
    DateTime? date,
    PeriodFlow? flow,
    int? crampsSeverity,
    int? pelvicPainSeverity,
    String? mood,
    List<String>? physicalSymptoms,
    List<String>? pcosObservations,
    double? basalBodyTemp,
    String? cervicalMucus,
    double? sleepHours,
    String? notes,
  }) {
    return DailySymptomLog(
      id: id ?? this.id,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      crampsSeverity: crampsSeverity ?? this.crampsSeverity,
      pelvicPainSeverity: pelvicPainSeverity ?? this.pelvicPainSeverity,
      mood: mood ?? this.mood,
      physicalSymptoms: physicalSymptoms ?? this.physicalSymptoms,
      pcosObservations: pcosObservations ?? this.pcosObservations,
      basalBodyTemp: basalBodyTemp ?? this.basalBodyTemp,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      sleepHours: sleepHours ?? this.sleepHours,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'flow': flow.name,
        'crampsSeverity': crampsSeverity,
        'pelvicPainSeverity': pelvicPainSeverity,
        'mood': mood,
        'physicalSymptoms': physicalSymptoms,
        'pcosObservations': pcosObservations,
        'basalBodyTemp': basalBodyTemp,
        'cervicalMucus': cervicalMucus,
        'sleepHours': sleepHours,
        'notes': notes,
      };

  factory DailySymptomLog.fromJson(Map<String, dynamic> json) {
    return DailySymptomLog(
      id: json['id']?.toString() ?? 'log_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      flow: PeriodFlow.fromString(json['flow']?.toString()),
      crampsSeverity: (json['crampsSeverity'] as num?)?.toInt() ?? 0,
      pelvicPainSeverity: (json['pelvicPainSeverity'] as num?)?.toInt() ?? 0,
      mood: json['mood']?.toString() ?? 'Calm',
      physicalSymptoms: (json['physicalSymptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pcosObservations: (json['pcosObservations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      basalBodyTemp: (json['basalBodyTemp'] as num?)?.toDouble(),
      cervicalMucus: json['cervicalMucus']?.toString(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 7.5,
      notes: json['notes']?.toString(),
    );
  }
}
