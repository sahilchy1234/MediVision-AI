import 'package:flutter/material.dart';

enum AssessmentRiskLevel {
  lowRisk,
  moderateRisk,
  highRisk,
  requiresImmediateConsultation;

  String get label {
    switch (this) {
      case AssessmentRiskLevel.lowRisk:
        return 'Low Clinical Probability';
      case AssessmentRiskLevel.moderateRisk:
        return 'Moderate Pattern Correlation';
      case AssessmentRiskLevel.highRisk:
        return 'High Pattern Correlation';
      case AssessmentRiskLevel.requiresImmediateConsultation:
        return 'Urgent Medical Attention Advised';
    }
  }

  Color get color {
    switch (this) {
      case AssessmentRiskLevel.lowRisk:
        return const Color(0xFF10B981); // Emerald
      case AssessmentRiskLevel.moderateRisk:
        return const Color(0xFFF59E0B); // Amber
      case AssessmentRiskLevel.highRisk:
        return const Color(0xFFF43F5E); // Rose
      case AssessmentRiskLevel.requiresImmediateConsultation:
        return const Color(0xFFDC2626); // Red
    }
  }
}

class ConditionAssessment {
  final String id;
  final String conditionName;
  final String category;
  final String subtitle;
  final AssessmentRiskLevel riskLevel;
  final double scorePercent; // 0 to 100
  final List<String> identifiedMarkers;
  final List<String> negativeMarkers;
  final List<String> recommendedLabTests;
  final List<String> physicianDiscussionPoints;
  final String clinicalRationale;

  const ConditionAssessment({
    required this.id,
    required this.conditionName,
    required this.category,
    required this.subtitle,
    required this.riskLevel,
    required this.scorePercent,
    required this.identifiedMarkers,
    required this.negativeMarkers,
    required this.recommendedLabTests,
    required this.physicianDiscussionPoints,
    required this.clinicalRationale,
  });

