# CoachApp — Master Product Specification & Business-Logic / Product QA Audit

**Status:** Source-of-truth description of the *current, real* product at the end of the V1 functional-implementation phase.
**Date:** 2026-09-14
**Decisions:** **PD1–PD10 are LOCKED as of 2026-09-14** (see §20.1). The redesign builds against these locked decisions.
**Scope of this document:** the CoachApp **mobile app** (`C:\src\APP\CoachAppMobile\coachappmobile`, Flutter) and the **CoachApp backend** (`C:\src\BACK\CoachApp`, ABP 10.4 / .NET 10). It describes what the product does *as built*, evaluates whether it behaves correctly as a coaching product (not just whether the API returns 200), and lists the changes and decisions needed before the planned UI/UX redesign.

---

## How this audit was produced & the verification legend

This is an **audit + documentation** exercise. It is based on **static inspection of the real source of both repositories** (all coaching AppServices, DTOs, domain entities, EF configuration, the permission tree, and every mobile feature slice), cross-referenced against the product-intent docs in the backend (`docs/CoachApp-Workflow-AR.md`, `docs/CoachApp-Mobile-Plan.md`).

**No live/end-to-end run was executed as part of this audit.** Where project logs record a prior on-device run, that is called out explicitly and *not* re-claimed as freshly verified. Every material claim below carries one of these labels:

| Label | Meaning |
|---|---|
| **[BE-VERIFIED]** | Provable from backend source (the authority on what the server enforces). |
| **[MO-VERIFIED]** | Provable from mobile source. |
| **[PRIOR-LIVE]** | Reported working on-device in project logs (2026-09-13); **not re-executed in this audit.** |
| **[ASSUMPTION]** | Behavior not explicitly defined in code/requirements — needs a product decision. |
| **[POTENTIAL-ISSUE]** | Logically questionable / risky; grounded in cited code but flagged for review. |

The QA sections deliberately separate **A. Technically verified (executed)**, **B. Implemented & code-verified (not business-E2E re-verified)**, **C. Product assumptions**, and **D. Potential issues**, per the audit brief.

---

# 1. Product Overview

**CoachApp** is a fitness-coaching platform: a **coach** builds and prescribes training and nutrition for their **trainees**, and each trainee executes and logs what they actually did, so the coach can track adherence and progress.

The relationship the product encodes is: **the coach _prescribes_, the trainee _executes and records_, the coach _reviews the results_ and _advises_** (notes). The domain entities are: Trainee, Exercise, Food, WorkoutPlan (→ Days → Exercises), NutritionPlan (→ Meals → Items), their **Templates**, WorkoutLog, NutritionLog, ProgressEntry, TraineeNote, and a computed Dashboard/Today. [BE-VERIFIED]

- **Who it's for:** independent fitness/nutrition coaches and their clients.
- **Core purpose:** replace ad-hoc spreadsheets/DMs with a structured prescribe → execute → track loop.
- **Platforms:** Flutter mobile (Android verified in dev; iOS not yet configured). RTL-first (Arabic default, English secondary).

---

# 2. User Roles

Two personas, each with its own permission subtree (`CoachApp.Coach.*` and `CoachApp.Trainee.*`). [BE-VERIFIED — `CoachAppPermissions.cs`]

| Role | Who | Can do |
|---|---|---|
| **Coach** | The management account (in the demo, the tenant admin) | Manage trainees (+ their logins), build Exercise/Food libraries, author & activate workout/nutrition plans, create/clone templates, review a trainee's logs/progress/dashboard, write notes. |
| **Trainee** | The client | View own profile & active plans, see "Today", log workouts & nutrition, record progress measurements, read coach notes, change password. |

**Intended capability matrix** (from `CoachApp-Workflow-AR.md §6`, reconciled with the shipped code):

| Feature | Coach | Trainee |
|---|---|---|
| Trainees (create/edit/delete + login) | ✅ full | — |
| Own profile | manages everyone's | **view only** (no self-edit — see F13) |
| Exercise / Food library | ✅ full | sees only within plans |
| Workout / Nutrition plans | ✅ full + activate | view own + active (read-only) |
| Workout / Nutrition logs | review (read-only) | create / view / delete **and edit** (see note) |
| Progress measurements | ✅ full CRUD | create / view / delete — **no edit** |
| Notes | ✅ full | **read only** (cannot create) |

> **Doc-vs-code drift:** `CoachApp-Workflow-AR.md` (an early Phase 1–2 snapshot) says logs are **create/delete only, no edit**. The shipped product **does** support editing logs — the permission tree has `WorkoutLogs.Update` / `NutritionLogs.Update`, the backend has `UpdateWorkoutLogDto` / `UpdateNutritionLogDto`, and the mobile app has log editors. The Arabic workflow doc should be updated. [BE-VERIFIED][MO-VERIFIED]

---

# 3. Product Architecture

- **Mobile:** Flutter + BLoC/Cubit, GetIt DI, Hive (`CacheHelper`) + `flutter_secure_storage` for tokens, Dio (`ApiProvider` → `RemoteDataSource`), `easy_localization` (AR/EN), `shadcn_ui` + a bespoke design system. Clean-architecture slices (model → params/usecase → repository → cubit → screen). [MO-VERIFIED]
- **Backend:** ABP 10.4 / .NET 10, SQL Server, conventional REST at `/api/app/<entity-kebab>/<method-kebab>`. OpenIddict OAuth2 (password grant + refresh). [BE-VERIFIED]
- **Authentication:** `POST /connect/token` (password grant, public client `CoachApp_App`, scope includes `offline_access` → refresh tokens issued), then `GET /api/abp/application-configuration` to load roles + granted policies into the mobile `SessionModel`. Tokens stored in the platform keystore; single-flight refresh; mid-session 401 → forced logout. [BE-VERIFIED][MO-VERIFIED]
- **Multi-tenancy:** ABP multi-tenancy **enabled**; every coaching aggregate implements `IMultiTenant`. Tenant resolved from the **`__tenant` header** (the "gym/coach code" typed at login, e.g. `demo`). Cross-tenant isolation is **automatic** via ABP's global data filter. [BE-VERIFIED]
- **Major feature domains:** Auth/Session · Trainees · Libraries (Exercises, Foods) · Workout Plans · Nutrition Plans · Templates · Today · Workout/Nutrition Logging · Progress · Notes · Dashboards/Tracking.

**The intended isolation model is "tenant-per-coach": one tenant == one coach's private workspace.** This is stated explicitly in the product docs and the entity comments, and is the linchpin of the coach-side security model (see §12). [BE-VERIFIED / intent from `CoachApp-Workflow-AR.md §2`]

---

# 4. Current Feature Inventory

