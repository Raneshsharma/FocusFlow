// Web implementation for file picker
// Uses file.bytes directly since path is not available on web

import 'package:file_picker/file_picker.dart';

class PickerResult {
  final String path;
  final String name;
  final List<int> bytes;

  PickerResult({
    required this.path,
    required this.name,
    required this.bytes,
  });
}

Future<PickerResult?> pickJsonFileImpl() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    allowMultiple: false,
    withData: true, // Important: ensure bytes are available on web
  );

  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  final bytes = file.bytes;

  if (bytes == null) return null;

  return PickerResult(
    path: '', // Web doesn't have file paths
    name: file.name,
    bytes: bytes,
  );
}