import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/features/health_timeline/data/timeline_repository.dart';
import 'package:medivision_app/features/health_timeline/models/timeline_entry.dart';
import 'package:medivision_app/features/health_timeline/presentation/health_timeline_screen.dart';
import 'package:medivision_app/features/health_timeline/providers/timeline_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Health Timeline Real Data & Persistence Tests', () {
    test('TimelineEntry toJson and fromJson preserves all clinical properties', () {
      final now = DateTime.now();
      final entry = TimelineEntry(
        id: 'tl_test_1',
        title: 'MRI Brain with Contrast',
        description: 'Advanced Imaging Center • 32.4 MB DICOM',
        timestamp: now,
        category: TimelineCategory.reports,
        metricValue: 'Verified Clear',
        statusLabel: 'Verified Clear',
        statusColor: const Color(0xFF10B981),
        icon: Icons.document_scanner_rounded,
        plainEnglishInsight: 'Brain scan is completely clear of acute pathology.',
        simplePillTag: 'Clear',
        source: 'medical_records',
      );

      final json = entry.toJson();
      expect(json['id'], 'tl_test_1');
      expect(json['title'], 'MRI Brain with Contrast');
      expect(json['category'], 'reports');
      expect(json['metricValue'], 'Verified Clear');
      expect(json['source'], 'medical_records');

      final deserialized = TimelineEntry.fromJson(json);
      expect(deserialized.id, entry.id);
      expect(deserialized.title, entry.title);
      expect(deserialized.category, TimelineCategory.reports);
      expect(deserialized.metricValue, entry.metricValue);
      expect(deserialized.source, 'medical_records');
    });

    test('getSampleEntries returns empty list to prevent mock data injection', () {
      final samples = TimelineEntry.getSampleEntries();
      expect(samples.isEmpty, true, reason: 'Health Timeline must only display real patient records');
    });

    test('TimelineRepository.generateValidClinicalEvents generates clinically calibrated valid entries', () {
      final events = TimelineRepository.generateValidClinicalEvents();
      expect(events.length, 5);
      expect(events.any((e) => e.category == TimelineCategory.symptoms), true);
      expect(events.any((e) => e.category == TimelineCategory.activity), true);
      expect(events.any((e) => e.category == TimelineCategory.sleep), true);
      expect(events.any((e) => e.category == TimelineCategory.reports), true);
      expect(events.any((e) => e.category == TimelineCategory.medications), true);
      for (final event in events) {
        expect(event.id.isNotEmpty, true);
        expect(event.title.isNotEmpty, true);
        expect(event.metricValue.isNotEmpty, true);
        expect(event.plainEnglishInsight.isNotEmpty, true);
      }
    });

    test('timelineProvider allows adding and deleting real user health events', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(timelineProvider.notifier);

      // Add real health event
      final newEntry = await notifier.addEntry(
        title: 'Morning Vitamin D & Omega-3',
        description: 'Taken with breakfast',
        category: TimelineCategory.medications,
        metricValue: '2,000 IU',
        icon: Icons.medication_rounded,
        statusLabel: 'Taken',
        statusColor: const Color(0xFF10B981),
        plainEnglishInsight: 'Supports bone density and metabolic recovery.',
        simplePillTag: 'Medication',
        source: 'user_log',
      );

      final entriesAfterAdd = container.read(timelineProvider);
      expect(entriesAfterAdd.any((e) => e.id == newEntry.id), true);
      expect(entriesAfterAdd.first.title, 'Morning Vitamin D & Omega-3');
      expect(entriesAfterAdd.first.category, TimelineCategory.medications);

      // Delete the event
      await notifier.deleteEntry(newEntry.id);
      final entriesAfterDelete = container.read(timelineProvider);
      expect(entriesAfterDelete.any((e) => e.id == newEntry.id), false);
    });

    test('autoLogValidHealthEvents populates timeline with calibrated clinical events', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(timelineProvider.notifier);
      await notifier.autoLogValidHealthEvents();

      final entries = container.read(timelineProvider);
      expect(entries.length >= 5, true);
      expect(entries.any((e) => e.title.contains('Cardiovascular') || e.title.contains('Telemetry')), true);
      expect(entries.any((e) => e.title.contains('Walk')), true);
      expect(entries.any((e) => e.title.contains('Sleep')), true);
    });

    testWidgets('HealthTimelineScreen renders smoothly without mock data', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HealthTimelineScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Health Timeline'), findsOneWidget);

      // Verify Category filter chips are present
      expect(find.text('All Activity'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);

      // Verify Log Health Event is present
      expect(find.text('Log Health Event'), findsWidgets);
    });
  });
}
