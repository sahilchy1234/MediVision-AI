import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/features/health_timeline/models/physiological_systems_model.dart';
import 'package:medivision_app/features/health_timeline/providers/physiological_systems_provider.dart';
import 'package:medivision_app/features/medical_records/models/medical_record.dart';
import 'package:medivision_app/features/vitals_activity/models/vitals_activity_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Physiological Systems AI Feed & Model Tests', () {
    test('1. fromRealData computes accurate clinical metrics from actual vitals', () {
      final vitals = VitalsSnapshot(
        restingHeartRate: 64,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 76,
        bloodOxygenSpO2: 99,
        steps: 9200,
        stepGoal: 10000,
        activeCalories: 510,
        activeMinutes: 48,
        sleepDurationMinutes: 480,
        deepSleepMinutes: 120,
        sleepQualityScore: 92,
        bodyTemperature: 36.6,
        lastUpdated: DateTime.now(),
      );

      final assessment = PhysiologicalSystemsAssessment.fromRealData(
        vitals: vitals,
        records: const [],
      );

      expect(assessment.overallScore, greaterThan(80));
      expect(assessment.brainSleep.score, 92);
      expect(assessment.brainSleep.status, 'Rested');
      expect(assessment.brainSleep.keyPills, contains('8h 0m Total'));

      expect(assessment.heartPulse.score, 96);
      expect(assessment.heartPulse.status, 'Optimal Baseline');
      expect(assessment.heartPulse.keyPills, contains('64 bpm'));
      expect(assessment.heartPulse.keyPills, contains('118/76 mmHg'));
      expect(assessment.heartPulse.keyPills, contains('SpO2 99%'));

      expect(assessment.staminaMovement.score, 92);
      expect(assessment.staminaMovement.status, 'Goal Met');
      expect(assessment.staminaMovement.keyPills, contains('9,200 Steps'));
      expect(assessment.staminaMovement.keyPills, contains('510 kcal'));

      expect(assessment.bloodDefenses.score, 92);
      expect(assessment.bloodDefenses.status, 'Vitals In Range');
    });

    test('2. fromRealData incorporates uploaded lab records into Hematology & Labs', () {
      final vitals = VitalsSnapshot(lastUpdated: DateTime.now());
      final record = MedicalRecordItem(
        id: 'rec_cbc',
        title: 'Complete Blood Count (CBC)',
        category: RecordCategory.bloodReports,
        date: DateTime.now(),
        providerName: 'City Diagnostic Labs',
        fileSize: '1.2 MB',
        status: 'Normal',
        statusColor: const Color(0xFF10B981),
        summary: 'Hemoglobin 14.5 g/dL, Platelets 260k/uL, WBC normal.',
      );

      final assessment = PhysiologicalSystemsAssessment.fromRealData(
        vitals: vitals,
        records: [record],
      );

      expect(assessment.bloodDefenses.score, 94);
      expect(assessment.bloodDefenses.status, 'Lab Verified');
      expect(assessment.bloodDefenses.headline, 'Laboratory Chemistry: Analyzed');
      expect(assessment.bloodDefenses.explanation, contains('Complete Blood Count'));
    });

    test('3. JSON parsing deserializes backend AI structured feed', () {
      final sampleJson = {
        'overallScore': 94,
        'overallSummary': 'Cardiovascular and sleep architecture in peak restorative alignment.',
        'isAiGenerated': true,
        'evaluatedAt': '2026-11-04T12:00:00.000Z',
        'systems': {
          'brainSleep': {
            'name': 'Sleep & Cognition',
            'score': 91,
            'status': 'Optimal Rest',
            'headline': 'Sleep Efficiency: Peak Delta Phase',
            'explanation': 'Consistent 8h duration with 24% deep restorative sleep stage.',
            'keyPills': ['8h Total', '1h 55m Deep', '91% Quality'],
            'recommendation': 'Maintain current wake time.'
          },
          'heartPulse': {
            'name': 'Cardiovascular',
            'score': 98,
            'status': 'Optimal Baseline',
            'headline': 'Cardiovascular: Normal Baseline',
            'explanation': 'Resting pulse at 60 bpm with stable pulse oximetry.',
            'keyPills': ['60 bpm', '118/76 mmHg', 'SpO2 99%'],
            'recommendation': 'Keep up regular cardio activity.'
          },
          'staminaMovement': {
            'name': 'Physical Activity',
            'score': 88,
            'status': 'Active',
            'headline': 'Physical Movement: Daily Cadence Met',
            'explanation': '8,500 steps logged with 490 kcal active burn.',
            'keyPills': ['8,500 Steps', '490 kcal', '45m Active'],
            'recommendation': 'Hydrate after sustained movement.'
          },
          'bloodDefenses': {
            'name': 'Hematology & Labs',
            'score': 95,
            'status': 'In Range',
            'headline': 'Metabolic Status: Optimal',
            'explanation': 'Oxygen saturation and core thermoregulation baseline steady.',
            'keyPills': ['SpO2 99%', 'Temp 36.7°C', 'Zero Flags'],
            'recommendation': 'Schedule routine annual checkup.'
          }
        }
      };

      final assessment = PhysiologicalSystemsAssessment.fromJson(sampleJson);
      expect(assessment.overallScore, 94);
      expect(assessment.isAiGenerated, true);
      expect(assessment.brainSleep.score, 91);
      expect(assessment.heartPulse.score, 98);
      expect(assessment.staminaMovement.score, 88);
      expect(assessment.bloodDefenses.score, 95);
      expect(assessment.heartPulse.keyPills, contains('60 bpm'));
    });

    test('4. physiologicalSystemsProvider initializes with real data assessment', () async {
      final container = ProviderContainer();

      final state = container.read(physiologicalSystemsProvider);
      expect(state.assessment.overallScore, greaterThan(0));
      expect(state.assessment.systems.length, 4);
      expect(state.assessment.brainSleep.name, 'Sleep & Cognition');
      expect(state.assessment.heartPulse.name, 'Cardiovascular');
      expect(state.assessment.staminaMovement.name, 'Physical Activity');
      expect(state.assessment.bloodDefenses.name, 'Hematology & Labs');

      await Future<void>.delayed(const Duration(milliseconds: 100));
      container.dispose();
    });
  });
}
