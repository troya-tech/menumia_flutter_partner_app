import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'widgets/categories_page.dart';
import '../orders_page.dart';
import '../profile_page.dart';
import '../../providers.dart';

/// Home page for Menumia Partner App
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize global restaurant context
    ref.read(restaurantContextServiceProvider).init();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderingEnabledAsync = ref.watch(orderingEnabledProvider);
    final orderingEnabled = orderingEnabledAsync.asData?.value ?? false;

    // Build pages list based on orderingEnabled flag
    final pages = <Widget>[
      const CategoriesPage(),
      if (orderingEnabled) const OrdersPage(),
      const ProfilePage(),
    ];

    // Build navigation items based on orderingEnabled flag
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

    // Ensure selected index is valid
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.brightBlue,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.navbarBackground,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
