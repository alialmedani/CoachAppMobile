import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_roles.dart';
import 'package:coachappmobile/features/auth/data/model/session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionModel.isCoach (F20 — any Coach.* capability)', () {
    test('true for the explicit Coach role', () {
      expect(SessionModel(roles: [CoachAppRoles.coach]).isCoach, isTrue);
    });

    test('true for the tenant admin role', () {
      expect(SessionModel(roles: [CoachAppRoles.admin]).isCoach, isTrue);
    });

    test('true for a custom coach granted a Coach.* policy OTHER than Trainees', () {
      // Regression for F20: previously only the Trainees permission (or Coach/admin role) counted,
      // so a plans-only custom coach dropped to the logout-only placeholder.
      final s = SessionModel(
        roles: const ['GymCoach'],
        grantedPolicies: const {CoachPermissions.workoutPlans: true},
      );
      expect(s.isCoach, isTrue);
    });

    test('false for a trainee-only session (Trainee.* grants are not Coach)', () {
      final s = SessionModel(
        roles: const [CoachAppRoles.trainee],
        grantedPolicies: const {TraineePermissions.myToday: true},
      );
      expect(s.isCoach, isFalse);
      expect(s.isTrainee, isTrue);
    });

    test('a DENIED Coach policy (false value) does not make a coach', () {
      final s = SessionModel(
        roles: const [],
        grantedPolicies: const {CoachPermissions.notes: false},
      );
      expect(s.isCoach, isFalse);
    });
  });
}
