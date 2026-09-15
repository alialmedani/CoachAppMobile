# CLAUDE.md

Guidance for Claude Code when working in the **CoachApp mobile** app. **The two integration guides
are the spec for _patterns_; the real code is the spec for _current state_.** When a guide's example
disagrees with the actual code, the pattern still holds but adapt it to what the code really is.

## What CoachApp mobile is

A **Flutter (Dart) mobile client** for the **CoachApp** fitness-coaching platform. It talks to the
**CoachApp ABP backend** at `C:\src\BACK\CoachApp` (ABP Framework 10.4.0 / .NET 10, SQL Server,
OpenIddict, multi-tenant). The coaching domain is: **Trainee, WorkoutPlan, NutritionPlan, Exercise,
Food, ProgressEntry, WorkoutLog, NutritionLog, Dashboard, TraineeNote**, and their templates.

> ⚠️ **This repo is a transitional scaffold.** Its `lib/core` was ported from the JasimExpress
> delivery app (`noon_express`) and is being migrated to CoachApp.
>
> **Done:** `lib/core` is populated (90 files) and `dart analyze` clean; package renamed to
> `coachappmobile`; `pubspec.yaml` aligned to the reference deps; `assets/` (fonts + `translations/`
> `ar.json`/`en.json`) in place; `firebase_options.dart` copied. Five feature-coupled files were
> moved to `reference_pending/` (see that folder's README) to keep the core self-contained.
>
> **Built since:** `main.dart`, `api_url.dart`, and the whole feature layer are done — auth/session,
> the Coach authoring side (Phases 4–8), and the Trainee experience (Phases 12–15) all live under
> `lib/features/`, verified on-device. See [Known cleanup](#known-cleanup-backlog) for the exact list.
>
> **Still pending:** Firebase/native config (`google-services.json`, iOS plist, a CoachApp
> `flutterfire configure`) is not set up — `firebase_options.dart` still holds JasimExpress's project.
> `Firebase.initializeApp()` is intentionally **not** called yet, so debug builds/runs work without it.
> The **delivery/merchant/driver examples** in the guides are legacy illustrations — the real domain is
> **coaching**. See [Known cleanup](#known-cleanup-backlog).

## Stack (from `pubspec.yaml`)

- **State management:** BLoC / Cubit (`flutter_bloc`, `bloc`)
- **DI:** GetIt (`get_it`) — `lib/core/di/injection.dart` (`getIt`, `setUp()`)
- **Local storage:** Hive (`hive_flutter`) via `CacheHelper`
- **HTTP:** Dio, wrapped by `ApiProvider` → `RemoteDataSource` (package `api_provider`, `http_methods`, `pretty_dio_logger`)
- **Functional:** `dartz` (`Either`) → wrapped in `Result` / `RemoteResult` / `PaginatedResult`
- **Localization:** `easy_localization` — **AR + EN**, default/fallback **AR** (RTL-first)
- **Responsive:** `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- **UI kit:** `shadcn_ui`, `shimmer`, `extended_image`, plus the app's own `AppDesignSystem` + `modern/` components
- Package name: **`coachappmobile`** (import prefix `package:coachappmobile/...`).

## Canonical layout — everything under `lib/`

Flutter resolves `package:` imports only under `lib/`. The canonical layout (per the guides) is:

```
lib/
  main.dart                     # entry: ScreenUtil + EasyLocalization + MultiBlocProvider + DI setUp()
  core/                         # shared infra — ported & analyze-clean (package:coachappmobile/core/...)
    boilerplate/{create_model,get_model,pagination}/   # widgets that DRIVE cubit state
    classes/            # CacheHelper (Hive), Keys (navigatorKey), notification (Firebase)
    constant/           # app_design_system, app_colors, text_styles, end_points/api_url.dart, enum
    data_source/        # RemoteDataSource.request / noModelRequest
    di/injection.dart   # getIt, setUp()
    http/               # ApiProvider (Dio), HttpMethod (UPPERCASE enum)
    params/             # BaseParams
    repository/         # CoreRepository (call / paginatedCall / noModelCall)
    results/            # Result / RemoteResult / PaginatedResult
    ui/{screens,widgets,widgets/modern,dialogs}
    usecase/            # UseCase<T, Params>
    utils/              # Navigation, validators, functions
  features/<Module>/<feature>/
    cubit/    <feature>_cubit.dart, <feature>_state.dart
    data/model/         <entity>_model.dart      (fromJson / toJson / copyWith)
    data/repository/    <feature>_repository.dart (extends CoreRepository)
    data/usecase/       <op>_<entity>_usecase.dart (Params extends BaseParams + UseCase<T,Params>)
    screen/             <feature>_screen.dart + widgets/
assets/translations/    en.json, ar.json   (declare in pubspec.yaml)
```

**Import-depth rule:** from `lib/features/<Module>/<feature>/data/usecase/` to `lib/core/` is **6
levels** (`../../../../../../core/`); from `.../screen/` or `.../cubit/` it is **5** (`../../../../../core/`).
Count carefully — miscounted `../` is the #1 build error (see the API guide's Pitfalls).

## The architecture flow (both guides agree)

```
Screen (dumb UI)
  → boilerplate widget (CreateModel / GetModel / PaginationList)  ← drives Loading/Success/Error
    → Cubit method returns Future<Result<T>>                       ← NO manual emit()
      → UseCase<T,Params>.call(params:)
        → Repository (extends CoreRepository) → RemoteDataSource.request<T>(converter:)
          → ApiProvider (Dio) → CoachApp backend → Either<String,T> → Result<T>
```

### Non-negotiable rules (the "keep rules" the guides mandate)

1. **Boilerplate widgets own state.** `CreateModel` / `GetModel` / `PaginationList` emit
   Loading/Success/Error from the `Future<Result<T>>` your cubit method returns. In **feature
   cubits, do NOT call `emit()`** — just update params/local state and return the `Result`. The one
   documented exception is **search** (`setSearchTerm` may `emit` a `…SearchChanged` state to rebuild
   the search field). The generic `PaginationCubit` inside `core/boilerplate` does emit — that's the
   boilerplate, not your feature cubit.
2. **Clean architecture, one job per layer.** Model = data + `fromJson`/`toJson`/`copyWith`;
   Params (`extends BaseParams`) = request shape + `toJson()`; UseCase (`UseCase<T,Params>`) = one
   action; Repository (`extends CoreRepository`) = the HTTP call via `RemoteDataSource`; Cubit =
   orchestration + mutable params; Screen = display only.
3. **Params fields are mutable (non-final)** when bound to `onChanged`. `HttpMethod` values are
   **UPPERCASE** (`HttpMethod.GET/POST/PUT/DELETE`).
4. **Repository return helpers:** `call(result:)` for a single model, `paginatedCall(result:)` for a
   list, `noModelCall(result:)` for no-body responses. List converters unwrap
   `json['items'] ?? json['data'] ?? []` (ABP returns `{ items, totalCount }`).
5. **ABP pagination/filter param names:** `GetListRequest` carries `skip`/`take`/`searchTerm` but
   `toJson()` emits **`SkipCount`**, **`MaxResultCount`**, **`SearchTerm`** (and `Filter` where the
   endpoint expects it). Never send raw `skip`/`take` to the backend.
6. **Localization:** every user-facing string uses `.tr()` with a snake_case key added to **both**
   `assets/translations/en.json` and `ar.json`. Never hardcode UI strings. App is **RTL-first (AR)**.
7. **Design system only.** Colors/spacing/radius/typography come from `AppDesignSystem` (or
   `AppColors`/`AppTextStyle`); size with ScreenUtil `.w/.h/.sp/.r`. No hardcoded hex/px.
8. **Wiring:** every feature Cubit is registered in `lib/core/di/injection.dart` (`getIt`). App-level
   cubits (e.g. `SessionCubit`) are provided in `main.dart`'s `MultiBlocProvider`; feature cubits are
   provided at their route/tab — e.g. per-tab in the role shells via `BlocProvider(create: (_) =>
   getIt<…>())` — so they are created lazily where used. Navigate via `Keys.navigatorKey` /
   `BlocProvider.value` when passing an existing cubit.

## CoachApp backend contract (the app's server)

- Base: ABP conventional controllers → REST at **`/api/app/<entity-kebab>/<method-kebab>`** (e.g.
  `api/app/trainee`, `api/app/workout-plan`). Auth token endpoint: **`connect/token`** (OpenIddict
  password grant). Trainee-scoped "My*" services exist (MyDashboard, MyNutritionPlan, MyProgress…).
- Multi-tenant: stock ABP resolves the tenant from the **`__tenant`** header. The copied
  `RemoteDataSource` currently sends a legacy **`JasimTenant`** header — **verify against the backend's
  tenant resolver and align** before relying on tenant scoping.
- List endpoints take `SkipCount`/`MaxResultCount` (+ optional `Filter`/`Sorting`) and return
  `PagedResultDto` = `{ items: [...], totalCount: n }`.
- The backend already has its own agents in `C:\src\BACK\CoachApp\.claude\agents\` (coachapp-backend,
  -db, -architect, …). When a mobile feature needs a backend change, name that and hand it to the
  backend side — do not invent endpoints. Read the real DTO/AppService there to mirror field names.

## Agents & rules

Specialist subagents live in `.claude/agents/`:

| Agent | Role |
|---|---|
| **mobile-brain** | Plan a request into ordered vertical slices, route each to a specialist, resolve ambiguity. Owns keeping these agents + this file up to date. Does not write feature code. |
| **mobile-feature** | Main implementer — builds a full feature slice (model → params/usecase → repository → cubit → screen → DI → translations). |
| **mobile-api** | API/backend-contract integration — reads the CoachApp ABP backend, wires endpoints, ABP conventions, `api_url.dart`, auth, converters. |
| **mobile-ui** | Screens, `AppDesignSystem`, `modern/` components, RTL + AR/EN localization, responsiveness. |
| **mobile-reviewer** | Read-only compliance review of the diff against the two guides + real code. |
| **mobile-runner** | `flutter pub get` / `analyze` / `build` / `run` / smoke-test. |
| **mobile-tester** | Unit / bloc / widget tests. |

Detailed patterns: **`MOBILE_INTEGRATION_GUIDE.md`** (architecture, design system, feature walkthrough)
and **`API_INTEGRATION_GUID.md`** (CURL→slice, boilerplate widgets, ABP params). These two files are
the authoritative pattern spec — agents must keep to them.

### ⚠️ Standing rule — keep the agents updated

**After any change to conventions, structure, the backend contract, or the guides, update the
affected `.claude/agents/*.md` and this `CLAUDE.md` in the same change.** The agents are living docs;
stale guidance is a defect. `mobile-brain` owns this and must verify it on every non-trivial task.

## Commands

```bash
flutter pub get                     # restore packages
dart analyze                        # static analysis — must be clean
dart format .                       # formatting
flutter test                        # unit/bloc/widget tests
flutter run                         # run on a connected device/emulator
flutter build apk --debug           # Android build sanity check
```

## Known cleanup backlog (transitional scaffold → CoachApp)

**✅ Done**
1. `lib/core` populated from the reference and `dart analyze` clean.
2. Package renamed `noon_express` → `coachappmobile` across `lib/`.
3. `pubspec.yaml` aligned to the reference deps; `assets/` (fonts + `translations/ar.json`,`en.json`)
   added; `firebase_options.dart` copied.
4. Feature-coupled core files moved to `reference_pending/` so `lib/core` is self-contained
   (`injection.dart` reduced to a clean `setUp()` stub; `token_validator.checkToken()` no longer
   depends on the auth feature; `notification.dart`'s tap router stubbed).

5. **`api_url.dart` repointed** at the CoachApp backend — `baseUrl` = `String.fromEnvironment('API_BASE_URL',
   defaultValue: 'https://10.0.2.2:44370/')` (Android-emulator → host `localhost:44370`); delivery routes
   dropped, ABP auth/config/document constants kept; tenant header aligned `JasimTenant` → `__tenant`.
6. **`main.dart` rewritten** — ScreenUtil + EasyLocalization (AR/EN, fallback AR) + `setUp()` DI +
   `MultiBlocProvider` + `Keys.navigatorKey`; counter deleted. **Foundation rule (invisible to `dart analyze`
   and to `flutter build` — it only surfaces at runtime): the app root MUST be a `ShadApp` (or otherwise
   provide a `ShadTheme` + `ShadToaster`) ABOVE `MaterialApp`**, via `ShadApp.custom(theme: buildShadLightTheme(),
   darkTheme: buildShadDarkTheme(), appBuilder: … MaterialApp …)` with `ShadToaster` in the `MaterialApp`
   builder. The `modern/` components depend on it (`AppButton` → `ShadButton`, `Dialogs` → `ShadToaster`);
   omitting it compiles and builds fine but crashes on the first `AppButton`. → smoke-test a slice on a
   device/emulator the moment it first renders an `AppButton`.
7. **Feature slices built** — all `dart analyze`-clean and verified live on an Android emulator against
   the real CoachApp backend:
   - **Auth/session/tenant + role routing** (Phases 1–2) — `lib/features/auth/`, `lib/features/shell/`
     (login → `connect/token` → `application-configuration` → `SessionCubit` with
     `isCoach`/`isTrainee`/`can(policy)`; permission-gated Coach/Trainee shells).
   - **Coach authoring** (Phases 4–8) — `lib/features/coach/`: Trainees CRUD, Exercise & Food
     libraries, and the Workout & Nutrition plan **nested builders** (`PlanViewer`,
     `NutritionPlanViewer`, `MacroSummaryCard`, set-active).
   - **Trainee self-service** (Phases 12–16) — `lib/features/trainee/`: My Plans (read-only, **reuses**
     the coach models + viewers), **Today** (`GET /my-today?Date=` with the device-**local** date),
     **workout + nutrition logging** (from-day / from-plan → edit actuals/quantities → PUT → Today
     refetch; view + delete), and **my dashboard/progress/notes/profile** (Phase 16): the Progress tab
     nests `GET /my-dashboard/summary` (self-scoped, **no traineeId**) over the reused `DashboardCards` +
     `ProgressTrendChart` with `my-progress` list/add/delete (**no edit** — backend has no My-progress
     update); the Profile tab loads `GET /my-profile` (**reuses the coach `TraineeModel` DTO**) and links
     Coach Notes (`GET /my-note`, **singular**, read-only), **Change Password** (ABP
     `POST /api/account/my-profile/change-password`), and Logout.
   - **Coach tracking** (Phases 10–11) — `lib/features/coach/tracking/`: from a trainee's detail a
     permission-gated **Tracking** section opens **Dashboard** (`/trainee-dashboard/summary`) +
     **Logs** (`/workout-log`, `/nutrition-log` — read-only; list rows are headers-only, fetch `/{id}`
     for entries) + **Progress** (`/progress-entry`, CRUD) + **Notes** (`/trainee-note`, CRUD), all
     scoped to that trainee. Built the shared P10 widgets inline: `DashboardCards`,
     `WorkoutLogView`/`NutritionLogView` (read-only), `ProgressTrendChart` (dependency-free
     `CustomPainter` chart — no `fl_chart`). Progress DTO field names: `bodyFatPercent`, `armCm`
     (singular); note field is `text` (required, max 2000). Tracking list inputs carry
     `TraineeId`+`FromDate`/`ToDate`+paging (no `Filter`/`SearchTerm`).
   - **Coach templates** (Phase 9) — `lib/features/coach/workout_plan_templates/` +
     `lib/features/coach/nutrition_plan_templates/`: workout & nutrition **plan templates** (list /
     detail / create-edit / delete), **clone template → trainee** (creates a new **inactive** real
     plan), and **save an existing plan as a template**. Endpoints: `api/app/workout-plan-template`
     and `api/app/nutrition-plan-template` (both `*TemplateUrl` in `api_url.dart`) with custom actions
     `POST {url}/{id}/clone-to-trainee` (body `CloneXTemplateDto` = `traineeId`+optional name/desc →
     returns the plan DTO) and `POST {url}/save-as-template` (body `SaveXPlanAsTemplateDto` =
     `workoutPlanId`/`nutritionPlanId`+`name`+optional desc). **Template read/write DTOs are the plan
     DTOs minus `traineeId`/`isActive`**, so templates **reuse the coach plan models + viewers**
     (`WorkoutPlanModel`/`NutritionPlanModel` + children, `PlanViewer`/`NutritionPlanViewer`/
     `MacroSummaryCard`, the day/meal editors + exercise/food/trainee picker sheets) — no duplicate
     models. Template **list** endpoints are **paged** (`PagedResultDto` `items`/`totalCount` →
     `paginatedCall`) and the list input is a plain `PagedAndSortedResultRequestDto` (`SkipCount`/
     `MaxResultCount`/`Filter`/`Sorting` — **no** `TraineeId`/`IsActive`). Create/update params must
     **not emit** `traineeId`/`isActive`. **Permission split to remember:** template CRUD +
     save-as-template are gated by `*PlanTemplates.Create/Update/Delete`, but **clone-to-trainee is
     gated by `*Plans.Create`** (it creates a real plan) — the UI mirrors this exactly. Entry point:
     a **Templates app-bar action** (bookmark icon) on the coach **Plans** tab
     (`lib/features/coach/plans/plans_screen.dart`) opens a segmented host
     `lib/features/coach/templates/templates_screen.dart` (Workout | Nutrition, each segment
     permission-gated, collapses to one list if only one perm); **save-as-template** is a button on the
     coach plan **detail** screens. Known edge case: a coach with template perms but **no** plan perms
     gets the placeholder Plans tab and can't reach Templates (the action lives on `PlansScreen`).
   Trainee-API gotchas learned here: the `My*` **plan list** endpoints are **unpaged top-level arrays**
   (map via `RemoteDataSource`'s `converter2`, NOT `paginatedCall`/`items` unwrap); the **log list**
   endpoints are paged with **`FromDate`/`ToDate`** (no `Filter`/`SearchTerm`); a **workout-log update
   sends actual fields only** — the server preserves the prescribed snapshot keyed by
   `(exerciseId, order)`, so never emit `prescribed*` and keep each entry's original `exerciseId`+`order`.
   Also: **detail screens must return their `_changed` refresh flag on system/gesture back** via
   `PopScope(canPop: false, onPopInvokedWithResult: … Navigator.pop(context, _changed))` — a plain
   implicit back pops `null` and leaves the list stale. And **create/edit form screens wrap their
   `Scaffold` in `UnsavedChangesGuard(isDirty: …, child: …)`** (`core/ui/widgets/unsaved_changes_guard.dart`)
   so backing out of a dirty draft prompts a discard confirm; keep the save/delete path on a direct
   `Navigator.pop(context, true)` (it bypasses the guard). Dirty signal = a JSON snapshot of the params
   (`jsonEncode(params.toJson())`) or a controller+date snapshot captured at `initState`.
   Note: the real feature tree is `lib/features/<feature>/…` (no `<Module>` level), so it is **shallower**
   than the "Import-depth rule" above implies — `screen`/`cubit` → `core` is 3 `../`, `data/usecase` →
   `core` is 4. Prefer `package:coachappmobile/core/...` absolute imports for core to avoid counting.

**⏳ Remaining (the agents should surface/execute next)**
8. **Firebase:** run `flutterfire configure` for the CoachApp project (regenerate `firebase_options.dart`
   — it currently holds JasimExpress's `com.enjaz.noon_express`) and add `google-services.json` /
   iOS plist. Note the debug APK **does** build today (the `google-services` Gradle plugin isn't applied
   and `Firebase.initializeApp()` is commented out); Firebase config only becomes a build/runtime
   blocker once those are actually wired.
9. **Remaining features** — the full **core product loop is now built** (coach authoring +
   coach tracking + trainee self-service, Phases 1–16) **and Coach Templates (Phase 9) is now built**
   too. What's left is non-core / polish:
   - **Coach Dashboard** shell tab is still a placeholder (tracking is reached via the trainee-detail hub).
   - Deferred within logging (14–15): **manual off-plan logging** (needs a plan-item picker —
     decision D3) and full **history lists**.
   - **Hardening (Phases 17–21):** ✅ **UnsavedChangesGuard done on ALL editors** —
     `lib/core/ui/widgets/unsaved_changes_guard.dart` (`UnsavedChangesGuard` wrapping a
     `PopScope(canPop:false)` that reads a live `isDirty()`; both the `AppTopBar` back button via
     `Navigator.maybePop` and the system back are guarded; a successful `Navigator.pop(context,true)`
     save is a direct pop and bypasses it). Applied to save_food/save_exercise/create_trainee (dirty =
     `jsonEncode(params.toJson())` snapshot) + note/coach-progress/trainee-progress editors AND the
     workout/nutrition **log editors** (dirty = a snapshot of the controllers taken after the
     prescribed/from-plan pre-fill); the plan builders already had their own inline guard.
     ✅ **P19 Security A+B+C done** (secure token storage, single-flight refresh, logout
     revocation+cleanup, release log/URL guards, R8, 401→login). ✅ **Search debounce done** —
     `lib/core/utils/functions/debouncer.dart` (`Debouncer`, 400ms) applied to the coach Exercises /
     Foods / Nutrition-plans lists + the food/exercise/trainee picker sheets (term stored immediately;
     only the backend re-fetch is debounced; clear + filter chips stay immediate). ✅ **Error states +
     Retry done** — `lib/core/ui/widgets/modern/app_error_state.dart` (`AppErrorState`: localized,
     design-system, self-centering, Retry button) is now the default error widget in BOTH boilerplate
     loaders (`GetModel` + `PaginationList`), replacing the ported `GeneralErrorWidget` (a Scaffold with
     hardcoded English "Try again" → now dead code). `PaginationCubit` distinguishes initial-load failure
     (`Error` → full-screen retry) from load-more failure (new `LoadMoreError` → keeps the loaded list,
     rolls back the page cursor, footer shows `load_more_failed` + retry). ✅ **Keyboard handling done** —
     added `textInputAction` (Next chain → Done on the last field) to the log editors (workout/nutrition),
     the plan-builder entry sheets (exercise-entry sets/reps/weight/rest, meal-item quantity), the
     nutrition-plan target fields (calories/protein/carbs → next, fat → done), and change-password
     (current/new → next, confirm → done). Numeric fields already had correct number/decimal keyboards
     and all forms already scroll under the keyboard (`resizeToAvoidBottomInset` default true + scrollable
     bodies / bottom-sheet `viewInsets` padding), so no keyboard-type or scroll changes were needed.
     **Still remaining in P17/P18:** network-failure banners + offline read-cache, accessibility audit,
     form-state-on-rotation; language switcher + `intl` date/number formatting (P17 tail).
   - **Testing (Phase 20):** ✅ **first tranche done** — `bloc_test`/`mocktail` added; `test/` mirrors
     `lib/`; **66 tests green** (`dart analyze test` clean) covering model round-trips (incl. int-enum
     mapping + the WorkoutLog `toWriteJson` actuals-only invariant), ABP param names, `FoodCubit`
     no-network orchestration, and the `UnsavedChangesGuard`. **Constraint discovered:** feature cubits
     hard-construct their repository (no DI seam) and repos use the **static** `RemoteDataSource`, so
     cubit **network** paths + screen tests can't be faked without a production seam — deferred. → **mobile-tester**
   → **mobile-feature** + **mobile-api** + **mobile-ui**
10. Re-home the remaining `reference_pending/` files into `lib/` as the matching coaching features are
   built — now just **excel export** and **notification router**. (The splash and home top bar were
   adapted into `lib/core` for CoachApp; the driver deep-link screen was deleted as not needed.)
