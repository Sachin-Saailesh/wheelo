import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/vehicle.dart';
import '../widgets/pill_button.dart';
import 'kyc_verification_screen.dart';

class BookingScreen extends StatefulWidget {
  final Vehicle vehicle;

  const BookingScreen({super.key, required this.vehicle});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _paymentMethod = 'UPI'; // Default payment
  String _insuranceTier = 'Basic';
  bool _addHelmet = false;
  bool _addPillion = false;
  final TextEditingController _promoController = TextEditingController();

  int get _hours {
    if (_startDate == null ||
        _endDate == null ||
        _startTime == null ||
        _endTime == null)
      return 0;
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final end = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    final duration = end.difference(start);
    return duration.inHours > 0 ? duration.inHours : 0;
  }

  double get _baseTotal => _hours * widget.vehicle.pricePerHour;

  double get _insuranceCost {
    if (_insuranceTier == 'Premium') return 150.0;
    if (_insuranceTier == 'Zero Dep') return 300.0;
    return 0.0; // Basic
  }

  double get _addonsCost {
    double total = 0;
    if (_addHelmet) total += 50.0;
    if (_addPillion) total += 100.0;
    return total;
  }

  double get _estimatedTotal => _baseTotal + _insuranceCost + _addonsCost;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _confirmBooking() async {
    if (_estimatedTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select valid rental dates and times.'),
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final end = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final success = await appState.createBooking(
      widget.vehicle,
      start,
      end,
      _paymentMethod,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Force them to hit 'Done'
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Center(
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 30,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your ride is locked in. The host has been notified.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: PillButton(
                text: 'Done',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Pop back to home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          if (isStart) {
            _startDate = date;
            _startTime = time;
          } else {
            _endDate = date;
            _endTime = time;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Booking')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Summary
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.vehicle.thumbnailUrl,
                      width: 100,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 100,
                        height: 70,
                        color: AppTheme.greyBackground,
                        child: const Icon(Icons.car_rental),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.vehicle.brand} ${widget.vehicle.model}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '₹${widget.vehicle.pricePerHour.toStringAsFixed(0)} / hr',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // KYC Alert
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'KYC Verification Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your KYC is pending. Please complete it to book.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KYCVerificationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Complete KYC'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Date/Time Selectors
              Text(
                'Rental Duration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              _buildDateTimeSelector(
                'Pickup',
                Icons.arrow_upward,
                Colors.green,
                _startDate,
                _startTime,
                () => _pickDateTime(true),
              ),
              const SizedBox(height: 16),
              _buildDateTimeSelector(
                'Drop-off',
                Icons.arrow_downward,
                Colors.red,
                _endDate,
                _endTime,
                () => _pickDateTime(false),
              ),

              const SizedBox(height: 32),

              // Add-ons & Extras
              Text(
                'Add-ons & Extras',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _addHelmet,
                onChanged: (val) => setState(() => _addHelmet = val ?? false),
                title: const Text('Extra Helmet'),
                subtitle: const Text('+ ₹50'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _addPillion,
                onChanged: (val) => setState(() => _addPillion = val ?? false),
                title: const Text('Pillion Rider Allowed'),
                subtitle: const Text('+ ₹100'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              // Insurance
              Text(
                'Insurance & Protection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                value: 'Basic',
                groupValue: _insuranceTier,
                onChanged: (val) => setState(() => _insuranceTier = val!),
                title: const Text('Basic (Free)'),
                subtitle: const Text('Standard coverage.'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'Premium',
                groupValue: _insuranceTier,
                onChanged: (val) => setState(() => _insuranceTier = val!),
                title: const Text('Premium (+ ₹150)'),
                subtitle: const Text('Lower liability in case of damage.'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'Zero Dep',
                groupValue: _insuranceTier,
                onChanged: (val) => setState(() => _insuranceTier = val!),
                title: const Text('Zero Dep (+ ₹300)'),
                subtitle: const Text('Full coverage, zero liability.'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              Text(
                'Promos & Discounts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promoController,
                decoration: InputDecoration(
                  hintText: 'Apply promo code',
                  filled: true,
                  fillColor: AppTheme.greyBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Promo code applied')),
                      );
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: AppTheme.skyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Payment Method
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.greyBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: ['UPI', 'Credit/Debit Card', 'Net Banking']
                    .map(
                      (method) =>
                          DropdownMenuItem(value: method, child: Text(method)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _paymentMethod = val!);
                },
              ),

              const SizedBox(height: 32),

              // Price Breakdown
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ride Fare'),
                        Text('₹${_baseTotal.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_insuranceCost > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Insurance'),
                          Text('₹${_insuranceCost.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_addonsCost > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Add-ons'),
                          Text('₹${_addonsCost.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Estimated',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_estimatedTotal.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.skyBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'By selecting Book Now, you confirm that you have read and agree to the Terms of Service & Privacy Policy.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              PillButton(
                text: 'Confirm & Pay',
                isLoading: isLoading,
                onPressed: _confirmBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(
    String label,
    IconData icon,
    Color iconColor,
    DateTime? date,
    TimeOfDay? time,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              radius: 16,
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  if (date != null && time != null)
                    Text(
                      '${date.day}/${date.month}/${date.year} at ${time.format(context)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  else
                    const Text(
                      'Select Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
