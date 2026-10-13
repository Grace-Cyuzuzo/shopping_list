# Shopping List+

A Flutter shopping list app built during Mobile Programming (Week 2, Session 3).

## Features

- Add items by typing in the field and tapping Add (or pressing Enter).
- Delete any item with the bin icon.
- Mark items as bought by tapping (crossed out + tick icon).
- Clear all bought items with the top-bar button.
- Title shows how many items are still left to buy.
- Empty state shows "Your list is empty" when there are no items.
- Every item has a quantity (− / + buttons, never below 1).
- Adding an item that already exists raises its quantity instead of duplicating it.
- Deleting shows an Undo button that restores the item in the same position.
- Filter chips: All / To buy / Bought. Bought items sink to the bottom of All.
- Long-press an item to open Item details (name, note, category).

## How to run

1. Clone this repository.
2. Run `flutter pub get`.
3. Run `flutter run -d chrome` (or on an emulator).

## Think

1. **Why does deleting by index remove the wrong item when a filter is on?**
   Because `index` comes from the filtered list (`shown`), but `items` is unchanged.
   Row 0 on screen is not item 0 in `items` when a filter is active.
   Fixed by removing the item itself: `items.remove(removed)`.

2. **Why remove `final` from `name`?**
   Because the details screen now changes the name, and `final` means "set once, never changed".
   `final` is still good for most fields — it makes code safer and clearer when a value truly never changes.

3. **Why hot restart after adding `quantity` to `Item`?**
   Hot reload keeps the app's state. That state was built with the old `Item` class, which had no `quantity`.
   The new code expects the field, so the app crashes. Hot restart rebuilds the state from scratch.

4. **Why did the list show the old name until `setState` in `.then`?**
   Because Flutter only redraws when a widget's `build` is called again.
   The details screen changed the item, but the list had no reason to rebuild.
   `setState` in `.then` tells Flutter "something changed, redraw".

## Screenshots

Coming soon — will be added to the `screenshots/` folder.

## Project structure

- `lib/main.dart` — the whole app.
- `android/`, `ios/`, `web/` — platform shells.
- `pubspec.yaml` — project settings and dependencies.
