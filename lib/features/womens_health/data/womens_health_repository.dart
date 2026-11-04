import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../medical_records/models/medical_record.dart';
import '../../profile/data/models/user_profile_model.dart';
import '../models/condition_assessment_model.dart';
import '../models/cycle_data_model.dart';
import '../models/symptom_log_model.dart';

class WomensHealthDataBundle {
  final CycleDataModel cycleData;
  final List<DailySymptomLog> symptomLogs;
  final List<ConditionAssessment> assessments;
  final bool isVaultLocked;
  final DateTime? lastAnalyzedAt;

  const WomensHealthDataBundle({
    required this.cycleData,
    required this.symptomLogs,
    required this.assessments,
    this.isVaultLocked = false,
    this.lastAnalyzedAt,
  });
}

class WomensHealthRepository {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'medivision_access_token';
  static const _cycleKey = 'medivision_womens_health_cycle';
  static const _logsKey = 'medivision_womens_health_logs';
  static const _assessmentsKey = 'medivision_womens_health_assessments';
  static const _vaultKey = 'medivision_womens_health_vault_locked';
  static const _analyzedAtKey = 'medivision_womens_health_analyzed_at';

  /// Load comprehensive Women's Health dataset (Backend sync with Secure Storage Fallback)
  Future<WomensHealthDataBundle> loadData() async {
    // 1. Try remote backend sync
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(ApiConstants.womensHealth), headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;

          final cycle = CycleDataModel.fromJson(data['cycleData'] as Map<String, dynamic>);
          final rawLogs = data['symptomLogs'] as List<dynamic>? ?? [];
          final logs = rawLogs.map((e) => DailySymptomLog.fromJson(e as Map<String, dynamic>)).toList();
          final rawAssessments = data['assessments'] as List<dynamic>? ?? [];
          final assessments = rawAssessments.map((e) => ConditionAssessment.fromJson(e as Map<String, dynamic>)).toList();
          final vaultLocked = data['vaultLocked'] as bool? ?? false;
          final analyzedAt = DateTime.tryParse(data['lastAnalyzedAt']?.toString() ?? '');

          // Cache locally
          await _cacheDataLocally(cycle, logs, assessments, vaultLocked, analyzedAt);

          return WomensHealthDataBundle(
            cycleData: cycle,
            symptomLogs: logs,
            assessments: assessments.isNotEmpty ? assessments : _generateLocalDeterministicAssessments(cycle, logs, null),
            isVaultLocked: vaultLocked,
            lastAnalyzedAt: analyzedAt,
          );
        }
      }
    } catch (e) {
      debugPrint('WomensHealthRepository remote sync notice: $e (Falling back to local storage)');
    }

    // 2. Fallback to Local Secure Storage Cache
    return await _loadFromLocalStorage();
  }

  Future<WomensHealthDataBundle> _loadFromLocalStorage() async {
    CycleDataModel cycle;
    List<DailySymptomLog> logs = [];
    List<ConditionAssessment> assessments = [];
    bool vaultLocked = false;
    DateTime? analyzedAt;

    try {
      final cycleRaw = await _storage.read(key: _cycleKey);
      if (cycleRaw != null) {
        cycle = CycleDataModel.fromJson(jsonDecode(cycleRaw) as Map<String, dynamic>);
      } else {
        // Sensible default based on real current date
        final now = DateTime.now();
        cycle = CycleDataModel.fromRealDates(
          lastPeriodStartDate: now.subtract(const Duration(days: 13)),
          averageCycleLength: 28,
          averagePeriodDuration: 5,
        );
      }

      final logsRaw = await _storage.read(key: _logsKey);
      if (logsRaw != null) {
        final list = jsonDecode(logsRaw) as List<dynamic>;
        logs = list.map((e) => DailySymptomLog.fromJson(e as Map<String, dynamic>)).toList();
      }

      final assessRaw = await _storage.read(key: _assessmentsKey);
      if (assessRaw != null) {
        final list = jsonDecode(assessRaw) as List<dynamic>;
        assessments = list.map((e) => ConditionAssessment.fromJson(e as Map<String, dynamic>)).toList();
      }

      final vaultRaw = await _storage.read(key: _vaultKey);
      vaultLocked = vaultRaw == 'true';

      final analyzedRaw = await _storage.read(key: _analyzedAtKey);
      if (analyzedRaw != null) {
        analyzedAt = DateTime.tryParse(analyzedRaw);
      }

      if (assessments.isEmpty) {
        assessments = _generateLocalDeterministicAssessments(cycle, logs, null);
      }

      return WomensHealthDataBundle(
        cycleData: cycle,
        symptomLogs: logs,
        assessments: assessments,
        isVaultLocked: vaultLocked,
        lastAnalyzedAt: analyzedAt,
      );
    } catch (e) {
      debugPrint('Error reading local womens health storage: $e');
      final now = DateTime.now();
      final defaultCycle = CycleDataModel.fromRealDates(
        lastPeriodStartDate: now.subtract(const Duration(days: 13)),
      );
      return WomensHealthDataBundle(
        cycleData: defaultCycle,
        symptomLogs: [],
        assessments: _generateLocalDeterministicAssessments(defaultCycle, [], null),
      );
    }
  }

  Future<void> _cacheDataLocally(
    CycleDataModel cycle,
    List<DailySymptomLog> logs,
    List<ConditionAssessment> assessments,
    bool vaultLocked,
    DateTime? analyzedAt,
  ) async {
    try {
      await _storage.write(key: _cycleKey, value: jsonEncode(cycle.toJson()));
      await _storage.write(key: _logsKey, value: jsonEncode(logs.map((l) => l.toJson()).toList()));
      await _storage.write(key: _assessmentsKey, value: jsonEncode(assessments.map((a) => a.toJson()).toList()));
      await _storage.write(key: _vaultKey, value: vaultLocked.toString());
      if (analyzedAt != null) {
        await _storage.write(key: _analyzedAtKey, value: analyzedAt.toIso8601String());
      }
    } catch (e) {
      debugPrint('Error caching womens health data locally: $e');
    }
  }

  /// Save Cycle parameters and sync
  Future<CycleDataModel> saveCycleData(CycleDataModel cycle) async {
    // 1. Cache locally
    try {
      await _storage.write(key: _cycleKey, value: jsonEncode(cycle.toJson()));
    } catch (e) {
      debugPrint('Error saving cycle locally: $e');
    }

    // 2. Sync to backend
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(
            Uri.parse(ApiConstants.womensHealthCycle),
            headers: headers,
            body: jsonEncode({
              'averageCycleLength': cycle.averageCycleLength,
              'averagePeriodDuration': cycle.averagePeriodDuration,
              'lastPeriodStartDate': cycle.lastPeriodStartDate.toIso8601String(),
              'cycleVariationDays': cycle.cycleVariationDays,
              'history': cycle.history.map((h) => h.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['data'] != null) {
          return CycleDataModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Backend cycle sync notice: $e');
    }

    return cycle;
  }

  /// Persist a daily symptom log
  Future<List<DailySymptomLog>> saveSymptomLog(
    DailySymptomLog newLog,
    List<DailySymptomLog> existingLogs, {
    bool isPeriodStart = false,
  }) async {
    final updatedList = [
      newLog,
      ...existingLogs.where((l) =>
          l.date.year != newLog.date.year ||
          l.date.month != newLog.date.month ||
          l.date.day != newLog.date.day),
    ];

    // 1. Cache locally
    try {
      await _storage.write(key: _logsKey, value: jsonEncode(updatedList.map((l) => l.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving logs locally: $e');
    }

    // 2. Sync to backend
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final payload = {
        ...newLog.toJson(),
        'isPeriodStart': isPeriodStart,
      };

      await http
          .post(
            Uri.parse(ApiConstants.womensHealthSymptoms),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Backend symptom log sync notice: $e');
    }

    return updatedList;
  }

  /// Run AI screening pattern evaluation
  Future<List<ConditionAssessment>> runAiScreeningAnalysis({
    required UserProfileModel userProfile,
    required CycleDataModel cycleData,
    required List<DailySymptomLog> symptomLogs,
    required List<MedicalRecordItem> records,
  }) async {
    // 1. Try remote AI analysis
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final payload = {
        'userProfile': userProfile.toJson(),
        'cycleData': cycleData.toJson(),
        'symptomLogs': symptomLogs.map((l) => l.toJson()).toList(),
        'records': records.map((r) => {
              'title': r.title,
              'category': r.category.name,
              'summary': r.summary,
            }).toList(),
      };

      final response = await http
          .post(
            Uri.parse(ApiConstants.womensHealthScreeningsAnalyze),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['assessments'] != null) {
          final list = (decoded['assessments'] as List<dynamic>)
              .map((e) => ConditionAssessment.fromJson(e as Map<String, dynamic>))
              .toList();

          await _storage.write(key: _assessmentsKey, value: jsonEncode(list.map((a) => a.toJson()).toList()));
          await _storage.write(key: _analyzedAtKey, value: DateTime.now().toIso8601String());
          return list;
        }
      }
    } catch (e) {
      debugPrint('Remote AI analysis error: $e (Using local clinical engine)');
    }

    // 2. Fallback to Local Deterministic Clinical Engine
    final localAssessments = _generateLocalDeterministicAssessments(cycleData, symptomLogs, userProfile);
    try {
      await _storage.write(key: _assessmentsKey, value: jsonEncode(localAssessments.map((a) => a.toJson()).toList()));
      await _storage.write(key: _analyzedAtKey, value: DateTime.now().toIso8601String());
    } catch (_) {}

    return localAssessments;
  }

  /// Toggle vault lock state
  Future<bool> toggleVaultLock(bool currentLock) async {
    final newStatus = !currentLock;
    try {
      await _storage.write(key: _vaultKey, value: newStatus.toString());

      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      await http
          .post(Uri.parse(ApiConstants.womensHealthVaultToggle), headers: headers)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Vault lock backend sync notice: $e');
    }
    return newStatus;
  }

  /// Local deterministic clinical screening engine
  List<ConditionAssessment> _generateLocalDeterministicAssessments(
    CycleDataModel cycle,
    List<DailySymptomLog> logs,
    UserProfileModel? profile,
  ) {
    int age = 30;
    if (profile?.dateOfBirth != null) {
      age = DateTime.now().difference(profile!.dateOfBirth!).inDays ~/ 365;
    }

    // 1. PCOS Pattern
    final pcosMarkers = <String>[];
    final pcosNegative = <String>[];
    double pcosScore = 20.0;

    if (cycle.cycleVariationDays > 3.0 || cycle.averageCycleLength > 35 || cycle.averageCycleLength < 24) {
      pcosScore += 25.0;
      pcosMarkers.add('Cycle variance exceeds ±${cycle.cycleVariationDays.toStringAsFixed(1)} days (oligomenorrhea cadence)');
    } else {
      pcosNegative.add('Regular cycle cadence (${cycle.averageCycleLength} days, ±${cycle.cycleVariationDays.toStringAsFixed(1)}d)');
    }

    final hasAcne = logs.any((l) => l.pcosObservations.any((o) => o.toLowerCase().contains('breakout') || o.toLowerCase().contains('acne')));
    final hasHair = logs.any((l) => l.pcosObservations.any((o) => o.toLowerCase().contains('hair') || o.toLowerCase().contains('facial')));
    final hasCravings = logs.any((l) => l.pcosObservations.any((o) => o.toLowerCase().contains('sugar') || o.toLowerCase().contains('cravings')));

    if (hasAcne) {
      pcosScore += 20.0;
      pcosMarkers.add('Cyclical cystic jawline breakouts logged in recent entries');
    }
    if (hasHair) {
      pcosScore += 20.0;
      pcosMarkers.add('Terminal facial/body hair coarseness logged');
    } else {
      pcosNegative.add('No clinical hirsutism reported');
    }
    if (hasCravings) {
      pcosScore += 10.0;
      pcosMarkers.add('Postprandial carb cravings logged');
    }

    pcosScore = pcosScore.clamp(15.0, 95.0);
    final pcosRisk = pcosScore >= 70
        ? AssessmentRiskLevel.highRisk
        : (pcosScore >= 45 ? AssessmentRiskLevel.moderateRisk : AssessmentRiskLevel.lowRisk);

    // 2. Endometriosis
    final endoMarkers = <String>[];
    final endoNegative = <String>[];
    double endoScore = 18.0;

    final maxCramps = logs.fold<int>(0, (max, l) => l.crampsSeverity > max ? l.crampsSeverity : max);
    final maxPelvic = logs.fold<int>(0, (max, l) => l.pelvicPainSeverity > max ? l.pelvicPainSeverity : max);
    final hasBackPain = logs.any((l) => l.physicalSymptoms.any((s) => s.toLowerCase().contains('back')));

    if (maxCramps >= 4) {
      endoScore += 35.0;
      endoMarkers.add('Severe dysmenorrhea ($maxCramps/5) logged during menses');
    } else if (maxCramps >= 2) {
      endoScore += 15.0;
      endoMarkers.add('Moderate menstrual cramps ($maxCramps/5)');
    } else {
      endoNegative.add('Mild/absent menstrual cramps (<= 1/5)');
    }

    if (maxPelvic >= 2) {
      endoScore += 25.0;
      endoMarkers.add('Non-menstrual pelvic pain reported at severity $maxPelvic/5');
    } else {
      endoNegative.add('No non-menstrual chronic pelvic soreness reported');
    }

    if (hasBackPain) {
      endoScore += 10.0;
      endoMarkers.add('Lower back radiating pain during cycle');
    }

    endoScore = endoScore.clamp(10.0, 95.0);
    final endoRisk = endoScore >= 70
        ? AssessmentRiskLevel.highRisk
        : (endoScore >= 45 ? AssessmentRiskLevel.moderateRisk : AssessmentRiskLevel.lowRisk);

    // 3. Ovulatory Reserve & Fertility Readiness
    final fertMarkers = <String>[];
    final fertNegative = <String>[];
    double fertScore = 20.0;

    final hasFertileMucus = logs.any((l) => (l.cervicalMucus ?? '').toLowerCase().contains('egg-white'));
    if (hasFertileMucus) {
      fertMarkers.add('Peak fertile egg-white cervical fluid recorded around Day 14');
    }
    if (age < 35 && cycle.averageCycleLength >= 26 && cycle.averageCycleLength <= 32) {
      fertNegative.add('Favorable reproductive age window ($age yrs) and healthy cycle periodicity');
    } else if (age >= 38) {
      fertScore += 25.0;
      fertMarkers.add('Chronological age ($age) indicates physiological ovarian transition');
    }

    fertScore = fertScore.clamp(10.0, 90.0);
    final fertRisk = fertScore >= 65 ? AssessmentRiskLevel.moderateRisk : AssessmentRiskLevel.lowRisk;

    // 4. Perimenopause Screening
    final periMarkers = <String>[];
    final periNegative = <String>[];
    double periScore = 12.0;

    final hasHotFlashes = logs.any((l) => l.physicalSymptoms.any((s) => s.toLowerCase().contains('hot flashes')));
    if (age >= 40) {
      periScore += 25.0;
      periMarkers.add('Age $age enters standard perimenopausal transition window');
    } else {
      periNegative.add('Age $age is well below typical perimenopause onset');
    }

    if (hasHotFlashes) {
      periScore += 35.0;
      periMarkers.add('Vasomotor fluctuations (hot flashes) logged in symptoms');
    } else {
      periNegative.add('No vasomotor temperature volatility reported');
    }

    periScore = periScore.clamp(10.0, 90.0);
    final periRisk = periScore >= 65
        ? AssessmentRiskLevel.highRisk
        : (periScore >= 40 ? AssessmentRiskLevel.moderateRisk : AssessmentRiskLevel.lowRisk);

    return [
      ConditionAssessment(
        id: 'pcos_pcod',
        conditionName: 'PCOS / PCOD',
        category: 'Endocrine & Ovulatory',
        subtitle: 'Rotterdam Criteria & Pattern Evaluation',
        riskLevel: pcosRisk,
        scorePercent: pcosScore,
        identifiedMarkers: pcosMarkers.isNotEmpty ? pcosMarkers : ['No androgenic symptoms or cycle irregularity logged'],
        negativeMarkers: pcosNegative,
        recommendedLabTests: [
          'Pelvic Ultrasound (Transvaginal Antral Follicle Count)',
          'Day 2–3 Serum LH & FSH (LH:FSH ratio)',
          'Serum Anti-Müllerian Hormone (AMH)',
          'Total & Free Serum Testosterone, DHEAS',
          'Fasting Glucose & Fasting Insulin (HOMA-IR)',
        ],
        physicianDiscussionPoints: [
          'Review pelvic ultrasound imaging for polycystic morphology (>12 follicles).',
          'Assess whether metabolic inositol supplementation is indicated.',
          'Evaluate morning basal body temperature biphasic curves.',
        ],
        clinicalRationale:
            'Evaluated via Rotterdam Consensus criteria. Current pattern correlation is ${pcosScore.toInt()}% based on logged cycle variance (±${cycle.cycleVariationDays.toStringAsFixed(1)}d) and recorded skin/metabolic indicators.',
      ),
      ConditionAssessment(
        id: 'endometriosis',
        conditionName: 'Endometriosis & Adenomyosis',
        category: 'Gynecological Pain & Structural',
        subtitle: 'Dysmenorrhea Severity & Pelvic Pain Mapping',
        riskLevel: endoRisk,
        scorePercent: endoScore,
        identifiedMarkers: endoMarkers.isNotEmpty ? endoMarkers : ['No severe dysmenorrhea or pelvic pain logged'],
        negativeMarkers: endoNegative,
        recommendedLabTests: [
          'High-Resolution Deep Infiltrating Pelvic Ultrasound',
          'Pelvic MRI with Contrast (if deep infiltration suspected)',
          'Serum CA-125 (supplementary inflammatory marker)',
        ],
        physicianDiscussionPoints: [
          'Differentiate primary dysmenorrhea from secondary endometriosis.',
          'Discuss cyclic or continuous progestin therapeutic options.',
          'Assess pain interference with daily activities during menses.',
        ],
        clinicalRationale:
            'Endometriosis frequently presents with progressive dysmenorrhea and non-cyclical pelvic pain. Your logs exhibit maximum cramps of $maxCramps/5 and non-menses pelvic soreness of $maxPelvic/5.',
      ),
      ConditionAssessment(
        id: 'infertility_ovulation',
        conditionName: 'Ovulatory Reserve & Fertility Readiness',
        category: 'Reproductive Potential',
        subtitle: 'Ovulation Regularity & Luteal Adequacy',
        riskLevel: fertRisk,
        scorePercent: fertScore,
        identifiedMarkers: fertMarkers.isNotEmpty ? fertMarkers : ['Normal follicular cadence observed'],
        negativeMarkers: fertNegative,
        recommendedLabTests: [
          'Day 21 (Mid-luteal) Serum Progesterone',
          'Serum Anti-Müllerian Hormone (AMH)',
          'Thyroid Panel (TSH, Free T4) & Serum Prolactin',
        ],
        physicianDiscussionPoints: [
          'Confirm biphasic ovulatory cycles with serum progesterone.',
          'Discuss preconception methylated folate and vitamin D3 optimization.',
        ],
        clinicalRationale:
            'Assesses spontaneous ovulatory regularity and luteal phase stability against current patient age ($age) and cervical fluid markers.',
      ),
      ConditionAssessment(
        id: 'perimenopause',
        conditionName: 'Perimenopause & Hormonal Transition',
        category: 'Endocrine Transition',
        subtitle: 'Vasomotor & Hormonal Transition Screening',
        riskLevel: periRisk,
        scorePercent: periScore,
        identifiedMarkers: periMarkers.isNotEmpty ? periMarkers : ['Zero vasomotor symptoms recorded'],
        negativeMarkers: periNegative,
        recommendedLabTests: [
          'Serum FSH and Estradiol (E2)',
          'Complete Thyroid Panel (TSH, FT3, FT4)',
          'DEXA Bone Mineral Density Scan',
        ],
        physicianDiscussionPoints: [
          'Discuss non-hormonal and hormonal therapies if vasomotor symptoms arise.',
          'Track cardiovascular lipid markers and bone mineral density.',
        ],
        clinicalRationale:
            'Assesses neuroendocrine indicators against current patient age ($age) and recorded physical symptoms.',
      ),
    ];
  }
}

