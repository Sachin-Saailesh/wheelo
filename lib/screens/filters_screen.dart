import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_button.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _priceRange = const RangeValues(10, 150);
  String _selectedVehicleType = 'Car';
  String _selectedSeating = '5';
  String _selectedTransmission = 'Automatic';
  String _selectedFuel = 'Petrol';
  String _selectedDistance = 'Within 5 km';

  void _clearAll() {
    setState(() {
      _priceRange = const RangeValues(10, 150);
      _selectedVehicleType = 'Car';
      _selectedSeating = '5';
      _selectedTransmission = 'Automatic';
      _selectedFuel = 'Petrol';
      _selectedDistance = 'Within 5 km';
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChoiceChips(
    List<String> options,
    String selectedValue,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.skyBlue : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppTheme.skyBlue : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filters',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price range
                    _buildSectionTitle('Price range'),
                    const Text(
                      'The average daily price is \$65',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    // Mock Histogram
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(20, (index) {
                        return Container(
                          width: 8,
                          height: (index % 5 + 1) * 10.0 + (index % 3) * 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 300,
                      activeColor: AppTheme.skyBlue,
                      inactiveColor: Colors.black12,
                      onChanged: (values) {
                        setState(() => _priceRange = values);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_priceRange.start.toInt()}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _priceRange.end >= 300
                              ? '\$300+'
                              : '\$${_priceRange.end.toInt()}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.black12, height: 48),

                    // Vehicle Type
                    _buildSectionTitle('Vehicle Type'),
                    _buildChoiceChips(
                      ['Car', 'Bike', 'Scooter'],
                      _selectedVehicleType,
                      (val) => setState(() => _selectedVehicleType = val),
                    ),

                    // Seating Capacity
                    _buildSectionTitle('Seating Capacity'),
                    _buildChoiceChips(
                      ['2', '4', '5', '7+'],
                      _selectedSeating,
                      (val) => setState(() => _selectedSeating = val),
                    ),

                    // Transmission
                    _buildSectionTitle('Transmission'),
                    _buildChoiceChips(
                      ['Automatic', 'Manual'],
                      _selectedTransmission,
                      (val) => setState(() => _selectedTransmission = val),
                    ),

                    // Fuel Type
                    _buildSectionTitle('Fuel Type'),
                    _buildChoiceChips(
                      ['Petrol', 'Diesel', 'Electric'],
                      _selectedFuel,
                      (val) => setState(() => _selectedFuel = val),
                    ),

                    // Distance
                    _buildSectionTitle('Location'),
                    _buildChoiceChips(
                      ['Within 5 km', 'Within 10 km', 'Within 20 km'],
                      _selectedDistance,
                      (val) => setState(() => _selectedDistance = val),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: PillButton(
                text: 'Show 200+ results',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
