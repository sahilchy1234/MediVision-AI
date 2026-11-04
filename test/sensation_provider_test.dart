import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/features/health_timeline/models/timeline_entry.dart';
import 'package:medivision_app/features/health_timeline/providers/sensation_provider.dart';
import 'package:medivision_app/features/health_timeline/providers/timeline_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Sensation Provider & Body Systems Logging', () {
    test('sensationProvider initializes with sample historical sensations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sensations = container.read(sensationProvider);
      expect(sensations.isNotEmpty, true);
      expect(sensations.any((s) => s.systemOrArea == 'Sleep & Cognition'), true);
      expect(sensations.any((s) => s.systemOrArea == 'Cardiovascular'), true);
    });

    test('addSensation logs sensation, persists to storage, and mirrors into timeline symptoms category', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sensationProvider.notifier);
      final entry = await notifier.addSensation(
        systemOrArea: 'Cardiovascular',
        sensation: 'Chest Tightness',
        severity: 6,
        qualityTags: ['Dull Ache', 'Tightness'],
        notes: 'Felt after morning run',
      );

      // Verify sensation list has new entry
      final updatedSensations = container.read(sensationProvider);
      expect(updatedSensations.first.id, entry.id);
      expect(updatedSensations.first.sensation, 'Chest Tightness');
      expect(updatedSensations.first.severity, 6);
      expect(updatedSensations.first.severityLabel, 'Moderate');

      // Verify mirrored into timeline entries under symptoms
      final timeline = container.read(timelineProvider);
      expect(timeline.first.title, contains('Chest Tightness'));
      expect(timeline.first.category, TimelineCategory.symptoms);
      expect(timeline.first.metricValue, '6/10 Intensity');

      // Verify persisted in storage
      const storage = FlutterSecureStorage();
      final persistedRaw = await storage.read(key: 'medivision_sensations_storage');
      expect(persistedRaw, isNotNull);
      expect(persistedRaw, contains('Chest Tightness'));
    });

    test('getLogsForSystem filters accurately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sensationProvider.notifier);
      final cardSensations = notifier.getLogsForSystem('Cardiovascular');
      expect(cardSensations.every((s) => s.systemOrArea.toLowerCase().contains('cardio')), true);
    });
  });
}
