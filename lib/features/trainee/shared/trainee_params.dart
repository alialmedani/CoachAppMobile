import 'package:coachappmobile/core/params/base_params.dart';

/// Empty params for no-argument trainee read endpoints (the unpaged "my"
/// list calls take no query args).
class NoParams extends BaseParams {}

/// Single-id params for trainee "get my X by id" endpoints.
class ByIdParams extends BaseParams {
  final String id;

  ByIdParams({required this.id});
}
