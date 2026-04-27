// Platform-agnostic file operations for FocusFlow
// This file handles the conditional import for web vs native

import 'file_helper_stub.dart'
    if (dart.library.io) 'file_helper_native.dart' as platform;

export 'file_helper_stub.dart';

/// Read contents of a file from path
Future<String> readFile(String path) => platform.readFile(path);

/// Check if a file exists
Future<bool> fileExists(String path) => platform.fileExists(path);

/// Delete a file
Future<void> deleteFile(String path) => platform.deleteFile(path);

/// Get a temporary directory path
Future<String> getTempDirectory() => platform.getTempDirectory();
