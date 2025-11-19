

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../theme/presentation/bloc/theme_event.dart';
import '../../../theme/presentation/bloc/theme_state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // List of drawer items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerHeader(context),
                  const SizedBox(height: AppTheme.spacing8),

                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/analytics');
                    },
                  ),

                  const Divider(height: AppTheme.spacing16),

                  _buildThemeToggle(context),

                  const Divider(height: AppTheme.spacing16),

                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact: support@propertyapp.com'),
                        ),
                      );
                    },
                  ),

                  const Divider(height: AppTheme.spacing16),

                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Bottom app info
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                children: [
                  Text(
                    'Property Listing App',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLarge),
          bottomRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacing8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: Icon(Icons.person, size: 40, color: AppColors.white),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            "John Smith",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            "john.smith@gmail.com",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing4,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                state.isDarkMode ? 'Enabled' : 'Disabled',
              ),
              value: state.isDarkMode,
              onChanged: (_) {
                context.read<ThemeBloc>().add(const ToggleThemeEvent());
              },
              secondary: Icon(
                state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: state.isDarkMode ? AppColors.primary : AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property Listing App',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Version: 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Built with Flutter & BLoC architecture for a seamless property browsing experience.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Features:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacing8),
              const Text('• Browse properties with advanced filtering'),
              const Text('• Track analytics and user interactions'),
              const Text('• Dark mode support'),
              const Text('• Responsive design for all devices'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
