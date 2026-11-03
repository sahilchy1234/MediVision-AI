class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? referencedRecord;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.referencedRecord,
  });
}

abstract class AiChatService {
  Future<ChatMessage> getAiResponse(String userPrompt);
  List<ChatMessage> getInitialMessages();
}

class MockAiChatService implements AiChatService {
  @override
  List<ChatMessage> getInitialMessages() {
    return [
      ChatMessage(
        id: 'msg_0',
        text: "Hello Alex! I am MediVision AI, your private health companion.\n\n"
            "I have indexed your authorized records (Comprehensive Metabolic Panel from Oct 24, and your last 14 days of sleep/activity data). How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<ChatMessage> getAiResponse(String userPrompt) async {
    // Simulate real AI network/reasoning latency
    await Future.delayed(const Duration(milliseconds: 700));

    final promptLower = userPrompt.toLowerCase();
    String responseText;
    String? recordRef;

    if (promptLower.contains('report') || promptLower.contains('metabolic') || promptLower.contains('blood')) {
      responseText =
          "### 📋 Comprehensive Metabolic Panel (Oct 24, 2026)\n\n"
          "• **Fasting Glucose:** 92 mg/dL (Normal Range: 70–99)\n"
          "• **HbA1c:** 5.4% (Optimal glycemic control)\n"
          "• **Serum Ferritin:** 42 ng/mL (Normal, improved from 28 ng/mL)\n"
          "• **eGFR (Kidney):** > 90 mL/min (Excellent function)\n\n"
          "💡 **Key Insight:** Your iron and glucose parameters are optimal. No flags were triggered in this panel.";
      recordRef = 'CMP_Oct2026.pdf';
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
          "Your overall biomarkers show stable homeostasis. If this is regarding a specific symptom or medication adjustment, feel free to upload the relevant lab scan or ask me to prepare a clinical summary for your practitioner.";
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

