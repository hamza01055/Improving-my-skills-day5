import 'package:dio/dio.dart';

/// A single exception type surfaced to the UI, with a human-readable message.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Connection timed out. Check your network.');
      case DioExceptionType.connectionError:
        return const ApiException('Cannot reach the server. Is it running?');
      case DioExceptionType.badResponse:
        final int? code = e.response?.statusCode;
        final dynamic detail = e.response?.data is Map
            ? (e.response!.data as Map)['detail']
            : null;
        return ApiException(
          detail is String ? detail : 'Request failed ($code)',
          statusCode: code,
        );
      default:
        return const ApiException('Something went wrong. Try again.');
    }
  }

  @override
  String toString() => message;
}
