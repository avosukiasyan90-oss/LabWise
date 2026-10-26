/// Configuration for the optional AI fallback that reads lab reports the
/// built-in parser does not recognise.
///
/// Two ways to wire it up, in order of preference:
///
/// 1. **Proxy (ship this).** Stand up an endpoint you control — a Firebase
///    Cloud Function is enough — that holds the OpenAI key server-side and
///    forwards the request. Build with:
///
///    `--dart-define=AI_PROXY_URL=https://your-function-url`
///
/// 2. **Direct key (local development only).** Build with:
///
///    `--dart-define=OPENAI_API_KEY=sk-...`
///
///    Never ship this. Anything compiled into a mobile binary can be pulled
///    back out of it, and a leaked key is billed to you.
class AiConfig {
  /// Endpoint that holds the API key on your server. Preferred.
  static const String proxyUrl = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: '',
  );

  /// Direct OpenAI key. Development builds only.
  static const String openAiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String model = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  static const String openAiEndpoint =
      'https://api.openai.com/v1/chat/completions';

  static bool get usesProxy => proxyUrl.trim().isNotEmpty;

  static bool get usesDirectKey => openAiKey.trim().isNotEmpty;

  /// False when neither route is configured, so the app can hide the feature
  /// instead of offering something that will fail.
  static bool get isConfigured => usesProxy || usesDirectKey;

  static Uri get endpoint =>
      Uri.parse(usesProxy ? proxyUrl.trim() : openAiEndpoint);
}
