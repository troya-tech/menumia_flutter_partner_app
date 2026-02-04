# TextEditingController Disposal Error - Fix Documentation

## Error Message

```
A TextEditingController was used after being disposed.
Once you have called dispose() on a TextEditingController, it can no longer be used.
```

## Root Cause

When a `TextEditingController` is created inside a method that calls `showDialog()`, and then disposed **after** the dialog returns, a race condition occurs:

1. User taps outside the dialog (barrier dismiss)
2. Dialog starts closing animation
3. `await showDialog()` returns immediately
4. `controller.dispose()` is called
5. Flutter is **still rebuilding** the TextField during the dismiss animation
6. **CRASH** - TextField tries to use the disposed controller

### Problematic Code Pattern

```dart
Future<void> _showAddCategoryDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: TextField(
          controller: nameController,  // ❌ Uses controller
          // ...
        ),
      );
    },
  );
  
  nameController.dispose();  // ❌ Disposed too early - widget may still exist!
}
```

## Solution

Move the `TextEditingController` into a **StatefulWidget** so Flutter manages its lifecycle properly.

### Fixed Code Pattern

```dart
// 1. Call site - no controller management needed
Future<void> _showAddCategoryDialog(BuildContext context) async {
  String categoryName = '';

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _AddCategoryDialog(
        onCategoryNameChanged: (name) => categoryName = name,
        onAdd: () {
          if (categoryName.isNotEmpty) {
            _addNewCategory(categoryName);
            Navigator.pop(dialogContext);
          }
        },
        onCancel: () => Navigator.pop(dialogContext),
      );
    },
  );
}

// 2. StatefulWidget properly manages controller lifecycle
class _AddCategoryDialog extends StatefulWidget {
  final ValueChanged<String> onCategoryNameChanged;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddCategoryDialog({
    required this.onCategoryNameChanged,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      widget.onCategoryNameChanged(_nameController.text.trim());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();  // ✅ Disposed by Flutter when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _nameController,
        // ...
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: Text('İptal')),
        TextButton(onPressed: widget.onAdd, child: Text('Ekle')),
      ],
    );
  }
}
```

## Why This Works

| Aspect | Before (Broken) | After (Fixed) |
|--------|-----------------|---------------|
| Controller creation | In method scope | In `initState()` |
| Controller disposal | After `showDialog` returns | In widget's `dispose()` |
| Lifecycle management | Manual (error-prone) | Flutter framework (automatic) |

Flutter's widget lifecycle ensures `dispose()` is called **only after** the widget is fully removed from the tree, including any dismiss animations.

## Key Takeaway

> **Never** manually dispose a `TextEditingController` that's used by a widget in a dialog. Let Flutter handle it via a StatefulWidget.

---

*Fixed in: `lib/app/pages/home_page/widgets/categories_page.dart`*  
*Date: 2026-02-04*
