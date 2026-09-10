# reference_pending/

These files were ported verbatim from the reference JasimExpress app's `lib/core` but
**depend on feature code that CoachApp does not have yet** (they couple `core` → delivery
`features/...`). They are kept here — **outside `lib/`, so they are not compiled** — so nothing
is lost. Re-home each one into `lib/` and adapt it to the CoachApp coaching domain when you build
the matching feature.

| File | Needs (before it can go back into `lib/`) |
|---|---|
| `core/services/excel_export_service.dart` | An `OrderModel` equivalent — rebuild for the CoachApp report you actually export (e.g. progress/nutrition), or drop. |
| `core/services/notification_router.dart` | The CoachApp target screens for a notification tap (trainee → today's plan, coach → trainee detail). Re-point `_openOrderFromData` in `lib/core/classes/notification.dart` at the new router. |
| `core/ui/screens/driver_order_deeplink_screen.dart` | Delivery driver order screens — replace with the CoachApp deep-link target, or drop. |
| `core/ui/screens/splash_screen.dart` | The auth + role home screens it routes to (login, trainee/coach home). Rebuild the app-shell splash once CoachApp auth + roles exist. |
| `core/ui/widgets/home_top_bar.dart` | The notifications feature + profile screen it links to. |

## What was changed to keep `lib/core` compiling
- `lib/core/di/injection.dart` — reduced to a clean `setUp()` stub (feature registrations removed).
- `lib/core/utils/functions/token_validator.dart` — `checkToken()` keeps the expiry check but drops
  the auth-feature refresh (re-add when the CoachApp auth feature exists).
- `lib/core/classes/notification.dart` — dropped the `notification_router` import; the tap handler
  logs instead of routing until the CoachApp router/screens exist.
