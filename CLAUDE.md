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
> **Still pending:** `main.dart` is still the default Flutter counter; `api_url.dart` still points at
> JasimExpress servers; Firebase/native config (`google-services.json`, iOS plist, a CoachApp
> `flutterfire configure`) is not set up — `firebase_options.dart` still holds JasimExpress's project;
> there are no `lib/features/` yet. The **delivery/merchant/driver examples** in the guides are legacy
> illustrations — the real domain is **coaching**. See [Known cleanup](#known-cleanup-backlog).

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
8. **Wiring:** every feature Cubit is registered in `lib/core/di/injection.dart` (`getIt`) and
   provided in `main.dart`'s `MultiBlocProvider`. Navigate via `Keys.navigatorKey` /
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

**⏳ Remaining (the agents should surface/execute next)**
5. **Repoint `api_url.dart`** `baseUrl` at the CoachApp backend and replace delivery endpoints with
   `/api/app/<entity>` coaching routes; align the tenant header (`JasimTenant` → `__tenant`?). → **mobile-api**
6. **Rewrite `main.dart`** to ScreenUtil + EasyLocalization + `setUp()` DI + `MultiBlocProvider` +
   `Keys.navigatorKey`, and delete the counter demo. (Port `reference_pending/.../splash_screen.dart`
   as the app-shell once auth/roles exist.)
7. **Firebase:** run `flutterfire configure` for the CoachApp project (regenerate `firebase_options.dart`
   — it currently holds JasimExpress's `com.enjaz.noon_express`) and add `google-services.json` /
   iOS plist before a device build. `dart analyze` passes without these; `flutter build` won't.
8. **Build coaching features** as vertical slices under `lib/features/` (start with Trainee, Today
   dashboard, WorkoutPlan, NutritionPlan, ProgressEntry). → **mobile-feature** + **mobile-api** + **mobile-ui**
9. Re-home the remaining `reference_pending/` files into `lib/` as the matching coaching features are
   built — now just **excel export** and **notification router**. (The splash and home top bar were
   adapted into `lib/core` for CoachApp; the driver deep-link screen was deleted as not needed.)
