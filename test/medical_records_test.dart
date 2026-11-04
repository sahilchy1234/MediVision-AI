import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivision_app/features/medical_records/models/medical_record.dart';

void main() {
  group('MedicalRecordItem Tests', () {
    test('toJson and fromJson preserves all fields', () {
      final now = DateTime.now();
      final item = MedicalRecordItem(
        id: 'rec_test_101',
        title: 'Thyroid Function Panel',
        category: RecordCategory.bloodReports,
        date: now,
        providerName: 'City Lab Diagnostics',
        fileSize: '1.2 MB PDF',
        status: 'Optimal Range',
        statusColor: const Color(0xFF10B981),
        summary: 'TSH and free T4 within standard limits.',
        notes: 'Follow-up in 12 months.',
        filePath: '/data/user/0/documents/thyroid.pdf',
        fileType: 'pdf',
      );

      final json = item.toJson();
      final recreated = MedicalRecordItem.fromJson(json);

      expect(recreated.id, equals(item.id));
      expect(recreated.title, equals(item.title));
      expect(recreated.category, equals(RecordCategory.bloodReports));
      expect(recreated.providerName, equals('City Lab Diagnostics'));
      expect(recreated.fileSize, equals('1.2 MB PDF'));
      expect(recreated.status, equals('Optimal Range'));
      expect(recreated.summary, equals(item.summary));
      expect(recreated.notes, equals(item.notes));
      expect(recreated.filePath, equals(item.filePath));
      expect(recreated.fileType, equals(item.fileType));
    });

    test('RecordCategoryExtension resolves category from String', () {
      expect(
        RecordCategoryExtension.fromString('bloodReports'),
        equals(RecordCategory.bloodReports),
      );
      expect(
        RecordCategoryExtension.fromString('xRays'),
        equals(RecordCategory.xRays),
      );
      expect(
        RecordCategoryExtension.fromString('prescriptions'),
        equals(RecordCategory.prescriptions),
      );
      expect(
        RecordCategoryExtension.fromString('other'),
        equals(RecordCategory.other),
      );
      expect(
        RecordCategoryExtension.fromString('unknown'),
        equals(RecordCategory.other),
      );
    });

    test('Default sample records return empty to ensure only real user records are displayed', () {
      final sample = MedicalRecordItem.getSampleRecords();
      expect(sample.isEmpty, isTrue);
    });
  });
}