| Feature | What it does | Who | Status | Key business rules |
|---|---|---|---|---|
| **Auth / session / tenant** | Login by gym-code + username/password; secure token storage; refresh; role routing | Both | Built [PRIOR-LIVE] | offline_access + refresh wired; 401→logout; role from granted policies |
| **Coach shells / routing** | Coach vs Trainee shell chosen by role/permissions | Both | Built [PRIOR-LIVE] | Coach wins if both roles; per-tab permission gating (partial — F20) |
| **Trainees CRUD** | Create trainee **+ login user**, edit, delete (cascade), reset password | Coach | Built [PRIOR-LIVE] | Create provisions IdentityUser in Trainee role; inactive ⇒ login locked |
| **Exercise library** | CRUD of exercises (muscle/equipment/media/instructions) | Coach | Built [PRIOR-LIVE] | Delete blocked if referenced (deactivate instead) |
| **Food library** | CRUD of foods with per-serving macros | Coach | Built [PRIOR-LIVE] | Macros stored per one serving; delete blocked if referenced |
| **Workout plans** | Nested builder (Plan→Days→Exercises), prescribed sets/reps/weight/rest, weekday scheduling, activate | Coach | Built [PRIOR-LIVE] | One active plan/trainee enforced; new plans inactive; edit = full replace |
| **Nutrition plans** | Nested builder (Plan→Meals→Items), macro targets, activate | Coach | Built [PRIOR-LIVE] | One active plan/trainee enforced; macros server-computed; edit = full replace |
| **Templates** | Workout & nutrition plan templates; save plan as template; clone template→trainee | Coach | Built (authenticated flow [ASSUMPTION], not [PRIOR-LIVE]) | Templates carry no traineeId/isActive; clone → **inactive** real plan; round-trip fidelity complete |
| **Today** | Resolves scheduled workout / rest-day / active nutrition plan + adherence for a date | Trainee | Built [PRIOR-LIVE] | Rest-day = active plan but nothing scheduled today; unscheduled days invisible |
| **Workout logging** | Log a scheduled day (prescribed snapshot + actuals), view, edit actuals, delete, history | Trainee | Built [PRIOR-LIVE] | Prescribed preserved server-side on update; multiple logs/day allowed |
| **Nutrition logging** | Log from active plan, edit quantities, view, delete, history | Trainee | Built [PRIOR-LIVE] | Consumption-only (no prescribed/actual split); macros server-computed |
| **Progress** | Weight + body measurements + notes over time; trend chart | Coach (CRUD) / Trainee (add/del) | Built [PRIOR-LIVE] | Shared timeline; trainee cannot edit; multiple/day allowed |
| **Notes** | Coach → trainee written notes | Coach (CRUD) / Trainee (read) | Built [PRIOR-LIVE] | One-way; all notes trainee-visible (no private flag) |
| **Coach tracking / dashboard** | Per-trainee dashboard (adherence + completion), read-only log viewers | Coach | Built [PRIOR-LIVE] | Reached via trainee-detail hub; the Coach Dashboard **tab** is still a placeholder |
| **Change password** | ABP account change-password | Trainee (+ any) | Built [PRIOR-LIVE] | Client validates min-6 + confirm |

---

# 5. Coach Journey (as built)

