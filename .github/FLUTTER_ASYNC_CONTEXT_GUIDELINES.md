# Flutter Async Context Guidelines

## BuildContext Across Async Gaps

### ❌ DON'T: Use context after await without checking mounted

```dart
void onButtonTap(BuildContext context) async {
  await someLongRunningOperation();
  
  // ❌ CRASH: Widget might be unmounted (e.g., user left screen)
  Navigator.pop(context); 
  // OR
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

### ✅ DO: Check mounted property before using context

```dart
void onButtonTap(BuildContext context) async {
  await someLongRunningOperation();
  
  if (!context.mounted) return; // ✅ Safety check
  
  Navigator.pop(context);
}
```

*Note: In StatefulWidgets, check `if (!mounted) return;` instead.*

## Why?

If a user navigates away from the screen while `await` is running:
1. The widget is removed from the tree (unmounted).
2. The `context` becomes invalid/detached.
3. Accessing `Navigator`, `Theme`, or `ScaffoldMessenger` via this context throws: **"Looking up a deactivated widget's ancestor is unsafe."**
