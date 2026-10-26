import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'medical_report.dart';

/// Groups reports into friendly folders in History.
enum ReportCategory {
  bloodCount,
  biochemistry,
  hormones,
  urinalysis,
  urogenital,
  infection,
  other;

  String label(AppL10n l10n) => switch (this) {
        ReportCategory.bloodCount => l10n.categoryBloodCount,
        ReportCategory.biochemistry => l10n.categoryBiochemistry,
        ReportCategory.hormones => l10n.categoryHormones,
        ReportCategory.urinalysis => l10n.categoryUrinalysis,
        ReportCategory.urogenital => l10n.categoryUrogenital,
        ReportCategory.infection => l10n.categoryInfection,
        ReportCategory.other => l10n.categoryOther,
      };

  String description(AppL10n l10n) => switch (this) {
        ReportCategory.bloodCount => l10n.categoryBloodCountDesc,
        ReportCategory.biochemistry => l10n.categoryBiochemistryDesc,
        ReportCategory.hormones => l10n.categoryHormonesDesc,
        ReportCategory.urinalysis => l10n.categoryUrinalysisDesc,
        ReportCategory.urogenital => l10n.categoryUrogenitalDesc,
        ReportCategory.infection => l10n.categoryInfectionDesc,
        ReportCategory.other => l10n.categoryOtherDesc,
      };

  IconData get icon => switch (this) {
        ReportCategory.bloodCount => Icons.bloodtype_outlined,
        ReportCategory.biochemistry => Icons.science_outlined,
        ReportCategory.hormones => Icons.monitor_heart_outlined,
        ReportCategory.urinalysis => Icons.water_drop_outlined,
        ReportCategory.urogenital => Icons.biotech_outlined,
        ReportCategory.infection => Icons.coronavirus_outlined,
        ReportCategory.other => Icons.folder_open_rounded,
      };
}

const _bloodCountIds = {
  'wbc',
  'rbc',
  'hemoglobin',
  'hct',
  'mcv',
  'mch',
  'mchc',
  'platelets',
  'rdw_sd',
  'rdw_cv',
  'pdw',
  'mpv',
  'p_lcr',
  'pct',
  'neut_pct',
  'lymph_pct',
  'mono_pct',
  'eo_pct',
  'baso_pct',
  'neut_abs',
  'lymph_abs',
  'mono_abs',
  'eo_abs',
  'baso_abs',
  'esr',
};

const _biochemistryIds = {
  'glucose',
  'cholesterol',
  'ldl',
  'hdl',
  'triglycerides',
  'hba1c',
  'creatinine',
  'alt',
  'ast',
  'iron',
  'b12',
  'vitamin_d',
};

const _hormoneIds = {'tsh', 't3', 't4', 'ft3', 'ft4'};

/// Picks the folder a report belongs to, based on which markers were read and
/// the exam title printed on the document.
ReportCategory categoryOf(MedicalReport report) {
  final ids = report.markers.map((m) => m.id).toList();

  var infection = 0;
  var urogenital = 0;
  var urine = 0;
  var blood = 0;
  var chemistry = 0;
  var hormones = 0;

  for (final id in ids) {
    if (id == 'h_pylori') {
      infection++;
    } else if (id.startsWith('uro_') || id.startsWith('af_')) {
      urogenital++;
    } else if (id.startsWith('urine_')) {
      urine++;
    } else if (_bloodCountIds.contains(id)) {
      blood++;
    } else if (_biochemistryIds.contains(id)) {
      chemistry++;
    } else if (_hormoneIds.contains(id)) {
      hormones++;
    }
  }

  final scores = <ReportCategory, int>{
    ReportCategory.infection: infection,
    ReportCategory.urogenital: urogenital,
    ReportCategory.urinalysis: urine,
    ReportCategory.bloodCount: blood,
    ReportCategory.biochemistry: chemistry,
    ReportCategory.hormones: hormones,
  };

  final best = scores.entries.reduce((a, b) => b.value > a.value ? b : a);
  if (best.value > 0) return best.key;

  return _categoryFromTitle(report) ?? ReportCategory.other;
}

ReportCategory? _categoryFromTitle(MedicalReport report) {
  final haystack = [
    report.examTitle ?? '',
    report.fileName,
  ].join(' ').toLowerCase();

  if (haystack.contains('blood count') || haystack.contains('cbc')) {
    return ReportCategory.bloodCount;
  }
  if (haystack.contains('biochem')) return ReportCategory.biochemistry;
  if (haystack.contains('urinalysis') || haystack.contains('urine')) {
    return ReportCategory.urinalysis;
  }
  if (haystack.contains('androflor') ||
      haystack.contains('urogenital') ||
      haystack.contains('микроскопич')) {
    return ReportCategory.urogenital;
  }
  if (haystack.contains('hormone') || haystack.contains('thyroid')) {
    return ReportCategory.hormones;
  }
  if (haystack.contains('helik') ||
      haystack.contains('հելիկ') ||
      haystack.contains('pylori')) {
    return ReportCategory.infection;
  }
  return null;
}

/// Reports bucketed by folder, each list newest-first and folders ordered by
/// how recently they were used.
List<MapEntry<ReportCategory, List<MedicalReport>>> groupByCategory(
  List<MedicalReport> reports,
) {
  final grouped = <ReportCategory, List<MedicalReport>>{};
  for (final report in reports) {
    grouped.putIfAbsent(categoryOf(report), () => []).add(report);
  }

  for (final list in grouped.values) {
    list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  final entries = grouped.entries.toList()
    ..sort(
      (a, b) => b.value.first.uploadedAt.compareTo(a.value.first.uploadedAt),
    );
  return entries;
}
