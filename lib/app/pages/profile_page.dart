import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/app/providers.dart';
import 'package:menumia_flutter_partner_app/app/routing/app_routes.dart';
import 'package:menumia_flutter_partner_app/app/services/profile_page_facade.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

/// Profile page for user account management
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static final _logger = AppLogger('ProfilePage');

  @override
  void initState() {
    super.initState();
    // Initialization handled by HomePage
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final facade = ref.watch(profilePageFacadeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: userAsync.when(
            data: (user) {
              if (user == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'User Profile Not Found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your account is authenticated, but no user profile exists in the database yet.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? '',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 32),

                  _RestaurantSelectionCard(),
                  
                  const SizedBox(height: 32),
                  _ProfileOption(
                    icon: Icons.person_outline,
                    title: 'Account Information',
                    subtitle: 'Update your personal details',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Password and security settings',
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, ref),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.auth,
                    (route) => false,
                  );
                }
              } catch (e) {
                _logger.error('Logout failed', e);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _RestaurantSelectionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(relatedRestaurantsProvider);
    final activeIdAsync = ref.watch(activeRestaurantIdProvider);

    return restaurantsAsync.when(
      data: (restaurants) {
        if (restaurants.isEmpty) return const SizedBox.shrink();

        final activeId = activeIdAsync.asData?.value;
        final activeRestaurant = restaurants.firstWhere(
          (r) => r.id == activeId,
          orElse: () => restaurants.first,
        );

        return Card(
          child: ListTile(
            leading: Icon(
              Icons.storefront,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Active Restaurant'),
            subtitle: Text(activeRestaurant.restaurantName),
            trailing: const Icon(Icons.swap_horiz),
            onTap: () => _showSelectionDialog(context, ref, restaurants, activeId),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    List<Restaurant> restaurants,
    String? activeId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Restaurant'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: restaurants.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final isActive = restaurant.id == activeId;
              return ListTile(
                title: Text(
                  restaurant.restaurantName,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                trailing: isActive ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(restaurantContextServiceProvider).setActiveRestaurant(restaurant.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
