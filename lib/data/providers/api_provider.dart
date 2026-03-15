import "package:booking_app/services/api_exception.dart";
import "package:dio/dio.dart";

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;

  late Dio dio;

  ApiProvider._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://flight.wigian.in/",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Future<Response> get(String url, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(url, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.post(url, data: data, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String url, {dynamic data}) async {
    try {
      return await dio.put(url, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String url) async {
    try {
      return await dio.delete(url);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection timeout");

      case DioExceptionType.sendTimeout:
        return ApiException("Request timeout");

      case DioExceptionType.receiveTimeout:
        return ApiException("Server took too long to respond");

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        switch (statusCode) {
          case 400:
            return ApiException("Bad request", statusCode: statusCode);

          case 401:
            return ApiException("Unauthorized access", statusCode: statusCode);

          case 403:
            return ApiException("Forbidden", statusCode: statusCode);

          case 404:
            return ApiException("Resource not found", statusCode: statusCode);

          case 500:
            return ApiException(
              "Internal server error",
              statusCode: statusCode,
            );

          default:
            return ApiException(
              error.response?.data["message"] ?? "Something went wrong",
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return ApiException("Request cancelled");

      case DioExceptionType.unknown:
        return ApiException("No internet connection");

      default:
        return ApiException("Unexpected error occurred");
    }
  }
}
