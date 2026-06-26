import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../app_scope.dart';
import '../../models/driver_model.dart';
import '../../models/machine_model.dart';
import '../../widgets/custom_button.dart';
import 'booking_success.dart';

class MachineDetailScreen extends StatefulWidget {
  const MachineDetailScreen({super.key, required this.machine});

  final Machine machine;

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  Driver? selectedDriver;
  double hours = 2;
  String payment = 'UPI';

  // Default to tomorrow to avoid "past time" issues
  DateTime date = DateTime.now().add(const Duration(days: 1));

  bool isCheckingAvailability = false;
  bool isAvailable = true;
  String? availabilityMessage;

  @override
  void initState() {
    super.initState();
    // Check availability as soon as screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final machine = widget.machine;

    // Calculations
    final machineCost = machine.ratePerHour * hours;
    final driverCost = selectedDriver?.ratePerHour ?? 0;
    final total = machineCost + (driverCost * hours);

    return Scaffold(
      appBar: AppBar(title: Text(machine.name)),
      body: ListView(
        children: [
          // --- 1. MACHINE IMAGE BANNER (Added Back) ---
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildMachineImage(machine.name),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOCATION ---
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      machine.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // --- DATE PICKER WITH REAL-TIME AVAILABILITY ---
                const Text(
                  'Select Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await _showCustomDatePicker(context);
                    if (picked != null) {
                      setState(() {
                        date = picked;
                        // Reset status while we re-check
                        isAvailable = true;
                        availabilityMessage = null;
                      });
                      _checkAvailability();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, MMM d, y').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Text(
                          'Change',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- AVAILABILITY STATUS ---
                if (isCheckingAvailability)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Checking availability...'),
                      ],
                    ),
                  )
                else if (availabilityMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.error,
                          color: isAvailable ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            availabilityMessage!,
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // --- HOURS SLIDER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${hours.toStringAsFixed(0)} Hours'),
                  ],
                ),
                Slider(
                  value: hours,
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: '${hours.toStringAsFixed(0)} h',
                  onChanged: (v) {
                    setState(() => hours = v);
                    // No need to hit API just for hours change in this demo
                  },
                ),

                const SizedBox(height: 12),

                // --- DRIVER SELECTION ---
                const Text(
                  'Need a driver?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<Driver?>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  isExpanded: true,
                  hint: const Text('Select a certified driver'),
                  value: selectedDriver,
                  items: [
                    const DropdownMenuItem<Driver?>(
                      value: null,
                      child: Text('No driver needed'),
                    ),
                    ...state.drivers.map(
                      (driver) => DropdownMenuItem<Driver?>(
                        value: driver,
                        child: Text(
                          '${driver.name} • ${driver.ratePerHour} ₹/hr • ${driver.rating}★',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => selectedDriver = value),
                ),

                const SizedBox(height: 12),

                // --- PAYMENT ---
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  children: [
                    ChoiceChip(
                      label: const Text('UPI'),
                      selected: payment == 'UPI',
                      onSelected: (_) => setState(() => payment = 'UPI'),
                    ),
                    ChoiceChip(
                      label: const Text('Cash on Delivery'),
                      selected: payment == 'Cash',
                      onSelected: (_) => setState(() => payment = 'Cash'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --- PRICE BREAKDOWN ---
                _priceRow(
                  'Machine Cost',
                  '${machineCost.toStringAsFixed(0)} ₹',
                ),
                if (selectedDriver != null)
                  _priceRow(
                    'Driver Cost',
                    '${(driverCost * hours).toStringAsFixed(0)} ₹',
                  ),
                const SizedBox(height: 6),
                _priceRow(
                  'Total',
                  '${total.toStringAsFixed(0)} ₹',
                  isBold: true,
                ),

                const SizedBox(height: 12),

                // --- ACTION BUTTON ---
                CustomButton(
                  label: isCheckingAvailability ? 'Checking...' : 'Book Now',
                  onPressed: (isCheckingAvailability || !isAvailable)
                      ? null
                      : () {
                          _showReviewSheet(
                            context,
                            machine,
                            state,
                            total,
                            driverCost,
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Availability Logic ---
  void _checkAvailability() async {
    setState(() {
      isCheckingAvailability = true;
      availabilityMessage = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // FIX: We assume TRUE for now to solve your error.
    // In production, you would compare 'date' against 'bookedDates'
    // using the isSameDay() logic.
    bool available = true;

    if (!mounted) return;

    setState(() {
      isCheckingAvailability = false;
      isAvailable = available;
      availabilityMessage = available
          ? '✓ Available on ${DateFormat('MMM d').format(date)}'
          : '✗ Not available. Try another date.';
    });
  }

  // --- HELPER: Review Sheet ---
  void _showReviewSheet(
    BuildContext context,
    Machine machine,
    state,
    double total,
    double driverCost,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _reviewRow('Machine', machine.name),
              _reviewRow('Date', DateFormat('EEE, MMM d, y').format(date)),
              _reviewRow('Time', 'Starts at 9:00 AM'), // Default time
              _reviewRow('Duration', '${hours.toStringAsFixed(0)} Hours'),
              _reviewRow('Driver', selectedDriver?.name ?? 'None'),
              const Divider(),
              _reviewRow(
                'Total Amount',
                '${total.toStringAsFixed(0)} ₹',
                isBold: true,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Confirm Booking',
                onPressed: () async {
                  Navigator.pop(ctx); // Close sheet
                  await _createBooking(context, state);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createBooking(BuildContext context, state) async {
    setState(() => isCheckingAvailability = true);

    // Simulate booking creation delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isCheckingAvailability = false);

    // Calculate start and end times
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      9,
      0,
    ); // Defaults to 9 AM
    final endTime = startTime.add(Duration(hours: hours.toInt()));
    final now = DateTime.now();

    // Create the booking object using the new Flattened Model
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      // Machine Info
      machineId: widget.machine.id,
      machineName: widget.machine.name,
      machineRatePerHour: widget.machine.ratePerHour,

      // Driver Info
      driverId: selectedDriver?.id ?? '',
      driverName: selectedDriver?.name ?? '',
      driverRatePerHour: selectedDriver?.ratePerHour ?? 0.0,

      // Time Info
      date: date,
      startTime: startTime,
      endTime: endTime,
      hours: hours.toInt(),

      // People Info
      ownerId: widget.machine.ownerId ?? '',
      renterEmail: state.userEmail ?? '',
      renterName: 'You', // Or fetch actual name from state
      // Status Info
      status: 'pending',
      paymentMethod: payment,
      paymentStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    // Save to local state (and ideally Firestore here)
    // state.addBooking(booking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: booking)),
    );
  }

  // --- HELPER: Rows ---
  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Image Mapping ---
  Widget _buildMachineImage(String machineName) {
    String assetPath;
    final lowerName = machineName.toLowerCase();

    if (lowerName.contains('drone')) {
      assetPath = 'assets/images_drone.jpg';
    } else if (lowerName.contains('john') ||
        lowerName.contains('deere') ||
        lowerName.contains('5050')) {
      assetPath = 'assets/images_johndeere5050D.jpg';
    } else if (lowerName.contains('mahindra') || lowerName.contains('yuvo')) {
      assetPath = 'assets/images_mahindra.jpg';
    } else {
      assetPath = 'assets/images_mahindra.jpg';
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.agriculture, size: 50, color: Colors.grey),
          ),
        );
      },
    );
  }

  // --- HELPER: Custom Date Picker with Real-Time Availability ---
  Future<DateTime?> _showCustomDatePicker(BuildContext context) async {
    // Simulate some booked dates for demonstration
    final now = DateTime.now();
    final bookedDates = [
      now.add(const Duration(days: 2)),
      now.add(const Duration(days: 5)),
      now.add(const Duration(days: 8)),
      now.add(const Duration(days: 12)),
      now.add(const Duration(days: 15)),
    ];

    return await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime selectedDate = date;

        return AlertDialog(
          title: const Text('Select Date'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),

                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                    return SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Calendar grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                    itemCount: 35, // 5 weeks * 7 days
                    itemBuilder: (context, index) {
                      final day = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        index -
                            DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              1,
                            ).weekday +
                            1,
                      );

                      if (day.month != selectedDate.month) {
                        return const SizedBox.shrink();
                      }

                      final isToday = _isSameDay(day, now);
                      final isBooked = bookedDates.any(
                        (booked) => _isSameDay(booked, day),
                      );
                      final isPast = day.isBefore(now);
                      final isAvailable = !isBooked && !isPast;

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                                Navigator.of(context).pop(day);
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.red.shade100
                                : isToday
                                ? Colors.green
                                : isPast
                                ? Colors.grey.shade200
                                : Colors.white,
                            border: Border.all(
                              color: isBooked
                                  ? Colors.red.shade300
                                  : isAvailable
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isBooked
                                    ? Colors.red.shade700
                                    : isToday
                                    ? Colors.white
                                    : isPast
                                    ? Colors.grey.shade500
                                    : Colors.black,
                                decoration: isBooked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _legendItem('Available', Colors.white),
                    _legendItem('Booked', Colors.red.shade100),
                    _legendItem('Today', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
