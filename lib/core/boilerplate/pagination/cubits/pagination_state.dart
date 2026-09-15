part of 'pagination_cubit.dart';

abstract class PaginationState {}

class PaginationInitial extends PaginationState {}

class Loading extends PaginationState {}

class GetListSuccessfully extends PaginationState {
  final List list;
  final bool noMoreData;

  GetListSuccessfully({required this.list, required this.noMoreData});
}

/// Initial-load (first page) failure — the list is empty, so the whole area
/// shows the error + retry.
class Error extends PaginationState {
  final String message;
  Error(this.message);
}

/// A *load-more* (next page) failure. The already-loaded [list] stays on screen
/// (never torn down to a full-screen error); the footer surfaces the failure
/// with a retry. Distinct from [Error] so the two are handled differently.
class LoadMoreError extends PaginationState {
  final String message;
  final List list;
  LoadMoreError(this.message, this.list);
}
