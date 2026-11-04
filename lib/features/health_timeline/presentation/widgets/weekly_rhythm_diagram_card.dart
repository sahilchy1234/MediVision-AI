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
      insight: 'Steady start to the week. Resting pulse averaged 62 bpm.',
    ),
    _DayRhythmData(
      dayLabel: 'Tue',
      dateNum: '29',
      score: 85,
      sleepTime: '7h 25m',
      steps: '8,100',
      insight: 'Aerobic activity goal achieved. Sleep latency under 15 minutes.',
    ),
    _DayRhythmData(
      dayLabel: 'Wed',
      dateNum: '30',
      score: 94,
      sleepTime: '8h 12m',
      steps: '9,250',
      insight: 'Optimal recovery day with 2h 05m deep sleep distribution.',
    ),
    _DayRhythmData(
      dayLabel: 'Thu',
      dateNum: '31',
      score: 89,
      sleepTime: '7h 35m',
      steps: '8,600',
      insight: 'Consistent circadian rhythm maintained. Evening screen time reduced.',
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
      insight: 'High physiological harmony. Resting vitals stable at 61 bpm.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDay = _days[_selectedDayIndex];

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
                      '7-Day Rhythm',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daily physiological stability trends',
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Avg: 89',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_days.length, (index) {
              final day = _days[index];
              final isSelected = index == _selectedDayIndex;
              final heightRatio = (day.score / 100).clamp(0.4, 1.0);

              return InkWell(
                onTap: () => setState(() => _selectedDayIndex = index),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Text(
                        '${day.score}',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.secondary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 24,
                        height: 70 * heightRatio,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? AppColors.secondary : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day.dayLabel,
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Detail Box for Selected Day
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDay.dayLabel}, Nov ${selectedDay.dateNum}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${selectedDay.sleepTime} Sleep • ${selectedDay.steps} Steps',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDay.insight,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
