import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_roles.dart';

/// Parsed session bootstrap from `GET api/abp/application-configuration`.
///
/// Standard ABP shape (only the parts CoachApp needs):
/// ```json
/// {
///   "currentUser":  { "id", "userName", "email", "tenantId", "roles": [...] },
///   "auth":         { "grantedPolicies": { "CoachApp.Coach.Trainees": true } },
///   "currentTenant":{ "id", "name", "isAvailable" }
/// }
/// ```
class SessionModel {
  final String? userId;
  final String? userName;
  final String? email;
  final String? tenantId;
  final List<String> roles;
  final Map<String, bool> grantedPolicies;
  final String? tenantName;
  final bool tenantAvailable;

  SessionModel({
    this.userId,
    this.userName,
    this.email,
    this.tenantId,
    this.roles = const [],
    this.grantedPolicies = const {},
    this.tenantName,
    this.tenantAvailable = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final currentUser =
        (json['currentUser'] as Map<String, dynamic>?) ?? const {};
    final auth = (json['auth'] as Map<String, dynamic>?) ?? const {};
    final grantedRaw =
        (auth['grantedPolicies'] as Map<String, dynamic>?) ?? const {};
    final currentTenant =
        (json['currentTenant'] as Map<String, dynamic>?) ?? const {};
    final rolesRaw = (currentUser['roles'] as List<dynamic>?) ?? const [];

    return SessionModel(
      userId: currentUser['id']?.toString(),
      userName: currentUser['userName'],
      email: currentUser['email'],
      tenantId: currentUser['tenantId']?.toString(),
      roles: rolesRaw.map((e) => e.toString()).toList(),
      grantedPolicies: grantedRaw.map(
        (key, value) => MapEntry(key, value == true),
      ),
      tenantName: currentTenant['name'],
      tenantAvailable: currentTenant['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUser': {
        'id': userId,
        'userName': userName,
        'email': email,
        'tenantId': tenantId,
        'roles': roles,
      },
      'auth': {'grantedPolicies': grantedPolicies},
      'currentTenant': {
        'name': tenantName,
        'isAvailable': tenantAvailable,
      },
    };
  }

  /// True for the management persona. Covers the explicit `Coach` role, the
  /// tenant `admin` (gym owner — carries all Coach permissions but not the
  /// `Coach` role string), and — per F20 — ANY account granted any
  /// `CoachApp.Coach.*` capability (not just the Trainees permission), so a
  /// custom coach profile still routes to the coach shell.
  bool get isCoach =>
      roles.contains(CoachAppRoles.coach) ||
      roles.contains(CoachAppRoles.admin) ||
      grantedPolicies.entries.any(
        (e) => e.value == true && e.key.startsWith(CoachPermissions.coachPrefix),
      );

  /// True for the self-service persona: the explicit `Trainee` role or an
  /// account granted the trainee "today" capability.
  bool get isTrainee =>
      roles.contains(CoachAppRoles.trainee) ||
      can(TraineePermissions.myToday);

  /// Whether an ABP permission policy is granted for this session.
  bool can(String policy) => grantedPolicies[policy] == true;

  SessionModel copyWith({
    String? userId,
    String? userName,
    String? email,
    String? tenantId,
    List<String>? roles,
    Map<String, bool>? grantedPolicies,
    String? tenantName,
    bool? tenantAvailable,
  }) {
    return SessionModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      tenantId: tenantId ?? this.tenantId,
      roles: roles ?? this.roles,
      grantedPolicies: grantedPolicies ?? this.grantedPolicies,
      tenantName: tenantName ?? this.tenantName,
      tenantAvailable: tenantAvailable ?? this.tenantAvailable,
    );
  }
}
