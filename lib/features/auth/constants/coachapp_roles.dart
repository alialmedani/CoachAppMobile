/// Dart mirror of the CoachApp backend role names.
///
/// The exact strings come from the ABP identity roles seeded for the CoachApp
/// tenant. They are compared against `currentUser.roles` returned by
/// `api/abp/application-configuration`.
///
/// Source of truth: C:\src\BACK\CoachApp (Coach = management persona,
/// Trainee = self-service persona).
class CoachAppRoles {
  CoachAppRoles._();

  /// Management persona (coach).
  static const String coach = 'Coach';

  /// Self-service persona (the signed-in trainee).
  static const String trainee = 'Trainee';

  /// ABP built-in tenant admin. The demo tenant's `admin` user carries this
  /// role (not `Coach`) while holding every `CoachApp.Coach.*` permission, so
  /// the gym owner / tenant admin is treated as a Coach for routing.
  static const String admin = 'admin';
}
