# Edit Category Order

## Use Case Description
As a restaurant partner, I want to reorder my menu categories so that I can control how they appear to customers in the app.

## Flow
1.  Navigate to the **Categories Page**.
2.  Tap the **3-dot menu** (context menu) in the top navigation bar (AppBar).
3.  Select **"Kategori Sıralaması Düzenle"** (Edit Category Order).
4.  User is navigated to the **Category Reorder Page**.
5.  Drag and drop categories to reorder them.
6.  Tap **"Kaydet"** (Save).
7.  The new order is saved to **Firebase Realtime Database**.
8.  User is navigated back to the Categories Page, showing the new order.

## Implementation Details
-   **Entry Point**: `CategoriesPage` (`lib/app/pages/home_page/widgets/categories_page.dart`)
-   **Reorder Page**: `CategoryReorderPage` (`lib/app/pages/home_page/widgets/category_reorder_page.dart`)
-   **Service**: `MenuService` (`lib/features/menu/application/services/menu_service.dart`)
-   **Repository**: `FirebaseMenuRepository` (`lib/features/menu/infrastructure/repositories/firebase_menu_repository.dart`)

## Data Updates
-   The `displayOrder` field of the `Category` entity is updated.
-   The update is performed via `menuService.updateCategoriesOrder(menuKey, categories)`.
-   **Critical**: The `menuKey` must be dynamic (current active restaurant), not hardcoded.

## Verification
-   Change order in the app.
-   Refresh the app or check Firebase Console to ensure the order persists.
