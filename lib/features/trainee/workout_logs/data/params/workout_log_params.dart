import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';

import '../model/workout_log_model.dart';

/// Body for `POST /my-workout-log/from-day` — seeds a log from a plan day; the
/// server snapshots the prescribed exercises and seeds the initial actuals.
class WorkoutLogFromDayParams extends BaseParams {
  final String workoutDayId;

  /// ISO-8601 local date (the trainee's "today").
  final String date;
  final String? notes;

  WorkoutLogFromDayParams({
    required this.workoutDayId,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'workoutDayId': workoutDayId,
    'date': date,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };
}

/// Body for `PUT /my-workout-log/{id}` — a **full replace** of entries with the
/// trainee's ACTUAL performance. Never emits `prescribed*`; each entry keeps its
/// original `exerciseId`/`order` so the server re-matches the prescribed
/// snapshot. [id] targets the URL only (not part of the body).
class UpdateWorkoutLogParams extends BaseParams {
  final String id;
  final String date;
  final String? notes;
  final List<WorkoutLogEntryModel> entries;

  UpdateWorkoutLogParams({
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

/// Paged list query for the trainee's OWN workout logs — a self-scoped mirror
/// of the coach `TrackingListInput` but with **NO `TraineeId`** (the backend
/// resolves the current trainee). Carries the boilerplate [GetListRequest]
/// (skip/take) plus an optional date range, mapped to the ABP param names in
/// [toJson]: `SkipCount` / `MaxResultCount` / `FromDate` / `ToDate` / `Sorting`.
/// This endpoint has **no** `Filter`/`SearchTerm`.
class MyWorkoutLogListInput extends BaseParams {
  GetListRequest? request;
  String? fromDate;
  String? toDate;
  String? sorting;

  MyWorkoutLogListInput({this.request, this.fromDate, this.toDate, this.sorting});

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
