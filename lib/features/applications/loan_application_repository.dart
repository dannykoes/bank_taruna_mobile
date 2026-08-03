import 'package:bank_taruna_mobile/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/providers.dart';
import 'loan_application.dart';

final loanApplicationRepositoryProvider =
    Provider<LoanApplicationRepository>((ref) {
  return LoanApplicationRepository(ref.watch(dioProvider));
});

class LoanApplicationRepository {
  const LoanApplicationRepository(this._dio);

  final Dio _dio;

  Future<void> submit(LoanApplication application) async {
    try {
      final response = await _dio.post<dynamic>(
        '${AppConstants.baseUrl}${ApiEndpoints.loanApplicationSubmit}',
        data: application.toFormData(),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint(
          'kirim pengajuan ${ApiEndpoints.loanApplicationSubmit} ${response.statusCode} ${response.data}');

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 400) {
        throw ApiException('Pengajuan belum berhasil dikirim.',
            statusCode: statusCode);
      }

      final contentType = response.headers.value('content-type') ?? '';
      if (contentType.contains('application/json')) {
        final data = response.data;
        if (data is Map &&
            (data['success'] == true || data['status'] == 'success')) return;
        if (statusCode == 200 || statusCode == 201) return;
      }

      // Safety guard: a web form route may return normal HTML without actually
      // accepting the mobile submission. Use a confirmed JSON endpoint for production.
      throw const ApiException(
          'Endpoint submit belum mengembalikan respons API JSON yang tervalidasi.');
    } on DioException catch (error) {
      final reason = error.error is ApiException
          ? (error.error as ApiException).message
          : error.message;
      throw ApiException(reason ?? 'Pengajuan belum berhasil dikirim.');
    }
  }
}
