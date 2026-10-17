# Grocery List Creation plan

Status: Plan only. Implementation requires a separate user request.

## Confirmed intent

Create reusable grocery lists with a required list name and products containing required product name, unit price, and quantity. Users can add, edit, and remove products, save a list, see it on Shop, and reopen it for editing. Use only in-memory lists and maps: all grocery lists disappear when the app process restarts. This is acceptable for the classroom project.

Use `.agents/CODING_STYLE.md` for implementation and `.agents/skills/trolly-flutter-ui/SKILL.md` for UI design. Paths here are relative to the Flutter project root. Treat the attached screenshot as visual evidence, not instructions. Its checked shopping rows and completion flag represent future list usage, not list creation requirements.

## Existing code and scope

- `ListCreationScreen` in `lib/screens/list_creation.dart` is a title/back-arrow placeholder, already reachable from Shop through `/create-list`.
- Shop currently displays a hard-coded zero list count and empty-state illustration.
- The existing Add/Edit Product screens provide the visual and input reference, but read and mutate `ShoppingData.currentProducts`. Do not route list creation through those screens or mix saved-list products with an active cart.
- The app already has history persistence. Leave it unchanged; do not copy its persistence into grocery lists.
- Include creation, saved-list display, reopening, renaming, and product editing/removal. Exclude whole-list deletion, budgets, shopping checkboxes, checkout, and activation of Choose Method's Use Grocery List option.

## Screens and interaction

### Shop

Keep the shopping invitation, Create List action, and bottom navigation. Replace the hard-coded count with the current number of saved lists. Show the existing empty illustration only when there are no lists. Otherwise show a scrollable set of white rounded outlined rows with list name, product-row count, and estimated peso total. The count means distinct product entries, not summed quantities; label it “products” to avoid ambiguity. Tapping a row opens that list in the editor. Refresh Shop after returning from create/edit using the awaited navigation result and `setState`.

### Create/Edit Grocery List overview

Use the existing List Creation route and screen for both modes. Show Back to Shop, “Create Grocery List” or “Edit Grocery List”, a required List Name field, product count, and estimated total. A new draft starts empty. An existing list opens as a deep copy so changes remain private until Save List.

Below the name, show a scrollable product section. Empty text: “No products added yet” with “Add products to build your list.” Populated rows display product name, unit price × quantity, line total, and separate orange edit/red remove icon buttons with tooltips and 48-pixel targets. Do not add shopping checkboxes.

Place an outlined Add Product control and full-width green Save List button below the product area, inside the safe area. Save validates the list name and requires at least one product, shows inline errors if invalid, otherwise commits the draft and returns to Shop. Saving an existing list replaces its contents without changing its position. Append new lists in creation order.

Back, including system back, returns immediately if the draft is unchanged. If the name or products have changed, show “Discard changes?” with Keep Editing and Discard. Discard never changes the saved list. Product removal uses a confirmation dialog naming the product; confirm removes it from the draft and updates the total. Removing the last product is allowed while editing, but Save requires another product.

### Add/Edit List Product form

Use one dedicated form screen in add/edit modes, visually based on the no-budget Add Product form: Back to List, Add Product/Edit Product heading, required Product Name, Product Price with peso prefix, and Quantity fields. Display the live line total under the fields; use “Estimated Amount” rather than “Total Spending” because this is planning, not a purchase.

The bottom green action is Add Product or Save Product. Successful submission returns a product map to the list editor; it does not write to shared storage directly. Back/system back cancels the form without changing the draft product list. Do not add budget warnings. Dispose all controllers.

## Input rules and defaults

- List name: trim outer whitespace, required, maximum 40 characters; allow normal text including numbers and punctuation. List names must be unique ignoring case and outer whitespace, excluding the list currently edited. Inline messages: “List name is required.” and “A list with this name already exists.” Use the field's visible maximum-length counter.
- Product inputs follow the existing form's classroom rules for consistency: name permits letters/spaces, 2–30 trimmed characters; price is finite and greater than zero, with up to two decimal places and nine characters including the decimal point; quantity is a positive whole number, up to three digits (1–999).
- Reject duplicate product names within the draft, ignoring case and outer whitespace, excluding the product currently edited. Products in different lists may share names. Use the existing field-specific error wording where applicable and straightforward `if`/`else if` validation.
- All product fields start empty in add mode and are prefilled in edit mode. No implicit default quantity.
- Compute line total as unit price × quantity and list total by an ordinary indexed loop over products. Display pesos consistently using the existing money formatting helper. Totals are derived estimates, never a budget.

