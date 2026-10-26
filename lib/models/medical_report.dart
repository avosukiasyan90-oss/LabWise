import '../l10n/app_localizations.dart';
import 'lab_marker.dart';
import 'report_comparison.dart';

class MedicalReport {
  const MedicalReport({
    required this.id,
    required this.fileName,
    required this.uploadedAt,
    required this.summary,
    required this.whatToDo,
    required this.markers,
    this.patientName,
    this.examTitle,
    this.reportNumber,
    this.sampleDate,
    this.doctorName,
    this.method,
    this.rawExcerpt,
    this.storedFilePath,
    this.cloudFileUrl,
    this.fileContentHash,
    this.patientAddress,
    this.patientPhone,
    this.patientEmail,
    this.licenseNumber,
    this.clinicName,
    this.previous,
    this.readByAi = false,
  });

  final String id;
  final String fileName;
  final DateTime uploadedAt;
  final String summary;
  final List<String> whatToDo;
  final List<LabMarker> markers;
  final String? patientName;
  final String? examTitle;
  final String? reportNumber;
  final String? sampleDate;
  final String? doctorName;
  final String? method;
  final String? rawExcerpt;
  final String? storedFilePath;
  final String? cloudFileUrl;

  /// SHA-256 of the original uploaded file bytes (exact duplicate detection).
  final String? fileContentHash;

  /// Contact block printed on the report; these belong to the patient.
  final String? patientAddress;
  final String? patientPhone;
  final String? patientEmail;

  /// Laboratory licence identifier printed on the report.
  final String? licenseNumber;

  /// Clinic or laboratory that performed the test, when printed.
  final String? clinicName;

  /// The earlier run of this same test that this upload replaced in History.
  final ReportSnapshot? previous;

  /// True when this upload superseded an earlier version of the same panel.
  bool get supersedesPrevious => previous != null;

  /// True when the built-in parser could not read this file and the user
  /// chose to have it read by the AI fallback instead.
  final bool readByAi;

  bool get hasContactDetails =>
      (clinicName?.isNotEmpty ?? false) ||
      (patientAddress?.isNotEmpty ?? false) ||
      (patientPhone?.isNotEmpty ?? false) ||
      (patientEmail?.isNotEmpty ?? false) ||
      (licenseNumber?.isNotEmpty ?? false);

  int get abnormalCount => markers.where((m) => m.isAbnormal).length;

  bool get hasAttachedFile =>
      (storedFilePath != null && storedFilePath!.isNotEmpty) ||
      (cloudFileUrl != null && cloudFileUrl!.isNotEmpty);

  String healthLabel(AppL10n l10n) {
    if (markers.isEmpty) return l10n.healthNeedsReview;
    if (abnormalCount == 0) return l10n.healthLookingGood;
    if (abnormalCount <= 2) return l10n.healthSomeAttention;
    return l10n.healthFollowUp;
  }

  MedicalReport copyWith({
    String? id,
    String? fileName,
    DateTime? uploadedAt,
    String? summary,
    List<String>? whatToDo,
    List<LabMarker>? markers,
    String? patientName,
    String? examTitle,
    String? reportNumber,
    String? sampleDate,
    String? doctorName,
    String? method,
    String? rawExcerpt,
    String? storedFilePath,
    String? cloudFileUrl,
    String? fileContentHash,
    String? patientAddress,
    String? patientPhone,
    String? patientEmail,
    String? licenseNumber,
    String? clinicName,
    ReportSnapshot? previous,
    bool? readByAi,
  }) {
    return MedicalReport(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      summary: summary ?? this.summary,
      whatToDo: whatToDo ?? this.whatToDo,
      markers: markers ?? this.markers,
      patientName: patientName ?? this.patientName,
      examTitle: examTitle ?? this.examTitle,
      reportNumber: reportNumber ?? this.reportNumber,
      sampleDate: sampleDate ?? this.sampleDate,
      doctorName: doctorName ?? this.doctorName,
      method: method ?? this.method,
      rawExcerpt: rawExcerpt ?? this.rawExcerpt,
      storedFilePath: storedFilePath ?? this.storedFilePath,
      cloudFileUrl: cloudFileUrl ?? this.cloudFileUrl,
      fileContentHash: fileContentHash ?? this.fileContentHash,
      patientAddress: patientAddress ?? this.patientAddress,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicName: clinicName ?? this.clinicName,
      previous: previous ?? this.previous,
      readByAi: readByAi ?? this.readByAi,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'uploadedAt': uploadedAt.toIso8601String(),
        'summary': summary,
        'whatToDo': whatToDo,
        'markers': markers.map((m) => m.toJson()).toList(),
        'patientName': patientName,
        'examTitle': examTitle,
        'reportNumber': reportNumber,
        'sampleDate': sampleDate,
        'doctorName': doctorName,
        'method': method,
        'rawExcerpt': rawExcerpt,
        'storedFilePath': storedFilePath,
        'cloudFileUrl': cloudFileUrl,
        'fileContentHash': fileContentHash,
        'patientAddress': patientAddress,
        'patientPhone': patientPhone,
        'patientEmail': patientEmail,
        'licenseNumber': licenseNumber,
        'clinicName': clinicName,
        'previous': previous?.toJson(),
        'readByAi': readByAi,
      };

  factory MedicalReport.fromJson(Map<String, dynamic> json) => MedicalReport(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        summary: json['summary'] as String? ?? '',
        whatToDo: (json['whatToDo'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        markers: (json['markers'] as List<dynamic>? ?? [])
            .map((e) => LabMarker.fromJson(e as Map<String, dynamic>))
            .toList(),
        patientName:
            json['patientName'] as String? ?? json['patientHint'] as String?,
        examTitle: json['examTitle'] as String?,
        reportNumber: json['reportNumber'] as String?,
        sampleDate: json['sampleDate'] as String?,
        doctorName: json['doctorName'] as String?,
        method: json['method'] as String?,
        rawExcerpt: json['rawExcerpt'] as String?,
        storedFilePath: json['storedFilePath'] as String?,
        cloudFileUrl: json['cloudFileUrl'] as String?,
        fileContentHash: json['fileContentHash'] as String?,
        patientAddress: json['patientAddress'] as String?,
        patientPhone: json['patientPhone'] as String?,
        patientEmail: json['patientEmail'] as String?,
        licenseNumber: json['licenseNumber'] as String?,
        clinicName: json['clinicName'] as String?,
        previous: json['previous'] == null
            ? null
            : ReportSnapshot.fromJson(
                Map<String, dynamic>.from(json['previous'] as Map),
              ),
        readByAi: json['readByAi'] as bool? ?? false,
      );
}
