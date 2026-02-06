import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'widgets/categories_page.dart';
import '../orders_page.dart';
import '../profile_page.dart';
import '../../providers/providers.dart';

/// Home page for Menumia Partner App
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

enum AppTab { categories, orders, profile }

class _HomePageState extends ConsumerState<HomePage> {
  AppTab _selectedTab = AppTab.categories;

  @override
  void initState() {
    super.initState();
    // Initialize global restaurant context
    ref.read(restaurantContextServiceProvider).init();
  }

  void _onItemTapped(int index, List<AppTab> currentTabs) {
    setState(() {
      _selectedTab = currentTabs[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderingEnabledAsync = ref.watch(orderingEnabledProvider);
    // Use valueOrNull to preserve state during loading
    final orderingEnabled = orderingEnabledAsync.valueOrNull ?? false;

    // Define available tabs based on configuration
    final availableTabs = [
      AppTab.categories,
      if (orderingEnabled) AppTab.orders,
      AppTab.profile,
    ];

    // Ensure selection is valid; if current tab is gone, fallback to profile (if valid) or categories
    if (!availableTabs.contains(_selectedTab)) {
      // If we lost the current tab (e.g. orders disabled), fallback safely
      _selectedTab = AppTab.categories;
    }

    // Build pages map
    final pages = {
      AppTab.categories: const CategoriesPage(key: ValueKey('categories')),
      AppTab.orders: const OrdersPage(key: ValueKey('orders')),
      AppTab.profile: const ProfilePage(key: ValueKey('profile')),
    };

    // Calculate current index for BottomNavigationBar
    final currentIndex = availableTabs.indexOf(_selectedTab);

    // Build navigation items
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: 'Kategori',
      ),
      if (orderingEnabled)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Siparişler',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: currentIndex,
          children: availableTabs.map((tab) => pages[tab]!).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.brightBlue,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.navbarBackground,
        onTap: (index) => _onItemTapped(index, availableTabs),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
