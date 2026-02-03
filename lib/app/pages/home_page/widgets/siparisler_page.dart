import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../routing/app_routes.dart';

/// Siparişler (Orders) page component
/// Displays and manages restaurant orders
class SiparislerPage extends StatelessWidget {
  const SiparislerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar content
        Container(
          color: AppColors.navbarBackground,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Siparişler',
                      style: TextStyle(
                        color: AppColors.navbarText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, color: AppColors.navbarText),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Page content
        Expanded(
          child: Center(
            child: Text(
              'Sipariş İçeriği',
              style: TextStyle(
                color: AppColors.navbarText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
