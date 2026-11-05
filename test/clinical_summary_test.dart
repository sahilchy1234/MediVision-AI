import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivision_app/features/clinical_summary/models/clinical_summary_model.dart';
import 'package:medivision_app/features/clinical_summary/presentation/clinical_summary_screen.dart';
import 'package:medivision_app/features/clinical_summary/providers/clinical_summary_provider.dart';
import 'package:medivision_app/features/clinical_summary/services/clinical_pdf_export_service.dart';
import 'package:medivision_app/features/health_timeline/data/timeline_repository.dart';
import 'package:medivision_app/features/health_timeline/models/sensation_log.dart';
import 'package:medivision_app/features/medical_records/models/medical_record.dart';
import 'package:medivision_app/features/profile/data/models/user_profile_model.dart';
import 'package:medivision_app/features/vitals_activity/models/vitals_activity_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Clinical Summary & Real PDF Export Tests', () {
    test('1. fromRealData synthesizes complete 360-degree patient dossier', () {
      const profile = UserProfileModel(
        fullName: 'Alex Morgan MD',
        gender: 'Female',
        heightCm: 168,
        weightKg: 58.0,
        allergies: ['Penicillin', 'Sulfa'],
        medicalConditions: ['Asthma (Controlled)'],
      );

      final vitals = VitalsSnapshot(
        steps: 8420,
        stepGoal: 10000,
        activeMinutes: 42,
        activeCalories: 482,
        restingHeartRate: 61,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        bloodOxygenSpO2: 98,
        bodyTemperature: 36.8,
        sleepDurationMinutes: 462,
        deepSleepMinutes: 108,
        sleepQualityScore: 89,
        lastUpdated: DateTime.now(),
      );

      final records = [
        MedicalRecordItem(
          id: 'rec_cmp_1',
          title: 'Comprehensive Metabolic Panel',
          category: RecordCategory.bloodReports,
          date: DateTime.now().subtract(const Duration(days: 2)),
          providerName: 'Quest Diagnostics',
          fileSize: '1.2 MB PDF',
          fileType: 'pdf',
          status: 'Verified In-Range',
          statusColor: const Color(0xFF10B981),
          summary: 'Normal fasting blood glucose (92 mg/dL) and lipid profile.',
        ),
      ];

      final timeline = TimelineRepository.generateValidClinicalEvents();
      final sensations = SensationLog.getInitialSampleLogs();

      final summary = ClinicalSummaryModel.fromRealData(
        profile: profile,
        vitals: vitals,
        records: records,
        timeline: timeline,
        sensations: sensations,
      );

      expect(summary.patientName, 'Alex Morgan MD');
      expect(summary.age, 29);
      expect(summary.gender, 'Female');
      expect(summary.bloodGroup, 'O+');
      expect(summary.bmi, 20.5);
      expect(summary.bmiCategory, 'Normal weight');
      expect(summary.allergies, contains('Penicillin'));
      expect(summary.medicalConditions, contains('Asthma (Controlled)'));
      expect(summary.healthScore >= 90, true);
      expect(summary.bloodPressureSystolic, 118);
      expect(summary.bloodPressureDiastolic, 78);
      expect(summary.meanArterialPressure, 91);
      expect(summary.restingHeartRate, 61);
      expect(summary.bloodOxygenSpO2, 98);
      expect(summary.dailySteps, 8420);
      expect(summary.systems.containsKey('cardiovascular'), true);
      expect(summary.records.length, 1);
      expect(summary.timeline.length, 5);
      expect(summary.physicianDiscussionGuide.isNotEmpty, true);
      expect(summary.lifestyleRecommendations.isNotEmpty, true);
    });

    test('2. toJson and fromJson serialization preserves all clinical fields', () {
      final summary = ClinicalSummaryModel.fromRealData(
        profile: UserProfileModel.defaultMock,
        vitals: VitalsSnapshot(lastUpdated: DateTime.now()),
        records: const [],
        timeline: const [],
        sensations: const [],
      );

      final json = summary.toJson();
      expect(json['patientName'], 'Alex Morgan MD');
      expect(json['bmi'], 20.5);
      expect(json['bloodPressureSystolic'], 118);

      final deserialized = ClinicalSummaryModel.fromJson(json);
      expect(deserialized.patientName, summary.patientName);
      expect(deserialized.bmi, summary.bmi);
      expect(deserialized.healthScore, summary.healthScore);
      expect(deserialized.restingHeartRate, summary.restingHeartRate);
      expect(deserialized.bloodPressureSystolic, summary.bloodPressureSystolic);
    });

    test('3. ClinicalPdfExportService generates real, valid PDF document bytes', () async {
      final summary = ClinicalSummaryModel.fromRealData(
        profile: UserProfileModel.defaultMock,
        vitals: VitalsSnapshot(lastUpdated: DateTime.now()),
        records: [
          MedicalRecordItem(
            id: 'rec_mri_1',
            title: 'Brain MRI with Contrast',
            category: RecordCategory.xRays,
            date: DateTime.now().subtract(const Duration(days: 30)),
            providerName: 'Advanced Imaging',
            fileSize: '32.4 MB',
            fileType: 'dicom',
            status: 'Verified Clear',
            statusColor: const Color(0xFF10B981),
            summary: 'Scan clear of acute pathology.',
          ),
        ],
        timeline: TimelineRepository.generateValidClinicalEvents(),
        sensations: SensationLog.getInitialSampleLogs(),
      );

      final pdfBytes = await ClinicalPdfExportService.generatePdfBytes(summary);

      // Verify PDF byte stream exists and has PDF header '%PDF-'
      expect(pdfBytes.isNotEmpty, true);
      expect(pdfBytes.length > 1000, true);
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, '%PDF-');
    });

    testWidgets('4. ClinicalSummaryScreen renders all patient sections and export triggers', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ClinicalSummaryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title and patient name
      expect(find.text('Clinical Summary & Dossier'), findsOneWidget);
      expect(find.text('Alex Morgan MD'), findsOneWidget);
      expect(find.text('Verified Patient'), findsOneWidget);

      // Verify sections
      expect(find.text('Vitals & Ambulatory Telemetry'), findsOneWidget);
      expect(find.text('Physiological Systems Assessment'), findsOneWidget);
      expect(find.text('Verified Medical Records & Labs'), findsOneWidget);
      expect(find.text('Recent Clinical Milestones'), findsOneWidget);
      expect(find.text('Physician Consultation Care Plan'), findsOneWidget);

      // Verify export buttons
      expect(find.text('Export Clinical PDF'), findsOneWidget);
      expect(find.text('Print / Save'), findsOneWidget);
    });
  });
}
