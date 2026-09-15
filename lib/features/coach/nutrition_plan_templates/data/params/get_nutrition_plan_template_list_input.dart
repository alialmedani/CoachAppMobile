import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';

/// Query for the coach nutrition-plan-template list
/// (`GetNutritionPlanTemplateListInput`, a `PagedAndSortedResultRequestDto`).
///
/// Templates are trainee-less blueprints, so — unlike the plan list — there is
/// **no `TraineeId`/`IsActive`**: only paging, a name [filter] and [sorting].
/// Carries the boilerplate [GetListRequest] (skip/take) and maps to the ABP
/// parameter names in [toJson]: `SkipCount` / `MaxResultCount` / `Filter` /
/// `Sorting`. Fields are non-final so the cubit can rebuild the query cheaply.
class GetNutritionPlanTemplateListInput extends BaseParams {
  GetListRequest? request;
  String? filter;
  String? sorting;

  GetNutritionPlanTemplateListInput({this.request, this.filter, this.sorting});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (filter != null && filter!.isNotEmpty) map['Filter'] = filter;
    if (sorting != null && sorting!.isNotEmpty) map['Sorting'] = sorting;
    return map;
  }
}
