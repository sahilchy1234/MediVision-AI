import 'condition_assessment_model.dart';
import 'cycle_data_model.dart';
import 'symptom_log_model.dart';

class GynecologistSummary {
  final String patientName;
  final int? patientAge;
  final String patientGender;
  final double? heightCm;
  final double? weightKg;
  final List<String> medicalConditions;
  final List<String> allergies;
  final DateTime generatedDate;
  final CycleDataModel cycleData;
  final List<DailySymptomLog> recentLogs;
  final List<ConditionAssessment> assessments;
  final bool isPrivateEncrypted;

  const GynecologistSummary({
    required this.patientName,
    this.patientAge,
    this.patientGender = 'Female',
    this.heightCm,
    this.weightKg,
    this.medicalConditions = const [],
    this.allergies = const [],
    required this.generatedDate,
    required this.cycleData,
    required this.recentLogs,
    required this.assessments,
    this.isPrivateEncrypted = true,
  });

  double? get bmi {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      final hMeters = heightCm! / 100.0;
      return weightKg! / (hMeters * hMeters);
    }
    return null;
  }

  String get summaryText {
    final buffer = StringBuffer();
    buffer.writeln('================================================================');
    buffer.writeln('MEDIVISION AI — CLINICAL GYNECOLOGY & ENDOCRINE CONSULTATION BRIEF');
    buffer.writeln('================================================================');
    buffer.writeln('Patient: $patientName');
    if (patientAge != null) {
      buffer.write('Age: $patientAge yrs | Gender: $patientGender');
      if (bmi != null) {
        buffer.write(' | BMI: ${bmi!.toStringAsFixed(1)} kg/m²');
      }
      buffer.writeln();
    }
    if (medicalConditions.isNotEmpty) {
      buffer.writeln('Medical History: ${medicalConditions.join(', ')}');
    }
    if (allergies.isNotEmpty) {
      buffer.writeln('Allergies: ${allergies.join(', ')}');
    }
    buffer.writeln('Date Generated: ${generatedDate.toIso8601String().split('T').first}');
    buffer.writeln('Status: Patient-Authorized Clinical Telemetry Digest\n');

    buffer.writeln('1. MENSTRUAL CHRONOLOGY & CYCLE METRICS:');
    buffer.writeln('• Mean Cycle Length: ${cycleData.averageCycleLength} days (Variance: ±${cycleData.cycleVariationDays.toStringAsFixed(1)} days)');
    buffer.writeln('• Mean Period Duration: ${cycleData.averagePeriodDuration} days');
    buffer.writeln('• Current Checkpoint: Day ${cycleData.currentDayOfCycle} (${cycleData.currentPhase.label})');
    buffer.writeln('• Next Expected Menses: ${cycleData.predictedNextPeriod.toIso8601String().split('T').first}\n');

    // Peak dysmenorrhea & symptom stats from real logs
    final maxCramps = recentLogs.fold<int>(0, (max, l) => l.crampsSeverity > max ? l.crampsSeverity : max);
    final maxPelvic = recentLogs.fold<int>(0, (max, l) => l.pelvicPainSeverity > max ? l.pelvicPainSeverity : max);
    final androgenicSigns = recentLogs
        .expand((l) => l.pcosObservations)
        .toSet()
        .toList();
    final latestBbt = recentLogs
        .where((l) => l.basalBodyTemp != null)
        .map((l) => l.basalBodyTemp!)
        .toList();

    buffer.writeln('2. RECORDED SYMPTOM SEVERITY & PATTERNS (${recentLogs.length} Checkpoints Logged):');
    buffer.writeln('• Dysmenorrhea Peak: $maxCramps / 5 (Severity Scale: 0 None to 5 Debilitating)');
    buffer.writeln('• Non-Menstrual Pelvic Discomfort: $maxPelvic / 5');
    if (androgenicSigns.isNotEmpty) {
      buffer.writeln('• Hyperandrogenic Signs Logged: ${androgenicSigns.join(', ')}');
    } else {
      buffer.writeln('• Hyperandrogenic Signs: None reported in logs');
    }
    if (latestBbt.isNotEmpty) {
      buffer.writeln('• Latest Basal Temperature: ${latestBbt.first.toStringAsFixed(1)} °C');
    }
    buffer.writeln();

    buffer.writeln('3. AI PRE-CONSULTATION PATTERN EVALUATION:');
    for (final assessment in assessments) {
      buffer.writeln('• ${assessment.conditionName}: ${assessment.riskLevel.label} (${assessment.scorePercent.toInt()}%)');
      for (final marker in assessment.identifiedMarkers.take(2)) {
        buffer.writeln('   - $marker');
      }
    }

    buffer.writeln('\n4. SUGGESTED GYNECOLOGICAL INVESTIGATIONS TO DISCUSS:');
    final allTests = assessments.expand((a) => a.recommendedLabTests).toSet().take(6);
    for (final test in allTests) {
      buffer.writeln('• $test');
    }

    buffer.writeln('\n5. PRE-APPOINTMENT DISCUSSION QUESTIONS:');
    final allQuestions = assessments.expand((a) => a.physicianDiscussionPoints).toSet().take(4);
    for (final q in allQuestions) {
      buffer.writeln('• $q');
    }

    buffer.writeln('\n================================================================');
    buffer.writeln('CONFIDENTIAL — Intended solely for physician-patient clinical review');
    buffer.writeln('================================================================');

    return buffer.toString();
  }
}
