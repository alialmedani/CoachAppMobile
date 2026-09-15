import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';

/// Shared list query for the coach tracking endpoints (logs / progress / notes).
/// Carries the boilerplate [GetListRequest] (skip/take) plus the required
/// `TraineeId` and optional date range, and maps them to the ABP param names in
/// [toJson]: `SkipCount` / `MaxResultCount` / `TraineeId` / `FromDate` /
/// `ToDate` / `Sorting`. These endpoints have **no** `Filter`/`SearchTerm`.
class TrackingListInput extends BaseParams {
  GetListRequest? request;
  String traineeId;
  String? fromDate;
  String? toDate;
  String? sorting;

  TrackingListInput({
    this.request,
    this.traineeId = '',
    this.fromDate,
    this.toDate,
    this.sorting,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (traineeId.isNotEmpty) map['TraineeId'] = traineeId;
    if (fromDate != null && fromDate!.isNotEmpty) map['FromDate'] = fromDate;
    if (toDate != null && toDate!.isNotEmpty) map['ToDate'] = toDate;
    if (sorting != null && sorting!.isNotEmpty) map['Sorting'] = sorting;
    return map;
  }
}
