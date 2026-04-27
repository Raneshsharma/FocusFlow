// Stub implementation for web platform
// dart:io is not available on web

Future<String> readFile(String path) async => '';

Future<bool> fileExists(String path) async => false;

Future<void> deleteFile(String path) async {}

Future<String> getTempDirectory() async => '';
