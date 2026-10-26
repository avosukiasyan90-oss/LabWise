import 'dart:typed_data';

class ReportFileStore {
  Future<String?> save({
    required String reportId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    // Web has no durable local file path for later download from history.
    return null;
  }

  Future<void> delete(String? storedFilePath) async {}

  Future<bool> exists(String? storedFilePath) async => false;

  Future<Uint8List?> readBytes(String? storedFilePath) async => null;
}
