import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design/app_colors.dart';
import '../design/app_typography.dart';
import '../design/app_spacing.dart';
import '../ui/components/app_scaffold.dart';
import '../ui/components/app_card.dart';
import '../providers/app_state.dart';
import 'rent_vehicle_screen.dart';
import 'host_registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('cachedUserName') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('FAQ coming soon')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppColors.textDisabled),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seeding mock vehicles...')),
              );
              await context.read<AppState>().seedMockVehiclesIfEmpty();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to Wheelo',
              style: AppTypography.textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hello, $_userName',
              style: AppTypography.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Designed for Seamless Experience',
              style: AppTypography.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),

            _buildOptionButton(
              context,
              title: 'Rent a vehicle',
              icon: Icons.directions_car_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RentVehicleScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOptionButton(
              context,
              title: 'Become a host',
              icon: Icons.key_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HostRegistrationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      color: AppColors.primary,
      usePrimaryShadow: true,
      padding: EdgeInsets.zero,
      child: Container(
        height: 120,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textInverse, size: 36),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: AppTypography.textTheme.displaySmall?.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
