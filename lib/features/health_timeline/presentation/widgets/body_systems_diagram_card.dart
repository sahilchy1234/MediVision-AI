import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

enum HealthSystemType { brainSleep, heartPulse, staminaMovement, bloodDefenses }

class BodySystemsDiagramCard extends StatefulWidget {
  const BodySystemsDiagramCard({super.key});

  @override
  State<BodySystemsDiagramCard> createState() => _BodySystemsDiagramCardState();
}

class _BodySystemsDiagramCardState extends State<BodySystemsDiagramCard> {
  HealthSystemType _selectedSystem = HealthSystemType.brainSleep;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physiological Systems',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Integrated balance across clinical markers',
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '94% Optimal',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4-Node Interactive Diagram
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.psychology_outlined,
                  title: 'Sleep & Cognition',
                  score: '92%',
                  status: 'Rested',
                  color: AppColors.accentIndigo,
                  isSelected: _selectedSystem == HealthSystemType.brainSleep,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.brainSleep),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Cardiovascular',
                  score: '96%',
                  status: 'Steady',
                  color: AppColors.accentRose,
                  isSelected: _selectedSystem == HealthSystemType.heartPulse,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.heartPulse),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.directions_walk_rounded,
                  title: 'Physical Activity',
                  score: '88%',
                  status: 'Goal Met',
                  color: AppColors.secondary,
                  isSelected: _selectedSystem == HealthSystemType.staminaMovement,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.staminaMovement),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.shield_outlined,
                  title: 'Hematology & Labs',
                  score: '95%',
                  status: 'Normal',
                  color: AppColors.accentEmerald,
                  isSelected: _selectedSystem == HealthSystemType.bloodDefenses,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.bloodDefenses),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Non-technical Plain-English Breakdown for selected system
          _buildSystemPlainExplanation(_selectedSystem),
        ],
      ),
    );
  }

  Widget _buildSystemPlainExplanation(HealthSystemType type) {
    String headline;
    String plainText;
    List<String> keyPills;

    switch (type) {
      case HealthSystemType.brainSleep:
        headline = 'Sleep Efficiency: Restored';
        plainText =
            '7 hours 42 minutes total sleep recorded with 1h 48m in restorative deep sleep. Autonomic recovery metrics indicate low physiological strain.';
        keyPills = ['7h 42m Total', '1h 48m Deep', '89% Efficiency'];
        break;
      case HealthSystemType.heartPulse:
        headline = 'Cardiovascular: Normal Baseline';
        plainText =
            'Resting heart rate averaged 61 bpm with normal diurnal variability. Recovery rate post-exercise was within optimal parameters.';
        keyPills = ['61 bpm Resting', '128 bpm Peak', 'Optimal HRV'];
        break;
      case HealthSystemType.staminaMovement:
        headline = 'Daily Activity: Active Target Met';
        plainText =
            '8,420 steps walked with 482 active calories burned. Sustained 42 minutes of moderate intensity cardiovascular stimulus.';
        keyPills = ['8,420 Steps', '482 kcal', '42 Active Min'];
        break;
      case HealthSystemType.bloodDefenses:
        headline = 'Laboratory Chemistry: In Range';
        plainText =
            'All primary metabolic and hematological values from recent lab uploads are within reference intervals with zero acute biomarker flags.';
        keyPills = ['HbA1c 5.4%', 'Fasting 92 mg/dL', 'eGFR > 90'];
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plainText,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: keyPills.map((pill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  pill,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DiagramNodeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String score;
  final String status;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiagramNodeItem({
    required this.icon,
    required this.title,
    required this.score,
    required this.status,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    score,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10.5,
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
