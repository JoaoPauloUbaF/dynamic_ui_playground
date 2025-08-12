abstract class AiService {
  /// Create an initial UI JSON from a natural language text description.
  Future<Map<String, dynamic>> createUiFromText({
    required String prompt,
  });

  /// Create an initial UI JSON from a spoken (audio) description.
  Future<Map<String, dynamic>> createUiFromAudio({
    required String prompt,
    Duration captureDuration = const Duration(seconds: 6),
  });

  /// Update an existing UI JSON given a natural language text instruction.
  Future<Map<String, dynamic>> updateUiFromText({
    required String prompt,
    required Map<String, dynamic> currentJson,
  });

  /// Update an existing UI JSON given a spoken (audio) instruction.
  /// Implementations may capture audio from the microphone and submit it along
  /// with the provided prompt/context to the LLM.
  Future<Map<String, dynamic>> updateUiFromAudio({
    required String prompt,
    required Map<String, dynamic> currentJson,
    Duration captureDuration = const Duration(seconds: 6),
  });
}
