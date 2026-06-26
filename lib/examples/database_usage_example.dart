import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/machine_model.dart';
import '../models/booking_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/database_init.dart';

class DatabaseUsageExample {
  /// Example: Create a new user
  static Future<void> createUserExample() async {
    try {
      final user = UserModel(
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'user123',
        email: 'farmer@example.com',
        name: 'John Farmer',
        phone: '+1234567890',
        userType: 'farmer',
        address: Address(
          street: '123 Farm Road',
          city: 'Agricultural City',
          state: 'Farm State',
          pincode: '123456',
          coordinates: const GeoPoint(40.7128, -74.0060),
        ),
        profileImage: '',
        aadharNumber: '123456789012',
        isVerified: false,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createUser(user);
      print('User created successfully!');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  /// Example: Get user data
  static Future<void> getUserExample() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'user123';
      final user = await FirestoreService.getUser(userId);

      if (user != null) {
        print('User found: ${user.name} (${user.email})');
        print('User type: ${user.userType}');
        print('Address: ${user.address.city}, ${user.address.state}');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error getting user: $e');
    }
  }

  /// Example: Create a machine listing
  static Future<void> createMachineExample() async {
    try {
      final machine = MachineModel(
        machineId: FirestoreService.machinesCollection.doc().id,
        ownerId: FirebaseAuth.instance.currentUser?.uid ?? 'user123',
        name: 'John Deere 5075E',
        type: 'Tractor',
        brand: 'John Deere',
        model: '5075E',
        year: 2023,
        hourlyRate: 50.0,
        dailyRate: 400.0,
        weeklyRate: 2500.0,
        monthlyRate: 8000.0,
        description: 'Powerful and reliable tractor for all farming needs',
        specifications: {
          'power': '75 HP',
          'fuelType': 'Diesel',
          'transmission': 'SynchroShuttle',
          'drive': '2WD',
        },
        images: [],
        isAvailable: true,
        location: const GeoPoint(40.7128, -74.0060),
        address: '123 Farm Road, Agricultural City',
        rating: 4.5,
        totalRatings: 10,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createMachine(machine);
      print('Machine created successfully!');
    } catch (e) {
      print('Error creating machine: $e');
    }
  }

  /// Example: Get all available machines
  static Future<void> getMachinesExample() async {
    try {
      final machines = await FirestoreService.getMachines(isAvailable: true);

      print('Found ${machines.length} available machines:');
      for (final machine in machines) {
        print('- ${machine.name} (${machine.brand} ${machine.model})');
        print('  Hourly Rate: \$${machine.hourlyRate}');
        print('  Location: ${machine.address}');
        print('  Rating: ${machine.rating} (${machine.totalRatings} reviews)');
        print('');
      }
    } catch (e) {
      print('Error getting machines: $e');
    }
  }

  /// Example: Stream machines for real-time updates
  static void streamMachinesExample() {
    print('Starting to stream machines...');

    final stream = FirestoreService.streamMachines();
    stream.listen((machines) {
      print('Updated machines list (${machines.length} machines):');
      for (final machine in machines.take(3)) {
        // Show only first 3
        print('- ${machine.name} - Available: ${machine.isAvailable}');
      }
      if (machines.length > 3) {
        print('... and ${machines.length - 3} more');
      }
    });
  }

  /// Example: Create a booking
  static Future<void> createBookingExample() async {
    try {
      final booking = BookingModel(
        bookingId: FirestoreService.bookingsCollection.doc().id,
        machineId: 'machine123',
        ownerId: 'owner123',
        renterId: FirebaseAuth.instance.currentUser?.uid ?? 'renter123',
        startDate: Timestamp.now(),
        endDate: Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
        totalAmount: 400.0,
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: 'credit_card',
        bookingType: 'daily',
        notes: 'Please deliver machine by 9 AM',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createBooking(booking);
      print('Booking created successfully!');
    } catch (e) {
      print('Error creating booking: $e');
    }
  }

  /// Example: Get user's bookings
  static Future<void> getUserBookingsExample() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'user123';
      final bookings = await FirestoreService.getBookingsForUser(userId);

      print('Found ${bookings.length} bookings:');
      for (final booking in bookings) {
        print('- Booking ${booking.bookingId}');
        print('  Machine: ${booking.machineId}');
        print('  Status: ${booking.status}');
        print('  Total Amount: \$${booking.totalAmount}');
        print('  Start Date: ${booking.startDate.toDate()}');
        print('');
      }
    } catch (e) {
      print('Error getting bookings: $e');
    }
  }

  /// Example: Update booking status
  static Future<void> updateBookingStatusExample() async {
    try {
      const bookingId = 'booking123';
      const newStatus = 'confirmed';

      await FirestoreService.updateBookingStatus(bookingId, newStatus);
      print('Booking status updated to: $newStatus');
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  /// Example: Create a product
  static Future<void> createProductExample() async {
    try {
      final product = ProductModel(
        productId: FirestoreService.productsCollection.doc().id,
        sellerId: FirebaseAuth.instance.currentUser?.uid ?? 'seller123',
        name: 'Organic Wheat Seeds',
        category: 'Seeds',
        description: 'High-quality organic wheat seeds for better yield',
        price: 45.99,
        quantity: 100,
        unit: 'kg',
        images: [],
        isAvailable: true,
        location: const GeoPoint(40.7128, -74.0060),
        rating: 4.8,
        totalRatings: 25,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createProduct(product);
      print('Product created successfully!');
    } catch (e) {
      print('Error creating product: $e');
    }
  }

  /// Example: Get products by category
  static Future<void> getProductsByCategoryExample() async {
    try {
      const category = 'Seeds';
      final products = await FirestoreService.getProducts(category: category);

      print('Found ${products.length} products in category: $category');
      for (final product in products) {
        print('- ${product.name}');
        print('  Price: \$${product.price} per ${product.unit}');
        print('  Available Quantity: ${product.quantity} ${product.unit}');
        print('  Rating: ${product.rating} (${product.totalRatings} reviews)');
        print('');
      }
    } catch (e) {
      print('Error getting products: $e');
    }
  }

  /// Example: Create an order
  static Future<void> createOrderExample() async {
    try {
      final order = OrderModel(
        orderId: FirestoreService.ordersCollection.doc().id,
        buyerId: FirebaseAuth.instance.currentUser?.uid ?? 'buyer123',
        items: [OrderItem(productId: 'product123', quantity: 5, price: 45.99)],
        totalAmount: 229.95,
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: 'upi',
        shippingAddress: ShippingAddress(
          name: 'Sample Buyer',
          phone: '+9876543210',
          address: '456 Market Street',
          city: 'Trade City',
          state: 'Commerce State',
          pincode: '654321',
        ),
        trackingNumber: '',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createOrder(order);
      print('Order created successfully!');
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  /// Example: Get user's orders
  static Future<void> getUserOrdersExample() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'user123';
      final orders = await FirestoreService.getOrdersForUser(userId);

      print('Found ${orders.length} orders:');
      for (final order in orders) {
        print('- Order ${order.orderId}');
        print('  Status: ${order.status}');
        print('  Total Amount: \$${order.totalAmount}');
        print('  Items: ${order.items.length}');
        print('  Payment Status: ${order.paymentStatus}');
        print('');
      }
    } catch (e) {
      print('Error getting orders: $e');
    }
  }

  /// Example: Batch operations
  static Future<void> batchOperationsExample() async {
    try {
      final operations = <WriteOperation>[
        WriteOperation(
          type: WriteOperationType.create,
          reference: FirestoreService.machinesCollection.doc(),
          data: {
            'name': 'Batch Machine 1',
            'ownerId': 'user123',
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
          },
        ),
        WriteOperation(
          type: WriteOperationType.create,
          reference: FirestoreService.productsCollection.doc(),
          data: {
            'name': 'Batch Product 1',
            'sellerId': 'user123',
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
          },
        ),
      ];

      await FirestoreService.batchWrite(operations);
      print('Batch operations completed successfully!');
    } catch (e) {
      print('Error in batch operations: $e');
    }
  }

  /// Example: Initialize database with sample data
  static Future<void> initializeDatabaseExample() async {
    try {
      await DatabaseInitializer.initializeDatabase();
      print('Database initialized with sample data!');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  /// Example: Clear sample data
  static Future<void> clearSampleDataExample() async {
    try {
      await DatabaseInitializer.clearSampleData();
      print('Sample data cleared successfully!');
    } catch (e) {
      print('Error clearing sample data: $e');
    }
  }

  /// Run all examples
  static Future<void> runAllExamples() async {
    print('=== Database Usage Examples ===\n');

    print('1. Initializing database...');
    await initializeDatabaseExample();
    print('');

    print('2. Creating user...');
    await createUserExample();
    print('');

    print('3. Getting user...');
    await getUserExample();
    print('');

    print('4. Creating machine...');
    await createMachineExample();
    print('');

    print('5. Getting machines...');
    await getMachinesExample();
    print('');

    print('6. Creating product...');
    await createProductExample();
    print('');

    print('7. Getting products by category...');
    await getProductsByCategoryExample();
    print('');

    print('8. Creating booking...');
    await createBookingExample();
    print('');

    print('9. Getting user bookings...');
    await getUserBookingsExample();
    print('');

    print('10. Creating order...');
    await createOrderExample();
    print('');

    print('11. Getting user orders...');
    await getUserOrdersExample();
    print('');

    print('12. Batch operations...');
    await batchOperationsExample();
    print('');

    print('=== All examples completed! ===');
  }
}
