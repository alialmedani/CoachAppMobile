// CoachApp backend endpoints.
//
// Base URL is flavor-driven: pass `--dart-define=API_BASE_URL=...` for
// dev / staging / prod. The default targets the local ABP host from an
// Android emulator (10.0.2.2 maps to the host machine's localhost:44370).
//
//   iOS simulator:   --dart-define=API_BASE_URL=https://localhost:44370/
//   physical device: --dart-define=API_BASE_URL=https://<lan-ip-or-tunnel>/
//
// The trailing slash is required — the constants below concatenate onto it.
//
// ABP conventional REST lives under /api/app/<entity-kebab>/<method-kebab>.
// Feature endpoints are added here per vertical slice as each phase is built
// (see the master roadmap). Keep this file the single source of URLs — never
// hardcode a URL in a repository.
const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://10.0.2.2:44370/',
);

/// True when [url] is unsafe to ship in a **release** build: a loopback/dev host
/// (the emulator/localhost default) or non-HTTPS. `main()` fails fast in release
/// if this holds, so a release built without `--dart-define=API_BASE_URL=<prod>`
/// cannot silently point at a dev server. Debug/profile builds are unaffected.
bool isInsecureReleaseBaseUrl(String url) {
  final u = url.toLowerCase();
  final loopback =
      u.contains('10.0.2.2') ||
      u.contains('localhost') ||
      u.contains('127.0.0.1');
  return loopback || !u.startsWith('https://');
}

/// Real-time hub base (SignalR) reuses [baseUrl].
var baseImageUrl = "${baseUrl}api/app/document/by-master/";

/////// auth & session (Phase 1) ////////
// OpenIddict password/refresh grant. The CoachApp_App public client has the
// refresh_token grant + the `offline_access` scope seeded, so login returns a
// refresh token; the scope string must include `offline_access` to receive it.
const loginUrl = '${baseUrl}connect/token';

// ABP session bootstrap: currentUser (id, roles, tenantId), grantedPolicies,
// currentTenant. Drives role + permission derivation.
const appConfigUrl = '${baseUrl}api/abp/application-configuration';

// Optional server-owned localization (enum/error/permission labels — Phase 17).
const appLocalizationUrl = '${baseUrl}api/abp/application-localization';

/////// account (self-service) ////////
// Change own password (surfaces in Profile for both roles — Phase 16).
const changePasswordUrl = '${baseUrl}api/account/my-profile/change-password';

/////// documents (ABP generic — used by core documents service) ////////
const deleteDocumentUrl = '${baseUrl}api/app/document';
const uploadCuurentUserDocumentUrl =
    '${baseUrl}api/app/document/upload-many/current_user';
const uploadManyDocumentUrl = '${baseUrl}api/app/document/upload-many';
const uploadOneDocumentUrl = '${baseUrl}api/app/document/upload';

/////// coaching feature endpoints ////////
// ABP conventional REST — mirror the real DTO/route from C:\src\BACK\CoachApp
// before adding each one.

// Coach — trainee management. reset-password is a custom action:
// POST {traineeUrl}/{id}/reset-password
const traineeUrl = '${baseUrl}api/app/trainee';

// Coach — exercise library.
const exerciseUrl = '${baseUrl}api/app/exercise';

// Coach — food library.
const foodUrl = '${baseUrl}api/app/food';

// Coach — workout plans (nested plan → days → exercises). set-active is a
// custom action: POST {workoutPlanUrl}/{id}/set-active
const workoutPlanUrl = '${baseUrl}api/app/workout-plan';

// Coach — nutrition plans (nested plan → meals → items, with enriched macros
// and server-computed totals). set-active is a custom action:
// POST {nutritionPlanUrl}/{id}/set-active
const nutritionPlanUrl = '${baseUrl}api/app/nutrition-plan';

// Coach — plan templates (Phase 9). Reusable, trainee-less blueprints sharing
// the plan day/exercise (meal/item) tree. List is PAGED (SkipCount/
// MaxResultCount/Filter/Sorting — no TraineeId/IsActive). Two custom actions:
//   POST {url}/{id}/clone-to-trainee  → a new INACTIVE real plan for a trainee
//   POST {url}/save-as-template       → snapshot an existing plan into a template
const workoutPlanTemplateUrl = '${baseUrl}api/app/workout-plan-template';
const nutritionPlanTemplateUrl = '${baseUrl}api/app/nutrition-plan-template';

