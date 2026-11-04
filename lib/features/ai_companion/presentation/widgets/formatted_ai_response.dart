import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

/// A clinical-grade formatted response viewer for MediVision AI.
/// It cleans raw LLM output, applies medical markdown typography,
/// and provides quick action controls (copy, consult physician).
class FormattedAiResponse extends StatelessWidget {
  final String rawResponse;
  final String? referencedRecord;
  final VoidCallback? onAskDoctor;

  const FormattedAiResponse({
    super.key,
    required this.rawResponse,
    this.referencedRecord,
    this.onAskDoctor,
  });

  /// Sanitize and format the raw text from AI (strip think tags, clean markdown)
  String _preprocessText(String text) {
    var cleaned = text;

    // 1. Remove reasoning / thought blocks if present (<think>...</think>)
    cleaned = cleaned.replaceAll(RegExp(r'<think>[\s\S]*?<\/think>', caseSensitive: false), '');

    // 2. Remove any accidental leading/trailing assistant role tags
    cleaned = cleaned.replaceAll(RegExp(r'^(assistant|ai):\s*', caseSensitive: false), '');

    // 3. Normalize excessive vertical whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.trim();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Clinical analysis copied to clipboard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanText = _preprocessText(rawResponse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Structured Markdown Body with medical typography
        MarkdownBody(
          data: cleanText,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            // Paragraph
            p: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryText,
              height: 1.55,
              fontSize: 14.5,
            ),
            // Headings
            h1: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
              letterSpacing: -0.3,
            ),
            h2: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.2,
            ),
            h3: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.forestGreen,
            ),
            h4: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            // Strong / Bold
            strong: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            // Emphasis / Italic
            em: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.secondaryText,
            ),
            // Blockquotes (styled as soft clinical callout cards)
            blockquote: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryText,
              height: 1.5,
              fontSize: 13,
            ),
            blockquoteDecoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: const Border(
                left: BorderSide(color: AppColors.secondary, width: 3.5),
              ),
            ),
            blockquotePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            // Lists & Bullets
            listBullet: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w800,
            ),
            listBulletPadding: const EdgeInsets.only(right: 8),
            // Inline Code (used for lab units, biomarker badges like 120/80 mmHg)
            code: AppTypography.labelSmall.copyWith(
              backgroundColor: const Color(0xFFF1F5F9),
              color: AppColors.forestGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            codeblockDecoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            // Tables (for lab panels & biomarker comparisons)
            tableHead: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            tableBody: AppTypography.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppColors.primaryText,
            ),
            tableBorder: TableBorder.all(
              color: AppColors.border,
              width: 0.8,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            tableCellsPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            tableHeadAlign: TextAlign.left,
            // Horizontal rule
            horizontalRuleDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withOpacity(0.6),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bottom Actions Bar (Copy, Share, Reference Pill)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Clinical Source Reference Tag (if record was reviewed)
            if (referencedRecord != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 12,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Source: $referencedRecord',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Spacer(),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Copy Button
                InkWell(
                  onTap: () => _copyToClipboard(context, cleanText),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.8),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10.5,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
