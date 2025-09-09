import 'package:dio/dio.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class ApiClient {
  final Dio dio;
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  ApiClient() : dio = Dio() {
    dio.addObsly();
  }

  Future<T> get<T>(String endpoint) async {
    try {
      final response = await dio.get('$baseUrl$endpoint');
      if (response.data == null) {
        throw Exception('No data received from API');
      }
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return Exception('Server error ($statusCode). Please try again later.');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('Network error occurred. Please try again.');
    }
  }

  Future<Response<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await dio.post<T>('$baseUrl$endpoint', data: data);
  }
}

final apiClient = ApiClient();
