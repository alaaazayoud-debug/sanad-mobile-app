class AppConstants {
  // ══════════════════════════════════════════
  // Appwrite Configuration
  // ══════════════════════════════════════════
  static const String appwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '6a8ab8ed003d63d5f766';

  // ══════════════════════════════════════════
  // Database IDs
  // ══════════════════════════════════════════
  static const String databaseId = 'sanad_db';
  static const String usersCollectionId = 'users';
  static const String partnershipsCollectionId = 'partnerships';
  static const String transactionsCollectionId = 'transactions';

  // ══════════════════════════════════════════
  // Auth
  // ══════════════════════════════════════════
  static const String pilotOtpCode = '0000';
  static const int otpLength = 4;

  // ══════════════════════════════════════════
  // Currencies
  // ══════════════════════════════════════════
  static const String defaultCurrency = 'USD';
  static const Map<String, String> supportedCurrencies = {
    'USD': '\$',
    'SYP': 'ل.س',
  };

  // ══════════════════════════════════════════
  // UI Constants
  // ══════════════════════════════════════════
  static const double balanceBarHeight = 60.0;
  static const int animationDurationMs = 300;
  static const int splashDurationMs = 2500;
}