  static List<ConditionAssessment> getInitialAssessments() {
    return [
      const ConditionAssessment(
        id: 'pcos_pcod',
        conditionName: 'PCOS / PCOD',
        category: 'Endocrine & Ovulatory',
        subtitle: 'Polycystic Ovary Syndrome / Rotterdam Criteria Pattern Evaluation',
        riskLevel: AssessmentRiskLevel.moderateRisk,
        scorePercent: 62.0,
        identifiedMarkers: [
          'Cycle variation exceeds 3 days (historical lengths: 28–31 days)',
          'Occasional jawline cystic breakouts noted during luteal phase',
          'Post-carbohydrate afternoon fatigue logged in lifestyle records',
        ],
        negativeMarkers: [
          'No severe hirsutism (excessive coarse facial hair) reported',
          'Recent metabolic glucose (92 mg/dL) remains in optimal range',
        ],
        recommendedLabTests: [
          'Pelvic Ultrasound (Transvaginal / Transabdominal antral follicle count)',
          'Day 2–3 Serum LH & FSH (LH:FSH ratio)',
          'Serum Anti-Müllerian Hormone (AMH)',
          'Total & Free Serum Testosterone, DHEAS',
          'Fasting Insulin & HOMA-IR ratio',
        ],
        physicianDiscussionPoints: [
          'Review ultrasound imaging for polycystic ovarian morphology (>12 follicles).',
          'Evaluate if dietary inositol supplementation or insulin-sensitizing support is warranted.',
          'Consider tracking morning basal body temperature to verify regular ovulatory thermal shift.',
        ],
        clinicalRationale:
          'Based on the Rotterdam Consensus criteria, PCOS evaluation requires 2 out of 3 features: oligo/anovulation, clinical or biochemical hyperandrogenism, and polycystic ovaries on ultrasound. Your logging exhibits borderline cycle fluctuations and mild androgenic skin signs.',
      ),
      const ConditionAssessment(
        id: 'endometriosis',
        conditionName: 'Endometriosis Assessment',
        category: 'Gynecological Pain & Structural',
        subtitle: 'Deep Pelvic Pain & Dysmenorrhea Severity Screening',
        riskLevel: AssessmentRiskLevel.moderateRisk,
        scorePercent: 54.0,
        identifiedMarkers: [
          'Menstrual cramps rated 4/5 requiring NSAIDs on Day 1',
          'Lower back radiating discomfort reported during menses',
          'Occasional inter-menstrual pelvic soreness',
        ],
        negativeMarkers: [
          'No chronic severe dyspareunia (pain with intercourse) logged',
          'No gastrointestinal / bowel painful evacuations during menses',
        ],
        recommendedLabTests: [
          'Specialized High-Resolution Pelvic Ultrasound (Endometriosis protocol)',
          'Pelvic MRI with IV contrast if deep infiltrating endometriosis is suspected',
          'Serum CA-125 (supplementary inflammatory biomarker)',
        ],
        physicianDiscussionPoints: [
          'Differentiate primary dysmenorrhea from secondary endometriosis.',
          'Discuss therapeutic options such as continuous progestin or cyclic support.',
          'Assess whether referral to an endometriosis imaging specialist is appropriate.',
        ],
        clinicalRationale:
          'Endometriosis frequently presents with progressive severe dysmenorrhea and non-menstrual pelvic discomfort. While Day 1 pain is common, your rating of 4/5 warrants clinical discussion to exclude endometrial tissue implants.',
      ),
      const ConditionAssessment(
        id: 'infertility_ovulation',
        conditionName: 'Ovulatory Reserve & Fertility Readiness',
        category: 'Reproductive Potential',
        subtitle: 'Ovulation Timing, Cervical Mucus & Luteal Phase Adequacy',
        riskLevel: AssessmentRiskLevel.lowRisk,
        scorePercent: 22.0,
        identifiedMarkers: [
          'Fertile egg-white cervical mucus consistently observed around Day 14',
          'Luteal phase duration is approximately 14 days (healthy window > 11 days)',
        ],
        negativeMarkers: [
          'No prolonged anovulatory stretches logged in last 6 months',
          'No unexplained mid-cycle anovulatory bleeding',
        ],
        recommendedLabTests: [
          'Day 21 (Mid-luteal) Serum Progesterone (optimal > 10 ng/mL confirms ovulation)',
          'Serum Anti-Müllerian Hormone (AMH) & Ovarian Reserve testing',
          'Semen analysis for partner (if attempting conception for > 12 months)',
        ],
        physicianDiscussionPoints: [
          'Confirmation of regular biphasic ovulatory cycles.',
          'Preconception counseling: Methylated folate (400–800 mcg) & Vitamin D3.',
        ],
        clinicalRationale:
          'Cycle length and fertile cervical secretions indicate preserved spontaneous ovulation and adequate luteal phase duration.',
      ),
      const ConditionAssessment(
        id: 'hormonal_thyroid',
        conditionName: 'Hormonal Imbalance & Thyroid Profile',
        category: 'Endocrine & Metabolic',
        subtitle: 'Estrogen/Progesterone Balance & Thyroid Screening',
        riskLevel: AssessmentRiskLevel.lowRisk,
        scorePercent: 28.0,
        identifiedMarkers: [
          'Mild premenstrual mood sensitivity and breast tenderness 3 days prior to menses',
        ],
        negativeMarkers: [
          'No severe cold intolerance, sudden unexplained weight gain, or hair shedding',
          'Resting heart rate remains stable (61 bpm average)',
        ],
        recommendedLabTests: [
          'Complete Thyroid Panel: TSH, Free T3, Free T4, Anti-TPO antibodies',
          'Serum Prolactin (fasting morning sample)',
          'Serum Estradiol and Progesterone balance',
        ],
        physicianDiscussionPoints: [
          'Baseline TSH screening to rule out subclinical hypothyroidism.',
          'Nutritional support for healthy estrogen detoxification (cruciferous vegetables, magnesium).',
        ],
        clinicalRationale:
          'Normal resting heart rate and predictable luteal onset suggest euthyroid function and physiologic hormonal fluctuations.',
      ),
      const ConditionAssessment(
        id: 'pregnancy_complications',
        conditionName: 'Pregnancy & Early Obstetric Screen',
        category: 'Obstetric Health',
        subtitle: 'Implantation, Ectopic Risk & Red Flag Triage',
        riskLevel: AssessmentRiskLevel.lowRisk,
        scorePercent: 12.0,
        identifiedMarkers: [
          'Currently in non-pregnant tracking mode (Day 14 of active cycle)',
        ],
        negativeMarkers: [
          'No abnormal continuous amenorrhea (missed period)',
          'No severe unilateral sharp pelvic cramping or unexplained vaginal hemorrhage',
        ],
        recommendedLabTests: [
          'Quantitative Serum Beta-hCG (if menses is delayed > 5 days)',
          'Early Transvaginal Obstetric Ultrasound (at 6–7 weeks gestation)',
        ],
        physicianDiscussionPoints: [
          'Immediate medical attention required if unilateral pelvic pain or acute bleeding develops.',
        ],
        clinicalRationale:
          'No indicators of acute gestational emergencies or missed menses detected at current cycle checkpoint.',
      ),
    ];
  }
}
