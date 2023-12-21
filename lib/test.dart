import 'dart:io';

import './env/env.dart';
import 'package:dart_openai/dart_openai.dart';

Future<void> main() async {
  // print(Env.apiKey);
  OpenAI.apiKey = Env.apiKey;
  final file = File('test.mp3');
  print(file.path);
  try {
    OpenAIAudioModel transcription =
        await OpenAI.instance.audio.createTranscription(
      file: File('test.m4a'),
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.json,
    );
    print(transcription.text);
  } catch (e) {
    print(e.toString());
  }
}