1. **Login** with gym code (`__tenant`) + username/password → password grant → application-configuration → routed to the **Coach shell** (role `Coach`/`admin` or the `Coach.Trainees` grant). [BE/MO-VERIFIED]
2. **Dashboard tab** — currently a **"coming soon" placeholder**; tracking is reached through a trainee's detail screen, not this tab. [MO-VERIFIED]
3. **Trainees** — list/search, create a trainee which **also provisions their login** (username + coach-set password, Trainee role), edit, reset password, delete (cascades to that trainee's data + hard-deletes the login). Deactivating a trainee **locks their login**. [BE-VERIFIED]
4. **Libraries** — build the Exercise and Food libraries first (a plan can only reference existing library items). Deleting an item that is referenced by any plan/template/log is **blocked** with "deactivate it instead". [BE-VERIFIED]
5. **Workout plan** — pick a trainee, add days, set each day's **weekday** (optional) and its exercises with **prescribed** sets/reps/weight/rest/notes, optionally mark active. Activating deactivates the trainee's other workout plans. [BE-VERIFIED]
6. **Nutrition plan** — add meals and items (food + quantity in servings) and optional macro targets (calories/protein/carbs/fat). Server computes the macros. Activating deactivates the trainee's other nutrition plans. [BE-VERIFIED]
7. **Templates** — save an existing plan as a template, or build a template from scratch; **clone a template to a trainee** (creates a new **inactive** real plan — the coach must then activate it). [BE-VERIFIED]
8. **Tracking** (from a trainee's detail): Dashboard (adherence + workout-completion), read-only Workout/Nutrition log viewers, Progress CRUD, Notes CRUD — all scoped to that trainee. [BE/MO-VERIFIED][PRIOR-LIVE]
9. **Notes** — write notes the trainee reads in their app.

**Journey coherence findings:** the create→activate→track loop is coherent and works. The main friction points: the Coach Dashboard *tab* is empty (tracking is buried in trainee-detail); after cloning a template there is no "now activate it" prompt (F6/F7-nut); and a coach with only template permissions cannot reach Templates at all (F6). See §17.

---

# 6. Trainee Journey (as built)

1. **Login** with the account the coach created → routed to the **Trainee shell** (role `Trainee` or the `MyToday` grant). [BE/MO-VERIFIED]
2. **Today** — the home screen. For today's date it shows: the scheduled workout day(s) from the active plan, or a **rest-day** card (active plan but nothing scheduled), or a **no-active-plan** card; the active nutrition plan + today's adherence; and whether today is already logged. [BE-VERIFIED]
3. **My Plans** — read-only view of workout/nutrition plans (all of them, active-badged). [BE/MO-VERIFIED]
4. **Log workout** — "Log this workout" copies the scheduled day's **prescribed** values into a new log (prescribed snapshotted, actuals pre-filled), the trainee edits actuals, saves; Today refreshes. Already-logged → "View" (with edit/delete). [BE/MO-VERIFIED]
5. **Log nutrition** — "Log nutrition" copies the active plan's meal items into a log; the trainee edits the **quantity** consumed; server recomputes macros. [BE/MO-VERIFIED]
6. **History** — paged workout/nutrition history by date. [BE/MO-VERIFIED]
7. **Progress** — add weight/measurements/notes; view the trend chart; delete an entry. **Cannot edit** an entry, and in the app **cannot re-open one to read** the measurements back (tap = delete). [BE/MO-VERIFIED] → F3.
8. **Profile** — read-only profile (no self-edit — F13), read coach notes, change password, logout.

**Isolation:** a trainee only ever sees their own data; foreign IDs return 404. A trainee cannot reach coach functionality (403). [BE-VERIFIED — see §12].

---

# 7. Workout Domain

- **Structure:** `WorkoutPlan (TraineeId, Name, Description, IsActive) → WorkoutDay (Name, Order, ScheduledDay: DayOfWeek?) → WorkoutExercise (ExerciseId, Order, Sets, Reps?, WeightKg?, RestSeconds?, Notes?)`. Only `ExerciseId` + `Sets` are effectively required; reps is a free-form string ("8-12", "AMRAP"). Field limits match exactly between mobile and backend. [BE/MO-VERIFIED]
- **Scheduling:** each day pins to **at most one weekday** (`ScheduledDay`); `null` = unscheduled. Weekday enum aligns (Sun=0…Sat=6 == .NET `DayOfWeek`). [BE/MO-VERIFIED]
- **Prescribed values** live on the plan's exercises and are **snapshotted into each log entry** (`PrescribedSets/Reps/WeightKg`) at log time, so later plan edits never rewrite history. [BE-VERIFIED]
- **Actual values** are the trainee's logged sets/reps/weight; on update the client sends **actuals only**, and the server **preserves the prescribed snapshot** by matching existing entries on `(ExerciseId, Order)`. [BE/MO-VERIFIED]
- **Active/inactive:** new plans are inactive; `SetActive` (and create/edit-with-active) deactivates the trainee's other plans first — **one active plan per trainee is genuinely enforced** at the app-service layer. [BE-VERIFIED]
- **Editing = full destructive replace** (all days/exercises cleared and rebuilt with new GUIDs). Safe for history because logs snapshot; the plan/day GUIDs churn on every edit. [BE-VERIFIED]
- **Logs:** created from a scheduled day; `WorkoutPlanId`/`WorkoutDayId` are nullable non-FK links (off-plan logging is structurally possible but not exposed in the app — F9). Coach view is read-only (list rows are header-only; detail fetched per id). [BE/MO-VERIFIED]
- **History:** paged, `FromDate`/`ToDate`, `Date desc`. [BE/MO-VERIFIED]

Domain findings: F2 (multi-day-same-weekday only first loggable), F7 (eager log creation), F14 (active plan with no scheduled days = perpetual rest day), F11 (deleting/deactivating active plan strips program), F12 (trainee sees inactive plans).

---

# 8. Nutrition Domain

- **Structure:** `NutritionPlan (TraineeId, Name, Description, IsActive, TargetCalories?/ProteinG?/CarbsG?/FatG?) → Meal (Name, Order) → MealItem (FoodId, Order, Quantity)`. Targets are **optional, coach-entered**. [BE/MO-VERIFIED]
- **Food macros** are stored **per one serving** (`ServingSize` + `ServingUnit`, e.g. per 100 g). **Quantity = number of servings.** [BE-VERIFIED]
- **Macros are 100% server-computed** at read time: `value = food.value × quantity`, summed to plan/log totals. The client sends only `foodId/order/quantity/notes`. [BE/MO-VERIFIED]
- **Active/inactive, edit=full-replace, one-active-enforced** — identical rules to the workout domain. [BE-VERIFIED]
- **Logs:** "from plan" flattens the plan's meals→items into a single ordered entry list (meal grouping is lost — F29-→low). There is **no prescribed-vs-actual split**: the planned quantity is copied into the single `Quantity`, which the trainee overwrites with what they actually ate. Coach sees **consumed only**. [BE/MO-VERIFIED] → F10.
- **Adherence:** consumed calories vs target (or plan totals if no target), **single-day**, uncapped, calories-only for the "overall" number. [BE-VERIFIED] → F5.

Domain findings: **F1 (serving-size shown as grams → up to ~100× error — the single most dangerous finding)**, F10 (no prescribed/actual), F5 (day-scoped adherence), F15/F16 (target labeling & fallback inconsistency), F9 (no off-plan logging).

---

# 9. Templates

- **Template = a plan blueprint minus `TraineeId`/`IsActive`.** Workout and nutrition variants each have list/detail/create-edit/delete. Template list endpoints are paged; the list input is a plain paged/sorted request (no TraineeId/IsActive). [BE/MO-VERIFIED]
- **Save existing plan as template** deep-copies the full tree — workout: day name/order/**scheduledDay** + all 7 exercise prescribed fields; nutrition: all 4 targets + meals/items. [BE-VERIFIED]
- **Clone template → trainee** creates a **new, INACTIVE** real plan for the target trainee, deep-copying the whole structure. It does **not** activate it and does **not** deactivate the trainee's other plans (correct, since it's inactive). The coach must activate it afterwards. [BE-VERIFIED]
- **Round-trip fidelity is complete** — plan → save-as-template → clone-to-trainee preserves scheduling weekdays *and* macro targets; the only intentionally-dropped fields (`TraineeId`/`IsActive`) are re-supplied on clone. [BE-VERIFIED]
- **Permission split is exact:** template CRUD + save-as-template are gated by `*PlanTemplates.*`; **clone-to-trainee is gated by `*Plans.Create`** (it creates a real plan). Mobile mirrors this 1:1. [BE/MO-VERIFIED]
- **Ownership:** templates are a **tenant-wide shared library** (no per-coach owner). Fine under tenant-per-coach; shared across coaches otherwise. [BE-VERIFIED]

Findings: F6 (templates-only coach can't reach the library), F7-nut (no post-clone "activate now" CTA).

---

# 10. Today — exact behavior

For the requested date (the client sends the **device-local date** as `?Date=yyyy-MM-dd`; the server uses that date's `DayOfWeek` directly, so no timezone shift): [BE/MO-VERIFIED]

1. **Active workout plan** = `FirstOrDefault(TraineeId == me && IsActive)`. `HasActiveWorkoutPlan` reflects it.
2. **Scheduled workout day(s)** = the active plan's days where `ScheduledDay == today's weekday`, ordered by `Order` — returned as a **list** (multiple days on one weekday are all returned).
3. **Rest day** = `HasActiveWorkoutPlan && no scheduled days today`. **No active plan is a distinct state** (not "rest day").
4. **Unscheduled days** (`ScheduledDay == null`) never surface on Today — so an active plan whose days are all unscheduled shows a **perpetual rest day** even though the full plan is visible under My Plans. [BE-VERIFIED] → F14.
5. **Already-logged** = any workout log exists for that date; Today exposes the **most recent** (`LatestWorkoutLogId` + embedded log). **Multiple logs per day are explicitly allowed** (backend decision "D5"). [BE-VERIFIED]
6. **Nutrition:** the active nutrition plan is embedded, plus **today's adherence** (consumed vs target). `AlreadyLoggedNutritionToday` = adherence has a log. Today has no nutrition-log id, so the app re-resolves today's log via a `FromDate==ToDate` list call. [BE/MO-VERIFIED]

Findings: F2 (only first scheduled day loggable), F5 (adherence shows 0% before logging), F14 (perpetual rest day).

---

# 11. Progress / Notes / Tracking (coach vs trainee)

**Progress entries** capture `Date` + optional `WeightKg`, `BodyFatPercent`, `ChestCm`, `WaistCm`, `HipsCm`, `ArmCm`, `ThighCm`, `Notes` (max 512). No photos. Multiple entries per day allowed. [BE-VERIFIED]
- **Coach:** full CRUD; `Create` takes `TraineeId` from the client.
- **Trainee:** create + delete only, **no update endpoint exists**; `Create` derives the trainee from the current user.
- **Both write to the same table** → coach- and trainee-created entries **merge into one timeline** each side sees in full. Deletion is not owner-checked: a **trainee can delete a coach-created entry** and vice versa; neither side sees who created an entry. [BE-VERIFIED] → **F3, F4**.

**Notes** = `Date` + `Text` (required, max 2000). **Coach-authored only** (trainee interface is list+get, no create). **No private/visibility flag** — every coach note is trainee-visible. [BE-VERIFIED] → F17.

**Dashboard/tracking summary** = nutrition adherence (**day-scoped**) + workout completion (**range-scoped**, distinct logged days ÷ planned sessions over the window). **No latest-weight, no streak** are computed. Coach and trainee dashboards use the **same calculator**; the app requests adherence for *today* and completion for the *trailing 28 days*. [BE-VERIFIED] → F5.

Findings: F3, F4, F5, F8 (coach affordances shown without permission → 403), F17.

---

# 12. Permissions / Ownership / Multi-Tenancy

**What is solidly enforced (no defects for the intended model):**
- **Every endpoint is `[Authorize]`'d; there is no `[AllowAnonymous]` anywhere.** Coach services require `Coach.*`; write ops carry granular Create/Update/Delete perms; trainee services require `Trainee.*`. [BE-VERIFIED]
- **Cross-trainee isolation is strict.** Every `My*` service resolves the trainee from `CurrentUser.GetId()` → `Trainee.UserId`; a client-supplied `traineeId` is **never** accepted; every read/write is filtered by the resolved id; foreign IDs return **404**. A trainee cannot read or mutate another trainee's plans, logs, progress, notes, dashboard, or profile. [BE-VERIFIED]
- **Cross-tenant isolation is automatic.** Multi-tenancy is enabled and all aggregates are `IMultiTenant`, so ABP's global filter scopes every query. Tenant A cannot see Tenant B. [BE-VERIFIED]
- **Role boundaries hold both ways.** A trainee calling coach endpoints → 403; a coach calling `My*` → 403 (lacks `Trainee.*`); an admin calling `My*` → 404 (no trainee profile). No data leaks in any direction. [BE-VERIFIED]

**The one structural caveat — coach→trainee ownership:**
- There is **no `CoachId`/owner field anywhere.** Coach-side services scope by **tenant + permission only** and trust the client-supplied `TraineeId`. The entire coach isolation model rests on the **unenforced "one coach per tenant" convention**. If two `Coach` users were ever placed in the same tenant, they would **share every trainee, plan, log, progress entry, note, and template** — and could edit/delete each other's. [BE-VERIFIED] → **F18 / PD1**.
- This is **correct and safe for the current single-coach-per-tenant V1**, and is explicitly the documented model. It becomes a **critical data-isolation gap only if multi-coach-per-tenant is ever in scope.** That is the single most important product decision (PD1).

Secondary: coach `Update` can **reassign** a plan/progress/note to a different `TraineeId` (F18); host/blank-tenant login is reachable from the client (F39); tokens survive a password change (F40).

---

# 13. Backend ↔ Mobile Contract (important behaviors)

- **ABP paging:** coach lists return `{ items, totalCount }`; params are `SkipCount` / `MaxResultCount` (+ `Filter`, `Sorting`, and per-list `TraineeId`/`IsActive`/`Goal`/`FromDate`/`ToDate`). The `My*` **plan** lists are **unpaged top-level arrays**; the **log** lists are paged with `FromDate`/`ToDate` (no `Filter`/`SearchTerm`). [BE/MO-VERIFIED]
- **Enums are integers and match exactly** — Gender 0–2, TrainingGoal 0–5, MuscleGroup 0–8, Equipment 0–8. (There is **no** activity-level enum.) [BE/MO-VERIFIED]
- **Macros/names are server-computed ("enrichment")** on read — exercise names, food macros, totals. The client must not compute them. [BE-VERIFIED]
- **Workout log update = actuals only**, echoing each entry's original `exerciseId`+`order`; the server preserves the prescribed snapshot. Never send `Prescribed*`. [BE/MO-VERIFIED]
- **Nutrition:** client sends `foodId/order/quantity(servings)/notes`; server computes macros. **`ServingSize` is not exposed on `MealItemDto`/`NutritionLogEntryDto`** — the mobile only receives `servingUnit`, which is the root of F1. [BE-VERIFIED]
- **Plan/log edit = full replace** of the child tree. [BE-VERIFIED]
- **Errors:** ABP standard — 400 (validation/business, localized `error.message`, honors `Accept-Language`), 401 (token), 403 (role/permission), 404 (missing **or** not-yours). [BE-VERIFIED]
- **Tenant/auth:** `__tenant` header on login + every request; `CoachApp_App` public client; scope includes `offline_access` (refresh tokens issued). [BE-VERIFIED]

---

# 14. QA / Business Scenarios

> **Verification note:** none of the scenarios below were executed live in this audit. "Actual" states what the **code enforces** (the authority for business rules) plus, where applicable, that a prior on-device run is recorded in project logs (2026-09-13). Security scenarios (D) are **backend-code-verified**, which is a stronger guarantee than a single happy-path live run.

### Scenario A — Coach creates a trainee and assigns a workout plan
- **Preconditions:** coach logged in; Exercise library non-empty.
- **Steps:** create trainee (→ login provisioned) → create workout plan with a day scheduled on today's weekday + prescribed exercises → activate → trainee logs in → Today → log workout → coach opens tracking.
- **Expected:** trainee can log in; Today shows the scheduled session; logging preserves prescribed vs actual; coach sees the log.
- **Actual (code):** all steps supported and rule-correct; create provisions the login; one-active enforced; prescribed snapshotted. [BE/MO-VERIFIED] Happy path [PRIOR-LIVE 2026-09-13].
- **Status:** **B — implemented & code-verified; core path prior-live.** Caveat: if the coach schedules **two days on the same weekday**, only the first is loggable (F2); if **no day is scheduled**, Today shows a perpetual rest day (F14).

### Scenario B — Nutrition end-to-end
- **Steps:** create foods → nutrition plan + targets → activate → trainee sees plan → logs nutrition → history updates → coach reviews.
- **Expected:** trainee sees the plan; logging records consumption; macros server-computed; coach sees intake vs target.
- **Actual (code):** supported; macros correct; adherence computed. **But** the quantity field is labeled/rendered as the food's unit ("Quantity (g)", "2 × g") while it means *servings* (F1 — mis-entry risk up to ~100×); the coach sees **consumed only** with **no planned-vs-actual** comparison (F10); adherence is **day-scoped** so it reads low before the day is complete (F5). [BE/MO-VERIFIED] Happy path [PRIOR-LIVE].
- **Status:** **B, with D-level concerns (F1 safety, F5/F10 product).**

### Scenario C — Template
- **Steps:** create plan → save as template → clone template to another trainee → verify cloned plan → trainee sees result.
- **Expected:** cloned plan is structurally identical and **inactive**; trainee sees nothing until the coach activates it.
- **Actual (code):** round-trip fidelity **complete** (scheduling + targets preserved); clone → inactive confirmed; coach must activate. **But** there is no post-clone "activate now" prompt (a coach may think the trainee already has an active plan — F7-nut), and a coach with only template perms **cannot reach Templates at all** (F6). [BE-VERIFIED]
- **Status:** **B; authenticated flow not [PRIOR-LIVE]** (backend was down during the build pass) — recommend a live pass.

### Scenario D — Ownership / security
- **D1 Trainee A → Trainee B's data:** **Blocked.** `My*` resolves the trainee from the token; foreign IDs → 404. **Status: enforcement BE-VERIFIED.**
- **D2 Trainee → coach-only operation:** **Blocked** (403 — lacks `Coach.*`). **BE-VERIFIED.**
- **D3 Tenant A → Tenant B's data:** **Blocked** (ABP tenant filter). **BE-VERIFIED.**
- **D4 Coach A → Coach B's trainees within one tenant:** **NOT blocked** — no `CoachId`; tenant-wide access. Safe only under one-coach-per-tenant. **BE-VERIFIED → F18/PD1.**
- **D5 Unauthenticated:** **Blocked** (no `[AllowAnonymous]`; all endpoints authorized). **BE-VERIFIED.**
- **Status:** **A-grade for the intended model** (isolation provable in source), with the multi-coach caveat.

### Scenario E — Lifecycle edge cases (code-derived expectations)
| Case | Behavior | Status |
|---|---|---|
| No active plan | Today shows "no active plan" card (distinct from rest day) | B — coherent |
| Rest day | Active plan, nothing scheduled today → rest-day card | B — coherent |
| No logs yet | Empty states present | B — coherent |
| Already logged today | Button flips to "View"; second scheduled day unreachable | B → F2 |
| Empty history | Empty state | B — coherent |
| Empty library | Coach can't build a plan until library seeded (onboarding friction) | C/D — no seed/onboarding |
| Inactive plan | Visible to trainee in My Plans (no draft concept) | D → F12 |
| Multiple plans | Allowed; only active drives Today | B — coherent |
| Edited plan | Full replace; logs unaffected (snapshot) | B — correct |
| Cloned plan | New inactive plan; needs activation | B → F7-nut/F6 |
| Deleted log | Allowed (no dedicated Delete permission) | B → F23 |
| Delete/deactivate active plan | Program silently stripped, no warning | D → F11 |

---

# 15. Verified vs Not Fully Verified

### A. Technically verified (executed in *this* audit)
**None.** No live/E2E run was performed here. (Project logs record on-device verification on 2026-09-13 of: login → coach/trainee shells → trainees/library/plans CRUD → set-active → nested builders → nutrition macros → workout & nutrition logging round-trips incl. prescribed-preservation → progress add/delete → change-password. Those are **[PRIOR-LIVE]**, not re-run.)

### B. Implemented & code-verified (not business-E2E re-verified here)
The entire feature set in §4 is code-verified in both repos: auth/session/isolation, trainees + login provisioning, libraries, workout/nutrition plan lifecycle + one-active enforcement, prescribed/actual mechanics, templates round-trip, Today logic, logging, progress/notes/dashboards, permission gating.

### C. Product assumptions (need a decision — see §20)
One-coach-per-tenant invariant; nutrition consumption-only (no prescribed/actual); trainee cannot edit progress/profile; all notes trainee-visible; multiple logs/entries per day; inactive plans visible to trainees; dual-role accounts; host/blank-tenant login.

### D. Potential issues
The full findings list is in §17. The highest-impact: **F1** (servings-as-grams safety), **F2** (multi-day loggability), **F3/F4** (progress edit + cross-actor deletion), **F5** (adherence windowing), **F6** (templates-only coach), **F7** (eager log creation), **F18/PD1** (coach ownership if multi-coach).

---

# 16. Known Limitations (honest list)

- **Coach Dashboard tab** is a placeholder; tracking is only reachable via a trainee's detail screen.
- **No off-plan / manual logging** (workout or nutrition) — the trainee can only log from an active plan (deferred decision D3). Backend already supports it.
- **No nutrition prescribed-vs-actual** — coach sees consumed only.
- **Nutrition adherence is day-only** (no weekly/range view; coach view pinned to today).
- **Trainee cannot edit** progress entries or their own profile.
- **No draft/published plan state** — inactive plans are visible to the trainee.
- **No photos/media surfaced** — progress has no photos; exercise video/image URLs are captured but never displayed.
- **Coach ownership is tenant-only** (no per-coach ownership within a tenant).
- **Firebase / push / iOS config** not set up; app still on `com.example.coachappmobile` with JasimExpress `firebase_options`; no release signing/icons/crash reporting.
- **No repository DI seam** in mobile cubits (limits unit-testability of network paths).
- **Debug builds** log raw tokens/passwords via PrettyDioLogger (release is gated/safe).

---

# 17. Recommended Changes (consolidated findings)

Each finding: **Current → Proposed → Why → Impact (Mobile/Backend/Both/Product) → Priority.** Priorities: **P1 = fix as part of the redesign (correctness/safety/data-loss)**, **P2 = strongly recommended**, **P3 = polish/hardening.**

### HIGH — P1

**F1 — Nutrition quantity (servings) is labeled/shown as the food's unit (grams).**
Current: food macros are per serving and `quantity` = number of servings, but the meal-item and log UI say "Quantity (g)", "1 serving = g", "2 × g"; `ServingSize` is never sent to the client. → Proposed: backend add `servingSize` to `MealItemDto` + `NutritionLogEntryDto` (+ enrich); mobile render "N servings (N×size unit)". → Why: a coach/trainee misreading servings as grams can mis-prescribe/mis-log by up to ~100× — a real coaching-safety issue. → **Both.** → **P1.** [BE/MO-VERIFIED]

**F2 — Multiple workout days on the same weekday: only the first is loggable.**
Current: Today returns all matching days but the app logs only `.first`, and after one log the section flips to "View". → Proposed: per-day log actions (or forbid two days on one weekday). → Why: silent data loss + adherence undercount for legit AM/PM or split programming. → **Both (Product-decision on legality).** → **P1.** [BE/MO-VERIFIED]

**F3 — Trainee progress is add+delete only; tap = delete; no read-back or edit.**
Current: no `MyProgress.Update`; the only row action is delete-confirm; measurements are write-only to the trainee. → Proposed: read-only detail view + explicit delete affordance, and either allow editing own recent entry or clearly present the delete-and-re-add rule. → Why: destructive + data the trainee can never see again. → **Both (backend add update, or product-decide).** → **P1.** [BE/MO-VERIFIED]

**F4 — Shared progress timeline with cross-actor deletion and no attribution.**
Current: trainee can delete a coach-created entry (and vice versa); no creator shown though `CreatorId` exists on the DTO. → Proposed: restrict trainee delete to self-authored entries; surface who logged each entry. → Why: a trainee can silently erase the coach's official measurements; coach vs self entries are indistinguishable. → **Both.** → **P1.** [BE-VERIFIED]

**F5 — Nutrition adherence is day-scoped and the coach dashboard is pinned to "today"; the card also shows 0% before logging.**
Current: adherence single-day, uncapped, calories-only; coach dashboard has no date/range selector; UI ignores `hasLog`. → Proposed: range aggregation (weekly avg / trend) + a date selector; show "not logged yet today" instead of 0%. → Why: a compliant trainee reads ~0% every morning; the coach can't review yesterday or a weekly average — the weakest part of the adherence story. → **Both.** → **P1.** [BE/MO-VERIFIED]

**F6 — A coach with only template permissions cannot reach the Templates library.**
Current: the Plans tab renders a "coming soon" placeholder when plan perms are absent, and the Templates entry lives only on `PlansScreen`. → Proposed: render `PlansScreen` collapsed to the Templates action when only template perms exist (or add a Templates entry to the placeholder). → Why: a fully-granted capability is 100% unreachable and shows a misleading "coming soon". → **Mobile.** → **P1.** [MO-VERIFIED]

**F7 — "Log this workout" creates a completed log eagerly, before the editor; backing out leaves a phantom "completed as prescribed" session.**
Current: `logFromDay` runs before the editor opens and Today refreshes regardless of save/cancel. → Proposed: create only on save (or a clear confirm/undo). → Why: accidental taps inflate adherence/completion and mislead the coach. → **Both.** → **P1 (mobile flow).** [MO-VERIFIED]

### MEDIUM — P2

**F8 — Coach Add/Edit/Delete affordances for Progress/Notes are shown without the granular permission → 403 on submit.** The granular constants exist but are unused. → Mobile gate affordances on Create/Update/Delete. → **Mobile.** → P2. [MO-VERIFIED]

**F9 — No off-plan / no-plan logging (workout + nutrition).** Backend supports manual `CreateAsync`; mobile wires only from-plan. → Add a manual picker (deferred D3). → **Mobile (Product-decision to prioritize).** → P2. [BE/MO-VERIFIED]

**F10 — No nutrition prescribed-vs-actual split.** Planned quantity is overwritten; coach sees consumed only. → Add `PrescribedQuantity` (like workout) or product-decide consumption-only. → **Both/Product.** → P2. [BE/MO-VERIFIED]

**F11 — Deleting/deactivating a trainee's ACTIVE plan silently strips their program, no warning.** → Warn the coach (name the active plan); optional backend guard. → **Mobile (+Backend).** → P2. [BE/MO-VERIFIED]

**F12 — Trainee sees inactive/draft plans in My Plans (no draft concept).** → Hide inactive from the trainee, or add a draft/published state. → **Product → Backend filter.** → P2. [BE/MO-VERIFIED]

**F13 — Trainee cannot edit their own profile** (no `MyProfile.UpdateAsync`). → Add a restricted self-edit. → **Backend + Mobile (Product).** → P2. [BE-VERIFIED]

**F14 — An active plan with zero scheduled days shows a perpetual rest day.** → Warn/block on activate, or surface unscheduled days on Today. → **Both.** → P2. [BE/MO-VERIFIED]

**F15 — `MacroSummaryCard` reused with 3 meanings; Today labels consumed intake as "Macro Totals".** → Add a title/mode param; label Today's card "Today's intake". → **Mobile.** → P2. [MO-VERIFIED]

**F16 — Target null-fallback inconsistent:** coach detail shows "no target" while the trainee is scored against plan meal totals as an implicit target. → Align the "effective target" definition; optionally warn when built totals diverge from entered targets. → **Both.** → P2. [BE/MO-VERIFIED]

**F17 — All coach notes are trainee-visible; no private flag.** → Document "notes are shared" in the editor, or add `IsPrivate`. → **Product (+Both).** → P2. [BE-VERIFIED]

**F18 — Coach writes trust client `TraineeId`; Update can reassign records across trainees.** → Bind records to their trainee / validate ownership (ties to PD1). → **Backend.** → P2 (P1 if multi-coach). [BE-VERIFIED]

**F19 — Delete trainee: profile/data soft-deleted, login user hard-deleted (asymmetry).** → Decide: soft-deactivate the user, or hard-delete everything. → **Backend/Product.** → P2. [BE-VERIFIED]

**F20 — Coach routing keys on the `Trainees` permission specifically, not "any coach capability".** A custom coach profile drops to the logout-only placeholder. → Broaden `isCoach` to any `CoachApp.Coach.*` grant. → **Mobile.** → P2. [MO-VERIFIED]

**F21 — Exercise video/image URLs are captured but never displayed (write-only).** → Render image / "watch video" on the exercise detail. → **Mobile.** → P2. [MO-VERIFIED]

### LOW — P3 (hardening / latent / polish)

- **F22** — Workout-log update prescribed-preservation is client-trusted; backend doesn't validate the entry set (safe with the current fixed-list editor). Harden server-side. [BE-VERIFIED]
- **F23** — Log/progress **delete** is gated only by the read permission (no `Delete` node). Add a Delete permission or document. [BE-VERIFIED]
- **F24** — No filtered-unique DB index for one-active; a concurrent set-active race could yield two active plans; read-side pick is nondeterministic. Add index + deterministic tie-break. [BE-VERIFIED]
- **F25** — `ToDate` filter excludes same-day timestamped logs (latent; logs currently midnight). Normalize to end-of-day. [BE-VERIFIED]
- **F26** — Null-`Date` fallback uses server UTC (dead today; wrong for non-UTC if the param is dropped). [BE-VERIFIED]
- **F27** — Today embeds the full latest log but the app re-fetches by id (extra round-trip). [BE/MO-VERIFIED]
- **F28** — Multiple logs/day: adherence sums them but the UI views/edits one; tie-break undefined. [BE/MO-VERIFIED]
- **F29** — Meal structure is lost in the nutrition log (flattened); coach can't see per-meal adherence. [BE/MO-VERIFIED]
- **F30** — "Overall" adherence is calories-only; over-target not visually distinct (bar clamps at 100%). [BE/MO-VERIFIED]
- **F31** — Coach nutrition-log detail doesn't show the log's date. [MO-VERIFIED]
- **F32** — Empty (date-only) progress entries can be saved. Require ≥1 measurement. [BE/MO-VERIFIED]
- **F33** — Future-dated entries/notes allowed and sort to the top. Cap pickers at today. [MO-VERIFIED]
- **F34** — Workout-completion % is fragile outside the fixed 28-day window; any workout-day counts (incl. off-plan); uncapped >100%. Document/lock the window. [BE-VERIFIED]
- **F35** — Trainee-list search is un-debounced (inconsistent with exercises/foods). [MO-VERIFIED]
- **F36** — Create-trainee synthetic email on the login vs blank on the profile. [BE-VERIFIED]
- **F37** — Exercise media URLs have no client-side URL validation (backend has `[Url]`). [BE/MO-VERIFIED]
- **F38** — Debug PrettyDioLogger logs raw tokens/passwords; per-request interceptor accumulation; shared static Dio header mutation (concurrency race). Release is safe. [MO-VERIFIED]
- **F39** — Host/blank-tenant login is reachable from the client. Refuse empty tenant pre-flight / reject host login for `CoachApp_App`. [MO/BE]
- **F40** — Tokens survive a password change (no session revocation). [ASSUMPTION]
- **F41** — `restoreSession` treats a token with no stored expiry as valid indefinitely (relies on the 401 path). [MO-VERIFIED]
- **F42** — *(Mitigated)* Deleting a referenced exercise/food is **blocked** (`ExerciseInUse`/`FoodInUse`), so historical logs can't be orphaned via a supported delete. Residual risk only if the guard is bypassed. [BE-VERIFIED]
- **F43** — Progress `Notes` max 512 not enforced in the editor → >512 → 400. Add `maxLength`. [BE/MO-VERIFIED]
- **F45** — A dual-role account always lands on the Coach shell (no persona switcher). [MO-VERIFIED]

---

# 18. V1 Scope (what belongs to the current V1)

The **core coaching loop is V1 and is built**:
- Auth/session/tenant + role routing; **single-coach-per-tenant** isolation.
- Trainees CRUD (+ login provisioning, activate/deactivate, reset password).
- Exercise & Food libraries (with referenced-item delete protection).
- Workout & Nutrition plan authoring (nested builders, prescribed values, macro targets, scheduling, one-active enforcement).
- Templates (create, save-as-template, clone-to-trainee).
- Trainee Today + workout/nutrition logging (from-plan) + history.
- Progress (coach CRUD / trainee add+delete), Notes (coach→trainee), coach tracking dashboard.
- Security: strict trainee & tenant isolation; permission-gated endpoints.

**V1 explicitly assumes one coach per tenant** (PD1). Under that assumption there are **no security/isolation/crash blockers**.

---

# 19. V1.1 / Future Features

- **Rich Coach Dashboard tab / trainee roster** (replace the placeholder; sticky active-trainee context — plan D4).
- **Off-plan / manual logging** with an exercise/food picker (D3; backend already supports it).
- **Nutrition prescribed-vs-actual** (planned vs consumed at item level).
- **Range/weekly nutrition adherence** + coach date selector.
- **Trainee self-edit profile** (restricted).
- **Draft/published plan state**; hide inactive plans from trainees.
- **Progress photos** (needs backend fields + media storage — plan B4).
- **Exercise media playback**; note privacy flag.
- **Push notifications** (out of V1 — D8; no backend support today).
- **Expanded offline read-cache + network banners**, accessibility audit, language switcher + intl formatting (P17/P18 tail).
- **Finer permission granularity** and, if multi-coach gyms are wanted, **per-coach ownership** (PD1).
- **Firebase/iOS/release readiness** (google-services, plist, `flutterfire configure`, signing, icons, crash reporting).

---

# 20. Product Decisions Needed

These change *what screens the redesign builds*, so they were decided **before** the redesign starts. **All ten are now locked** — §20.1 records the approved V1 decisions; §20.2 keeps the original decision detail and rationale.

## 20.1 Locked V1 Decisions (approved 2026-09-14)

> These decisions are **approved and final for V1**. They are recorded here as product direction; **the code changes they imply are NOT yet implemented** (the P1/P2 fixes are folded into the redesign — see §21). "Approved as proposed" means the §20.2 recommendation for that PD is adopted verbatim.

| # | Decision | Locked outcome for V1 |
|---|---|---|
| **PD1** | Tenant model | **CONFIRMED: one coach per tenant is the official V1 model.** One tenant == one coach's private workspace. **Guardrails (to implement, not yet done):** (a) prevent a **second `Coach` from ever being assigned to a tenant that already has one** — enforce at trainee/coach provisioning; (b) **do NOT introduce `CoachId` or any multi-coach ownership** — scoping stays tenant + permission; (c) apply the **small F18 hardening** so a Coach `Update` cannot arbitrarily **reassign a record's `TraineeId`** (bind each record to its trainee / reject a changed `TraineeId` on update). Multi-coach-per-tenant is explicitly **deferred to a later major version.** |
| **PD2** | Nutrition logging model | **Approved as proposed — keep consumption-only logs for V1** and **document** that the coach sees consumed intake only (no prescribed-vs-actual at item level). Prescribed-vs-actual nutrition is deferred to **V1.1** (revisit if item-level adherence becomes a coach need). (F10) |
| **PD3** | Off-plan / manual logging | **Approved as proposed — from-plan logging only in V1;** add manual/off-plan logging (needs an exercise/food picker) in **V1.1**. Backend already supports it. (F9) |
| **PD4** | Progress ownership & editing | **Approved as proposed —** give the trainee **read-back + edit of their own** entries; **restrict trainee delete to self-authored** entries (a trainee may not delete a coach-created entry); **show the creator (attribution)** on each entry. (F3, F4) |
| **PD5** | Adherence window | **Approved as proposed —** add **weekly/range adherence + a coach date selector**; show **"not logged yet today"** instead of 0% before the day is logged. (F5) |
| **PD6** | Trainee self-edit profile | **Approved WITH scope clarification — the trainee may self-edit ONLY: Phone, Email, Birthdate, Current weight.** **Username is immutable.** **Goals, targets, and all coaching-related fields remain Coach-owned** (trainee cannot edit them). (F13) |
| **PD7** | Coach note privacy | **Approved as proposed —** for V1, **label notes as "shared with the trainee"** in the editor so the coach knows every note is trainee-visible; a private `IsPrivate` flag is a **V1.1** consideration. (F17) |
| **PD8** | Inactive/draft plans visibility | **Approved as proposed — hide inactive plans from the trainee** (trainee sees active plans only); a full draft/published state is deferred. (F12) |
| **PD9** | Multi-day-per-weekday | **CONFIRMED 2026-09-14 (V1-simple) — a workout plan may have only ONE scheduled workout per weekday; duplicate weekdays are REJECTED by backend validation.** Keep the existing `WorkoutDay.ScheduledDay` model — **no schema redesign.** Multiple sessions on the same weekday are deferred to **V1.1**. This supersedes the earlier provisional "per-day logging" reading: the **F2 fix becomes a weekday-uniqueness validation (+ a client-side guard)**, which also eliminates F2's silent-data-loss (there can no longer be two days on one weekday, so Today's single loggable day is always correct). (F2) |
| **PD10** | Delete-trainee semantics | **CONFIRMED 2026-09-14 — soft-delete / deactivation is the V1 behavior.** Deactivate is the primary **reversible** action; **no permanent hard-delete/purge in V1.** A removed trainee's historical **plans, logs, progress, and notes stay intact.** Permanent purge is considered for **V1.1+**. (Removes today's hard-delete-login asymmetry by deactivating rather than purging the login.) (F19) |

**Consequences for the redesign & backend backlog (from the locked decisions):**
- **PD1** adds two backend guardrails (second-coach block + `TraineeId`-reassignment reject/bind) and keeps the data model `CoachId`-free.
- **PD4** and **PD6** each add a **new backend endpoint** (trainee progress **update**; trainee **profile self-edit** restricted to phone/email/birthdate/current-weight) plus the matching restricted mobile screens.
- **PD5** adds a **range-adherence backend input + a coach date selector** on the dashboard.
- **PD2/PD3/PD7/PD8** are mostly **document/label/filter** decisions for V1 (defer the heavier build to V1.1).
- **PD9** makes the **F2** fix a **weekday-uniqueness validation** (reject a duplicate scheduled weekday) — no per-day logging in V1, no schema change; **PD10** normalizes delete-trainee to **soft-delete/deactivation** (no hard purge in V1; history preserved).

## 20.2 Decision detail & rationale

These change *what screens the redesign builds*, so decide them **before** the redesign starts.

| # | Decision | Why it matters | Recommendation |
|---|---|---|---|
| **PD1** | **Tenant model: confirm one-coach-per-tenant, or support multi-coach-per-tenant?** | There is no `CoachId`; the whole coach isolation model depends on this. Multi-coach needs ownership everywhere + a roster. | **Confirm one-coach-per-tenant for V1** and document/guard tenant provisioning; defer multi-coach to a later major version. (F18/F42-owner, templates B3/B4, libraries B1.) |
| **PD2** | **Nutrition: keep consumption-only logs, or add prescribed-vs-actual?** | Determines the nutrition log/tracking screens and a backend field. | Add planned-vs-actual if adherence-at-item-level matters to coaches; else document consumption-only. (F10) |
| **PD3** | **Off-plan / manual logging in V1 or V1.1?** | Adds a picker flow; affects Today + history. | Ship from-plan in V1; add manual logging in V1.1. (F9, plan D3) |
| **PD4** | **Progress: allow trainee to edit own entry? Who can delete whose on the shared timeline? Show attribution?** | Changes progress screens + a backend rule. | Give trainee read-back + edit-own; restrict trainee delete to self-authored; show creator. (F3, F4) |
| **PD5** | **Adherence window: day vs range; add a coach date selector?** | Changes the dashboard screens + a backend input. | Add weekly/range adherence + selector; show "not logged yet today". (F5) |
| **PD6** | **Trainee self-edit profile?** | Adds a backend endpoint + a screen. | Allow restricted self-edit (contact fields). (F13) |
| **PD7** | **Coach note privacy (add `IsPrivate`)?** | Affects the note model + editor. | At minimum label notes as "shared with trainee"; consider a private flag. (F17) |
| **PD8** | **Should trainees see inactive/draft plans?** | Adds a draft state or a list filter. | Hide inactive from trainees (or add draft/published). (F12) |
| **PD9** | **Multi-day-per-weekday: legal or forbidden?** | Determines Today's log UI. | Decide; if legal, add per-day logging; if not, enforce uniqueness. (F2) |
| **PD10** | **Delete-trainee: recoverable or fully purged?** | Soft/hard-delete asymmetry today. | Make it consistent. (F19) |

**Already-resolved decisions** (from `CoachApp-Mobile-Plan.md`, confirmed against code): D1 `offline_access`/refresh — **resolved** (seeded + wired); D2 tenant onboarding — **resolved** (gym-code → tenant name); D8 push — out of V1.

---

# 21. Recommended Next Steps (prioritized)

1. ✅ **DONE 2026-09-14 — PD1–PD10 locked** (see §20.1). PD1 confirmed one-coach-per-tenant (+ second-coach guardrail + F18 `TraineeId`-reassignment hardening, no `CoachId`); PD6 restricted trainee self-edit (phone/email/birthdate/current-weight). *(Product — done.)*
2. **Do one authenticated live E2E pass** covering the flows not in the 2026-09-13 run — especially **Templates** (save-as-template → clone → activate → trainee sees it) and the security scenarios D1–D5 with two trainees. Convert the [PRIOR-LIVE]/code-verified items to freshly-verified. *(QA — in progress.)*
3. **Fold the P1 correctness/safety fixes into the redesign** (they are not skin-deep): **F1** (serving-size — needs a backend DTO field), **F2**, **F3/F4**, **F5**, **F6**, **F7**. *(Both.)*
4. **Redesign the screens** on top of the locked decisions and fixed rules.
5. **Address P2** during the redesign where the screen is already being touched (F8, F11, F12, F14, F15, F16, F20, F21).
6. **Security hardening pass** (P3): F18/PD1 guardrails, F24 unique-active index, F38 debug-logging cleanup, F39/F40 login/session hygiene, F23 delete permissions.
7. **Release readiness** (separate track): Firebase/iOS config, bundle id, signing, icons, crash reporting.

---

# Verdict & Final Report

## Verdict

**READY FOR UI/UX REDESIGN — conditional on locking the product decisions below first.**

Rationale: the audit found **no security, data-isolation, or crash blocker** for the intended V1 model. Trainee-level and tenant-level isolation are **strictly enforced and provable in the backend source**; every endpoint is authorized; the core create → activate → log → track loop is coherent and rule-correct (one-active-plan is genuinely enforced, prescribed values are correctly snapshotted, templates round-trip with full fidelity, deleting a referenced library item is safely blocked). The real findings are **business-logic / product-semantics and UX issues** — labeling, affordance gating, empty states, adherence windowing, progress-editing flow — which a UI/UX redesign will rework anyway. Fixing them in the *current* UI first would be wasted effort. **The one hard precondition is that the product decisions (especially PD1, the tenant model) are locked before the redesign**, because they determine which screens and data shapes the redesign must build.

## Must-fix items (genuine V1 blockers)
There are **no blockers that prevent starting the redesign** for the single-coach-per-tenant model. The following are **must-fix as part of the redesign** (P1) — not skin-deep, some need backend changes — and must not be dropped:
- **F1** — nutrition servings shown as grams (safety: up to ~100× mis-entry). *Needs a backend DTO field.*
- **F2** — multi-day-same-weekday: only the first day is loggable (silent data loss).
- **F3 + F4** — trainee progress: no read-back/edit, tap-to-delete, and cross-actor deletion with no attribution.
- **F5** — nutrition adherence day-scoped + coach pinned to "today" + 0%-before-logging.
- **F6** — a templates-only coach cannot reach Templates.
- **F7** — "Log this workout" creates a phantom completed log on an accidental tap.
- **PD1 must be answered:** if multi-coach-per-tenant is ever in scope, the absence of `CoachId` (**F18**) becomes a **critical isolation blocker** and must be built into the backend before such tenants exist.

## Recommended improvements (non-blocking, ideally during the redesign)
F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F19, F20, F21 (P2) — see §17.

## V1.1 / Future (safe to defer)
Rich coach dashboard/roster, off-plan logging, nutrition prescribed-vs-actual, range adherence, trainee self-edit, draft plans, progress photos, exercise media playback, note privacy, push, offline/a11y/intl, Firebase/iOS/release. See §19.

## Product decisions (LOCKED 2026-09-14)
**PD1–PD10 are locked** — see §20.1. **PD1 confirmed one coach per tenant** (with a second-coach guardrail + the F18 `TraineeId`-reassignment hardening, and no `CoachId`); **PD6** grants the trainee a **restricted** self-edit (phone/email/birthdate/current-weight only; username immutable; goals/targets Coach-owned); all other PDs adopted as proposed. The implied code changes are folded into the redesign (§21), **not yet implemented**.

## Recommended execution order
1. Lock **PD1–PD10** (PD1 first).
2. One authenticated live E2E pass (Templates + security scenarios).
3. Fold **P1** fixes (F1, F2, F3/F4, F5, F6, F7) into the redesign; add the backend `servingSize` field for F1.
4. Run the UI/UX redesign on the locked decisions.
5. Sweep **P2** where screens are already touched.
6. Security/hardening pass (**P3**).
7. Release-readiness track (Firebase/iOS/signing).

---

*This document reflects the code as of 2026-09-14 on both repositories and the product-intent docs in `C:\src\BACK\CoachApp\docs`. The code and Swagger remain the ultimate authority; where the Arabic workflow doc disagrees (e.g. log editing), the code is correct and that doc is a stale early snapshot.*
