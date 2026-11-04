import 'package:flutter_test/flutter_test.dart';
import 'package:medivision_app/features/vitals_activity/models/vitals_activity_model.dart';

void main() {
  group('Vitals & Activity Model and Calculations Tests', () {
    test('VitalsSnapshot formatting and calculations are accurate', () {
      final snapshot = VitalsSnapshot(
        steps: 10450,
        stepGoal: 10000,
        restingHeartRate: 65,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        bloodOxygenSpO2: 99,
        sleepDurationMinutes: 480, // 8h
        deepSleepMinutes: 120,     // 2h
        screenTimeMinutes: 180,    // 3h
        lastUpdated: DateTime.now(),
      );

      expect(snapshot.formattedSteps, equals('10,450'));
      expect(snapshot.stepsProgress, equals(1.0));
      expect(snapshot.stepsSubtitle, equals('100% of daily goal'));

      expect(snapshot.formattedPulse, equals('65 bpm'));
      expect(snapshot.pulseSubtitle, equals('Healthy aerobic range'));

      expect(snapshot.formattedSleep, equals('8h 0m'));
      expect(snapshot.formattedDeepSleep, equals('2h 0m'));
      expect(snapshot.formattedScreenTime, equals('3h 0m'));
      expect(snapshot.formattedBP, equals('120/80 mmHg'));

      // Health score for optimal indicators should be high
      expect(snapshot.computedHealthScore, greaterThanOrEqualTo(90));
    });

    test('ActivitySession serializes and deserializes properly', () {
      final now = DateTime.now();
      final session = ActivitySession(
        id: 'act_test_1',
        type: 'Running',
        startTime: now,
        durationMinutes: 25,
        steps: 3200,
        calories: 180,
        distanceKm: 2.5,
        avgHeartRate: 142,
        notes: 'Morning cardio test',
      );

      final json = session.toJson();
      final reconstructed = ActivitySession.fromJson(json);

      expect(reconstructed.id, equals('act_test_1'));
      expect(reconstructed.type, equals('Running'));
      expect(reconstructed.steps, equals(3200));
      expect(reconstructed.calories, equals(180));
      expect(reconstructed.distanceKm, equals(2.5));
    });
  });
}

