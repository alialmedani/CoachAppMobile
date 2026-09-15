import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the release API-host safety predicate (P19/M4): a release build must
/// not ship a loopback/dev host or a non-HTTPS URL.
void main() {
  test('flags loopback / dev hosts as insecure for release', () {
    expect(isInsecureReleaseBaseUrl('https://10.0.2.2:44370/'), isTrue);
    expect(isInsecureReleaseBaseUrl('https://localhost:44370/'), isTrue);
    expect(isInsecureReleaseBaseUrl('https://127.0.0.1:44370/'), isTrue);
  });

  test('flags non-HTTPS URLs as insecure', () {
    expect(isInsecureReleaseBaseUrl('http://api.coachapp.example/'), isTrue);
  });

  test('accepts a real HTTPS production host', () {
    expect(isInsecureReleaseBaseUrl('https://api.coachapp.example/'), isFalse);
    expect(isInsecureReleaseBaseUrl('https://coachapp.io/'), isFalse);
  });
}
