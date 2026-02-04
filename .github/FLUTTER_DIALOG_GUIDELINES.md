# Flutter Dialog Guidelines

## TextEditingController in Dialogs

### ❌ DON'T: Dispose controller after showDialog returns

```dart
Future<void> showMyDialog(BuildContext context) async {
  final controller = TextEditingController();
  
  await showDialog(
    builder: (ctx) => AlertDialog(
      content: TextField(controller: controller),
    ),
  );
  
  controller.dispose(); // ❌ Causes crash on barrier dismiss
}
```

### ✅ DO: Use StatefulWidget for controller lifecycle

```dart
Future<void> showMyDialog(BuildContext context) async {
  String value = '';
  await showDialog(
    builder: (ctx) => _MyDialog(
      onChanged: (v) => value = v,
      onSubmit: () { /* use value */ Navigator.pop(ctx); },
    ),
  );
}

class _MyDialog extends StatefulWidget { /* ... */ }

class _MyDialogState extends State<_MyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ Flutter handles timing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: TextField(controller: _controller),
  );
}
```

## Why?

When user taps outside dialog (barrier dismiss):
1. `showDialog` returns immediately
2. Manual `dispose()` runs
3. Flutter still animating dismiss → **TextField accesses disposed controller → CRASH**

Using StatefulWidget, Flutter calls `dispose()` only after widget is fully removed.
