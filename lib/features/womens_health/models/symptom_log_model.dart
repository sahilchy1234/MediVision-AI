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

  static List<DailySymptomLog> defaultSampleLogs() {
    final now = DateTime.now();
    return [
      DailySymptomLog(
        id: 'log_0',
        date: now,
        flow: PeriodFlow.none,
        crampsSeverity: 1,
        pelvicPainSeverity: 1,
        mood: 'Energetic',
        physicalSymptoms: ['Mild Bloating'],
        pcosObservations: ['Mild Breakout on Jawline'],
        basalBodyTemp: 36.7,
        cervicalMucus: 'Egg-white (Fertile)',
        sleepHours: 7.8,
        notes: 'Ovulation peak suspected. Mild right lower quadrant twinge (mittelschmerz).',
      ),
      DailySymptomLog(
        id: 'log_1',
        date: now.subtract(const Duration(days: 1)),
        flow: PeriodFlow.none,
        crampsSeverity: 0,
        pelvicPainSeverity: 0,
        mood: 'Calm',
        physicalSymptoms: ['Clear Skin'],
        basalBodyTemp: 36.5,
        cervicalMucus: 'Creamy',
        sleepHours: 8.0,
      ),
      DailySymptomLog(
        id: 'log_13',
        date: now.subtract(const Duration(days: 13)),
        flow: PeriodFlow.heavy,
        crampsSeverity: 4,
        pelvicPainSeverity: 3,
        mood: 'Fatigued',
        physicalSymptoms: ['Severe Cramps', 'Headache', 'Lower Back Pain', 'Fatigue'],
        basalBodyTemp: 36.3,
        sleepHours: 6.5,
        notes: 'First day of cycle. Required warm compress and ibuprofen.',
      ),
    ];
  }
}
