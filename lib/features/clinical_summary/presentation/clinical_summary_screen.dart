import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/clinical_summary_model.dart';
import '../providers/clinical_summary_provider.dart';

class ClinicalSummaryScreen extends ConsumerStatefulWidget {
  const ClinicalSummaryScreen({super.key});

  @override
  ConsumerState<ClinicalSummaryScreen> createState() => _ClinicalSummaryScreenState();
}

class _ClinicalSummaryScreenState extends ConsumerState<ClinicalSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clinicalSummaryProvider);
    final summary = state.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Clinical Summary & Dossier',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Print / Preview PDF',
            icon: const Icon(Icons.print_rounded),
            onPressed: state.isExportingPdf
                ? null
                : () => ref.read(clinicalSummaryProvider.notifier).printOrPreview(context),
          ),
          IconButton(
            tooltip: 'Export PDF Report',
            icon: state.isExportingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
            onPressed: state.isExportingPdf ? null : () => _exportPdf(context),
          ),
          IconButton(
            tooltip: 'Refresh Summary',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(clinicalSummaryProvider.notifier).loadSummary(forceFresh: true),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print / Save'),
                  onPressed: state.isExportingPdf
                      ? null
                      : () => ref.read(clinicalSummaryProvider.notifier).printOrPreview(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: state.isExportingPdf ? 'Generating PDF...' : 'Export Clinical PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  isLoading: state.isExportingPdf,
                  onPressed: state.isExportingPdf ? null : () => _exportPdf(context),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () => ref.read(clinicalSummaryProvider.notifier).loadSummary(forceFresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Patient Identification & Demographics Banner
              _buildPatientDemographicsCard(summary),
              const SizedBox(height: 16),

              // 2. Executive Health Score & Clinical Digest
              _buildExecutiveSummaryCard(summary),
              const SizedBox(height: 18),

              // 3. Vitals & Hemodynamics Telemetry Grid
              const SectionHeader(title: 'Vitals & Ambulatory Telemetry'),
              const SizedBox(height: 10),
              _buildVitalsTelemetryGrid(summary),
              const SizedBox(height: 18),

              // 4. Physiological Systems Breakdown
              const SectionHeader(title: 'Physiological Systems Assessment'),
              const SizedBox(height: 10),
              _buildPhysiologicalSystemsSection(summary),
              const SizedBox(height: 18),

              // 5. Active Bodily Sensations (if present)
              if (summary.sensations.isNotEmpty) ...[
                const SectionHeader(title: 'Active Bodily Sensations (Body Atlas)'),
                const SizedBox(height: 10),
                _buildSensationsSection(summary),
                const SizedBox(height: 18),
              ],

              // 6. Medical Records Vault
              const SectionHeader(title: 'Verified Medical Records & Labs'),
              const SizedBox(height: 10),
              _buildMedicalRecordsSection(summary),
              const SizedBox(height: 18),

              // 7. Women's Reproductive Health (if applicable)
              if (summary.womensHealth != null) ...[
                const SectionHeader(title: 'Reproductive & Hormonal Health'),
                const SizedBox(height: 10),
                _buildWomensHealthCard(summary.womensHealth!),
                const SizedBox(height: 18),
              ],

              // 8. Health Timeline Milestones
              const SectionHeader(title: 'Recent Clinical Milestones'),
              const SizedBox(height: 10),
              _buildTimelineSection(summary),
              const SizedBox(height: 18),

              // 9. Physician Consultation Care Plan
              const SectionHeader(title: 'Physician Consultation Care Plan'),
              const SizedBox(height: 10),
              _buildCarePlanCard(summary),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref.read(clinicalSummaryProvider.notifier).exportPdf();
    if (mounted) {
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Clinical summary PDF generated and shared successfully.'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not generate PDF. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPatientDemographicsCard(ClinicalSummaryModel summary) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      summary.patientName.isNotEmpty ? summary.patientName[0].toUpperCase() : 'P',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.patientName,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${summary.age} yrs • ${summary.gender} • Blood: ${summary.bloodGroup}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const StatusBadge(
                label: 'Verified Patient',
                type: BadgeType.success,
                isPill: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoTile('Height', '${summary.heightCm.toInt()} cm'),
              _infoTile('Weight', '${summary.weightKg.toInt()} kg'),
              _infoTile('BMI', '${summary.bmi} (${summary.bmiCategory})'),
              _infoTile('Report Ref', summary.reportId.split('-').last),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (summary.allergies.isNotEmpty)
                _pillTag('Allergies: ${summary.allergies.join(", ")}', AppColors.errorBackground, AppColors.error),
              if (summary.medicalConditions.isNotEmpty)
                _pillTag('History: ${summary.medicalConditions.join(", ")}', AppColors.primaryContainer, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummaryCard(ClinicalSummaryModel summary) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.healthScore} / 100 Health Stability',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(summary.generatedAt),
                style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary.clinicalStatus,
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            summary.summaryNarrative,
            style: AppTypography.bodySmall.copyWith(height: 1.45, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protective Health Factors',
                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.secondary),
                ),
                const SizedBox(height: 4),
                ...summary.protectiveFactors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 5),
                        Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(fontSize: 11.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTelemetryGrid(ClinicalSummaryModel summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _vitalTile(width, 'Resting Pulse', summary.formattedPulse, Icons.favorite_rounded, const Color(0xFFE11D48), 'Optimal Sinus Rhythm'),
            _vitalTile(width, 'Blood Pressure', summary.formattedBP, Icons.speed_rounded, const Color(0xFF0D9488), 'MAP: ${summary.meanArterialPressure} mmHg'),
            _vitalTile(width, 'Oxygen Saturation', '${summary.bloodOxygenSpO2}% SpO2', Icons.water_drop_rounded, const Color(0xFF0284C7), 'Normal Capillary Tone'),
            _vitalTile(width, 'Body Temperature', '${summary.bodyTemperature.toStringAsFixed(1)}°C', Icons.thermostat_rounded, const Color(0xFFD97706), 'Normothermic'),
            _vitalTile(width, 'Daily Steps', '${NumberFormat("#,###").format(summary.dailySteps)} steps', Icons.directions_walk_rounded, const Color(0xFF0D9488), '${summary.activeCalories} kcal burned'),
            _vitalTile(width, 'Restorative Sleep', summary.formattedSleep, Icons.bedtime_rounded, const Color(0xFF6366F1), '${summary.deepSleepMinutes}m deep sleep'),
          ],
        );
      },
    );
  }

  Widget _vitalTile(double width, String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPhysiologicalSystemsSection(ClinicalSummaryModel summary) {
    return Column(
      children: summary.systems.values.map((sys) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${sys.score}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.secondary, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(sys.name, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                          StatusBadge(label: sys.status, type: BadgeType.success, isPill: true),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(sys.headline, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(sys.explanation, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSensationsSection(ClinicalSummaryModel summary) {
    return Column(
      children: summary.sensations.take(4).map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Scale ${s.intensity}/10',
                    style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.area}: ${s.sensation}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                      if (s.notes.isNotEmpty)
                        Text(s.notes, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text(DateFormat('MMM dd').format(s.timestamp), style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedicalRecordsSection(ClinicalSummaryModel summary) {
    if (summary.records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No external records uploaded yet.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      );
    }
    return Column(
      children: summary.records.take(4).map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.document_scanner_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      Text('${r.category} • ${r.providerName}', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                StatusBadge(label: r.status, type: BadgeType.neutral, isPill: true),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWomensHealthCard(ClinicalWomensHealthSummary wh) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menstrual Cycle Day ${wh.currentDay}', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              StatusBadge(label: wh.phaseLabel, type: BadgeType.neutral, isPill: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(wh.phaseDescription, style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Text('Next Period: ~${wh.daysUntilNextPeriod} days remaining', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary)),
          if (wh.screeningRiskLevels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: wh.screeningRiskLevels.entries.map((e) {
                return _pillTag('${e.key}: ${e.value}', AppColors.surfaceSubtle, AppColors.textPrimary);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineSection(ClinicalSummaryModel summary) {
    return Column(
      children: summary.timeline.take(4).map((t) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text('${t.category} • ${t.metricValue}', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text(DateFormat('MMM dd').format(t.timestamp), style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCarePlanCard(ClinicalSummaryModel summary) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discussion Topics for Doctor', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...summary.physicianDiscussionGuide.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Expanded(child: Text(q, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Text('Lifestyle Recommendations', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...summary.lifestyleRecommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✓ ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  Expanded(child: Text(r, style: AppTypography.bodySmall.copyWith(fontSize: 11.5))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10.5)),
          const SizedBox(height: 1),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _pillTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}
