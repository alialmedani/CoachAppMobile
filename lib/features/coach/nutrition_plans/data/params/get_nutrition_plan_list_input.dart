import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';

/// Query for the coach nutrition-plan list (ABP `GetNutritionPlanListInput`).
///
/// Carries the boilerplate [GetListRequest] (skip/take) plus the coaching
/// filters, and maps them to the ABP parameter names in [toJson]:
/// `SkipCount` / `MaxResultCount` / `Filter` / `TraineeId` / `IsActive` /
/// `Sorting`. Fields are non-final so the cubit can rebuild the query cheaply.
class GetNutritionPlanListInput extends BaseParams {
  GetListRequest? request;
  String? filter;
  String? traineeId;
  bool? isActive;
  String? sorting;

  GetNutritionPlanListInput({
    this.request,
    this.filter,
    this.traineeId,
    this.isActive,
    this.sorting,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (filter != null && filter!.isNotEmpty) map['Filter'] = filter;
    if (traineeId != null && traineeId!.isNotEmpty) {
      map['TraineeId'] = traineeId;
    }
    if (isActive != null) map['IsActive'] = isActive;
    if (sorting != null && sorting!.isNotEmpty) map['Sorting'] = sorting;
    return map;
  }
}
