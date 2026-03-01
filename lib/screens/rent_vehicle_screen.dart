import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/vehicle.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/search_details_overlay.dart';
import 'vehicle_details_screen.dart';
import 'host_registration_screen.dart';

class RentVehicleScreen extends StatefulWidget {
  const RentVehicleScreen({super.key});

  @override
  State<RentVehicleScreen> createState() => _RentVehicleScreenState();
}

class _RentVehicleScreenState extends State<RentVehicleScreen> {
  bool _isSearchOverlayVisible = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Monthly', 'Car', 'Bike'];

  void _toggleSearchOverlay() {
    setState(() {
      _isSearchOverlayVisible = !_isSearchOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Area
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleSearchOverlay,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.greyBackground,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.black54),
                                const SizedBox(width: 12),
                                Text(
                                  'Search anywhere',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs Row
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.skyBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? null
                                : Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Vehicle List
                Expanded(child: _buildVehicleList(appState)),
              ],
            ),
          ),

          // Search details overlay (40% height top-down)
          if (_isSearchOverlayVisible)
            SearchDetailsOverlay(
              initialLocation: _searchController.text,
              onClose: () {
                setState(() {
                  _isSearchOverlayVisible = false;
                });
              },
            ),

          // Nav Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 20, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(
                    Icons.search,
                    'Explore',
                    true,
                    () {},
                  ), // we are here
                  _buildNavItem(
                    Icons.favorite_border,
                    'Favorites',
                    false,
                    () {},
                  ),
                  _buildNavItem(Icons.car_rental, 'Booking', false, () {}),
                  _buildNavItem(Icons.person_outline, 'Account', false, () {}),
                  _buildNavItem(Icons.add_circle_outline, 'Host', false, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HostRegistrationScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.skyBlue : Colors.black54,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.skyBlue : Colors.black54,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(AppState appState) {
    if (appState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.skyBlue),
      );
    }

    return StreamBuilder<List<Vehicle>>(
      stream: appState.vehicleStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.skyBlue),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading vehicles',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final vehicles = snapshot.data ?? [];

        if (vehicles.isEmpty) {
          return const Center(
            child: Text(
              'No vehicles available',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 120,
            left: 16,
            right: 16,
          ), // space for bottom nav
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(
              vehicle: vehicle,
              isDark: true, // Matches Dark Feed spec
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
