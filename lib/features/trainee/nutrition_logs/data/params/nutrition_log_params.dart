import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';

import '../model/nutrition_log_model.dart';

/// Body for `POST /my-nutrition-log/from-plan` — the server flattens the plan's
/// meals → items into log entries (foodId + quantity, ordered).
class NutritionLogFromPlanParams extends BaseParams {
  final String nutritionPlanId;

  /// ISO-8601 local date (the trainee's "today").
  final String date;
  final String? notes;

  NutritionLogFromPlanParams({
    required this.nutritionPlanId,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'nutritionPlanId': nutritionPlanId,
    'date': date,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };
}

/// Body for `PUT /my-nutrition-log/{id}` — a **full replace** of entries. Sends
/// only `foodId`/`order`/`quantity`/`notes`; macros are server-computed. [id]
/// targets the URL only.
class UpdateNutritionLogParams extends BaseParams {
  final String id;
  final String date;
  final String? notes;
  final List<NutritionLogEntryModel> entries;

  UpdateNutritionLogParams({
    required this.id,
    required this.date,
    this.notes,
    this.entries = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    'entries': [for (final e in entries) e.toWriteJson()],
  };
}

/// Paged list query for the trainee's OWN nutrition logs — a self-scoped mirror
/// of the coach `TrackingListInput` but with **NO `TraineeId`** (the backend
/// resolves the current trainee). Carries the boilerplate [GetListRequest]
/// (skip/take) plus an optional date range, mapped to the ABP param names in
/// [toJson]: `SkipCount` / `MaxResultCount` / `FromDate` / `ToDate` / `Sorting`.
/// This endpoint has **no** `Filter`/`SearchTerm`.
class MyNutritionLogListInput extends BaseParams {
  GetListRequest? request;
  String? fromDate;
  String? toDate;
  String? sorting;

  MyNutritionLogListInput({
    this.request,
    this.fromDate,
    this.toDate,
    this.sorting,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (fromDate != null && fromDate!.isNotEmpty) map['FromDate'] = fromDate;
    if (toDate != null && toDate!.isNotEmpty) map['ToDate'] = toDate;
    if (sorting != null && sorting!.isNotEmpty) map['Sorting'] = sorting;
    return map;
  }
}
