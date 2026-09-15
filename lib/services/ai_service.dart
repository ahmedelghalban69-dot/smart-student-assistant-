import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class AiService {
  const AiService();

  Future<String> generate({
    required String prompt,
    String mode = 'assistant',
  }) async {
    final endpoint = AppConfig.aiEndpoint.trim();
    if (endpoint.isEmpty) {
      throw const AiConfigurationException(
        'لم يتم ربط التطبيق بخادم الذكاء الاصطناعي. اضبط AI_ENDPOINT عند بناء التطبيق.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt.trim(), 'mode': mode}),
          )
          .timeout(const Duration(seconds: 40));

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data?['message']?.toString() ??
            data?['error']?.toString() ??
            'تعذر الاتصال بخادم الذكاء الاصطناعي (${response.statusCode}).';
        throw AiRequestException(message);
      }

      final text = data?['text']?.toString().trim();
      if (text == null || text.isEmpty) {
        throw const AiRequestException('وصل رد من الخادم بدون نص قابل للعرض.');
      }
      return text;
    } on AiServiceException {
      rethrow;
    } on Exception catch (e) {
      throw AiRequestException('تعذر الاتصال بخدمة الذكاء الاصطناعي: $e');
    }
  }
}

abstract class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);

  @override
  String toString() => message;
}

class AiConfigurationException extends AiServiceException {
  const AiConfigurationException(super.message);
}

class AiRequestException extends AiServiceException {
  const AiRequestException(super.message);
}