/////// trainee — my plans (Phase 12) ////////
// Trainee-scoped, read-only. GetList returns an UNPAGED top-level array of
// summaries (days/meals empty); `/{id}` returns the full enriched tree. Same
// WorkoutPlanDto/NutritionPlanDto shapes as the coach endpoints, so the models
// are reused. (The `/active` variants are deferred — list summaries carry
// isActive and Today embeds the active plan, so they aren't needed yet.)
const myWorkoutPlanUrl = '${baseUrl}api/app/my-workout-plan';
const myNutritionPlanUrl = '${baseUrl}api/app/my-nutrition-plan';

/////// trainee — today (Phase 13) ////////
// GET with `?Date=yyyy-MM-dd` (the trainee's LOCAL date, so "today" respects
// their timezone). Returns MyTodayDto (always non-null).
const myTodayUrl = '${baseUrl}api/app/my-today';

/////// trainee — logging (Phases 14–15) ////////
// Workout logs. GET list is paged (SkipCount/MaxResultCount/Sorting +
// FromDate/ToDate — no Filter/SearchTerm). `/from-day` seeds a log from a plan
// day (server snapshots prescribed + seeds actuals). PUT sends ACTUAL fields
// only; the server preserves the prescribed snapshot keyed by (exerciseId,order).
const myWorkoutLogUrl = '${baseUrl}api/app/my-workout-log';
const myWorkoutLogFromDayUrl = '${baseUrl}api/app/my-workout-log/from-day';

// Nutrition logs. `/from-plan` flattens the plan's meals→items into entries.
// Macros are server-computed (read-only); the client sends only foodId/order/
// quantity/notes.
const myNutritionLogUrl = '${baseUrl}api/app/my-nutrition-log';
const myNutritionLogFromPlanUrl = '${baseUrl}api/app/my-nutrition-log/from-plan';

/////// coach — tracking (Phase 11) ////////
// Coach dashboard analytics for a trainee (read-only). Query: TraineeId + Date
// (adherence, single day) / FromDate + ToDate (completion, range).
const traineeDashboardSummaryUrl = '${baseUrl}api/app/trainee-dashboard/summary';

// Coach — read a trainee's logs (read-only: GetList + Get/{id}). GetList query:
// TraineeId (req), FromDate?, ToDate?, paging. NOTE: list rows are headers only
// — entries/totals populate only via /{id}. Distinct from the trainee my-* logs.
const coachWorkoutLogUrl = '${baseUrl}api/app/workout-log';
const coachNutritionLogUrl = '${baseUrl}api/app/nutrition-log';

// Coach — progress entries (full CRUD; Create/Update/Delete each gated).
// GetList query: TraineeId (req), FromDate?, ToDate?, paging (default Date desc).
const progressEntryUrl = '${baseUrl}api/app/progress-entry';

// Coach — trainee notes (full CRUD). GetList query: TraineeId (req) + paging
// only (no date filter).
const traineeNoteUrl = '${baseUrl}api/app/trainee-note';

/////// trainee — self-service (Phase 16) ////////
// Trainee's OWN dashboard (analytics). No TraineeId — derived from the caller.
// summary: Date+FromDate+ToDate. Returns the same TraineeDashboardDto as coach.
const myDashboardSummaryUrl = '${baseUrl}api/app/my-dashboard/summary';

// Trainee's own progress: Create / List / Get / Delete — **no Update**. The
// create body OMITS traineeId. List: paging + FromDate?/ToDate? (default Date desc).
const myProgressUrl = '${baseUrl}api/app/my-progress';

// Trainee reads coach notes (read-only: List + Get/{id}). NOTE **singular** route
// `my-note` (the permission is MyNotes). List: paging + Sorting only.
const myNoteUrl = '${baseUrl}api/app/my-note';

// Trainee's own profile (read-only GET, no input). Returns TraineeDto.
const myProfileUrl = '${baseUrl}api/app/my-profile';
