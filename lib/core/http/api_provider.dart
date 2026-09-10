import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'dio_error_handle.dart';
import 'http_method.dart';

class ApiProvider {
  static var options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  );
  static final Dio dio = Dio(options)
    ..httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Only allow self-signed certificates in debug mode
        if (kDebugMode) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        }
        return client;
      },
    );

  static Future<Either<String, T>> sendObjectRequest<T>({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? data,
    Function(Map<String, dynamic>)? converter,
    Function(dynamic)? converter2,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    File? file,
    File? secondFile,
    List<File>? imageFiles,
    List<File>? videoFiles,
    String? fileVideoKey,
    String? fileKey,
    String? secondFileKey,
    String? contentType,
  }) async {
    final Map<String, dynamic> dataMap = {};
    Response? response;
    try {
      if (data != null) {
        dataMap.addAll(data);
      }
      if (file != null) {
        if (fileKey != null && fileKey != '') {
          String fileName = file.path.split("/").last;
          debugPrint('fileNamexxxx in file');
          debugPrint(fileName);
          late MultipartFile multipartFile;
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );
          dataMap.addAll({fileKey: multipartFile});
        }
      }
      if (secondFile != null) {
        if (secondFileKey != null && secondFileKey != '') {
          String fileName = secondFile.path.split("/").last;
          debugPrint('fileNamexxxx in secondFile');
          debugPrint(fileName);
          late MultipartFile multipartFile;
          multipartFile = await MultipartFile.fromFile(
            secondFile.path,
            filename: fileName,
          );
          dataMap.addAll({secondFileKey: multipartFile});
        }
      }

      if (imageFiles != null &&
          imageFiles.isNotEmpty &&
          fileKey != null &&
          fileKey.isNotEmpty) {
        List<MultipartFile> multipartFiles = [];

        for (var element in imageFiles) {
          String fileName = element.path.split("/").last;
          debugPrint('fileNamexxxx in imageFiles');
          debugPrint(fileName);
          multipartFiles.add(
            await MultipartFile.fromFile(element.path, filename: fileName),
          );
        }

        dataMap[fileKey] = multipartFiles;
      }

      if (videoFiles != null && videoFiles.isNotEmpty) {
        debugPrint('fileNamexxxx in videoooos');
        List<MultipartFile> multipartFiles = [];
        for (var element in videoFiles) {
          String fileName = element.path.split("/").last;
          debugPrint('fileNamexxxxvideoooos');
          debugPrint(videoFiles.first.path);
          multipartFiles.add(
            await MultipartFile.fromFile(element.path, filename: fileName),
          );
        }
        dataMap.addAll({fileVideoKey!: multipartFiles});
      }
      debugPrint('[$method: $url] data : [$data]');
      debugPrint('queryParameters : [$queryParameters]');

      dio.options.headers = headers;
      if (kDebugMode) {
        dio.interceptors.add(
          PrettyDioLogger(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );
      }
      switch (method) {
        case HttpMethod.GET:
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case HttpMethod.POST:
          final useFormData = fileKey != null && fileKey.isNotEmpty;
          final postData = useFormData ? FormData.fromMap(dataMap) : dataMap;

          response = await dio.post(
            url,
            data: postData,
            queryParameters: queryParameters ?? {},
            options: Options(
              contentType: useFormData ? 'multipart/form-data' : contentType,
            ),

            onSendProgress: (int sent, int total) {
              debugPrint(
                'progress: ${(sent / total * 100).toStringAsFixed(0)}% ($sent/$total)',
              );
            },
          );
          break;

        case HttpMethod.PUT:
          final hasFiles =
              file != null ||
              secondFile != null ||
              imageFiles != null && imageFiles.isNotEmpty ||
              videoFiles != null && videoFiles.isNotEmpty;

          final putData = hasFiles ? FormData.fromMap(dataMap) : dataMap;

          response = await dio.put(
            url,
            data: putData,
            queryParameters: queryParameters,
            options: Options(
              contentType: hasFiles
                  ? 'multipart/form-data'
                  : 'application/json',
            ),
          );
          break;

        case HttpMethod.DELETE:
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
      }
      dynamic decodedJson;

      if (response.data is String) {
        decodedJson = json.decode(response.data);
      } else {
        decodedJson = response.data;
      }

      if ((response.statusCode)! > 199 && (response.statusCode)! < 300) {
        if (decodedJson != null) {
          if (converter2 != null) {
            return Right(converter2(decodedJson));
          } else {
            return Right(converter!(decodedJson));
          }
        } else {
          return Left(response.data['message']);
        }
      } else {
        return Left(response.data['message']);
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map<String, dynamic>) {
        // Check for force password change scenario
        if (errorData['error_description'] ==
            'ShouldChangePasswordOnNextLogin') {
          final userId = errorData['userId'];
          // Return special format with userId only
          return Left('FORCE_PASSWORD_CHANGE|$userId');
        }

        // Check if error is a Map (for validation errors)
        final error = errorData['error'];
        if (error is Map<String, dynamic>) {
          final validationErrors = error['validationErrors'];
          if (validationErrors != null &&
              validationErrors is List &&
              validationErrors.isNotEmpty) {
            final validationMessages = validationErrors
                .map((e) => e['message'] ?? 'Unknown error')
                .join('\n');
            return Left(validationMessages);
          }

          final errorMessage = error['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }

        // If error is a string (like "invalid_grant"), prefer the human-readable
        // error_description (already localized by the backend, e.g. the Arabic
        // "account locked" message). Trimmed because OpenIddict can pad it with
        // trailing whitespace/newlines.
        if (error is String) {
          final errorDescription = errorData['error_description'];
          if (errorDescription is String &&
              errorDescription.trim().isNotEmpty) {
            return Left(errorDescription.trim());
          }
          return Left(error);
        }

        // Some endpoints return a top-level message / error_description string.
        final topMessage =
            errorData['error_description'] ?? errorData['message'];
        if (topMessage is String && topMessage.trim().isNotEmpty) {
          return Left(topMessage.trim());
        }

        return Left('An error occurred');
      }

      Map dioError = DioErrorsHandler.onError(e);
      return Left(dioError.toString());
    } on SocketException catch (e, stacktrace) {
      if (kDebugMode) {
        debugPrint('SocketException');
        print(e);
        print(stacktrace);
      }
      return const Left('please check your connection');
    }
  }

  static Future<Either<String, String>> sendObjectWithOutResponseRequest<T>({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      debugPrint('[$method: $url] data : $data');
      debugPrint('queryParameters : [$queryParameters]');
      dio.options.headers = headers;

      Response response;
      switch (method) {
        case HttpMethod.GET:
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case HttpMethod.POST:
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters ?? {},
          );
          break;
        case HttpMethod.PUT:
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.DELETE:
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data == null || response.data.toString().isEmpty) {
          return const Right('Request successful, but no response body');
        }

        dynamic decodedJson;
        if (response.data is String) {
          decodedJson = json.decode(response.data);
        } else {
          decodedJson = response.data;
        }

        return Right(decodedJson);
      } else {
        return Left(response.data?.toString() ?? 'Unexpected error');
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map<String, dynamic>) {
        // Check if error is a Map (for validation errors)
        final error = errorData['error'];
        if (error is Map<String, dynamic>) {
          final validationErrors = error['validationErrors'];
          if (validationErrors != null &&
              validationErrors is List &&
              validationErrors.isNotEmpty) {
            final validationMessages = validationErrors
                .map((e) => e['message'] ?? 'Unknown error')
                .join('\n');
            return Left(validationMessages);
          }

          final errorMessage = error['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }

        // If error is a string
        if (error is String) {
          final errorDescription = errorData['error_description'];
          if (errorDescription is String) {
            return Left(errorDescription);
          }
          return Left(error);
        }

        return Left('An error occurred');
      }

      Map dioError = DioErrorsHandler.onError(e);
      debugPrint('DioException: $e');
      return Left(dioError.toString());
    } on SocketException catch (e, stacktrace) {
      debugPrint('SocketException: $e\n$stacktrace');
      return const Left('Please check your connection');
    }
  }

  static void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }
}
