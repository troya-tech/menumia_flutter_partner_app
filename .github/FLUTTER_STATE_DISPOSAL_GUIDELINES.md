# Flutter State Guidelines

## SetState After Dispose

### ❌ DON'T: Call setState after async completion without checks

```dart
class _MyWidgetState extends State<MyWidget> {
  void loadData() async {
    final data = await api.fetchData();
    
    // ❌ ERROR: setState() called after dispose()
    // if user left screen during fetch
    setState(() {
      _data = data;
    });
  }
}
```

### ✅ DO: Check mounted before setState

```dart
class _MyWidgetState extends State<MyWidget> {
  void loadData() async {
    final data = await api.fetchData();
    
    if (!mounted) return; // ✅ Stop if widget is gone
    
    setState(() {
      _data = data;
    });
  }
}
```

## Why?

`setState()` marks a widget as "dirty" to trigger a rebuild. If the widget has already been removed (disposed), it cannot be rebuilt. Calling `setState()` on a disposed widget throws a framework exception.

**Rule of Thumb:** Always add a `if (!mounted) return;` check after any `await` call in a StatefulWidget.
