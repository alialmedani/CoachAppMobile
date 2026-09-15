import 'package:coachappmobile/features/auth/data/model/token_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [TokenModel] — the OAuth2 `connect/token` response. The wire
/// keys are snake_case (`access_token`, `token_type`, `expires_in`,
/// `refresh_token`); refresh_token is optional and kept nullable.
void main() {
  test('fromJson reads snake_case OAuth keys', () {
    final t = TokenModel.fromJson({
      'access_token': 'abc.def.ghi',
      'token_type': 'Bearer',
      'expires_in': 3600,
      'refresh_token': 'r-123',
    });

    expect(t.accessToken, 'abc.def.ghi');
    expect(t.tokenType, 'Bearer');
    expect(t.expiresIn, 3600);
    expect(t.refreshToken, 'r-123');
  });

  test('tolerates a response without a refresh_token', () {
    final t = TokenModel.fromJson({
      'access_token': 'abc',
      'token_type': 'Bearer',
      'expires_in': 3600,
    });
    expect(t.refreshToken, isNull);
    expect(t.accessToken, 'abc');
  });

  test('toJson emits snake_case keys', () {
    final json = TokenModel(
      accessToken: 'abc',
      tokenType: 'Bearer',
      expiresIn: 3600,
      refreshToken: 'r-1',
    ).toJson();

    expect(json['access_token'], 'abc');
    expect(json['token_type'], 'Bearer');
    expect(json['expires_in'], 3600);
    expect(json['refresh_token'], 'r-1');
  });

  test('round-trips through JSON', () {
    final original = TokenModel(
      accessToken: 'tok',
      tokenType: 'Bearer',
      expiresIn: 7200,
      refreshToken: 'ref',
    );
    final restored = TokenModel.fromJson(original.toJson());

    expect(restored.accessToken, original.accessToken);
    expect(restored.tokenType, original.tokenType);
    expect(restored.expiresIn, original.expiresIn);
    expect(restored.refreshToken, original.refreshToken);
  });

  test('copyWith overrides only the given field', () {
    final base = TokenModel(accessToken: 'a', refreshToken: 'r');
    final copy = base.copyWith(accessToken: 'b');
    expect(copy.accessToken, 'b');
    expect(copy.refreshToken, 'r');
    expect(base.accessToken, 'a');
  });
}
