import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReportFileStore {
  Future<String?> save({
    required String reportId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final dir = await _reportsDir();
    final safeName = _safeFileName(fileName);
    final file = File(p.join(dir.path, '${reportId}_$safeName'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> delete(String? storedFilePath) async {
    if (storedFilePath == null || storedFilePath.isEmpty) return;
    final file = File(storedFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> exists(String? storedFilePath) async {
    if (storedFilePath == null || storedFilePath.isEmpty) return false;
    return File(storedFilePath).exists();
  }

  Future<Uint8List?> readBytes(String? storedFilePath) async {
    if (storedFilePath == null || storedFilePath.isEmpty) return null;
    final file = File(storedFilePath);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<Directory> _reportsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'lab_reports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _safeFileName(String fileName) {
    final base = p.basename(fileName).trim();
    final cleaned = base.replaceAll(RegExp(r'[\\/:\0]'), '_');
    if (cleaned.isEmpty) return 'report.pdf';
    return cleaned;
  }
}
