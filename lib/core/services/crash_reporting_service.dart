import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics error reporting service
class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();

  factory CrashReportingService() {
    return _instance;
  }

  CrashReportingService._internal();

  bool _isInitialized = false;

  /// Initialize Firebase & Crashlytics
  Future<void> initialize() async {
    if (_isInitialized) return;
    // Firebase is only configured for Android/iOS; Crashlytics has no web support.
    if (kIsWeb) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Get Crashlytics instance
      final crashlytics = FirebaseCrashlytics.instance;

      // Enable collection in production, disable in debug
      if (kDebugMode) {
        await crashlytics.setCrashlyticsCollectionEnabled(false);
        debugPrint('🐛 Crashlytics disabled (Debug Mode)');
      } else {
        await crashlytics.setCrashlyticsCollectionEnabled(true);
        debugPrint('✅ Crashlytics enabled (Production Mode)');
      }

      // Set error handlers
      _setupErrorHandlers(crashlytics);

      _isInitialized = true;
      debugPrint('✅ Crash reporting initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing crash reporting: $e');
    }
  }

  /// Setup global error handlers
  void _setupErrorHandlers(FirebaseCrashlytics crashlytics) {
    // Catch uncaught exceptions
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      debugPrint('🔴 Flutter Error: ${errorDetails.exception}');
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
      );
      debugPrint('🔴 Platform Error: $error');
      return true;
    };
  }

  /// Report custom error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      debugPrint('📤 Error reported to Crashlytics: $error');
    } catch (e) {
      debugPrint('❌ Failed to report error: $e');
    }
  }

  /// Log breadcrumb (non-fatal message)
  Future<void> logMessage(String message, {String? level}) async {
    try {
      final prefix = level != null ? '[$level]' : '[INFO]';
      await FirebaseCrashlytics.instance.log('$prefix $message');
      debugPrint('📝 Logged: $message');
    } catch (e) {
      debugPrint('❌ Failed to log message: $e');
    }
  }

  /// Set user information
  Future<void> setUserId(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      debugPrint('👤 User ID set: $userId');
    } catch (e) {
      debugPrint('❌ Failed to set user ID: $e');
    }
  }

  /// Set custom key-value pairs
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
      debugPrint('🔑 Custom key set: $key = $value');
    } catch (e) {
      debugPrint('❌ Failed to set custom key: $e');
    }
  }

  /// Report API error
  Future<void> reportApiError({
    required String endpoint,
    required int statusCode,
    required String message,
    String? responseBody,
  }) async {
    try {
      final errorMessage = '''
API Error:
Endpoint: $endpoint
Status Code: $statusCode
Message: $message
Response: $responseBody
''';
      await logMessage(errorMessage, level: 'ERROR');
      debugPrint('🌐 API Error: $endpoint ($statusCode)');
    } catch (e) {
      debugPrint('❌ Failed to report API error: $e');
    }
  }

  /// Get crash reporting status
  bool get isEnabled => !kDebugMode && _isInitialized;

  /// Simulate crash (for testing - only in debug)
  void simulateCrash() {
    if (kDebugMode) {
      debugPrint('⚠️  Simulating crash...');
      throw Exception('Test crash - this is intentional for testing');
    } else {
      debugPrint('❌ Cannot simulate crash in production');
    }
  }
}

/// Global instance accessor
CrashReportingService get crashReporting => CrashReportingService();
