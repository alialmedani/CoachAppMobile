class Result<Data> {
  Result({this.data, this.error}) : assert(data != null || error != null);
  final Data? data;
  final String? error;

  bool get hasDataOnly => data != null && error == null;

  bool get hasErrorOnly => data == null;

  bool get hasDataAndError => data != null;
}

class RemoteResult<Data> extends Result<Data> {
  RemoteResult({super.data, super.error});
}

class PaginatedResult<Data> extends Result<List<Data>> {
  PaginatedResult({super.data, super.error});
}
