/// App secrets for LabWise.
///
/// Telegram: create a bot with @BotFather, add it as admin to
/// https://t.me/LabWiseApp, then paste the bot token below
/// (or pass --dart-define=TELEGRAM_BOT_TOKEN=...).
class AppSecrets {
  /// Prefer compile-time define when provided.
  static const String telegramBotToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '',
  );

  /// Channel username for https://t.me/LabWiseApp
  static const String telegramChannel = String.fromEnvironment(
    'TELEGRAM_CHANNEL',
    defaultValue: '@LabWiseApp',
  );

  static bool get hasTelegramBot => telegramBotToken.trim().isNotEmpty;
}
