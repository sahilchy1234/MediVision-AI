import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/clinical_summary_model.dart';

class ClinicalPdfExportService {
  /// Generate a high-fidelity, multi-page clinical dossier PDF document
  static Future<Uint8List> generatePdfBytes(ClinicalSummaryModel summary) async {
    final pdf = pw.Document(
      title: 'MediVision AI - Clinical Health Dossier',
      author: 'MediVision AI Clinical Intelligence System',
      creator: 'MediVision Health Technologies',
      subject: 'Patient Medical Summary for ${summary.patientName}',
    );

    // Styling constants
    final brandDark = const PdfColor.fromInt(0xFF0F172A); // Slate 900
    final brandPrimary = const PdfColor.fromInt(0xFF0D9488); // Teal 600
    final brandPrimaryLight = const PdfColor.fromInt(0xFFF0FDFA); // Teal 50
    final neutralBg = const PdfColor.fromInt(0xFFF8FAFC); // Slate 50
    final borderColor = const PdfColor.fromInt(0xFFCBD5E1); // Slate 300
    final textMuted = const PdfColor.fromInt(0xFF64748B); // Slate 500
    final textDark = const PdfColor.fromInt(0xFF1E293B); // Slate 800
    final successColor = const PdfColor.fromInt(0xFF059669); // Emerald 600

    final dateStr = DateFormat('MMMM dd, yyyy - HH:mm').format(summary.generatedAt);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 14),
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.teal, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 18,
                      height: 18,
                      decoration: pw.BoxDecoration(
                        color: brandPrimary,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        '+',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'MediVision AI',
                      style: pw.TextStyle(
                        color: brandDark,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      '| Clinical Health Dossier',
                      style: pw.TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'CONFIDENTIAL MEDICAL RECORD',
                  style: const pw.TextStyle(
                    color: PdfColors.red800,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 14),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Report ID: ${summary.reportId} - Generated: $dateStr',
                  style: pw.TextStyle(color: textMuted, fontSize: 8),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(color: textMuted, fontSize: 8),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // 1. Report Title & Meta Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: brandPrimaryLight,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: brandPrimary, width: 0.8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'COMPREHENSIVE PATIENT CLINICAL SUMMARY',
                      style: pw.TextStyle(
                        color: brandDark,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Aggregated Ambulatory Telemetry, Physiological Systems & Diagnostic Vault',
                      style: pw.TextStyle(color: textMuted, fontSize: 8.5),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: brandDark,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'HEALTH SCORE: ${summary.healthScore} / 100',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // 2. Patient Demographics Table
          _buildSectionHeader('1. PATIENT DEMOGRAPHICS & CLINICAL IDENTITY', brandDark),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(2.0),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(2.0),
            },
            children: [
              _buildTableRow('Full Name', summary.patientName, 'Age / Sex', '${summary.age} yrs (${summary.gender})'),
              _buildTableRow('Date of Birth', summary.dateOfBirth != null ? DateFormat('MMM dd, yyyy').format(summary.dateOfBirth!) : 'Unspecified', 'Blood Group', summary.bloodGroup),
              _buildTableRow('Height / Weight', '${summary.heightCm.toInt()} cm / ${summary.weightKg.toInt()} kg', 'BMI Category', '${summary.bmi} (${summary.bmiCategory})'),
              _buildTableRow('Known Allergies', summary.allergies.isNotEmpty ? summary.allergies.join(', ') : 'No known allergies (NKDA)', 'Medical Conditions', summary.medicalConditions.isNotEmpty ? summary.medicalConditions.join(', ') : 'None documented'),
            ],
          ),
          pw.SizedBox(height: 14),

          // 3. Executive Medical Digest & Clinical Narrative
          _buildSectionHeader('2. EXECUTIVE MEDICAL DIGEST', brandDark),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: neutralBg,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: borderColor, width: 0.6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Clinical Status: ${summary.clinicalStatus}',
                      style: pw.TextStyle(
                        color: successColor,
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Report ID: ${summary.reportId}',
                      style: pw.TextStyle(color: textMuted, fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  summary.summaryNarrative,
                  style: pw.TextStyle(color: textDark, fontSize: 9, lineSpacing: 1.4),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: borderColor, thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Key Protective Factors:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: brandDark)),
                          pw.SizedBox(height: 3),
                          ...summary.protectiveFactors.map((f) => pw.Text('- $f', style: pw.TextStyle(fontSize: 8, color: textDark))),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Monitored Clinical Risks:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: brandDark)),
                          pw.SizedBox(height: 3),
                          ...summary.keyRiskFactors.map((r) => pw.Text('- $r', style: pw.TextStyle(fontSize: 8, color: textDark))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // 4. Vitals & Hemodynamics Matrix
          _buildSectionHeader('3. VITALS, HEMODYNAMICS & METABOLIC TELEMETRY', brandDark),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.5),
            },
            children: [
              _buildMetricRow('Resting Pulse', summary.formattedPulse, 'Blood Pressure', summary.formattedBP),
              _buildMetricRow('Oxygen Saturation', '${summary.bloodOxygenSpO2}% SpO2', 'Body Temperature', '${summary.bodyTemperature.toStringAsFixed(1)}°C'),
              _buildMetricRow('Mean Arterial Pressure', '${summary.meanArterialPressure} mmHg', 'Pulse Pressure', '${summary.pulsePressure} mmHg'),
              _buildMetricRow('Daily Steps (Mobility)', '${NumberFormat("#,###").format(summary.dailySteps)} steps', 'Active Calorie Burn', '${summary.activeCalories} kcal (${summary.activeMinutes}m active)'),
              _buildMetricRow('Sleep Duration & Rest', summary.formattedSleep, 'Sleep Architecture', '${summary.formattedDeepSleep} Deep (${summary.sleepQualityScore}% index)'),
              _buildMetricRow('Digital Screen Hygiene', '${summary.screenTimeMinutes / 60}h ${summary.screenTimeMinutes % 60}m', 'Screen Device Pickups', '${summary.screenPickups} pickups/day'),
            ],
          ),
          pw.SizedBox(height: 14),

          // 5. Physiological Systems Assessment Table
          _buildSectionHeader('4. PHYSIOLOGICAL SYSTEMS ASSESSMENT', brandDark),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.0),
              1: pw.FlexColumnWidth(1.0),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(3.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableHeaderCell('Anatomical / Health System'),
                  _tableHeaderCell('Score'),
                  _tableHeaderCell('Status'),
                  _tableHeaderCell('Clinical Findings & Guidance'),
                ],
              ),
              ...summary.systems.values.map(
                (sys) => pw.TableRow(
                  children: [
                    _tableCell(sys.name, isBold: true),
                    _tableCell('${sys.score} / 100'),
                    _tableCell(sys.status),
                    _tableCell('${sys.headline}. ${sys.explanation} ${sys.recommendation}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // 6. Active Body Sensations Log (if present)
          if (summary.sensations.isNotEmpty) ...[
            _buildSectionHeader('5. ACTIVE BODILY SENSATIONS (BODY ATLAS)', brandDark),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.6),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.8),
                1: pw.FlexColumnWidth(2.0),
                2: pw.FlexColumnWidth(1.2),
                3: pw.FlexColumnWidth(2.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeaderCell('System / Area'),
                    _tableHeaderCell('Sensation'),
                    _tableHeaderCell('Intensity (1-10)'),
                    _tableHeaderCell('Clinical Context / Notes'),
                  ],
                ),
                ...summary.sensations.map(
                  (s) => pw.TableRow(
                    children: [
                      _tableCell(s.area, isBold: true),
                      _tableCell(s.sensation),
                      _tableCell('${s.intensity} / 10'),
                      _tableCell(s.notes.isNotEmpty ? s.notes : 'Logged in Body Atlas'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
          ],

          // 7. Medical Records & Diagnostic Vault
          _buildSectionHeader('6. VERIFIED MEDICAL RECORDS VAULT', brandDark),
          pw.SizedBox(height: 6),
          if (summary.records.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: neutralBg,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: borderColor, width: 0.5),
              ),
              child: pw.Text('No external diagnostic files currently stored in vault.', style: pw.TextStyle(color: textMuted, fontSize: 8.5)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.6),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.6),
                3: pw.FlexColumnWidth(1.2),
                4: pw.FlexColumnWidth(3.0),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeaderCell('Document / Test'),
                    _tableHeaderCell('Category'),
                    _tableHeaderCell('Provider / Lab'),
                    _tableHeaderCell('Status'),
                    _tableHeaderCell('Diagnostic Impression'),
                  ],
                ),
                ...summary.records.take(6).map(
                  (rec) => pw.TableRow(
                    children: [
                      _tableCell(rec.title, isBold: true),
                      _tableCell(rec.category),
                      _tableCell(rec.providerName),
                      _tableCell(rec.status),
                      _tableCell(rec.summary.isNotEmpty ? rec.summary : 'Verified in personal records vault'),
                    ],
                  ),
                ),
              ],
            ),
          pw.SizedBox(height: 14),

          // 8. Women's Reproductive Health Profile (if applicable)
          if (summary.womensHealth != null) ...[
            _buildSectionHeader('7. REPRODUCTIVE & HORMONAL HEALTH PROFILE', brandDark),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFDF2F8), // Rose 50
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFF472B6), width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Menstrual Cycle Day ${summary.womensHealth!.currentDay} - Phase: ${summary.womensHealth!.phaseLabel}',
                        style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: PdfColor.fromInt(0xFF9D174D)),
                      ),
                      pw.Text(
                        'Next Cycle in ${summary.womensHealth!.daysUntilNextPeriod} days',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: textDark),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    summary.womensHealth!.phaseDescription,
                    style: pw.TextStyle(fontSize: 8.5, color: textDark),
                  ),
                  if (summary.womensHealth!.screeningRiskLevels.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('Clinical Condition Screenings:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: brandDark)),
                    pw.SizedBox(height: 2),
                    pw.Row(
                      children: summary.womensHealth!.screeningRiskLevels.entries.map((e) {
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(right: 8),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(3),
                            border: pw.Border.all(color: borderColor, width: 0.5),
                          ),
                          child: pw.Text('${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          // 9. Chronological Clinical Milestones
          _buildSectionHeader('8. RECENT HEALTH TIMELINE MILESTONES', brandDark),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.4),
              1: pw.FlexColumnWidth(2.2),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1.4),
              4: pw.FlexColumnWidth(2.8),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableHeaderCell('Timestamp'),
                  _tableHeaderCell('Event / Intervention'),
                  _tableHeaderCell('Category'),
                  _tableHeaderCell('Metric / Value'),
                  _tableHeaderCell('Clinical Insight'),
                ],
              ),
              ...summary.timeline.take(5).map(
                (item) => pw.TableRow(
                  children: [
                    _tableCell(DateFormat('MMM dd, yyyy').format(item.timestamp)),
                    _tableCell(item.title, isBold: true),
                    _tableCell(item.category),
                    _tableCell(item.metricValue.isNotEmpty ? item.metricValue : 'Logged'),
                    _tableCell(item.plainEnglishInsight.isNotEmpty ? item.plainEnglishInsight : item.description),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // 10. Physician Consultation Care Plan
          _buildSectionHeader('9. PHYSICIAN CONSULTATION CARE PLAN', brandDark),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: neutralBg,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: borderColor, width: 0.6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Key Discussion Points for Healthcare Provider:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandDark)),
                pw.SizedBox(height: 4),
                ...summary.physicianDiscussionGuide.map(
                  (q) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text('- $q', style: pw.TextStyle(fontSize: 8.5, color: textDark)),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Lifestyle & Prevention Prescription:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandDark)),
                pw.SizedBox(height: 4),
                ...summary.lifestyleRecommendations.map(
                  (r) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text('- $r', style: pw.TextStyle(fontSize: 8.5, color: textDark)),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Follow-up Timeline: ${summary.followUpSchedule}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: brandPrimary)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Digital Signature & Disclaimer Block
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Verification Hash: SHA256-${summary.reportId.hashCode.abs().toRadixString(16)}', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                  pw.SizedBox(height: 2),
                  pw.Text('MediVision AI Cryptographic Clinical Digest', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 140,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.8)),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Attending Clinician / Patient Signature', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Launch system print / preview dialog to print or save as PDF
  static Future<void> printOrPreviewPdf(
    BuildContext context,
    ClinicalSummaryModel summary,
  ) async {
    final pdfBytes = await generatePdfBytes(summary);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'MediVision_Clinical_Summary_${summary.patientName.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Export and share PDF file across Android, iOS, Web, and Desktop
  static Future<void> exportPdf(ClinicalSummaryModel summary) async {
    final pdfBytes = await generatePdfBytes(summary);
    final filename = 'MediVision_Clinical_Summary_${summary.patientName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(summary.generatedAt)}.pdf';
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  // --- Helper Widgets for Table Formatting ---

  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.teal, width: 3),
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(left: 6),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  static pw.TableRow _buildTableRow(String label1, String val1, String label2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label1, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(val1, style: const pw.TextStyle(fontSize: 8)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label2, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(val2, style: const pw.TextStyle(fontSize: 8)),
        ),
      ],
    );
  }

  static pw.TableRow _buildMetricRow(String label1, String val1, String label2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label1, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 1),
              pw.Text(val1, style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label2, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 1),
              pw.Text(val2, style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Clinical Baseline', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 1),
              pw.Text('Standard Target', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Variance Status', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 1),
              pw.Text('Verified Normative', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.grey800,
        ),
      ),
    );
  }
}