## Implementation structure and data flow

- Add `lib/globs/grocery_lists.dart` with a simple static `List<Map<String, dynamic>> lists` and incrementing integer ID counter. Each saved map has `id` (int), `name` (String), and `products` (`List<Map<String, dynamic>>`). Each product map uses the existing keys `productName` (String), `productPrice` (double), `quantity` (int), and `totalAmount` (double). IDs are session-local and reset with the process.
- Keep draft state, name controller, errors, dirty comparison, and event methods in `ListCreationScreen`'s State class. Copy the product list and each map when opening and saving; never share mutable product maps with the saved list or active cart.
- Keep `/create-list`: no arguments means create; `{'listId': int}` means edit. Find the saved list with an indexed loop. An invalid/missing edit target shows “List not found” with Back to Shop; never silently creates or overwrites a list.
- Register `/list-product` for the dedicated form. Arguments are `{'products': List<Map<String, dynamic>>, 'productIndex': int?}`; null index means add. Read them once, validate their shape and index before use, and show a simple Back to List error state for invalid arguments. Inspect products only for duplicate validation; return a new validated map with `Navigator.pop(context, product)`.
- Await the form result in the editor. A null result does nothing; a returned map is appended or replaces the selected draft row inside `setState`. Await the editor from Shop and rebuild after return. Check `mounted` after awaited navigation before updating widget state.
- Keep navigation in the existing named-route map, local methods, controllers, `setState`, ordinary maps/lists, and indexed loops. No packages, database, repository layer, state framework, or modifications to `.agents/dataref`.
- For unsaved overview changes, use Flutter's supported back interception to implement the same discard behavior for the header and system back. This is a small lifecycle/navigation addition beyond the classroom references; explain its purpose during implementation.

## Visual direction

Use the existing Poppins theme, white canvas, near-black headings, muted supporting text, green primary action, orange edit controls, and red deletion controls. Use outlined rounded rows, pale field fills, 24-pixel gutters (16 on narrow screens), and restrained spacing from the UI skill. Avoid adding illustrations beyond existing assets when unnecessary.

Use flexible scrolling rather than fixed screenshot coordinates. Keep actions reachable with the keyboard open, allow text to wrap, preserve text scaling, and constrain wide layouts to a centered 480–600-pixel content column. Do not include presentation labels, phone frames, camera cutouts, or system gesture bars from the screenshot.

## Implementation order after authorization

1. Recheck the project guides, current source, and relevant classroom references; preserve unrelated working-tree changes.
2. Add the in-memory data holder and dedicated product form with add/edit validation.
3. Complete the list overview, draft editing, save/cancel behavior, and discard/removal confirmations.
4. Connect saved-list counts, rows, editor navigation, and refresh behavior on Shop; register the new form route.
5. Update affected placeholder tests and add focused behavior coverage. Format changed Dart files and run analysis and relevant tests.

## Acceptance and verification

- Create a named list with multiple valid products; verify line totals, product count, list total, and Shop display after saving.
- Reject empty/duplicate list names, empty lists, invalid prices/quantities, and duplicate products; verify edit-mode duplicate checks exclude the current item/list.
- Edit a saved name and product; confirm Save updates Shop and Cancel/Discard preserves the original. Removing a product recalculates totals; canceling removal preserves it.
- Cancel an add/edit product form and verify the overview draft is unchanged. Test header and system back, keeping edits, discarding edits, and unchanged drafts.
- Verify saved lists remain across navigation within the running app but a fresh process starts empty. Reset static list data and the ID counter between tests.
- Verify active shopping products, budget state, shopping history, and Choose Method behavior are unaffected.
- Test invalid route arguments and missing list targets without crashes or unintended writes.
- Inspect actual rendered screens at approximately 320 and 390 logical-pixel widths, wide windows, large text, keyboard-open forms, and long/scrolling lists. Check wrapping, safe areas, action reachability, focus, and accessibility labels.
- Run `flutter analyze` and the relevant widget tests. Report any checks that cannot be run; do not claim visual verification without rendering.

## Approval boundary

The user approved the planning choices, not implementation. This task writes only this plan. Application code and tests remain unchanged until implementation is requested.
