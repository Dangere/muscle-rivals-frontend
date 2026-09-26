import 'dart:async';

import 'package:dio/dio.dart';
import 'package:muscle_rivals/error_management/app_error_code.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:stack_trace/stack_trace.dart';

/// Maps [Exception]s to [AppErrorCode]
class ErrorMapper {
  /// Maps an error object into a [AppErrorCode]
  static AppErrorCode mapError(Object e) {
    if (e is DioException) return _mapDioError(e);

    if (e is TimeoutException) return AppErrorCode.DIO_SEND_TIMEOUT;

    if (e is HttpError) {
      return _mapHttpError(e);
    }

    // if (_isFatalDbError(e)) return AppErrorCode.DATABASE_ERROR;

    return AppErrorCode.UNKNOWN;
  }

  /// parses stack traces into a contained log message
  static String parseLogMessage(
    String message,
    StackTrace stacktrace,
    StackTrace currentStackTrace,
  ) {
    final origin = _parseStackTrace(stacktrace).toString().trim();
    final current = _parseStackTrace(currentStackTrace).toString().trim();

    return '''
      $message

      ── Origin (where it was thrown) ──

      $origin



      ── Caught at (your code) ──

      $current
        '''
        .trim();
  }

  /// Parses stack traces into a smalled folded instances
  static StackTrace _parseStackTrace(StackTrace stackTrace) {
    return Trace.from(stackTrace).foldFrames(
      (p0) =>
          p0.toString().contains("dart-sdk") ||
          p0.toString().contains("flutter") ||
          p0.toString().contains("riverpod") ||
          p0.toString().contains("dart:ui"),
    );
  }

  /// Maps[DioException] into an [AppErrorCode]
  static AppErrorCode _mapDioError(DioException e) {
    // If the response comes with an error code we parse it
    var data = e.response?.data;
    var code = data is Map ? data['code'] : null;
    String? errorCode = code is String ? code : null;
    AppErrorCode? errorCodeEnum = AppErrorCode.values
        .where((element) => element.name == errorCode)
        .firstOrNull;

    if (errorCodeEnum != null) {
      return errorCodeEnum;
    }
    // If it does not, we parse the exception type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppErrorCode.DIO_CONNECTION_TIMEOUT;
      case DioExceptionType.sendTimeout:
        return AppErrorCode.DIO_SEND_TIMEOUT;
      case DioExceptionType.receiveTimeout:
        return AppErrorCode.DIO_RECEIVE_TIMEOUT;
      case DioExceptionType.badCertificate:
        return AppErrorCode.DIO_BAD_CERTIFICATE;
      case DioExceptionType.cancel:
        return AppErrorCode.DIO_REQUEST_CANCELLED;
      case DioExceptionType.connectionError:
        return AppErrorCode.DIO_CONNECTION_ERROR;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return switch (code) {
          400 => AppErrorCode.HTTP_BAD_REQUEST,
          401 => AppErrorCode.HTTP_UNAUTHORIZED,
          403 => AppErrorCode.HTTP_FORBIDDEN,
          404 => AppErrorCode.HTTP_NOT_FOUND,
          408 => AppErrorCode.HTTP_REQUEST_TIMEOUT,
          422 => AppErrorCode.HTTP_UNPROCESSABLE,
          429 => AppErrorCode.HTTP_TOO_MANY_REQUESTS,
          _ => AppErrorCode.HTTP_UNEXPECTED,
        };
      case DioExceptionType.unknown:
        return AppErrorCode.UNKNOWN;
      case DioExceptionType.transformTimeout:
        return AppErrorCode.DIO_TRANSFORM_TIMEOUT;
    }
  }

  static AppErrorCode _mapHttpError(HttpError e) {
    switch (e.statusCode) {
      case 400:
        return AppErrorCode.HTTP_BAD_REQUEST;
      case 401:
        return AppErrorCode.HTTP_UNAUTHORIZED;
      case 403:
        return AppErrorCode.HTTP_FORBIDDEN;
      case 404:
        return AppErrorCode.HTTP_NOT_FOUND;
      case 408:
        return AppErrorCode.HTTP_REQUEST_TIMEOUT;
      case 422:
        return AppErrorCode.HTTP_UNPROCESSABLE;
      case 429:
        return AppErrorCode.HTTP_TOO_MANY_REQUESTS;
      default:
        return AppErrorCode.HTTP_UNEXPECTED;
    }
  }
}
