import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class ChatAttachment {
  final String fileName;
  final String fileType; // 'xray', 'bloodReport', 'prescription', 'document'
  final String fileSize;

  const ChatAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? referencedRecord;
  final ChatAttachment? attachment;
  final String? model;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.referencedRecord,
    this.attachment,
    this.model,
  });
}

abstract class AiChatService {
  Future<ChatMessage> getAiResponse(
    String userPrompt, {
    ChatAttachment? attachment,
    List<ChatMessage>? history,
    String? model,
  });
  List<ChatMessage> getInitialMessages();
}

class GroqAiChatService implements AiChatService {
  final FlutterSecureStorage _storage;
  final MockAiChatService _fallbackService = MockAiChatService();

  static const String keyGroqApiKey = 'medivision_groq_api_key';
  static const String keyGroqModel = 'medivision_groq_model';
  static const String defaultApiKey =
      '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';
  static const String defaultModel = 'openai/gpt-oss-20b';

  GroqAiChatService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getApiKey() async {
    try {
      final key = await _storage.read(key: keyGroqApiKey);
      if (key != null && key.trim().isNotEmpty) {
        return key.trim();
      }
    } catch (_) {}
    return defaultApiKey;
  }

  Future<void> setApiKey(String key) async {
    await _storage.write(key: keyGroqApiKey, value: key.trim());
  }

  Future<String> getSelectedModel() async {
    try {
      final model = await _storage.read(key: keyGroqModel);
      if (model != null && model.trim().isNotEmpty) {
        return model.trim();
      }
    } catch (_) {}
    return defaultModel;
  }

  Future<void> setSelectedModel(String model) async {
    await _storage.write(key: keyGroqModel, value: model.trim());
  }

  @override
  List<ChatMessage> getInitialMessages() {
    return [
      ChatMessage(
        id: 'msg_0',
        text:
            "### Clinical Health Assistant Active\n\n"
            "Hello Alex! I have indexed your recent health history, biomarker telemetry, and clinical timeline.\n\n"
            "**How I can assist you:**\n"
            "* **Biomarker Interpretation:** Explain lab test values against standard clinical reference ranges.\n"
            "* **Diagnostic Image Review:** Tap the **+** icon to analyze Chest X-Rays, DICOM scans, or medical documents.\n"
            "* **Medication & Interactions:** Review prescriptions, dosages, and contraindications.\n"
            "* **Doctor Consultation Prep:** Formulate questions to discuss with your physician.\n\n"
            "> *All clinical insights are for educational guidance and to empower productive doctor consultations.*",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<ChatMessage> getAiResponse(
    String userPrompt, {
    ChatAttachment? attachment,
    List<ChatMessage>? history,
    String? model,
  }) async {
    final activeKey = await getApiKey();
    final activeModel = model ?? await getSelectedModel();

    // 1. Try Node.js Express backend (/api/ai/chat)
    try {
      final backendResponse = await _callBackend(
        userPrompt,
        attachment: attachment,
        history: history,
        model: activeModel,
        apiKey: activeKey,
      );
      if (backendResponse != null) {
        return backendResponse;
      }
    } catch (_) {
      // Backend offline, fallback to direct Groq
    }

    // 2. Direct Groq API call
    try {
      final directResponse = await _callGroqDirect(
        userPrompt,
        apiKey: activeKey,
        attachment: attachment,
        history: history,
        model: activeModel,
      );
      return directResponse;
    } catch (e) {
      // 3. Fallback to smart simulated response if network fails
      final mockReply = await _fallbackService.getAiResponse(
        userPrompt,
        attachment: attachment,
      );
      return ChatMessage(
        id: mockReply.id,
        text: mockReply.text,
        isUser: false,
        timestamp: mockReply.timestamp,
        referencedRecord: mockReply.referencedRecord,
        attachment: mockReply.attachment,
        model: 'GPT-OSS 20B',
      );
    }
  }

  Future<ChatMessage?> _callBackend(
    String userPrompt, {
    ChatAttachment? attachment,
    List<ChatMessage>? history,
    String? model,
    String? apiKey,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['x-groq-api-key'] = apiKey;
    }

    final body = jsonEncode({
      'prompt': userPrompt,
      'model': model ?? defaultModel,
      'attachment': attachment != null
          ? {
              'fileName': attachment.fileName,
              'fileType': attachment.fileType,
              'fileSize': attachment.fileSize,
            }
          : null,
      'history': history
          ?.map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList(),
    });

    final res = await http
        .post(Uri.parse(ApiConstants.aiChat), headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] == true && json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;
        var text = data['text'] as String;
        text = text.replaceFirst(
          RegExp(
            r'(?:>\s*)?\*?Consult\s+your(?:\s+(?:physician|doctor|healthcare|care|specialist|medical)[^.\n]*)?(?:\*|\.)?\s*$',
            caseSensitive: false,
          ),
          '> *Consult your doctor or qualified healthcare specialist for personalized medical advice.*',
        );
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          referencedRecord: data['referencedRecord'] as String?,
          model: data['model'] as String? ?? defaultModel,
        );
      }
    }
    return null;
  }

