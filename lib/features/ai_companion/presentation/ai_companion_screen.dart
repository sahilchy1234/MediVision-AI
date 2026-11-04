import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/ai_chat_service.dart';
import '../providers/ai_companion_provider.dart';

class AiCompanionScreen extends ConsumerStatefulWidget {
  const AiCompanionScreen({super.key});

  @override
  ConsumerState<AiCompanionScreen> createState() => _AiCompanionScreenState();
}

class _AiCompanionScreenState extends ConsumerState<AiCompanionScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatAttachment? _stagedAttachment;

  final List<String> _suggestedPrompts = [
    'Explain my latest blood panel.',
    'Review my chest X-Ray findings.',
    'What should I discuss with my doctor?',
    'Correlate my sleep duration with my resting heart rate.',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final query = text ?? _inputController.text;
    if (query.trim().isEmpty && _stagedAttachment == null) return;

    final attachment = _stagedAttachment;
    setState(() {
      _stagedAttachment = null;
    });

    _inputController.clear();
    ref
        .read(aiCompanionProvider.notifier)
        .sendMessage(query, attachment: attachment);
    _scrollToBottom();
  }

  void _stageAttachment(ChatAttachment attachment, {String? defaultPrompt}) {
    setState(() {
      _stagedAttachment = attachment;
      if (defaultPrompt != null && _inputController.text.isEmpty) {
        _inputController.text = defaultPrompt;
      }
    });
  }

  void _showAttachmentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Attach Medical Record or Scan',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Encrypted and analyzed on-device without cloud training disclosure',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),

                _AttachmentOptionTile(
                  icon: Icons.document_scanner_outlined,
                  title: 'Chest X-Ray / Diagnostic Imaging',
                  subtitle:
                      'DICOM, JPEG, or PNG radiograph (Chest, Spine, Extremities)',
                  badge: 'DICOM Supported',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Chest_XRay_PA_Nov2026.dcm',
                        fileType: 'xray',
                        fileSize: '14.2 MB DICOM',
                      ),
                      defaultPrompt:
                          'Please review this Chest X-Ray radiograph for any abnormalities.',
                    );
                  },
                ),
                const SizedBox(height: 10),

                _AttachmentOptionTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Blood & Metabolic Lab Report',
                  subtitle: 'PDF panel, complete blood count, or lipid profile',
                  badge: 'PDF OCR',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Comprehensive_Metabolic_Panel.pdf',
                        fileType: 'bloodReport',
                        fileSize: '1.8 MB PDF',
                      ),
                      defaultPrompt:
                          'Explain the biomarkers and abnormal flags in this blood panel.',
                    );
                  },
                ),
                const SizedBox(height: 10),

                _AttachmentOptionTile(
                  icon: Icons.medication_outlined,
                  title: 'Prescription & Medication Order',
                  subtitle: 'Doctor Rx slip or medication bottle photo',
                  badge: 'Dosage Check',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Rx_Albuterol_Inhaler_Order.jpg',
                        fileType: 'prescription',
                        fileSize: '640 KB Image',
                      ),
                      defaultPrompt:
                          'Check dosage instructions and interactions for this medication.',
                    );
                  },
                ),
                const SizedBox(height: 10),

                _AttachmentOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Clinical Summary or Discharge Note',
                  subtitle:
                      'Hospital consultation notes, visit summaries, or records',
                  badge: 'Document',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Annual_Physical_Summary.pdf',
                        fileType: 'document',
                        fileSize: '2.1 MB PDF',
                      ),
                      defaultPrompt:
                          'Summarize the key findings from this medical report.',
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGroqConfigModal() {
    final groqConfig = ref.read(groqConfigProvider);
    final keyController = TextEditingController(text: groqConfig.apiKey ?? '');
    String selectedModel = groqConfig.selectedModel;
    bool obscure = true;

    final models = [
      {'id': 'llama-3.3-70b-versatile', 'name': 'Llama 3.3 70B (Recommended)'},
      {'id': 'openai/gpt-oss-20b', 'name': 'GPT-OSS 20B (OpenAI OSS)'},
      {'id': 'llama-3.1-8b-instant', 'name': 'Llama 3.1 8B (Instant Speed)'},
      {'id': 'mixtral-8x7b-32768', 'name': 'Mixtral 8x7B (Long Context)'},
      {'id': 'gemma2-9b-it', 'name': 'Gemma 2 9B IT'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusXL),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.secondaryDark,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Groq LPU AI Engine',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Sub-second clinical reasoning & document parsing',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Groq API Key',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: keyController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: 'gsk_...',
                          prefixIcon: const Icon(Icons.key_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setModalState(() => obscure = !obscure),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusM),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Free keys are available at console.groq.com/keys. Keys are stored with on-device hardware encryption.',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Model Selection',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedModel,
                            isExpanded: true,
                            items: models.map((m) {
                              return DropdownMenuItem<String>(
                                value: m['id'],
                                child: Text(
                                  m['name']!,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedModel = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_rounded,
                                  size: 18),
                              label: const Text(
                                'Save Configuration',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              onPressed: () {
                                final key = keyController.text.trim();
                                ref
                                    .read(groqConfigProvider.notifier)
                                    .setApiKey(key);
                                ref
                                    .read(groqConfigProvider.notifier)
                                    .setModel(selectedModel);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      key.isNotEmpty
                                          ? 'Groq configuration active ($selectedModel)'
                                          : 'Groq API Key cleared. Using demo simulator.',
                                    ),
                                    backgroundColor: AppColors.secondary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiCompanionProvider);
    final groqConfig = ref.watch(groqConfigProvider);

    ref.listen(aiCompanionProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length ||
          next.isThinking) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical Health Companion',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Encrypted Medical Memory • Active',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Groq LPU Status Chip & Config Button
          GestureDetector(
            onTap: _showGroqConfigModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: groqConfig.isConfigured
                    ? AppColors.secondaryContainer
                    : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: groqConfig.isConfigured
                      ? AppColors.secondary
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: groqConfig.isConfigured
                        ? AppColors.secondaryDark
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    groqConfig.isConfigured ? 'Groq LPU' : 'Setup Groq',
                    style: AppTypography.labelSmall.copyWith(
                      color: groqConfig.isConfigured
                          ? AppColors.secondaryDark
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.key_rounded, size: 20),
            tooltip: 'Groq API Settings',
            onPressed: _showGroqConfigModal,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Clear Conversation',
            onPressed: () {
              ref.read(aiCompanionProvider.notifier).clearChat();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Clinical Educational Disclaimer (Subtle and human-centered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.surfaceSubtle,
              child: Center(
                child: Text(
                  'AI Companion provides educational information based on your records, not certified medical diagnosis.',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            // Groq LPU Banner if not configured
            if (!groqConfig.isConfigured)
              InkWell(
                onTap: _showGroqConfigModal,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border:
                        Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: AppColors.secondaryDark, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Powered by Groq LPU. Tap here to enter your Groq API Key for live ultra-fast inference.',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16, color: AppColors.secondaryDark),
                    ],
                  ),
                ),
              ),

            // Chat Messages History
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    chatState.messages.length + (chatState.isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length &&
                      chatState.isThinking) {
                    return _ThinkingBubble();
                  }

                  final message = chatState.messages[index];
                  final isUser = message.isUser;

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.forestGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                              border: isUser
                                  ? null
                                  : Border.all(
                                      color: AppColors.border,
                                      width: 1.0,
                                    ),
                              boxShadow: isUser
                                  ? null
                                  : AppDimensions.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AI Header label for assistant messages
                                if (!isUser) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              size: 11,
                                              color: AppColors.secondaryDark,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              message.model != null
                                                  ? 'GROQ LPU • ${message.model}'
                                                  : 'AI CLINICAL ANALYSIS',
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.secondaryDark,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 9.5,
                                                    letterSpacing: 0.3,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // User attachment card
                                if (message.attachment != null) ...[
                                  _AttachmentBubbleCard(
                                    attachment: message.attachment!,
                                    isUser: isUser,
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Message Text
                                Text(
                                  message.text,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isUser
                                        ? Colors.white
                                        : AppColors.primaryText,
                                    height: 1.5,
                                  ),
                                ),

                                // Source references for medical info
                                if (message.referencedRecord != null &&
                                    !isUser) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.source_outlined,
                                          size: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Clinical Source: ${message.referencedRecord}',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                color: AppColors.secondaryText,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 3,
                              left: 4,
                              right: 4,
                            ),
                            child: Text(
                              DateFormatter.formatTime(message.timestamp),
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Suggested Clinical Questions
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _suggestedPrompts[index];
                  return ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border, width: 1.0),
                    label: Text(
                      prompt,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  );
                },
              ),
            ),

            // Staged Attachment Preview (if selected)
            if (_stagedAttachment != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.primaryGreen, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(_stagedAttachment!.fileType),
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stagedAttachment!.fileName,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_stagedAttachment!.fileSize} • Staged for analysis',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _stagedAttachment = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Refined Clinical Message Composer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  // Document Upload Button
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file_rounded,
                      size: 20,
                      color: AppColors.forestGreen,
                    ),
                    tooltip: 'Upload report or X-Ray',
                    onPressed: _showAttachmentModal,
                  ),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: _stagedAttachment != null
                            ? 'Add question for this ${_stagedAttachment!.fileType == "xray" ? "X-ray" : "report"}...'
                            : 'Ask a health question or attach records...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.mainBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Action Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getIconForType(String type) {
  switch (type) {
    case 'xray':
      return Icons.document_scanner_outlined;
    case 'bloodReport':
      return Icons.water_drop_outlined;
    case 'prescription':
      return Icons.medication_outlined;
    default:
      return Icons.description_outlined;
  }
}

class _AttachmentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _AttachmentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mainBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Icon(icon, color: AppColors.forestGreen, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mintAccent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9.5,
                            color: AppColors.forestGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBubbleCard extends StatelessWidget {
  final ChatAttachment attachment;
  final bool isUser;

  const _AttachmentBubbleCard({required this.attachment, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withValues(alpha: 0.12)
            : AppColors.mainBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(
          color: isUser ? Colors.white24 : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForType(attachment.fileType),
            size: 18,
            color: isUser ? Colors.white : AppColors.forestGreen,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.fileName,
                  style: AppTypography.labelSmall.copyWith(
                    color: isUser ? Colors.white : AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${attachment.fileSize} • Encrypted DICOM/PDF',
                  style: AppTypography.bodySmall.copyWith(
                    color: isUser ? Colors.white70 : AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Cross-referencing authorized clinical history...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
