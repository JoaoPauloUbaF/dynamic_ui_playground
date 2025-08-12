import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dynamic_ui_playground/services/ai_service/ai_prompts.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:record/record.dart';

/// FirebaseAI-backed implementation that returns JSON-structured UI responses.
class FirebaseAiService extends AiService {
  GenerativeModel? _jsonModel;
  String _currentJsonModelName = 'gemini-2.5-flash';
  final String _fallbackJsonModelName = 'gemini-1.5-flash';

  FirebaseAiService() {
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    _jsonModel = _createUiJsonModel(_currentJsonModelName);
  }

  GenerativeModel _createUiJsonModel(String modelName) {
    // The firebase_ai Schema API does not support recursive schemas at the
    // time of writing. We enforce structure via prompts and request JSON only.
    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<Map<String, dynamic>> _generateJsonFromParts(List<Part> parts) async {
    if (_jsonModel == null) {
      await _ensureInitialized();
    }

    try {
      final res = await _jsonModel!.generateContent([Content.multi(parts)]);
      final text = res.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty JSON response from AI');
      }
      return json.decode(text) as Map<String, dynamic>;
    } on FirebaseAIException catch (e) {
      log('FirebaseAIException: ${e.message}', error: e);
      if (_currentJsonModelName != _fallbackJsonModelName) {
        _currentJsonModelName = _fallbackJsonModelName;
        _jsonModel = _createUiJsonModel(_currentJsonModelName);
        final res = await _jsonModel!.generateContent([Content.multi(parts)]);
        final text = res.text;
        if (text == null || text.isEmpty) {
          throw Exception('Empty JSON response from AI (fallback)');
        }
        return json.decode(text) as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUiFromText({
    required String prompt,
    required Map<String, dynamic> currentJson,
  }) async {
    final fullPrompt = AiPrompts.updateUiPrompt(
      instruction: prompt,
      currentJson: currentJson,
    );
    return _generateJsonFromParts([TextPart(fullPrompt)]);
  }

  @override
  Future<Map<String, dynamic>> updateUiFromAudio({
    required String prompt,
    required Map<String, dynamic> currentJson,
    Duration captureDuration = const Duration(seconds: 6),
  }) async {
    // Capture audio from the microphone using the 'record' package
    final recorder = AudioRecorder();
    if (!await recorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    final tempDir = Directory.systemTemp.createTempSync('ai_audio');
    final filePath = '${tempDir.path}/prompt.m4a';

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    // Simple fixed-duration capture
    await Future.delayed(captureDuration);
    final recordedPath = await recorder.stop();

    if (recordedPath == null) {
      throw Exception('Failed to record audio');
    }

    final bytes = await File(recordedPath).readAsBytes();

    final instruction = AiPrompts.audioUpdateUiPrompt(
      guidance: prompt,
      currentJson: currentJson,
    );

    final parts = <Part>[
      TextPart(instruction),
      InlineDataPart('audio/mp4', bytes), // m4a typically uses audio/mp4
    ];

    return _generateJsonFromParts(parts);
  }
}
