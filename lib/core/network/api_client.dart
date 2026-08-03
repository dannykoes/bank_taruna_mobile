import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';

class ApiClient {
  const ApiClient._();

  static Dio createDio({String baseUrl = AppConstants.baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json, text/html;q=0.9',
          'User-Agent': 'BankTarunaMobile/1.0 Flutter',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final response = error.response;
          final message = _messageFromError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: response,
              error: ApiException(message, statusCode: response?.statusCode),
              type: error.type,
            ),
          );
        },
      ),
    );

    return dio;
  }

  static String _messageFromError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi terlalu lama. Periksa internet lalu coba lagi.';
      case DioExceptionType.badResponse:
        return 'Server mengembalikan respons ${error.response?.statusCode ?? '-'}.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server Bank Taruna.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat koneksi tidak valid.';
      case DioExceptionType.unknown:
        return 'Terjadi gangguan jaringan.';
    }
  }
}
