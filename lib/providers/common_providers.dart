import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:muscle_rivals/interceptors/auth_interceptor.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logger provider used to initialize the logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 1, // Number of method calls to be displayed
      // errorMethodCount: 0, // Number of method calls if stacktrace is provided
      lineLength: 40, // Width of the output (minimal)
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      // noBoxingByDefault: true, // THIS removes the rounded borders/lines
    ),
  );
});

/// This is the authenticated dio instance, we make separate instances when we need to make unauthenticated requests
final dioProvider = Provider<Dio>((ref) {
  Dio dio = Dio();
  // dio.options.headers['Device-Id'] =
  //     ref.read(diagnosticsServiceProvider).deviceId;

  // dio.interceptors.add(BreadcrumbInterceptor());
  // dio.interceptors.add(ConnectionInterceptor(() => ref.read(isOnlineProvider)));
  dio.interceptors.add(
    AuthInterceptor(
      logger: ref.read(loggerProvider),
      tokens: () => ref.read(authProvider.notifier).tokens,
      refreshTokens: () async =>
          ref.read(authProvider.notifier).refreshTokens(),
      dio: dio,
    ),
  );

  return dio;
});

final unauthenticatedDioProvider = Provider<Dio>((ref) {
  return Dio();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("This gets initialized in main");
});

final storageProvider = Provider<StorageService>((ref) {
  return StorageService(
    shardPreferences: ref.read(sharedPreferencesProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});
