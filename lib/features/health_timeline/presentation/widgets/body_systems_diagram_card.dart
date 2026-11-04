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
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          Colors.white,
          _getColorForSystem(_selectedSystem).withOpacity(0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Body Harmony Diagram',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap any system to see how your body is doing in plain words',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '94% In Balance',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4-Node Interactive Diagram
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.psychology_rounded,
                  title: 'Sleep & Brain',
                  score: '92%',
                  status: 'Well Rested',
                  color: AppColors.accentIndigo,
                  isSelected: _selectedSystem == HealthSystemType.brainSleep,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.brainSleep),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.favorite_rounded,
                  title: 'Heart & Pulse',
                  score: '96%',
                  status: 'Calm & Steady',
                  color: AppColors.accentRose,
                  isSelected: _selectedSystem == HealthSystemType.heartPulse,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.heartPulse),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.directions_walk_rounded,
                  title: 'Daily Stamina',
                  score: '88%',
                  status: 'Active Goal Met',
                  color: AppColors.secondary,
                  isSelected: _selectedSystem == HealthSystemType.staminaMovement,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.staminaMovement),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.shield_rounded,
                  title: 'Blood & Labs',
                  score: '95%',
                  status: 'All Safe & Clear',
                  color: AppColors.accentEmerald,
                  isSelected: _selectedSystem == HealthSystemType.bloodDefenses,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.bloodDefenses),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Non-technical Plain-English Breakdown for selected system
          _buildSystemPlainExplanation(_selectedSystem),
        ],
      ),
    );
  }

  Color _getColorForSystem(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return AppColors.accentIndigo;
      case HealthSystemType.heartPulse:
        return AppColors.accentRose;
      case HealthSystemType.staminaMovement:
        return AppColors.secondary;
      case HealthSystemType.bloodDefenses:
        return AppColors.accentEmerald;
    }
  }

  Widget _buildSystemPlainExplanation(HealthSystemType type) {
    String headline;
    String plainText;
    List<String> keyPills;
    IconData icon;
    Color color = _getColorForSystem(type);

    switch (type) {
      case HealthSystemType.brainSleep:
        headline = 'Sleep & Mental Energy: Restored';
        plainText =
            'You slept 7 hours and 42 minutes. Most importantly, you had nearly 2 hours of deep sleep. Deep sleep is when your brain flushes out mental tiredness and repairs your body. You will feel focused and clear today.';
        keyPills = ['7h 42m Asleep', '1h 48m Deep Recovery', 'Zero Sleep Wakeups'];
        icon = Icons.bedtime_rounded;
        break;
      case HealthSystemType.heartPulse:
        headline = 'Heart & Blood Flow: Very Calm';
        plainText =
            'Your resting heart beats around 61 times per minute. That means your heart muscle is relaxed and efficient. When you walked today, your heart responded smoothly and calmed back down quickly.';
        keyPills = ['61 bpm Resting', 'Peak 128 bpm', 'Quick Recovery'];
        icon = Icons.monitor_heart_rounded;
        break;
      case HealthSystemType.staminaMovement:
        headline = 'Physical Energy: Great Movement Streak';
        plainText =
            'You logged 8,420 steps and burned 482 active calories without over-exhausting your joints. You spent 42 minutes at an active pace, which keeps your blood pressure naturally healthy.';
        keyPills = ['8,420 Steps Walked', '482 kcal Burned', '42 Active Minutes'];
        icon = Icons.directions_run_rounded;
        break;
      case HealthSystemType.bloodDefenses:
        headline = 'Internal Blood Health: 100% In the Green';
        plainText =
            'All 18 checkup markers from your blood tests are safe. Your blood sugar is balanced, your iron levels give your body plenty of oxygen, and your kidneys are filtering with high efficiency.';
        keyPills = ['Fasting Sugar: Ideal', 'Iron & Energy: Normal', 'Lungs: Completely Clear'];
        icon = Icons.health_and_safety_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plainText,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: keyPills.map((pill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  pill,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                Text(
                  score,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10.5,
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

