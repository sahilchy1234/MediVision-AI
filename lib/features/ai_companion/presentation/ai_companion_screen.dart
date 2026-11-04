import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/ai_chat_service.dart';
import '../providers/ai_companion_provider.dart';
import 'widgets/formatted_ai_response.dart';

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
    'Explain my latest lab results',
    'Review active medications and dosage',
    'Questions to prepare for my next doctor visit',
    'Summarize my health metrics over the last 30 days',
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
                  'Attach Health Document',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),

                _AttachmentOptionTile(
                  icon: Icons.document_scanner_outlined,
                  title: 'Chest X-Ray / Imaging',
                  subtitle: 'DICOM radiographic study',
                  badge: 'Imaging',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'CXR_Posteroanterior_20261014.dcm',
                        fileType: 'xray',
                        fileSize: '4.8 MB DICOM',
                      ),
                      defaultPrompt: 'Review and explain the clinical findings in this chest X-ray.',
                    );
                  },
                ),
                const SizedBox(height: 8),

                _AttachmentOptionTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Complete Metabolic Panel & CBC',
                  subtitle: 'Laboratory blood chemistry report',
                  badge: 'Lab Panel',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Lab_Report_Metabolic_CBC.pdf',
                        fileType: 'bloodReport',
                        fileSize: '1.2 MB PDF',
                      ),
                      defaultPrompt: 'Explain the biomarkers and abnormal flags in this blood panel.',
                    );
                  },
                ),
                const SizedBox(height: 8),

                _AttachmentOptionTile(
                  icon: Icons.medication_outlined,
                  title: 'Prescription & Medication Order',
                  subtitle: 'Doctor Rx slip or medication instructions',
                  badge: 'Medication',
                  onTap: () {
                    Navigator.pop(context);
                    _stageAttachment(
                      const ChatAttachment(
                        fileName: 'Rx_Albuterol_Inhaler_Order.jpg',
                        fileType: 'prescription',
                        fileSize: '640 KB Image',
                      ),
                      defaultPrompt: 'Check dosage instructions and interactions for this medication.',
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiCompanionProvider);

    ref.listen(aiCompanionProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length || next.isThinking) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical Assistant',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Personal Health Consultation',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Clear Conversation',
            onPressed: () {
              ref.read(aiCompanionProvider.notifier).clearChat();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages History
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: chatState.messages.length + (chatState.isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length && chatState.isThinking) {
                    return _ThinkingBubble();
                  }

                  final message = chatState.messages[index];
                  final isUser = message.isUser;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                              border: isUser
                                  ? null
                                  : Border.all(color: AppColors.border, width: 1.0),
                              boxShadow: isUser ? null : AppDimensions.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Attachment card (if present)
                                if (message.attachment != null) ...[
                                  _AttachmentBubbleCard(
                                    attachment: message.attachment!,
                                    isUser: isUser,
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Message Text
                                if (isUser)
                                  Text(
                                    message.text,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white,
                                      height: 1.45,
                                    ),
                                  )
                                else
                                  FormattedAiResponse(
                                    rawResponse: message.text,
                                    referencedRecord: message.referencedRecord,
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                            child: Text(
                              DateFormatter.formatTime(message.timestamp),
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textTertiary,
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

            // Clean Suggested Prompts
            Container(
              height: 36,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _suggestedPrompts[index];
                  return ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border, width: 1.0),
                    label: Text(
                      prompt,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.secondary, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(_stagedAttachment!.fileType),
                      size: 16,
                      color: AppColors.secondary,
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
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _stagedAttachment!.fileSize,
                            style: AppTypography.bodySmall.copyWith(fontSize: 10),
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

            // Refined Message Input Bar
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
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Attach document or report',
                    onPressed: _showAttachmentModal,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: _stagedAttachment != null
                            ? 'Add a question about this attachment...'
                            : 'Ask a clinical question...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9.5,
                            color: AppColors.secondaryDark,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUser ? Colors.white.withValues(alpha: 0.12) : AppColors.surfaceSubtle,
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
            size: 16,
            color: isUser ? Colors.white : AppColors.secondary,
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
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.fileSize,
                  style: AppTypography.bodySmall.copyWith(
                    color: isUser ? Colors.white70 : AppColors.textTertiary,
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Reviewing clinical records...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
