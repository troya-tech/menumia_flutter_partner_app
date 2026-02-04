# Flutter Layout Guidelines

## Unbounded Height/Width Errors

### ❌ DON'T: Nest Scrollables without Constraints

```dart
Column(
  children: [
    Text("Header"),
    // ❌ ERROR: Vertical viewport was given unbounded height
    ListView.builder( 
      itemBuilder: (c, i) => Text("Item $i"),
    ),
  ],
)
```

### ✅ DO: Use Expanded or ShrinkWrap

**Option A: Expand to fill remaining space (Best Performance)**
```dart
Column(
  children: [
    Text("Header"),
    Expanded( // ✅ Gives ListView a definite height constraint
      child: ListView.builder(
        itemBuilder: (c, i) => Text("Item $i"),
      ),
    ),
  ],
)
```

**Option B: Shrink to fit content (Use sparingly)**
```dart
Column(
  children: [
    Text("Header"),
    ListView.builder(
      shrinkWrap: true, // ✅ Calculates height based on children
      physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
      itemBuilder: (c, i) => Text("Item $i"),
    ),
  ],
)
```

## Why?

A `Column` allows its children to be as tall as they want (unbounded height). A `ListView` tries to be as tall as it can be (infinite height) to allow scrolling. 
*   **Infinity + Unbounded = Layout Error.**

Using `Expanded` tells the ListView: "You can only be as tall as the remaining screen space."
