// Native implementation for file operations
// Uses dart:io for native platforms only

import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> readFile(String path) async {
  final file = File(path);
  return file.readAsString();
}

Future<bool> fileExists(String path) async {
  final file = File(path);
  return file.exists();
}

Future<void> deleteFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<String> getTempDirectory() async {
  final dir = await getTemporaryDirectory();
  return dir.path;
}
