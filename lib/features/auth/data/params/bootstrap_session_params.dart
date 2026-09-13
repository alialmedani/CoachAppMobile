import 'package:coachappmobile/core/params/base_params.dart';

/// Params for the session bootstrap (`GET api/abp/application-configuration`).
///
/// The request carries no query fields — the bearer token + `__tenant` header
/// (added automatically by `RemoteDataSource`) are all ABP needs — so [toJson]
/// is empty. The class exists to satisfy the `UseCase<T, Params>` contract.
class BootstrapSessionParams extends BaseParams {
  BootstrapSessionParams();

  Map<String, dynamic> toJson() => <String, dynamic>{};
}
