# Flutter Navigation & State Management Best Practices

This document outlines specific patterns to avoid "Wiggling" (Infinite Rebuild Loops) and Unstable Navigation in the Menumia Flutter Partner App.

## 1. Stable Navigation State (Enum vs Index)

**Problem:**
When using `int _selectedIndex` for `BottomNavigationBar`, conditional tabs (e.g., an "Orders" tab that appears only when enabled) cause index shifting.
- *Scenario:* User is on "Profile" (Index 2). "Orders" (Index 1) is disabled. "Profile" becomes Index 1.
- *Result:* The app suddenly switches tabs or resets navigation, causing a confusing UX.

**Solution:**
ALWAYS use a stable identifier (Enum) to track the selected tab, never a raw integer index.

```dart
// ✅ GOOD: Use Enum for state
enum AppTab { categories, orders, profile }

class _HomePageState extends State<HomePage> {
  AppTab _selectedTab = AppTab.profile; // State is an Enum

  @override
  Widget build(BuildContext context) {
    // 1. Define available tabs dynamically
    final availableTabs = [
      AppTab.categories,
      if (orderingEnabled) AppTab.orders,
      AppTab.profile
    ];

    // 2. Validate selection
    if (!availableTabs.contains(_selectedTab)) {
      _selectedTab = AppTab.categories; // Fallback
    }

    // 3. Derive index only for the widget
    final currentIndex = availableTabs.indexOf(_selectedTab);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => setState(() => _selectedTab = availableTabs[index]),
      // ...
    );
  }
}
```

## 2. Preventing Rebuild Loops (Side-Effects)

**Problem:**
Triggering global state initialization (e.g., `ref.read(provider).init()`) inside `initState` of a child widget (e.g., `ProfilePage`) can cause infinite loops.
- *Cycle:* 
  1. `ProfilePage` mounts -> calls `init()`.
  2. `init()` updates a Provider.
  3. `HomePage` watches that Provider -> Rebuilds layout.
  4. Layout change forces `ProfilePage` to unmount & remount.
  5. `ProfilePage` calls `init()` again -> **LOOP**.

**Solution:**
- Initialize global data ONCE in a stable parent widget (`HomePage`) or via a dedicated `StartupService`.
- **NEVER** place side-effects that trigger upstream rebuilds inside the `initState` of a child widget that is subject to conditional rendering (like tabs).

```dart
// ❌ BAD: Child initializing global state
class ProfilePage extends State {
  @override
  void initState() {
    ref.read(globalProvider).init(); // Triggers rebuild of parent!
  }
}

// ✅ GOOD: Parent handles initialization
class HomePage extends State {
  @override
  void initState() {
    ref.read(globalProvider).init(); // Stable parent
  }
}
```
