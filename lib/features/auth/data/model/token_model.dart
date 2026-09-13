/// OAuth2 token response from `POST connect/token` (OpenIddict password /
/// refresh_token grants).
///
/// Shape: `{ access_token, token_type, expires_in, refresh_token? }`.
/// [refreshToken] is issued when the client is granted `offline_access` (now
/// seeded on `CoachApp_App`, so login returns one) and kept nullable defensively.
class TokenModel {
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final String? refreshToken;

  TokenModel({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
    };
  }

  TokenModel copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? refreshToken,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
