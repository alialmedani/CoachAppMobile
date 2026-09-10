import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:coachappmobile/core/constant/end_points/cashe_helper_constant.dart';
import 'package:coachappmobile/core/http/api_provider.dart';
import 'package:coachappmobile/core/http/http_method.dart';

import '../utils/functions/token_validator.dart';

abstract class RemoteDataSource {
  static Future<Either<String, Data>> request<Data>({
    Function(Map<String, dynamic>)? converter,
    Function(dynamic)? converter2,
    required HttpMethod method,
    required String url,
    File? file,
    File? secondFile,
    String? fileKey,
    String? secondFileKey,
    List<File>? files,
    List<File>? videoFiles,
    String? fileVideoKey,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    bool withAuthentication = false,
  }) async {
    final Map<String, String> headers = {};
    String? leftResponse;
    dynamic rightResponse;

    headers.putIfAbsent("Content-Type", () => 'application/json');
    headers.putIfAbsent(
      "Accept-Language",
      () => CacheHelper.lang == "ar" ? "ar" : "en",
    );
    headers.putIfAbsent("JasimTenant", () => CacheHelper.tenant);

    if (withAuthentication) {
      await checkToken();
      final String token = CacheHelper.token ?? "";
      debugPrint(token);
      if (token != "") {
        headers.putIfAbsent(headerAuth, () => 'Bearer $token');
      }
    }
    final response = await ApiProvider.sendObjectRequest(
      contentType: contentType,
      method: method,
      url: url,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
      file: file,
      fileKey: fileKey,
      secondFileKey: secondFileKey,
      secondFile: secondFile,
      imageFiles: files,
      fileVideoKey: fileVideoKey,
      videoFiles: videoFiles,
      converter2: converter2,
      converter: converter,
    );

    response.fold((l) => leftResponse = l, (r) => Right(rightResponse = r));
    if (response.isLeft()) {
      return Left(leftResponse ?? '');
    } else {
      return Right(rightResponse);
    }
  }

  static Future<Either<String, String>> noModelRequest({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    required bool withAuthentication,
  }) async {
    String? leftResponse;
    dynamic rightResponse;
    final Map<String, String> headers = {};
    headers.putIfAbsent(
      "Accept-Language",
      () => CacheHelper.lang == "ar" ? "ar" : "en",
    );
    if (withAuthentication) {
      String token = CacheHelper.token!;
      headers.putIfAbsent(headerAuth, () => 'Bearer $token');
    }

    final response = await ApiProvider.sendObjectWithOutResponseRequest(
      method: method,
      url: url,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
    );

    response.fold((l) => leftResponse = l, (r) => rightResponse = r);

    if (response.isLeft()) {
      return Left(leftResponse ?? '');
    } else {
      return Right(rightResponse ?? 'Request successful with no response body');
    }
  }
}
