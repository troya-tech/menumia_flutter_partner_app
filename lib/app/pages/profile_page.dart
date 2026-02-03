import 'package:flutter/material.dart';
import '../services/profile_page_facade.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant.dart';
import '../../services/auth_service.dart';
import '../routing/app_routes.dart';

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
              // Debug logging
              print('[ProfilePage] StreamBuilder - connectionState: ${snapshot.connectionState}');
              print('[ProfilePage] StreamBuilder - hasData: ${snapshot.hasData}');
              print('[ProfilePage] StreamBuilder - hasError: ${snapshot.hasError}');
              print('[ProfilePage] StreamBuilder - data: ${snapshot.data}');
              
              // Show loading indicator while waiting for data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Show error if stream has error
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final user = snapshot.data;
              
              // Show message if user data not found in database
              if (user == null && snapshot.connectionState == ConnectionState.active) {
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
                        Text(
                          'Your account is authenticated, but no user profile exists in the database yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please contact your administrator to set up your profile.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
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
                    user?.displayName ?? 'No Name',
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
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                // Sign out
                await AuthService().signOut();
                
                // Close loading indicator
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Navigate to auth screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.auth,
                    (route) => false,
                  );
                }
              } catch (e) {
                // Close loading indicator
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
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
