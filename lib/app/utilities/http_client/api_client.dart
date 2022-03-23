import 'package:dio/dio.dart';

enum ApiMethod {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
}

class ApiClient {
  ApiClient._();

  static final int sendTimeout = 6 * 1000;
  static final int receiveTimeout = 6 * 1000;
  static final int connectTimeout = 6 * 1000;
  static final BaseOptions baseOptions = BaseOptions(
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
    connectTimeout: connectTimeout,
  );

  final dio = Dio(baseOptions)
    ..interceptors.add(InterceptorsWrapper(
      onError: _CustomInterceptors().onError,
      onResponse: _CustomInterceptors().onResponse,
      onRequest: _CustomInterceptors().onRequest,
    ));

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
      throw _handleError(err);
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

class _CustomInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}
