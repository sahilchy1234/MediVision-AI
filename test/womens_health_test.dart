import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivision_app/features/profile/data/models/user_profile_model.dart';
import 'package:medivision_app/features/profile/providers/profile_provider.dart';
import 'package:medivision_app/features/womens_health/models/condition_assessment_model.dart';
import 'package:medivision_app/features/womens_health/models/cycle_data_model.dart';
import 'package:medivision_app/features/womens_health/models/symptom_log_model.dart';
import 'package:medivision_app/features/womens_health/presentation/condition_screening_screen.dart';
import 'package:medivision_app/features/womens_health/presentation/womens_health_screen.dart';
import 'package:medivision_app/features/womens_health/providers/womens_health_provider.dart';

void main() {
  group('Women\'s Health Real Data & AI Screenings Tests', () {
    test('1. CycleDataModel serializes, deserializes and calculates real metrics dynamically', () {
      final now = DateTime.now();
      final lastPeriod = now.subtract(const Duration(days: 14));

      final cycle = CycleDataModel.fromRealDates(
        lastPeriodStartDate: lastPeriod,
        averageCycleLength: 29,
        averagePeriodDuration: 5,
        cycleVariationDays: 1.9,
      );

      expect(cycle.currentDayOfCycle, 15);
      expect(cycle.averageCycleLength, 29);
      expect(cycle.currentPhase, CyclePhase.ovulatory);
      expect(cycle.isFertileWindow, true);
      expect(cycle.daysUntilNextPeriod, 14);

      final json = cycle.toJson();
      final revived = CycleDataModel.fromJson(json);

      expect(revived.averageCycleLength, 29);
      expect(revived.currentPhase, CyclePhase.ovulatory);
      expect(revived.cycleVariationDays, 1.9);
    });

    test('2. DailySymptomLog correctly serializes and stores reproductive indicators', () {
      final now = DateTime.now();
      final log = DailySymptomLog(
        id: 'test_log_1',
        date: now,
        flow: PeriodFlow.medium,
        crampsSeverity: 3,
        pelvicPainSeverity: 1,
        mood: 'Energetic',
        physicalSymptoms: ['Mild Bloating', 'Tender Breasts'],
        pcosObservations: ['Jawline / Cystic Breakout'],
        basalBodyTemp: 36.7,
        cervicalMucus: 'Egg-white (Fertile)',
        notes: 'Clinical ovulation spike.',
      );

      final json = log.toJson();
      final revived = DailySymptomLog.fromJson(json);

      expect(revived.id, 'test_log_1');
      expect(revived.flow, PeriodFlow.medium);
      expect(revived.crampsSeverity, 3);
      expect(revived.pelvicPainSeverity, 1);
      expect(revived.mood, 'Energetic');
      expect(revived.physicalSymptoms.length, 2);
      expect(revived.pcosObservations.first, 'Jawline / Cystic Breakout');
      expect(revived.basalBodyTemp, 36.7);
      expect(revived.cervicalMucus, 'Egg-white (Fertile)');
      expect(revived.notes, 'Clinical ovulation spike.');
    });

    test('3. ConditionAssessment correctly parses risk levels and score indicators', () {
      const assessment = ConditionAssessment(
        id: 'pcos_pcod',
        conditionName: 'PCOS / PCOD',
        category: 'Endocrine & Ovulatory',
        subtitle: 'Rotterdam Pattern Screener',
        riskLevel: AssessmentRiskLevel.moderateRisk,
        scorePercent: 58.0,
        identifiedMarkers: ['Cycle variation exceeds ±3.0 days'],
        negativeMarkers: ['No hirsutism reported'],
        recommendedLabTests: ['Pelvic Ultrasound', 'Day 2–3 Serum LH & FSH'],
        physicianDiscussionPoints: ['Review ovarian follicle count.'],
        clinicalRationale: 'Calculated using Rotterdam criteria.',
      );

      final json = assessment.toJson();
      final revived = ConditionAssessment.fromJson(json);

      expect(revived.id, 'pcos_pcod');
      expect(revived.riskLevel, AssessmentRiskLevel.moderateRisk);
      expect(revived.scorePercent, 58.0);
      expect(revived.identifiedMarkers.length, 1);
      expect(revived.recommendedLabTests.length, 2);
    });

    test('4. Doctor consultation summary calculates real user age, BMI, and telemetry digest', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith((ref) => ProfileNotifier()
            ..updateProfile(UserProfileModel(
              fullName: 'Elena Rostova',
              dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 28 + 10)),
              gender: 'Female',
              heightCm: 165.0,
              weightKg: 55.0,
              medicalConditions: ['Asthma (Mild)'],
              allergies: ['Penicillin'],
            ))),
        ],
      );

      final notifier = container.read(womensHealthProvider.notifier);
      final profile = container.read(profileProvider);

      final summary = notifier.generateDoctorSummary(profile);

      expect(summary.patientName, 'Elena Rostova');
      expect(summary.patientAge, 28);
      expect(summary.patientGender, 'Female');
      expect(summary.bmi, closeTo(20.2, 0.2));
      expect(summary.summaryText.contains('Elena Rostova'), true);
      expect(summary.summaryText.contains('Age: 28 yrs'), true);
      expect(summary.summaryText.contains('Asthma (Mild)'), true);
      expect(summary.summaryText.contains('Penicillin'), true);
    });

    testWidgets('5. WomensHealthScreen renders smoothly with real cycle data and actions', (tester) async {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith((ref) => ProfileNotifier()
            ..updateProfile(const UserProfileModel(
              fullName: 'Jane Doe',
              gender: 'Female',
            ))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WomensHealthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Women's Health"), findsOneWidget);
      expect(find.text('Log Today'), findsOneWidget);
      expect(find.text('Assess Patterns'), findsOneWidget);
      expect(find.text('Reproductive Imaging & Panels'), findsOneWidget);
      expect(find.text('Screening Patterns'), findsOneWidget);
    });

    testWidgets('6. ConditionScreeningScreen renders clinical screener and AI evaluation banner', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ConditionScreeningScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Clinical Condition Screener'), findsOneWidget);
      expect(find.text('Real AI Clinical Synthesis'), findsOneWidget);
      expect(find.text('Re-evaluate'), findsOneWidget);
      expect(find.text('Condition Risk & Patterns'), findsOneWidget);
    });
  });
}

