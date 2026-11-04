import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class WeeklyRhythmDiagramCard extends StatefulWidget {
  const WeeklyRhythmDiagramCard({super.key});

  @override
  State<WeeklyRhythmDiagramCard> createState() => _WeeklyRhythmDiagramCardState();
}

class _WeeklyRhythmDiagramCardState extends State<WeeklyRhythmDiagramCard> {
  int _selectedDayIndex = 6; // Sunday / Today

  final List<_DayRhythmData> _days = const [
    _DayRhythmData(
      dayLabel: 'Mon',
      dateNum: '28',
      score: 82,
      sleepTime: '7h 10m',
      steps: '7,400',
      insight: 'A steady start to the week. You felt normal energy and went to bed on time.',
    ),
    _DayRhythmData(
      dayLabel: 'Tue',
      dateNum: '29',
      score: 85,
      sleepTime: '7h 25m',
      steps: '8,100',
      insight: 'Good physical momentum. Your afternoon walk helped prevent evening fatigue.',
    ),
    _DayRhythmData(
      dayLabel: 'Wed',
      dateNum: '30',
      score: 94,
      sleepTime: '8h 12m',
      steps: '9,250',
      insight: 'Highest recovery day of the week! Extra sleep gave you great mental stamina all afternoon.',
    ),
    _DayRhythmData(
      dayLabel: 'Thu',
      dateNum: '31',
      score: 89,
      sleepTime: '7h 35m',
      steps: '8,600',
      insight: 'Deep sleep remained solid. Screen time before bed was 30 minutes lower than usual.',
    ),
    _DayRhythmData(
      dayLabel: 'Fri',
      dateNum: '1',
      score: 86,
      sleepTime: '7h 05m',
      steps: '7,800',
      insight: 'Slightly shorter sleep, but heart rhythm stayed calm and steady.',
    ),
    _DayRhythmData(
      dayLabel: 'Sat',
      dateNum: '2',
      score: 91,
      sleepTime: '8h 00m',
      steps: '10,200',
      insight: 'Active weekend outdoor walking. Body felt refreshed and joints stayed loose.',
    ),
    _DayRhythmData(
      dayLabel: 'Sun',
      dateNum: '3',
      score: 94,
      sleepTime: '7h 42m',
      steps: '8,420',
      insight: 'Today! Muscles are fully recovered from yesterday, resting pulse is low (61 bpm), and you are ready for the week ahead.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDay = _days[_selectedDayIndex];

    return GlassCard(
      padding: const EdgeInsets.all(20),
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
                    '7-Day Energy & Rest Flow',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap any day to see how you recovered',
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
                  'Avg: 89% Harmony',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Visual Diagram Columns (7 days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_days.length, (index) {
              final day = _days[index];
              final isSelected = index == _selectedDayIndex;
              final double heightRatio = day.score / 100.0;

              return InkWell(
                onTap: () => setState(() => _selectedDayIndex = index),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${day.score}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.secondary : AppColors.textTertiary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Bar Diagram Column
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 32,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 90 * heightRatio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [AppColors.secondary, AppColors.secondaryDark]
                                  : [
                                      AppColors.secondary.withOpacity(0.4),
                                      AppColors.secondary.withOpacity(0.65)
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.dayLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      day.dateNum,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: isSelected ? AppColors.secondary : AppColors.textTertiary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // Non-technical Daily Takeaway
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: AppColors.secondaryDark, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDay.dayLabel}, Nov ${selectedDay.dateNum} • ${selectedDay.sleepTime} Sleep',
                            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${selectedDay.steps} steps',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDay.insight,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class _DayRhythmData {
  final String dayLabel;
  final String dateNum;
  final int score;
  final String sleepTime;
  final String steps;
  final String insight;

  const _DayRhythmData({
    required this.dayLabel,
    required this.dateNum,
    required this.score,
    required this.sleepTime,
    required this.steps,
    required this.insight,
  });
}
