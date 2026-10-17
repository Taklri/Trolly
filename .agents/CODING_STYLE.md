# Trolly classroom coding guide

## Purpose

When implementing tasks in this project, use the straightforward Flutter/Dart techniques demonstrated in `.agents/dataref/router/lib`. Keep the code organized, readable, and explainable by a student who learned from those examples. Prefer what the reference already uses over introducing a different programming style or framework.

This guide describes observed code patterns, not a verified syllabus or a claim about everything the professor has taught. Do not claim that a new technique came from the professor if it is absent from the reference. Preserve honest explanations of implementation choices and assistance.

## Reference map

Paths below are relative to the Flutter project root.

| Reference file | What it demonstrates |
| --- | --- |
| `.agents/dataref/router/lib/main.dart` | `runApp`, `StatelessWidget`, `MaterialApp`, `ThemeData`, a named `routes` map, and an initial `home` screen |
| `.agents/dataref/router/lib/globs/allusers2.dart` | A class holding a static `List<Map<String, dynamic>>`, initial records, and string map keys |
| `.agents/dataref/router/lib/globs/activeuser.dart` | Shared current-user data in a static `Map<String, dynamic>` |
| `.agents/dataref/router/lib/globs/allmovies.dart` | A static map declaration; no implemented movie storage workflow |
| `.agents/dataref/router/lib/screens/register.dart` | `StatefulWidget`, state fields, controllers, `setState`, `if`/`else if`, indexed `for`, flags, `break`, `.add`, and error text |
| `.agents/dataref/router/lib/screens/login.dart` | Reading controller text, searching a list, assigning the active record, and passing named-route arguments |
| `.agents/dataref/router/lib/screens/home.dart` | Reading shared map data with interpolation and button-driven navigation |
| `.agents/dataref/router/lib/screens/profile.dart`, `contact.dart`, `aboutme.dart` | Simple display screens and clearing shared user state before replacement navigation |
| `.agents/dataref/router/lib/screens/watchlist.dart` | A `Widget movieCard(...)` helper returning a basic widget tree |
| `.agents/dataref/router/lib/screens/deets.dart` | A display screen; route-argument extraction appears only in commented code |

Read the relevant reference file and the actual target screen before making a change. Reference code is study material: implement the task in the project's real `lib/`, not in `.agents/dataref/router/`.

## Organization

Use the structure already demonstrated:

```text
lib/
  main.dart          App setup, theme, and route registration
  screens/           Screen widgets and their local task logic
  globs/             Simple shared in-memory data holders
```

Keep one screen's main widget and its `State` class together in its screen file. Put controllers, local flags, error strings, and event methods in that `State` class. Use a shared class in `globs/` only for data needed by multiple screens.

The active Trolly app already has additional files such as `models/` and `services/`. Preserve and reuse working existing features when a task touches them; do not delete or rewrite those layers just to match the reference. For new work, prefer the simpler reference approach when it satisfies the requirement.

Use descriptive file and variable names consistent with adjacent app code. Use the current package name or local relative imports; do not copy `package:router/...` into the Trolly app.

## Default implementation techniques

### Widgets and local state

- Use `StatelessWidget` for screens that only display data and navigate.
- Use `StatefulWidget` with a separate `State<...>` class when input, errors, selections, or displayed data change locally.
- The reference names the widget `RegisterState` and the state class `RegisterPage`. Understand this pairing, but keep existing Trolly class names rather than renaming them to force that naming convention.
- Declare simple fields explicitly: `String err = '';`, `bool isTaken = false;`, and `TextEditingController nameController = TextEditingController();`.
- Use `setState(() { ... });` for values whose changes must rebuild the current screen. Keep validation and navigation easy to follow in named methods.
- Use normal method calls from callbacks: `onPressed: () { saveItem(); }` or `onPressed: saveItem` when the signature fits.
- Prefer a short `Widget itemCard(...)` method for repeated presentation, following `movieCard`. Extract a separate widget only when reuse or complexity makes it useful; do not build a component framework for a small screen.

### Data and logic

- Prefer ordinary variables, `List<Map<String, dynamic>>`, `Map<String, dynamic>`, and simple static holder classes for new shared in-memory records when they are sufficient.
- Keep map keys consistent between creation and reading. Write down a record's expected keys near its declaration if they are not obvious.
- Use direct assignments, map access, `.add(...)`, string interpolation, `.isEmpty`, `.length`, comparisons, and boolean conditions as demonstrated.
- Prefer an indexed `for (int i = 0; i < records.length; i++)` with `if` and `break` for searches. Avoid replacing a readable beginner loop with chained transformations or terse functional expressions.
- Validate in an explicit `if` / `else if` / `else` chain. Set a clear error message, and only save or navigate when the input is valid.
- Reset temporary flags for each operation. Use a straightforward success/found flag when needed so a failed lookup can show an error.
- Shared static data does not automatically rebuild other screens and does not survive app restarts. Handle a required refresh explicitly; use existing app persistence when the task needs retained data.

