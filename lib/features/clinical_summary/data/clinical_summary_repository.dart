import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../authentication/data/auth_service.dart';
import '../../health_timeline/models/physiological_systems_model.dart';
import '../../health_timeline/models/sensation_log.dart';
import '../../health_timeline/models/timeline_entry.dart';
import '../../medical_records/models/medical_record.dart';
import '../../profile/data/models/user_profile_model.dart';
import '../../vitals_activity/models/vitals_activity_model.dart';
import '../../womens_health/providers/womens_health_provider.dart';
import '../models/clinical_summary_model.dart';

class ClinicalSummaryRepository {
  static const _storageKey = 'medivision_clinical_summary_cache_v1';
  final FlutterSecureStorage _storage;

  ClinicalSummaryRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Retrieve existing cached clinical summary
  Future<ClinicalSummaryModel?> getCachedSummary() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(raw);
        return ClinicalSummaryModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error reading cached clinical summary: $e');
    }
    return null;
  }

  /// Persist summary to secure storage
  Future<void> saveSummaryLocally(ClinicalSummaryModel summary) async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(summary.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving clinical summary locally: $e');
    }
  }

  /// Fetch latest summary from backend or synthesize dynamically from live app providers
  Future<ClinicalSummaryModel> fetchOrSynthesizeSummary({
    required UserProfileModel profile,
    required VitalsSnapshot vitals,
    required List<MedicalRecordItem> records,
    required List<TimelineEntry> timeline,
    required List<SensationLog> sensations,
    PhysiologicalSystemsAssessment? physiologicalSystems,
    WomensHealthState? womensHealthState,
    bool forceFresh = false,
  }) async {
    // 1. Try backend sync
    try {
      final token = await AuthService.getStoredToken();
      final headers = ApiConstants.headers(token);

      final response = await http
          .get(Uri.parse(ApiConstants.clinicalSummary), headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final summary = ClinicalSummaryModel.fromJson(data);
          await saveSummaryLocally(summary);
          return summary;
        }
      }
    } catch (e) {
      debugPrint('Backend clinical summary sync offline/unavailable: $e. Synthesizing from local patient data.');
    }

    // 2. Synthesize directly from real client data sources
    final synthesized = ClinicalSummaryModel.fromRealData(
      profile: profile,
      vitals: vitals,
      records: records,
      timeline: timeline,
      sensations: sensations,
      physiologicalSystems: physiologicalSystems,
      womensHealthState: womensHealthState,
    );

    await saveSummaryLocally(synthesized);
    return synthesized;
  }
}