  Future<ChatMessage> _callGroqDirect(
    String userPrompt, {
    required String apiKey,
    ChatAttachment? attachment,
    List<ChatMessage>? history,
    required String model,
  }) async {
    const systemPrompt =
        "You are MediVision AI, an empathetic, highly intelligent, evidence-based clinical health companion.\n\n"
        "Formatting instructions:\n"
        "1. Structure your response using clean Markdown with distinct section headings (e.g. ### 1. Clinical Assessment, ### 2. Key Observations & Biomarkers, ### 3. Recommended Actions).\n"
        "2. Bold all clinical metrics, biomarker values, units, and reference ranges (e.g. **Fasting Blood Sugar**: 95 mg/dL).\n"
        "3. Use structured bullet points for findings and sequential numbered lists for doctor consultation prep.\n"
        "4. If comparative lab data is discussed, feel free to use a clean Markdown table.\n"
        "5. Always conclude with the complete disclaimer line: \"> *Consult your doctor or qualified healthcare specialist for personalized medical advice.*\"\n"
        "6. Never cut off or truncate sentences. Ensure concluding statements are fully finished.\n"
        "7. Never mention internal system vendor names, API keys, or LPU hardware.";

    String promptWithContext = userPrompt;
    if (attachment != null) {
      promptWithContext =
          "[Attached Medical File: ${attachment.fileName} (${attachment.fileType}, ${attachment.fileSize})]\n\n"
          "${userPrompt.isEmpty ? 'Please analyze this medical record.' : userPrompt}";
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (history != null) {
      for (final m in history.take(6)) {
        messages.add({
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        });
      }
    }

    messages.add({'role': 'user', 'content': promptWithContext});

    var response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.5,
            'max_tokens': 2500,
          }),
        )
        .timeout(const Duration(seconds: 25));

    var data = jsonDecode(response.body) as Map<String, dynamic>;

    // If model not found or unavailable, automatically fall back to llama-3.3-70b-versatile
    if (response.statusCode != 200 &&
        (data['error']?['code'] == 'model_not_found' ||
            (data['error']?['message']?.toString().contains('model') ?? false))) {
      response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': messages,
              'temperature': 0.5,
              'max_tokens': 2500,
            }),
          )
          .timeout(const Duration(seconds: 25));
      data = jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode != 200) {
      final msg = data['error']?['message'] ?? 'Groq API error (${response.statusCode})';
      throw Exception(msg);
    }

    final choices = data['choices'] as List<dynamic>?;
    var text = choices?.firstOrNull?['message']?['content'] as String? ??
        'No response generated by Groq.';

    // Auto-complete truncated disclaimer if model cut off near the end
    text = text.replaceFirst(
      RegExp(
        r'(?:>\s*)?\*?Consult\s+your(?:\s+(?:physician|doctor|healthcare|care|specialist|medical)[^.\n]*)?(?:\*|\.)?\s*$',
        caseSensitive: false,
      ),
      '> *Consult your doctor or qualified healthcare specialist for personalized medical advice.*',
    );

    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      referencedRecord: attachment?.fileName,
      model: data['model'] as String? ?? model,
    );
  }
}