### Inputs

Use `TextField(controller: ...)`, read `.text` in an event method, and display an `err` string through `Text(err, ...)`. Use `obscureText: true` for password input when relevant. Do not introduce form builders or validation packages for checks that fit ordinary conditions.

### Navigation

Register screen routes in the existing `MaterialApp.routes` map in `lib/main.dart`. Use `Navigator.pushNamed` to open a route and `Navigator.pushReplacementNamed` when the previous screen should be replaced, matching the reference's logout pattern. Use the existing app's back-navigation convention for returning.

Pass a map with named keys if route data is needed:

```dart
Navigator.pushNamed(
  context,
  '/item-details',
  arguments: {'name': itemName, 'price': itemPrice},
);
```

The login sample demonstrates map arguments. The watchlist sample instead passes a set of values, and the details sample's map extraction is commented out. Do not treat those two samples as a working end-to-end argument contract. Make the sending and receiving types match and handle missing arguments clearly when implementing that feature.

### UI construction

Build readable nested Flutter widgets, following `Scaffold`, `AppBar`, `Center`, `Column`, `Text`, `TextField`, `ElevatedButton`, `Container`, `SizedBox`, `Icon`, and `TextStyle` from the examples. Keep business steps in named methods instead of burying a long algorithm in `build` or `onPressed`.

Apply [the Trolly UI skill](skills/trolly-flutter-ui/SKILL.md) for appearance. Its styling guidance does not require changing the app's data or state architecture. Use basic Flutter layout/styling additions as needed for the requested design, and identify them as additions rather than techniques confirmed by this reference.

## Small example in this style

This is an illustrative pattern for a new in-memory feature, not an instruction to replace existing Trolly data or persistence. Put the data holder in `globs/` and the screen in `screens/`, with the appropriate import between them.

```dart
class ItemData {
  static List<Map<String, dynamic>> items = [];
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => AddItemPage();
}

class AddItemPage extends State<AddItemScreen> {
  TextEditingController nameController = TextEditingController();
  String err = '';

  void saveItem() {
    String name = nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        err = 'Enter an item name.';
      });
    } else {
      Map<String, dynamic> newItem = {'name': name};
      ItemData.items.add(newItem);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add item')),
      body: Column(
        children: [
          Text('Item name'),
          TextField(controller: nameController),
          Text(err, style: TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: saveItem, child: Text('Save')),
        ],
      ),
    );
  }
}
```

The example adds `.trim()`, controller disposal, and `Navigator.pop` to the reference's basic pattern. Its minimal layout demonstrates code organization; use the UI guide for the finished screen layout.

## Keep the approach simple without copying mistakes

Follow the reference's level of abstraction, not its accidental defects:

- Dispose controllers when a screen is removed. This lifecycle cleanup is not shown in the reference, but should be included for correctness.
- Do not copy the username check's inconsistent minimum and message (`< 5` versus "3 characters"). Make validation messages match actual conditions.
- Avoid nested `setState` calls like the registration flow's validation calling another method that also calls `setState`. Update state deliberately and navigate after validation succeeds.
- Do not copy `onPressed: () => {valData()}` as the preferred callback. That expression constructs a set; a normal callback block or method tear-off is clearer.
- Show an error when a search fails; the sample login currently has no failed-login feedback.
- Do not preserve unused flags, dead/commented experiments, or debug prints just because they appear in a teaching example. Never print passwords or full user records containing passwords.
- Do not copy the example's admin credentials, exam identifiers, account limit, or movie content into unrelated tasks. Those are sample data and exercise rules, not general requirements.
- The reference stores passwords in plain in-memory records for a classroom exercise. It does not demonstrate production authentication; do not extend that mechanism into a real deployed sign-in system.

## Techniques outside the reference

Do not introduce Provider, Riverpod, BLoC, GetX, GoRouter, dependency injection, repositories, code generation, custom extensions, streams, databases, or remote APIs for a new task that the demonstrated tools can reasonably solve. Do not add packages merely for convenience.

This is a default preference, not a reason to break required behavior or remove existing working code. If the task requires something absent from the reference:

1. Check whether the active Trolly app already implements it and reuse that implementation.
2. Prefer the smallest understandable Dart/Flutter addition. Explain its purpose and state that it is not demonstrated by the reference.
3. If a substantial new technique is unavoidable and course constraints are uncertain, explain the concrete gap and ask for direction. Continue independent work that does not depend on that choice.

Do not make routine tasks depend on repeated approval for simple correctness or layout improvements.

## Completing a task

Keep the patch focused, format changed Dart files, and run the project's relevant analysis and checks. Exercise the changed input, validation, and navigation behavior where possible. Describe which reference patterns the solution follows and any necessary additions in plain language, so the student can understand and explain the actual code. Do not claim an unperformed check passed or that reference compliance proves compliance with an unknown course rubric.
