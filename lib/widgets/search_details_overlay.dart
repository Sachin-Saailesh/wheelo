import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/search_results_screen.dart';

class SearchDetailsOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final String initialLocation;

  const SearchDetailsOverlay({
    super.key,
    required this.onClose,
    required this.initialLocation,
  });

  @override
  State<SearchDetailsOverlay> createState() => _SearchDetailsOverlayState();
}

class _SearchDetailsOverlayState extends State<SearchDetailsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _locationController = TextEditingController();
  String _selectedType = 'Car';
  DateTimeRange? _selectedDates;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.initialLocation;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _closeOverlay() async {
    await _controller.reverse();
    widget.onClose();
  }

  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.skyBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _selectedDates = picked;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeOverlay,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onTap: () {},
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.pearlWhite,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: _closeOverlay,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Plan Your Trip',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // VEHICLE TYPE
                          const Text(
                            'VEHICLE TYPE',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedType = 'Car'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'Car'
                                          ? AppTheme.skyBlue.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedType == 'Car'
                                            ? AppTheme.skyBlue
                                            : Colors.black26,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 18,
                                          color: _selectedType == 'Car'
                                              ? AppTheme.skyBlue
                                              : Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Car',
                                          style: TextStyle(
                                            color: _selectedType == 'Car'
                                                ? AppTheme.skyBlue
                                                : Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedType = 'Bike'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'Bike'
                                          ? AppTheme.skyBlue.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedType == 'Bike'
                                            ? AppTheme.skyBlue
                                            : Colors.black26,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pedal_bike,
                                          size: 18,
                                          color: _selectedType == 'Bike'
                                              ? AppTheme.skyBlue
                                              : Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bike',
                                          style: TextStyle(
                                            color: _selectedType == 'Bike'
                                                ? AppTheme.skyBlue
                                                : Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // DROP-OFF LOCATION
                          const Text(
                            'DROP-OFF LOCATION',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _locationController,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Where to drop off?',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.skyBlue,
                              ),
                              fillColor: AppTheme.greyBackground,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // PICK-UP & DROP-OFF DATES (Simplified)
                          const Text(
                            'PICK-UP DATE & TIME',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _selectDates,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.greyBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppTheme.skyBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDates == null
                                        ? 'mm/dd/yyyy, --:-- --'
                                        : '${_selectedDates!.start.day}/${_selectedDates!.start.month}/${_selectedDates!.start.year}',
                                    style: TextStyle(
                                      color: _selectedDates == null
                                          ? Colors.black54
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'DROP-OFF DATE & TIME',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _selectDates,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.greyBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppTheme.skyBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDates == null
                                        ? 'mm/dd/yyyy, --:-- --'
                                        : '${_selectedDates!.end.day}/${_selectedDates!.end.month}/${_selectedDates!.end.year}',
                                    style: TextStyle(
                                      color: _selectedDates == null
                                          ? Colors.black54
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _closeOverlay();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SearchResultsScreen(
                                      location: _locationController.text,
                                      type: _selectedType,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF6B4DFF,
                                ), // Purple accent from spec
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: const Text(
                                'Find Vehicles',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
