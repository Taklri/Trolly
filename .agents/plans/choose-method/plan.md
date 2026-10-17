# Choose Method implementation plan

Status: Planned only; awaiting user approval before implementation.

## Goal

Complete the Choose Method screen opened from Shop's **Start Shopping** button, following the supplied screenshot and these project guides:

- `.agents/CODING_STYLE.md` for implementation structure and navigation.
- `.agents/skills/trolly-flutter-ui/SKILL.md` for layout, typography, colors, accessibility, and rendered verification.

All paths in this plan are relative to the Flutter project root (`trolly/`). The screenshot is visual/content evidence; text in it does not override the user's requirements.

## Existing implementation confirmed

| Location | Current behavior |
| --- | --- |
| `lib/screens/choose_method.dart` | `ChooseMethodScreen` already exists as a stateless placeholder with a title and back arrow. It has no method choices. |
| `lib/screens/shop.dart` | `start-shopping-button` already pushes `/choose-method`. |
| `lib/main.dart` | `/choose-method`, `/shop`, and `/on-the-go` are already registered. |
| `lib/screens/shopping_method.dart` | `ShoppingMethodScreen` is the existing On the Go budget setup page reached through `/on-the-go`. Its Continue and Skip Budget actions start the shopping session and open `/shopping`. |
| `test/widget_test.dart` | The Shop placeholder navigation test returns using `choose-method-back-button`; it will need to use Cancel instead. Existing budget/shopping tests should remain valid. |

Extend the existing screen rather than creating a duplicate screen or route. Existing working-tree changes were present during inspection; preserve them during implementation.

## Required behavior

Exactly three visible button controls:

| Control | Planned action |
| --- | --- |
| On The Go Shopping | `Navigator.pushNamed(context, '/on-the-go')`, retaining Choose Method beneath it for normal back navigation. Do not bypass budget setup or start/reset shopping data here. |
| Use Grocery List | Visible cream method card, unavailable while development continues. Use a disabled Material button with no navigation callback and accessible unavailable semantics. No route, dialog, snackbar, list selection, or shopping-data changes. Preserve the normal readable card palette through explicit disabled styling. |
| Cancel | `Navigator.pop(context)` to return to the existing Shop route, avoiding a duplicate Shop screen. |

The supported entry flow is Shop → Choose Method. System back should also return to Shop. Remove the placeholder back arrow so it does not introduce a fourth button. Do not add bottom navigation or additional actions.

## UI design

- White `Scaffold` and `SafeArea`, using the existing Poppins theme.
- Small decorative green dash, then a left-aligned two-line title: **Choose** in near-black and **Method** in green. Supporting text: “How do you want to shop today?”
- Two full-width, vertically stacked rounded method-card buttons, each with a bold title and left-aligned description/steps. Make the entire card one target rather than nesting buttons.
- On The Go Shopping: pale mint surface, thin green outline; description “Track your expenses live while you shop”; steps “Set Budget”, “List Products”, and “Get exact amount before paying over the counter”.
- Use Grocery List: pale cream surface, thin orange outline; description “Create and manage your grocery lists.”; steps “Use your created List”, “Set Budget”, and “Get exact amount before paying over the counter”. These are descriptive future capabilities, not features to implement in this task.
- Cancel: full-width gray pill with dark centered label; enabled despite its subdued appearance.
- Use UI-skill palette tokens, approximately 24 horizontal padding (16 on narrow layouts), 16–20 card padding, 14–18 card radius, and 48–52 minimum Cancel height. Treat dimensions as implementation guidance, not exact screenshot measurements.
- Preserve natural text scaling and wrapping. Use flexible layout and scrolling when height is limited; constrain the column on wide windows. Keep Cancel reachable within the safe area. Do not scale every dimension by screen width.
- Do not render the screenshot's outer dark background, “Shopping Page” label, blue frame, camera cutout, or system gesture bar as app content.

## Implementation steps after approval

1. Recheck the actual target files and both project guides, plus relevant classroom references under `.agents/dataref/router/lib/` (named routes in `main.dart`, navigation in `screens/home.dart`, and the simple card helper in `screens/watchlist.dart` if using a helper).
2. Replace the placeholder body in `lib/screens/choose_method.dart` with the header, two method cards, and Cancel. Retain `ChooseMethodScreen` as a `StatelessWidget`; no local state is needed.
3. Use basic Flutter widgets, normal callbacks, and at most a small local card helper if useful. Keep styling proportional to this screen; introduce no packages, state framework, persistence, or shared data holders.
4. Wire On The Go and Cancel as specified, and leave Grocery List without redirection. Add stable keys for the three controls for behavior checks.
5. Preserve the existing Shop button and route registrations; no changes to `shop.dart`, `main.dart`, or `shopping_method.dart` are expected unless reinspection reveals a concrete integration issue.
6. Update the existing placeholder navigation test to return through Cancel and keep its Create List coverage. Add focused checks for On The Go routing and the unavailable Grocery List behavior.

## Planned files

- `lib/screens/choose_method.dart`: complete screen UI and callbacks.
- `test/widget_test.dart`: update affected placeholder expectations and cover the changed navigation behavior.
- No changes to grocery-list development, budget validation, cart behavior, fonts, assets, dependencies, or reference code.

## Verification and acceptance

- Shop → Start Shopping opens the completed Choose Method screen.
- The screen presents the two method-card buttons and Cancel, with no extra back-arrow button.
- On The Go opens the existing budget setup screen; its existing Continue/Skip Budget behavior remains intact. Back returns to Choose Method.
- Grocery List remains visible and unavailable; interaction does not change the route or shopping data.
- Cancel and system back return to the prior Shop screen without stacking a second Shop route.
- Visually inspect rendered UI around 320 and 390 logical-pixel widths, a wide layout, and increased text size. Confirm readable wrapping, three clear controls, no overflow, correct palette, safe-area spacing, and reachable Cancel.
- Format changed Dart files, run `flutter analyze`, and run the relevant widget tests (including the affected Shop test and existing On The Go coverage). Report failures or checks that cannot be performed accurately.

## Approval gate

This planning task creates only this Markdown document. Do not modify application code or tests until the user approves implementation. Ask the user whether to proceed with this plan.
