// Native implementation for file picker
// Uses dart:io FilePicker for native platforms

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
  );

  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  if (file.path == null) return null;

  return PickerResult(
    path: file.path!,
    name: file.name,
    bytes: file.bytes ?? [],
  );
}