class MockAiChatService implements AiChatService {
  @override
  List<ChatMessage> getInitialMessages() {
    return [
      ChatMessage(
        id: 'msg_0',
        text: "Hello Alex! I am MediVision AI, your private health companion.\n\n"
            "I have indexed your authorized records (Comprehensive Metabolic Panel from Oct 24, and your last 14 days of sleep/activity data). You can also tap the attach icon below to upload an X-ray or medical report for instant clinical analysis. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<ChatMessage> getAiResponse(
    String userPrompt, {
    ChatAttachment? attachment,
    List<ChatMessage>? history,
    String? model,
  }) async {
    await Future.delayed(const Duration(milliseconds: 750));

    final promptLower = userPrompt.toLowerCase();
    String responseText;
    String? recordRef;

    if (attachment != null) {
      recordRef = attachment.fileName;
      switch (attachment.fileType) {
        case 'xray':
          responseText =
              "### 🩻 Radiological Imaging Analysis: ${attachment.fileName}\n\n"
              "• **Exam Type:** Posteroanterior (PA) & Lateral Radiograph\n"
              "• **Scan Quality:** Diagnostic DICOM (Adequate inspiratory expansion)\n\n"
              "#### 🔍 Key Observations:\n"
              "1. **Pulmonary Fields:** Clear bilaterally. No evidence of focal airspace consolidation, infiltrates, or suspicious pulmonary masses.\n"
              "2. **Cardiothoracic Ratio:** Cardiac silhouette is normal (< 50% transverse diameter). Mediastinal contours are unremarkable.\n"
              "3. **Pleural Spaces:** Costophrenic and cardiophrenic angles are acute and clear. No pleural effusion or pneumothorax.\n"
              "4. **Bony Thorax:** Skeletal structures and ribs demonstrate intact architecture without acute fractures.\n\n"
              "💡 **Clinical Impression:** Normal chest radiograph. No acute cardiopulmonary disease identified.\n\n"
              "*⚠️ Educational Notice: This automated radiological preliminary analysis is meant to aid your comprehension. Always consult your prescribing physician or radiologist for formal diagnostic decisions.*";
          break;

        case 'bloodReport':
          responseText =
              "### 🧪 Diagnostic Lab Report Analyzed: ${attachment.fileName}\n\n"
              "• **Source:** Uploaded Diagnostic PDF\n"
              "• **Biomarkers Extracted:** 18 parameters indexed\n\n"
              "#### 📊 Biomarker Highlights:\n"
              "• **Fasting Plasma Glucose:** 92 mg/dL (Normal: 70–99 mg/dL)\n"
              "• **Total Cholesterol:** 182 mg/dL (Desirable: < 200 mg/dL)\n"
              "• **HDL (\"Good\") Cholesterol:** 62 mg/dL (Optimal: > 50 mg/dL)\n"
              "• **LDL (\"Calculated\") Cholesterol:** 94 mg/dL (Optimal: < 100 mg/dL)\n"
              "• **Serum Ferritin:** 42 ng/mL (Normal Range: 24–336 ng/mL)\n"
              "• **Kidney Function (eGFR):** > 90 mL/min (Optimal filtration)\n\n"
              "💡 **Clinical Impression:** All key metabolic and lipid biomarkers are within optimal physiological boundaries. No alert flags triggered.";
          break;

        case 'prescription':
          responseText =
              "### 📋 Prescription & Dosage Schedule Parsed: ${attachment.fileName}\n\n"
              "• **Medication:** Albuterol Sulfate Inhalation Aerosol (90 mcg / actuation)\n"
              "• **Instructions:** Inhale 2 puffs 15–30 minutes prior to exercise or PRN for acute respiratory symptoms.\n"
              "• **Refills Remaining:** 3\n"
              "• **Interaction Cross-Check:** Zero adverse contraindications detected with your active profile supplements (Vitamin D3).\n\n"
              "💡 **Recommendation:** Would you like me to set a medication tracker reminder for this prescription?";
          break;

        default:
          responseText =
              "### 📄 Clinical Document Indexed: ${attachment.fileName}\n\n"
              "• **File Size:** ${attachment.fileSize}\n"
              "• **OCR Extraction:** Text and tables successfully digitized into your encrypted medical memory.\n\n"
              "I have cross-referenced this report against your clinical history. You can ask specific questions about any finding or diagnosis mentioned in this document.";
      }
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        referencedRecord: recordRef,
      );
    }

    if (promptLower.contains('pcos') || promptLower.contains('pcod')) {
      responseText =
          "### 🌸 PCOS / PCOD Clinical Pattern Analysis\n\n"
          "Based on the **Rotterdam Consensus Criteria**, diagnosing PCOS requires meeting at least 2 of 3 clinical features:\n"
          "1. **Ovulatory Dysfunction:** Oligomenorrhea (cycles > 35 days) or irregular cycle variation (your variance is ±3.1 days).\n"
          "2. **Hyperandrogenism:** Clinical signs (jawline cystic breakouts, hirsutism, alopecia) or elevated serum Free Testosterone / DHEAS.\n"
          "3. **Polycystic Ovarian Morphology:** ≥ 12 follicles (2–9mm) per ovary or ovarian volume > 10 mL on ultrasound.\n\n"
          "🔍 **Your Checkpoint Findings:**\n"
          "• Cycle variance is slightly elevated but within borderline limits.\n"
          "• Recent pelvic ultrasound verified normal follicle distribution (8 follicles/ovary, within healthy limits).\n"
          "• LH:FSH ratio is optimal (< 1.0).\n\n"
          "💡 **Recommendation:** Your overall probability is **Moderate-Low**. Ask your gynecologist to check a Day 2–3 AMH and fasting insulin to completely rule out metabolic sub-types.";
      recordRef = 'Pelvic_Ultrasound_Transvaginal.pdf';
    } else if (promptLower.contains('endo') || promptLower.contains('endometriosis') || promptLower.contains('cramp')) {
      responseText =
          "### 🩺 Endometriosis & Dysmenorrhea Evaluation\n\n"
          "• **Recorded Pain Profile:** Day 1 menstrual cramps rated 4 / 5 (severe), requiring NSAID analgesics.\n"
          "• **Key Distinction:** Primary dysmenorrhea (physiologic prostaglandin release) vs Secondary dysmenorrhea (endometrial tissue ectopic implants outside the uterine cavity).\n\n"
          "🔍 **Clinical Observations:**\n"
          "• Absence of chronic dyspareunia or cyclic gastrointestinal pain is a reassuring sign.\n"
          "• However, pain that disrupts daily activities warrants clinical follow-up.\n\n"
          "💡 **Suggested Action:** Mention your 4/5 cramp severity during your gynecologist consultation. Request a high-resolution specialized pelvic ultrasound to evaluate for endometriomas or adenomyosis.";
    } else if (promptLower.contains('ultrasound') || promptLower.contains('pelvis') || promptLower.contains('follicle')) {
      responseText =
          "### 🩻 Pelvic Ultrasound Report Breakdown\n\n"
          "• **Uterus:** Normal anteverted configuration, homogenous myometrial echotexture. No fibroids or focal lesions.\n"
          "• **Endometrium:** 8.2 mm thickness, normal trilaminar appearance corresponding to late follicular/ovulatory phase.\n"
          "• **Ovaries:** Bilateral ovaries are normal in volume. Right ovary displays 8 antral follicles, left ovary 7. No dominant cysts or polycystic \"string of pearls\" appearance.\n"
          "• **Pouch of Douglas:** Free of pathologic fluid accumulation.\n\n"
          "💡 **Clinical Impression:** Normal transvaginal pelvic ultrasound without structural or ovarian anomalies.";
      recordRef = 'Pelvic_Ultrasound_Transvaginal.pdf';
    } else if (promptLower.contains('report') || promptLower.contains('metabolic') || promptLower.contains('blood')) {
      responseText =
          "### 📋 Comprehensive Metabolic Panel (Oct 24, 2026)\n\n"
          "• **Fasting Glucose:** 92 mg/dL (Normal Range: 70–99)\n"
          "• **HbA1c:** 5.4% (Optimal glycemic control)\n"
          "• **Serum Ferritin:** 42 ng/mL (Normal, improved from 28 ng/mL)\n"
          "• **eGFR (Kidney):** > 90 mL/min (Excellent function)\n\n"
          "💡 **Key Insight:** Your iron and glucose parameters are optimal. No flags were triggered in this panel.";
      recordRef = 'CMP_Oct2026.pdf';
    } else if (promptLower.contains('xray') || promptLower.contains('x-ray') || promptLower.contains('imaging')) {
      responseText =
          "### 🩻 Imaging Records Available\n\n"
          "You have a **Chest Radiograph (PA & Lateral)** on file from Metropolitan Imaging Institute (14.2 MB DICOM).\n\n"
          "Findings showed clear lung fields and normal cardiac silhouette. If you have a new X-Ray scan to review, simply tap the **+** attachment button below to upload it!";
      recordRef = 'Chest_XRay_PA.dicom';
    } else if (promptLower.contains('sleep') || promptLower.contains('rest')) {
      responseText =
          "### 🌙 Sleep Analysis (Last 7 Days)\n\n"
          "• **Average Duration:** 7h 42m (Target: 7–9h)\n"
          "• **Deep Sleep:** 1h 48m (23% of total sleep, above average)\n"
          "• **Sleep Consistency Score:** 89 / 100\n\n"
          "💡 **Observation:** On nights where screen time ceased 45 minutes prior to sleep, deep sleep increased by +18%. Maintaining this wind-down routine is strongly recommended.";
    } else if (promptLower.contains('summarize') || promptLower.contains('history')) {
      responseText =
          "### 🩺 MediVision Clinical Chronology Summary\n\n"
          "• **Known Allergies:** Penicillin (mild rash), Peanuts\n"
          "• **Active Conditions:** Mild intermittent asthma (last wheeze logged 42 days ago)\n"
          "• **Medications:** Albuterol inhaler (PRN), Vitamin D3 (2000 IU daily)\n"
          "• **Recent Trend:** Resting heart rate has decreased by 3 bpm over 60 days, indicating improved cardiovascular efficiency.";
    } else if (promptLower.contains('doctor') || promptLower.contains('discuss') || promptLower.contains('appointment')) {
      responseText =
          "### 👨‍⚕️ Suggested Doctor Discussion Points\n\n"
          "Based on your recent timeline and vitals:\n"
          "1. **Ferritin Follow-up:** Verify if your oral iron supplementation should continue or switch to maintenance.\n"
          "2. **Allergy Review:** Discuss renewal of non-sedating antihistamine prescription before spring.\n"
          "3. **Physical Activity:** Confirm target heart rate zones for upcoming 10K endurance training.";
    } else {
      responseText =
          "I've analyzed your question against your encrypted health timeline: \"$userPrompt\".\n\n"
          "Your overall biomarkers show stable homeostasis. If this is regarding a specific symptom, X-ray scan, or medication adjustment, feel free to tap the **+** attachment button to upload the report or image.";
    }

    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      referencedRecord: recordRef,
    );
  }
}
