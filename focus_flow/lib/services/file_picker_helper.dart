// Platform-agnostic file picker for FocusFlow
// Handles both web (using bytes) and native (using path)

import 'file_picker_web.dart'
    if (dart.library.html) 'file_picker_web.dart'
    if (dart.library.io) 'file_picker_native.dart';

export 'file_picker_native.dart' show PickerResult;

/// Pick a JSON file for import
/// Returns the file contents as a string, or null if cancelled
Future<PickerResult?> pickJsonFile() => pickJsonFileImpl();