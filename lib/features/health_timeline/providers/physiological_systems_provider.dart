import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../ai_companion/data/ai_chat_service.dart';
import '../../medical_records/models/medical_record.dart';
import '../../medical_records/providers/medical_records_provider.dart';
import '../../vitals_activity/models/vitals_activity_model.dart';
import '../../vitals_activity/providers/vitals_provider.dart';
import '../models/physiological_systems_model.dart';

class PhysiologicalSystemsState {
  final PhysiologicalSystemsAssessment assessment;
  final bool isLoading;
  final bool isLiveAi;
  final String? errorMessage;
  final DateTime? lastRefreshed;

  const PhysiologicalSystemsState({
    required this.assessment,
    this.isLoading = false,
    this.isLiveAi = false,
    this.errorMessage,
    this.lastRefreshed,
  });

  PhysiologicalSystemsState copyWith({
    PhysiologicalSystemsAssessment? assessment,
    bool? isLoading,
    bool? isLiveAi,
    String? errorMessage,
    DateTime? lastRefreshed,
  }) {
    return PhysiologicalSystemsState(
      assessment: assessment ?? this.assessment,
      isLoading: isLoading ?? this.isLoading,
      isLiveAi: isLiveAi ?? this.isLiveAi,
      errorMessage: errorMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

class PhysiologicalSystemsNotifier extends StateNotifier<PhysiologicalSystemsState> {
  final Ref _ref;
  final FlutterSecureStorage _storage;
  static const _cacheKey = 'medivision_physiological_systems_cache_v1';

  PhysiologicalSystemsNotifier(this._ref, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(
          PhysiologicalSystemsState(
            assessment: PhysiologicalSystemsAssessment.fromRealData(
              vitals: _ref.read(vitalsProvider).snapshot,
              records: _ref.read(medicalRecordsProvider).records,
            ),
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    // 1. Try restore from cached JSON
    try {
      final cachedJson = await _storage.read(key: _cacheKey);
      if (cachedJson != null && cachedJson.trim().isNotEmpty) {
        final parsed = jsonDecode(cachedJson) as Map<String, dynamic>;
        state = state.copyWith(
          assessment: PhysiologicalSystemsAssessment.fromJson(parsed),
          isLiveAi: true,
          lastRefreshed: DateTime.tryParse(parsed['evaluatedAt'] as String? ?? ''),
        );
      }
    } catch (e) {
      debugPrint('Physiological systems cache read error: $e');
    }

    // 2. Fetch fresh real AI assessment in background
    refreshAnalysis(forceAi: true);
  }

  /// Request an AI evaluation of the user's real vitals & medical records
  Future<void> refreshAnalysis({bool forceAi = true}) async {
    final vitals = _ref.read(vitalsProvider).snapshot;
    final records = _ref.read(medicalRecordsProvider).records;

    // Immediately calculate deterministic assessment using real data so UI is always updated
    final localAssessment = PhysiologicalSystemsAssessment.fromRealData(
      vitals: vitals,
      records: records,
      isAi: state.isLiveAi,
    );

    if (!forceAi) {
      state = state.copyWith(
        assessment: localAssessment,
        lastRefreshed: DateTime.now(),
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Try Express backend endpoint (/api/ai/physiological-systems)
      final backendResult = await _callBackendAi(vitals, records);
      if (backendResult != null) {
        state = state.copyWith(
          assessment: backendResult,
          isLoading: false,
          isLiveAi: true,
          lastRefreshed: DateTime.now(),
        );
        await _cacheAssessment(backendResult);
        return;
      }

      // 2. Try direct Groq LLM completion
      final directGroqResult = await _callDirectGroq(vitals, records);
      if (directGroqResult != null) {
        state = state.copyWith(
          assessment: directGroqResult,
          isLoading: false,
          isLiveAi: true,
          lastRefreshed: DateTime.now(),
        );
        await _cacheAssessment(directGroqResult);
        return;
      }

      // 3. Graceful fallback using real data calculation
      state = state.copyWith(
        assessment: localAssessment,
        isLoading: false,
        isLiveAi: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Physiological systems AI generation error: $e');
      state = state.copyWith(
        assessment: localAssessment,
        isLoading: false,
        errorMessage: 'Using local clinical telemetry ($e)',
        lastRefreshed: DateTime.now(),
      );
    }
  }

  Future<void> _cacheAssessment(PhysiologicalSystemsAssessment assessment) async {
    try {
      final jsonStr = jsonEncode(assessment.toJson());
      await _storage.write(key: _cacheKey, value: jsonStr);
    } catch (_) {}
  }

  Future<PhysiologicalSystemsAssessment?> _callBackendAi(
    VitalsSnapshot vitals,
    List<MedicalRecordItem> records,
  ) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'vitals': {
          'steps': vitals.steps,
          'stepGoal': vitals.stepGoal,
          'activeMinutes': vitals.activeMinutes,
          'activeCalories': vitals.activeCalories,
          'restingHeartRate': vitals.restingHeartRate,
          'bloodPressureSystolic': vitals.bloodPressureSystolic,
          'bloodPressureDiastolic': vitals.bloodPressureDiastolic,
          'bloodOxygenSpO2': vitals.bloodOxygenSpO2,
          'bodyTemperature': vitals.bodyTemperature,
          'sleepDurationMinutes': vitals.sleepDurationMinutes,
          'deepSleepMinutes': vitals.deepSleepMinutes,
          'sleepQualityScore': vitals.sleepQualityScore,
          'screenTimeMinutes': vitals.screenTimeMinutes,
          'screenPickups': vitals.screenPickups,
        },
        'records': records.take(5).map((r) => {
          'title': r.title,
          'category': r.category.codeName,
          'date': r.date.toIso8601String(),
          'summary': r.summary,
        }).toList(),
      });

      final response = await http
          .post(
            Uri.parse(ApiConstants.aiPhysiologicalSystems),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return PhysiologicalSystemsAssessment.fromJson(
            decoded['data'] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      debugPrint('Backend physiological systems call skipped: $e');
    }
    return null;
  }

  Future<PhysiologicalSystemsAssessment?> _callDirectGroq(
    VitalsSnapshot vitals,
    List<MedicalRecordItem> records,
  ) async {
    try {
      const apiKey = GroqAiChatService.defaultApiKey;
      const model = 'llama-3.3-70b-versatile';

      final recordsInfo = records.isNotEmpty
          ? records
              .take(3)
              .map((r) => '- [${r.category.label}] ${r.title}: ${r.summary}')
              .join('\n')
          : 'None uploaded yet.';

      final prompt = '''
Analyze this real patient's telemetry and medical records to evaluate their 4 core physiological systems:
Telemetry:
- Resting Heart Rate: ${vitals.restingHeartRate} bpm
- Blood Pressure: ${vitals.bloodPressureSystolic}/${vitals.bloodPressureDiastolic} mmHg
- Blood Oxygen SpO2: ${vitals.bloodOxygenSpO2}%
- Body Temperature: ${vitals.bodyTemperature}°C
- Sleep: ${vitals.sleepDurationMinutes} mins total (${vitals.formattedSleep}), Deep Sleep: ${vitals.deepSleepMinutes} mins (${vitals.formattedDeepSleep}), Sleep Score: ${vitals.sleepQualityScore}%
- Steps: ${vitals.steps} / ${vitals.stepGoal} goal, Active Minutes: ${vitals.activeMinutes}m, Calories: ${vitals.activeCalories} kcal
- Screen Time: ${vitals.screenTimeMinutes}m

Records:
$recordsInfo

Output valid JSON only with structure:
{
  "overallScore": 92,
  "overallSummary": "...",
  "systems": {
    "brainSleep": { "name": "Sleep & Cognition", "score": 89, "status": "Rested", "headline": "...", "explanation": "...", "keyPills": ["${vitals.formattedSleep} Total", "${vitals.formattedDeepSleep} Deep", "${vitals.sleepQualityScore}% Efficiency"], "recommendation": "..." },
    "heartPulse": { "name": "Cardiovascular", "score": 96, "status": "Optimal Baseline", "headline": "...", "explanation": "...", "keyPills": ["${vitals.restingHeartRate} bpm", "${vitals.bloodPressureSystolic}/${vitals.bloodPressureDiastolic} mmHg", "SpO2 ${vitals.bloodOxygenSpO2}%"], "recommendation": "..." },
    "staminaMovement": { "name": "Physical Activity", "score": ${(vitals.stepsProgress * 100).toInt()}, "status": "Active", "headline": "...", "explanation": "...", "keyPills": ["${vitals.formattedSteps} Steps", "${vitals.activeCalories} kcal", "${vitals.activeMinutes} Active Min"], "recommendation": "..." },
    "bloodDefenses": { "name": "Hematology & Labs", "score": 95, "status": "In Range", "headline": "...", "explanation": "...", "keyPills": ["SpO2 ${vitals.bloodOxygenSpO2}%", "Temp ${vitals.bodyTemperature}°C", "Zero Flags"], "recommendation": "..." }
  }
}''';

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are MediVision AI clinical intelligence engine. Return only raw JSON without backticks.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.2,
              'max_tokens': 1200,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        var content = data['choices']?[0]?['message']?['content'] as String? ?? '';
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(content) as Map<String, dynamic>;
        if (parsed.containsKey('systems')) {
          return PhysiologicalSystemsAssessment.fromJson(parsed);
        }
      }
    } catch (e) {
      debugPrint('Direct Groq physiological systems call failed: $e');
    }
    return null;
  }
}

final physiologicalSystemsProvider =
    StateNotifierProvider<PhysiologicalSystemsNotifier, PhysiologicalSystemsState>((ref) {
  return PhysiologicalSystemsNotifier(ref);
});

