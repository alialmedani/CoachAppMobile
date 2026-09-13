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

    // Default to JSON, but honour an explicit [contentType] (e.g.
    // `application/x-www-form-urlencoded` for the OpenIddict token endpoint).
    // Setting the header to match the per-request contentType keeps Dio's
    // "content-type header vs contentType param" assertion happy and lets Dio
    // url-encode the data Map for form posts; JSON callers are unaffected.
    headers.putIfAbsent("Content-Type", () => contentType ?? 'application/json');
    headers.putIfAbsent(
      "Accept-Language",
      () => CacheHelper.lang == "ar" ? "ar" : "en",
    );
    // Stock ABP resolves the tenant (the "gym/coach code") from the __tenant
    // header. Only send it when one is stored, so host-level (no-tenant)
    // requests stay untenanted.
    if (CacheHelper.tenant.isNotEmpty) {
      headers.putIfAbsent("__tenant", () => CacheHelper.tenant);
    }

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
      // Mirror request<T>: refresh a just-expired token and never force-unwrap
      // (checkToken may clear it on failure), so delete / reset-password /
      // change-password get the same silent-refresh + safe-token handling.
      await checkToken();
      final String token = CacheHelper.token ?? "";
      if (token.isNotEmpty) {
        headers.putIfAbsent(headerAuth, () => 'Bearer $token');
      }
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
