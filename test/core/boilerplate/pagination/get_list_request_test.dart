import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:flutter_test/flutter_test.dart';

/// The #1 backend-contract guard: list requests must serialize to ABP's
/// `SkipCount` / `MaxResultCount` / `SearchTerm` — never raw `skip`/`take`.
void main() {
  test('maps skip/take to SkipCount/MaxResultCount (ABP names)', () {
    final json = GetListRequest(skip: 20, take: 10).toJson();

    expect(json['SkipCount'], 20);
    expect(json['MaxResultCount'], 10);
    // raw field names must never reach the backend
    expect(json.containsKey('skip'), isFalse);
    expect(json.containsKey('take'), isFalse);
  });

  test('emits SearchTerm only when non-empty', () {
    expect(
      GetListRequest(skip: 0, take: 10, searchTerm: 'chicken').toJson()['SearchTerm'],
      'chicken',
    );
    expect(
      GetListRequest(skip: 0, take: 10, searchTerm: '').toJson().containsKey('SearchTerm'),
      isFalse,
    );
    expect(
      GetListRequest(skip: 0, take: 10).toJson().containsKey('SearchTerm'),
      isFalse,
    );
  });

  test('omits null paging fields entirely', () {
    final json = GetListRequest().toJson();
    expect(json.containsKey('SkipCount'), isFalse);
    expect(json.containsKey('MaxResultCount'), isFalse);
  });
}
