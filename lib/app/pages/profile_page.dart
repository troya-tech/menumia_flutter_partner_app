import 'package:flutter/material.dart';
import '../services/profile_page_facade.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant.dart';

/// Profile page for user account management
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePageFacade _facade;

  @override
  void initState() {
    super.initState();
    _facade = ProfilePageFacade()..init();
  }

  @override
  void dispose() {
    _facade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<RestaurantUser?>(
            stream: _facade.currentUser$,
            builder: (context, snapshot) {
              final user = snapshot.data;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  
                  // Profile avatar
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
                  
                  // User name
                  Text(
                    user?.displayName ?? 'Loading...',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  
                  // User email
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 32),

                  // ACTIVE RESTAURANT SELECTION CARD
                  _RestaurantSelectionCard(facade: _facade),
                  
                  const SizedBox(height: 32),
                  
                  // Profile options
                  _ProfileOption(
                    icon: Icons.person_outline,
                    title: 'Account Information',
                    subtitle: 'Update your personal details',
                    onTap: () {
                      // TODO: Navigate to account info page
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _ProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences',
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _ProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Password and security settings',
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _ProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // TODO: Navigate to help page
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement logout
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout logic
              Navigator.of(context).pop();
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

class _RestaurantSelectionCard extends StatelessWidget {
  final ProfilePageFacade facade;

  const _RestaurantSelectionCard({required this.facade});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Restaurant>>(
      stream: facade.relatedRestaurants$,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Hide if no restaurants or loading
        }

        final restaurants = snapshot.data!;

        return StreamBuilder<String?>(
          stream: facade.activeRestaurantId$,
          builder: (context, activeSnapshot) {
            final activeId = activeSnapshot.data;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Active Restaurant',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (restaurants.isEmpty)
                     const Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Text("No restaurants found."),
                     )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurants.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final restaurant = restaurants[i];
                        final isActive = restaurant.id == activeId;
                        
                        return ListTile(
                          title: Text(restaurant.restaurantName),
                          subtitle: Text('Open: ${restaurant.openHour} - ${restaurant.closeHour}'),
                          trailing: isActive 
                              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                              : const Icon(Icons.circle_outlined),
                          tileColor: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
                          onTap: () {
                            facade.setActiveRestaurant(restaurant.id);
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}

/// Profile option list item widget
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
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
