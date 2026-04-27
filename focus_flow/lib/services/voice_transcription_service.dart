import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Voice transcription service using speech_to_text package
/// Provides real-time speech recognition for voice notes
class VoiceTranscriptionService {
  static VoiceTranscriptionService? _instance;
  static VoiceTranscriptionService get instance => _instance ??= VoiceTranscriptionService._();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  VoiceTranscriptionService._();

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  /// Check if speech recognition is available on this device
  bool get isAvailable => _isInitialized;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get available locales for speech recognition
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  /// Start listening for speech
  /// Returns true if listening started successfully
  Future<bool> startListening({
    required Function(String transcription) onResult,
    Function(String partialResult)? onPartialResult,
    Function()? onListeningComplete,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return false;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;

      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          final transcription = result.recognizedWords;
          if (result.finalResult) {
            onResult(transcription);
            onListeningComplete?.call();
          } else {
            onPartialResult?.call(transcription);
          }
        },
        localeId: localeId,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      );

      return true;
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      return false;
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    } finally {
      _isListening = false;
    }
  }

  /// Cancel listening without triggering completion
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('Error canceling speech recognition: $e');
    } finally {
      _isListening = false;
    }
  }

  /// Dispose of resources
  void dispose() {
    cancelListening();
    _isInitialized = false;
  }
}
