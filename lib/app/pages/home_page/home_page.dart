import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/kategoriler_page.dart';
import '../orders_page.dart';
import '../profile_page.dart';
import '../../services/home_page_facade.dart';

/// Home page for Menumia Partner App
/// Main landing page after authentication
/// Contains bottom navigation between Kategoriler, Siparişler, and Profile
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageFacade _facade;
  int _selectedIndex = 0; // Default to 0 (Categories) as it's always present

  @override
  void initState() {
    super.initState();
    _facade = HomePageFacade();
  }

  @override
  void dispose() {
    _facade.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show Kategoriler, Orders, and Profile pages
    final pages = <Widget>[
      const KategorilerPage(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: 'Kategori',
      ),
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
