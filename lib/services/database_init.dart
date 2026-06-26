import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/machine_model.dart';
import '../models/booking_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/driver_model.dart';
import '../models/maintenance_model.dart';
import '../models/notification_model.dart';
import '../models/favorite_model.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize all Firestore collections with proper indexes and sample data
  static Future<void> initializeDatabase() async {
    try {
      // Create collections and set up indexes
      await _setupUsersCollection();
      await _setupMachinesCollection();
      await _setupBookingsCollection();
      await _setupProductsCollection();
      await _setupOrdersCollection();
      await _setupReviewsCollection();
      await _setupDriversCollection();
      await _setupMaintenanceCollection();
      await _setupNotificationsCollection();
      await _setupFavoritesCollection();

      print('Database initialized successfully!');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Setup Users collection
  static Future<void> _setupUsersCollection() async {
    final collection = _firestore.collection('users');

    // Create a sample user for testing
    final sampleUser = UserModel(
      userId: 'sample_user_123',
      email: 'farmer@example.com',
      name: 'Sample Farmer',
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

    try {
      await collection.doc(sampleUser.userId).set(sampleUser.toMap());
      print('Users collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample user already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Machines collection
  static Future<void> _setupMachinesCollection() async {
    final collection = _firestore.collection('machines');

    // Create a sample machine
    final sampleMachine = MachineModel(
      machineId: 'sample_machine_123',
      ownerId: 'sample_user_123',
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

    try {
      await collection.doc(sampleMachine.machineId).set(sampleMachine.toMap());
      print('Machines collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample machine already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Products collection
  static Future<void> _setupProductsCollection() async {
    final collection = _firestore.collection('products');

    // Create a sample product
    final sampleProduct = ProductModel(
      productId: 'sample_product_123',
      sellerId: 'sample_user_123',
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

    try {
      await collection.doc(sampleProduct.productId).set(sampleProduct.toMap());
      print('Products collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample product already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Bookings collection
  static Future<void> _setupBookingsCollection() async {
    final collection = _firestore.collection('bookings');

    // Create a sample booking
    final sampleBooking = BookingModel(
      bookingId: 'sample_booking_123',
      machineId: 'sample_machine_123',
      ownerId: 'sample_user_123',
      renterId: 'renter_user_123',
      startDate: Timestamp.now(),
      endDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
      totalAmount: 400.0,
      status: 'confirmed',
      paymentStatus: 'paid',
      paymentMethod: 'credit_card',
      bookingType: 'daily',
      notes: 'Please deliver machine by 9 AM',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await collection.doc(sampleBooking.bookingId).set(sampleBooking.toMap());
      print('Bookings collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample booking already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Orders collection
  static Future<void> _setupOrdersCollection() async {
    final collection = _firestore.collection('orders');

    // Create a sample order
    final sampleOrder = OrderModel(
      orderId: 'sample_order_123',
      buyerId: 'buyer_user_123',
      items: [
        OrderItem(productId: 'sample_product_123', quantity: 5, price: 45.99),
      ],
      totalAmount: 229.95,
      status: 'processing',
      paymentStatus: 'paid',
      paymentMethod: 'upi',
      shippingAddress: ShippingAddress(
        name: 'Sample Buyer',
        phone: '+9876543210',
        address: '456 Market Street',
        city: 'Trade City',
        state: 'Commerce State',
        pincode: '654321',
      ),
      trackingNumber: 'TRK123456789',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await collection.doc(sampleOrder.orderId).set(sampleOrder.toMap());
      print('Orders collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample order already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Reviews collection
  static Future<void> _setupReviewsCollection() async {
    final collection = _firestore.collection('reviews');

    // Create a sample review
    final sampleReview = ReviewModel(
      reviewId: 'sample_review_123',
      type: 'machine',
      targetId: 'sample_machine_123',
      reviewerId: 'renter_user_123',
      rating: 5.0,
      comment: 'Excellent machine! Very well maintained and easy to operate.',
      images: [],
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await collection.doc(sampleReview.reviewId).set(sampleReview.toMap());
      print('Reviews collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample review already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Drivers collection
  static Future<void> _setupDriversCollection() async {
    final collection = _firestore.collection('drivers');

    // Create a sample driver
    final sampleDriver = DriverModel(
      driverId: 'sample_driver_123',
      userId: 'driver_user_123',
      licenseNumber: 'DL123456789',
      licenseExpiry: Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 365)),
      ),
      isAvailable: true,
      currentLocation: const GeoPoint(40.7128, -74.0060),
      rating: 4.7,
      totalTrips: 150,
      vehicleDetails: VehicleDetails(
        type: 'Truck',
        number: 'MH12AB1234',
        capacity: '5 tons',
      ),
      documents: DriverDocuments(
        license: 'https://example.com/license.jpg',
        aadhar: 'https://example.com/aadhar.jpg',
        rcBook: 'https://example.com/rcbook.jpg',
      ),
      isVerified: true,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await collection.doc(sampleDriver.driverId).set(sampleDriver.toMap());
      print('Drivers collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample driver already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Maintenance collection
  static Future<void> _setupMaintenanceCollection() async {
    final collection = _firestore.collection('maintenance');

    // Create a sample maintenance record
    final sampleMaintenance = MaintenanceModel(
      maintenanceId: 'sample_maintenance_123',
      machineId: 'sample_machine_123',
      ownerId: 'sample_user_123',
      serviceDate: Timestamp.now(),
      serviceType: 'Regular Service',
      description: 'Oil change and filter replacement',
      cost: 150.0,
      nextServiceDate: Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 90)),
      ),
      serviceProvider: 'Farm Equipment Service Center',
      receiptImage: 'https://example.com/receipt.jpg',
      notes: 'Machine is in excellent condition',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await collection
          .doc(sampleMaintenance.maintenanceId)
          .set(sampleMaintenance.toMap());
      print('Maintenance collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample maintenance record already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Notifications collection
  static Future<void> _setupNotificationsCollection() async {
    final collection = _firestore.collection('notifications');

    // Create a sample notification
    final sampleNotification = NotificationModel(
      notificationId: 'sample_notification_123',
      userId: 'sample_user_123',
      title: 'New Booking Request',
      message: 'You have a new booking request for John Deere 5075E',
      type: 'booking',
      isRead: false,
      referenceId: 'sample_booking_123',
      createdAt: Timestamp.now(),
    );

    try {
      await collection
          .doc(sampleNotification.notificationId)
          .set(sampleNotification.toMap());
      print('Notifications collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample notification already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Setup Favorites collection
  static Future<void> _setupFavoritesCollection() async {
    final collection = _firestore.collection('favorites');

    // Create a sample favorite
    final sampleFavorite = FavoriteModel(
      favoriteId: 'sample_favorite_123',
      userId: 'sample_user_123',
      type: 'machine',
      itemId: 'sample_machine_123',
      createdAt: Timestamp.now(),
    );

    try {
      await collection
          .doc(sampleFavorite.favoriteId)
          .set(sampleFavorite.toMap());
      print('Favorites collection initialized with sample data');
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        print('Sample favorite already exists');
      } else {
        rethrow;
      }
    }
  }

  /// Clear all sample data (useful for testing)
  static Future<void> clearSampleData() async {
    final collections = [
      'users',
      'machines',
      'products',
      'bookings',
      'orders',
      'reviews',
      'drivers',
      'maintenance',
      'notifications',
      'favorites',
    ];

    for (final collectionName in collections) {
      final collection = _firestore.collection(collectionName);
      final snapshot = await collection
          .where('userId', isEqualTo: 'sample_user_123')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Also delete any sample documents
      final sampleDocs = await collection
          .where(
            FieldPath.documentId,
            whereIn: [
              'sample_user_123',
              'sample_machine_123',
              'sample_product_123',
              'sample_booking_123',
              'sample_order_123',
              'sample_review_123',
              'sample_driver_123',
              'sample_maintenance_123',
              'sample_notification_123',
              'sample_favorite_123',
            ],
          )
          .get();

      for (final doc in sampleDocs.docs) {
        await doc.reference.delete();
      }
    }

    print('Sample data cleared successfully');
  }
}
