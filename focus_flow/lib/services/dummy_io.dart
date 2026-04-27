// Dummy file for web platform compatibility
// dart:io is not available on web, so we use this stub

class File {
  File(String path);
  Future<String> readAsString() async => '';
  Future<bool> exists() async => false;
  Future<void> delete() async {}
}

class Directory {
  Directory(String path);
  String get path => '';
}
