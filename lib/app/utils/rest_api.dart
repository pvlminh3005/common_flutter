import 'package:dio/dio.dart';

enum ApiMethod {
  GET,
  POST,
  PUT,
  PATCH,
}

class RestApiClient {
  static Future restApiClient({
    required String url,
    ApiMethod method = ApiMethod.GET,
    Options? options,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? receiveTimeout,
    int? sendTimeout,
  }) async {
    options ??= Options(
      method: method.name.toString(),
      responseType: ResponseType.json,
      contentType: 'application/x-www-form-urlencoded',
    );
    final dio = Dio();

    try {
      var response = await dio.request(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioError catch (err) {
      _handleError(err);
    }
  }

  static String _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        return "Request was cancelled";
      case DioErrorType.connectTimeout:
        return "Connection timeout";
      case DioErrorType.receiveTimeout:
        return "Receive timeout in connection";
      case DioErrorType.sendTimeout:
        return "Receive timeout in send request";
      case DioErrorType.response:
        return "Received invalid status code: ${error.response!.statusCode}";
      default:
        return "Request was cancelled";
    }
  }
}
