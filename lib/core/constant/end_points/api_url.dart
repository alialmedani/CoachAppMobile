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
