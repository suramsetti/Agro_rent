import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/booking_model.dart';
import '../models/driver_model.dart';
import '../models/item_model.dart';
import '../models/machine_model.dart';
import 'booking_service.dart';
import 'cart_service.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

enum PaymentStatus { pending, paid, refunded }

class Order {
  Order({
    required this.id,
    required this.item,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.date,
    this.rating,
    this.feedback,
    this.buyerPhone,
    this.buyerName,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.deliveryAddress,
    this.deliveryStatus,
  });

  final String id;
  final LeftoverItem item;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final DateTime date;
  double? rating;
  String? feedback;
  String? buyerPhone; // Who bought this item
  String? buyerName;
  BookingStatus status;
  PaymentStatus paymentStatus;
  String? deliveryAddress;
  String? deliveryStatus; // pending, dispatched, delivered

  bool isOwnedBy(String? ownerId) => item.isOwnedBy(ownerId);
}

class AppState extends ChangeNotifier {
  AppState(this.box) : _cartService = CartService();

  final Box box;
  final CartService _cartService;

  bool loggedIn = false;
  String? userEmail; // Reverted from userPhone to userEmail
  bool offlineMode = false;
  String? savedLanguage;
  bool sellingModeEnabled =
      false; // Meesho-like: enable selling to add items/machinery
  String? deliveryAddress; // User's default delivery address
  // Seller reputation config
  static const double _sellerBanThreshold = 3.0;
  static const int _minRatingsForBan = 3;

  // User-owned items (like Meesho - one profile can sell and buy)
  final List<Machine> userMachines = [];
  final List<LeftoverItem> userItems = [];
  final List<Driver> userDrivers = [];

  final List<Machine> machines = [
    Machine(
      id: 'm1',
      name: 'Mahindra 575',
      ratePerHour: 600,
      location: '2.1 km • Nizamabad Road',
      owner: 'Raju',
      rating: 4.7,
      position: const LatLng(18.673, 78.099),
      imageUrl: 'assets/images_mahindra.jpg',
    ),
    Machine(
      id: 'm2',
      name: 'John Deere 5050D',
      ratePerHour: 750,
      location: '4.5 km • Karimnagar',
      owner: 'Sita',
      rating: 4.4,
      position: const LatLng(18.438, 79.128),
      imageUrl: 'assets/images_johndeere5050D.jpg',
    ),
    Machine(
      id: 'm3',
      name: 'Drone - Krishi Vayu',
      ratePerHour: 1200,
      location: '6.3 km • Varni',
      owner: 'Farmer Co-op',
      rating: 4.9,
      position: const LatLng(18.704, 78.021),
      imageUrl: 'assets/images_drone.jpg',
    ),
  ];

  final List<Driver> drivers = [
    Driver(
      id: 'd1',
      name: 'Mahesh',
      phone: '+919876543210',
      email: 'mahesh@example.com',
      ratePerHour: 200,
      certifiedFor: ['Tractor', 'Rotavator'],
      rating: 4.8,
      position: const LatLng(18.685, 78.102),
      experience: '5 years',
      vehicleType: 'Tractor',
      licenseNumber: 'DL123456',
      licenseExpiry: '2025-12-31',
    ),
    Driver(
      id: 'd2',
      name: 'Ramesh',
      phone: '+919876543211',
      email: 'ramesh@example.com',
      ratePerHour: 180,
      certifiedFor: ['Harvester', 'Thresher'],
      rating: 4.9,
      position: const LatLng(18.704, 78.021),
      experience: '3 years',
      vehicleType: 'Tractor',
      licenseNumber: 'DL123457',
      licenseExpiry: '2025-06-30',
    ),
    Driver(
      id: 'd3',
      name: 'Anusha',
      phone: '+919876543212',
      email: 'anusha@example.com',
      ratePerHour: 250,
      certifiedFor: ['Sprayer', 'Drone'],
      rating: 4.6,
      position: const LatLng(18.442, 79.11),
      experience: '2 years',
      vehicleType: 'Drone',
      licenseNumber: 'DL123458',
      licenseExpiry: '2025-03-31',
    ),
  ];

  final List<LeftoverItem> leftovers = [
    LeftoverItem(
      id: 'l1',
      name: 'Urea 10kg',
      quantity: '10 kg',
      discount: 0.5,
      price: 180,
      seller: 'Lakshmi',
      distance: '1.4 km',
      imageUrl: 'assets/image_529fe3.jpg',
      inStock: true,
    ),
    LeftoverItem(
      id: 'l2',
      name: 'DAP 5kg',
      quantity: '5 kg',
      discount: 0.35,
      price: 320,
      seller: 'Kiran',
      distance: '3.0 km',
      imageUrl: 'assets/image_529957.jpg',
      inStock: true,
    ),
    LeftoverItem(
      id: 'l3',
      name: 'Potash 3kg',
      quantity: '3 kg',
      discount: 0.4,
      price: 150,
      seller: 'Suman',
      distance: '2.6 km',
      imageUrl: 'assets/image_529c1d.jpg',
      inStock: true, // All items in stock by default
    ),
  ];

  final List<Booking> bookings = [];
  final List<Order> orders = [];

  Future<void> initialize() async {
    loggedIn = box.get('loggedIn', defaultValue: false) as bool;
    userEmail = box.get('userEmail') as String?;
    // Backward compatibility: check for old userPhone field
    if (userEmail == null) {
      final phone = box.get('userPhone') as String?;
      if (phone != null) {
        userEmail = phone; // Migrate old phone to email field
        box.put('userEmail', userEmail);
      }
    }
    offlineMode = box.get('offlineMode', defaultValue: false) as bool;
    savedLanguage = box.get('savedLanguage') as String?;
    sellingModeEnabled =
        box.get('sellingModeEnabled', defaultValue: true) as bool;

    // Load user-owned machines and items
    _loadUserMachines();
    _loadUserItems();
    _loadUserDrivers();
    _loadOrders();
    _loadDeliveryAddress();

    final stored = box.get('bookings') as List?;
    if (stored != null) {
      for (final raw in stored) {
        try {
          final data = Map<String, dynamic>.from(jsonDecode(jsonEncode(raw)));
          final machine = machines.firstWhere(
            (m) => m.id == data['machineId'],
            orElse: () => machines.first,
          );
          final driver = drivers
              .where((d) => d.id == data['driverId'])
              .cast<Driver?>()
              .firstWhere((d) => d != null, orElse: () => null);
          bookings.add(
            Booking(
              id: data['id'] as String,
              machineId: data['machineId'] as String,
              machineName: machine.name,
              machineRatePerHour: machine.ratePerHour,
              driverId: driver?.id ?? '',
              driverName: driver?.name ?? '',
              driverRatePerHour: driver?.ratePerHour ?? 0.0,
              date: DateTime.parse(data['date'] as String),
              startTime: DateTime.parse(data['date'] as String),
              endTime: DateTime.parse(
                data['date'] as String,
              ).add(Duration(hours: (data['hours'] as num).toInt())),
              hours: (data['hours'] as num).toInt(),
              ownerId: machine.ownerId ?? '',
              renterEmail: userEmail ?? '',
              renterName: userEmail ?? '',
              status: data['status'] ?? 'pending',
              paymentMethod: data['paymentMethod'] as String,
              paymentStatus: data['paymentStatus'] ?? 'pending',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        } catch (_) {
          // ignore corrupted entries
        }
      }
    }
  }

  void completeLogin(String email) {
    userEmail = email;
    loggedIn = true;
    box.put('loggedIn', true);
    box.put('userEmail', email);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      // Firebase not available, continue with logout
    }
    loggedIn = false;
    userEmail = null;
    box.put('loggedIn', false);
    box.put('userEmail', null);
    notifyListeners();
  }

  void setOffline(bool value) {
    offlineMode = value;
    box.put('offlineMode', value);
    notifyListeners();
  }

  void addBooking(Booking booking) {
    bookings.insert(0, booking);
    _persistBookings();
    notifyListeners();
  }

  void addOrder(Order order) {
    // Set buyer info if not already set
    if (order.buyerPhone == null) {
      order.buyerPhone = userEmail;
      order.buyerName = userEmail;
    }
    orders.insert(0, order);
    _persistOrders();
    notifyListeners();
  }

  // Get bookings for machines owned by current user
  List<Booking> getMyMachineBookings() {
    return bookings.where((b) => b.ownerId == userEmail).toList();
  }

  // Get orders for items owned by current user
  List<Order> getMyItemOrders() {
    return orders.where((o) => o.isOwnedBy(userEmail)).toList();
  }

  // Update booking status (with Firestore sync)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final oldBooking = bookings[index];
    final now = DateTime.now();

    final newBooking = Booking(
      id: oldBooking.id,
      machineId: oldBooking.machineId,
      machineName: oldBooking.machineName,
      machineRatePerHour: oldBooking.machineRatePerHour,
      driverId: oldBooking.driverId,
      driverName: oldBooking.driverName,
      driverRatePerHour: oldBooking.driverRatePerHour,
      date: oldBooking.date,
      startTime: status == 'inProgress' ? now : oldBooking.startTime,
      endTime: status == 'completed' ? now : oldBooking.endTime,
      hours: oldBooking.hours,
      ownerId: oldBooking.ownerId,
      renterEmail: oldBooking.renterEmail,
      renterName: oldBooking.renterName,
      status: status,
      paymentMethod: oldBooking.paymentMethod,
      paymentStatus: status == 'completed' ? 'paid' : oldBooking.paymentStatus,
      createdAt: oldBooking.createdAt,
      updatedAt: now,
    );

    bookings[index] = newBooking;
    _persistBookings();
    notifyListeners();

    // Sync with Firestore for real-time updates
    try {
      if (Firebase.apps.isNotEmpty) {
        final bookingService = BookingService();
        await bookingService.updateBookingStatus(
          bookingId: bookingId,
          status: status,
        );
      }
    } catch (e) {
      debugPrint('Error syncing booking status to Firestore: $e');
      // Continue with local update even if Firestore sync fails
    }
  }

  // Update order status
  void updateOrderStatus(String orderId, BookingStatus status) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status = status;
    if (status == BookingStatus.completed) {
      order.paymentStatus = PaymentStatus.paid;
      order.deliveryStatus = 'delivered';
    }
    _persistOrders();
    notifyListeners();
  }

  // Update payment status
  void updatePaymentStatus(
    String bookingId,
    PaymentStatus status, {
    bool isOrder = false,
  }) {
    if (isOrder) {
      final order = orders.firstWhere((o) => o.id == bookingId);
      order.paymentStatus = status;
      _persistOrders();
    } else {
      // Note: The new Booking model has immutable properties
      // This would need to create a new Booking object with updated paymentStatus
      // For now, just log the update
      debugPrint('Updating payment status for booking $bookingId to $status');
    }
    notifyListeners();
  }

  void rateBooking(String id, double rating, String note) {
    // Note: The new Booking model doesn't support rating/feedback
    // This method is kept for compatibility but doesn't do anything
    // In a real implementation, you might want to add a separate ratings table
    debugPrint('Rating booking $id with $rating stars: $note');
  }

  void addLeftover(LeftoverItem item) {
    leftovers.insert(0, item);
    notifyListeners();
  }

  // --- Seller reputation helpers ---
  double get sellerRating {
    // Note: The new Booking model doesn't have rating field
    // In a real implementation, ratings would be stored separately
    // For now, return default rating
    return 5.0;
  }

  int get sellerRatingCount {
    // Note: The new Booking model doesn't have rating field
    // In a real implementation, ratings would be stored separately
    // For now, return default count
    return 0;
  }

  bool get isSellerBanned {
    // Ban selling if enough ratings and below threshold
    return sellerRatingCount >= _minRatingsForBan &&
        sellerRating < _sellerBanThreshold;
  }

  // Add machine owned by current user
  void addUserMachine(Machine machine) {
    userMachines.insert(0, machine);
    machines.insert(0, machine); // Also add to main list for booking
    _persistUserMachines();
    notifyListeners();

    // Fire-and-forget sync to Firestore
    unawaited(_syncMachineToFirestore(machine));
  }

  // Add driver owned by current user
  void addDriver(Driver driver) {
    userDrivers.insert(0, driver);
    drivers.insert(0, driver); // Also add to main list for booking
    _persistUserDrivers();
    notifyListeners();

    // Fire-and-forget sync to Firestore
    unawaited(_syncDriverToFirestore(driver));
  }

  // Add item owned by current user
  void addUserItem(LeftoverItem item) {
    userItems.insert(0, item);
    leftovers.insert(0, item); // Also add to main list
    _persistUserItems();
    notifyListeners();

    // Fire-and-forget sync to Firestore
    unawaited(_syncItemToFirestore(item));
  }

  // Delete user item
  void deleteUserItem(String itemId) {
    debugPrint('Attempting to delete item with ID: $itemId');
    debugPrint('Current userItems count: ${userItems.length}');
    debugPrint('Current leftovers count: ${leftovers.length}');

    userItems.removeWhere((item) => item.id == itemId);
    leftovers.removeWhere((item) => item.id == itemId);

    debugPrint('After deletion - userItems count: ${userItems.length}');
    debugPrint('After deletion - leftovers count: ${leftovers.length}');

    _persistUserItems();
    notifyListeners();
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }

  // Cancel order
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, BookingStatus.cancelled);
  }

  // Delivery address methods
  void setDeliveryAddress(String address) {
    deliveryAddress = address;
    _persistDeliveryAddress();
    notifyListeners();
  }

  void clearDeliveryAddress() {
    deliveryAddress = null;
    _persistDeliveryAddress();
    notifyListeners();
  }

  void _persistDeliveryAddress() {
    box.put('deliveryAddress', deliveryAddress);
  }

  void _loadDeliveryAddress() {
    deliveryAddress = box.get('deliveryAddress');
  }

  // Upsert user profile to Firestore
  Future<void> upsertUserProfile({
    required String email,
    String? name,
    String? village,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(email).set({
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        if (village != null && village.isNotEmpty) 'village': village,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore upsert user failed: $e');
    }
  }

  Future<void> _syncMachineToFirestore(Machine machine) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('machines').doc(machine.id).set({
        'id': machine.id,
        'name': machine.name,
        'ratePerHour': machine.ratePerHour,
        'location': machine.location,
        'ownerId': machine.ownerId ?? userEmail,
        'ownerName': machine.owner,
        'rating': machine.rating,
        'lat': machine.position.latitude,
        'lng': machine.position.longitude,
        'description': machine.description,
        'imageUrl': machine.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync machine failed: $e');
    }
  }

  Future<void> _syncDriverToFirestore(Driver driver) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('drivers').doc(driver.id).set({
        'id': driver.id,
        'name': driver.name,
        'phone': driver.phone,
        'email': driver.email,
        'ratePerHour': driver.ratePerHour,
        'certifiedFor': driver.certifiedFor,
        'rating': driver.rating,
        'lat': driver.position.latitude,
        'lng': driver.position.longitude,
        'experience': driver.experience,
        'vehicleType': driver.vehicleType,
        'licenseNumber': driver.licenseNumber,
        'licenseExpiry': driver.licenseExpiry,
        'isAvailable': driver.isAvailable,
        'totalTrips': driver.totalTrips,
        'registeredAt': driver.registeredAt?.toIso8601String(),
        'ownerId': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync driver failed: $e');
    }
  }

  Future<void> _syncItemToFirestore(LeftoverItem item) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('items').doc(item.id).set({
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'discount': item.discount,
        'distance': item.distance,
        'sellerId': item.sellerId ?? userEmail,
        'sellerName': item.seller,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync item failed: $e');
    }
  }

  // Get machines owned by current user
  List<Machine> getMyMachines() {
    return machines.where((m) => m.isOwnedBy(userEmail)).toList();
  }

  List<LeftoverItem> getMyItems() {
    return leftovers.where((i) => i.isOwnedBy(userEmail)).toList();
  }

  // Set language preference
  void setLanguage(String languageCode) {
    savedLanguage = languageCode;
    box.put('savedLanguage', languageCode);
    notifyListeners();
  }

  // Enable/disable selling mode (Meesho-like strategy)
  void setSellingMode(bool enabled) {
    sellingModeEnabled = enabled;
    box.put('sellingModeEnabled', enabled);
    notifyListeners();
  }

  void _loadUserMachines() {
    final stored = box.get('userMachines') as List?;
    if (stored != null) {
      userMachines.clear();
      for (final raw in stored) {
        try {
          final data = Map<String, dynamic>.from(raw);
          userMachines.add(
            Machine(
              id: data['id'] as String,
              name: data['name'] as String,
              ratePerHour: (data['ratePerHour'] as num).toDouble(),
              location: data['location'] as String,
              owner: data['owner'] as String,
              rating: (data['rating'] as num).toDouble(),
              position: LatLng(
                (data['lat'] as num).toDouble(),
                (data['lng'] as num).toDouble(),
              ),
              ownerId: data['ownerId'] as String?,
              description: data['description'] as String?,
              imageUrl: data['imageUrl'] as String?,
            ),
          );
        } catch (_) {
          // ignore corrupted entries
        }
      }
    }
  }

  void _loadUserItems() {
    final stored = box.get('userItems') as List?;
    if (stored != null) {
      userItems.clear();
      for (final raw in stored) {
        try {
          final data = Map<String, dynamic>.from(raw);
          userItems.add(
            LeftoverItem(
              id: data['id'] as String,
              name: data['name'] as String,
              quantity: data['quantity'] as String,
              discount: (data['discount'] as num).toDouble(),
              price: (data['price'] as num).toDouble(),
              seller: data['seller'] as String,
              distance: data['distance'] as String,
              sellerId: data['sellerId'] as String?,
              description: data['description'] as String?,
              imageUrl: data['imageUrl'] as String?,
            ),
          );
        } catch (_) {
          // ignore corrupted entries
        }
      }
    }
  }

  void _persistUserMachines() {
    final data = userMachines
        .map(
          (m) => {
            'id': m.id,
            'name': m.name,
            'ratePerHour': m.ratePerHour,
            'location': m.location,
            'owner': m.owner,
            'rating': m.rating,
            'lat': m.position.latitude,
            'lng': m.position.longitude,
            'ownerId': m.ownerId,
            'description': m.description,
            'imageUrl': m.imageUrl,
          },
        )
        .toList();
    box.put('userMachines', data);
  }

  void _persistUserItems() {
    final data = userItems
        .map(
          (i) => {
            'id': i.id,
            'name': i.name,
            'quantity': i.quantity,
            'discount': i.discount,
            'price': i.price,
            'seller': i.seller,
            'distance': i.distance,
            'sellerId': i.sellerId,
            'description': i.description,
            'imageUrl': i.imageUrl,
          },
        )
        .toList();
    box.put('userItems', data);
  }

  void _persistUserDrivers() {
    final data = userDrivers.map((d) => d.toMap()).toList();
    box.put('userDrivers', data);
  }

  void _loadUserDrivers() {
    final stored = box.get('userDrivers') as List?;
    if (stored != null) {
      userDrivers.clear();
      for (final raw in stored) {
        try {
          final data = Map<String, dynamic>.from(raw);
          userDrivers.add(Driver.fromMap(data));
        } catch (_) {
          // ignore corrupted entries
        }
      }
    }
  }

  void _persistBookings() {
    final data = bookings
        .map(
          (b) => {
            'id': b.id,
            'machineId': b.machineId,
            'machineName': b.machineName,
            'machineRatePerHour': b.machineRatePerHour,
            'driverId': b.driverId,
            'driverName': b.driverName,
            'driverRatePerHour': b.driverRatePerHour,
            'hours': b.hours,
            'paymentMethod': b.paymentMethod,
            'date': b.date.toIso8601String(),
            'startTime': b.startTime.toIso8601String(),
            'endTime': b.endTime.toIso8601String(),
            'ownerId': b.ownerId,
            'renterEmail': b.renterEmail,
            'renterName': b.renterName,
            'status': b.status,
            'paymentStatus': b.paymentStatus,
            'createdAt': b.createdAt.toIso8601String(),
            'updatedAt': b.updatedAt.toIso8601String(),
          },
        )
        .toList();
    box.put('bookings', data);
  }

  void _persistOrders() {
    final data = orders
        .map(
          (o) => {
            'id': o.id,
            'itemId': o.item.id,
            'quantity': o.quantity,
            'totalPrice': o.totalPrice,
            'paymentMethod': o.paymentMethod,
            'date': o.date.toIso8601String(),
            'rating': o.rating,
            'feedback': o.feedback,
            'buyerPhone': o.buyerPhone,
            'buyerName': o.buyerName,
            'status': o.status.name,
            'paymentStatus': o.paymentStatus.name,
            'deliveryAddress': o.deliveryAddress,
            'deliveryStatus': o.deliveryStatus,
          },
        )
        .toList();
    box.put('orders', data);
  }

  void _loadOrders() {
    final stored = box.get('orders') as List?;
    if (stored != null) {
      orders.clear();
      for (final raw in stored) {
        try {
          final data = Map<String, dynamic>.from(raw);
          final item = leftovers.firstWhere(
            (i) => i.id == data['itemId'],
            orElse: () => leftovers.first,
          );
          orders.add(
            Order(
              id: data['id'] as String,
              item: item,
              quantity: data['quantity'] as int,
              totalPrice: (data['totalPrice'] as num).toDouble(),
              paymentMethod: data['paymentMethod'] as String,
              date: DateTime.parse(data['date'] as String),
              rating: (data['rating'] as num?)?.toDouble(),
              feedback: data['feedback'] as String?,
              buyerPhone: data['buyerPhone'] as String?,
              buyerName: data['buyerName'] as String?,
              status: BookingStatus.values.firstWhere(
                (s) => s.name == (data['status'] as String? ?? 'pending'),
                orElse: () => BookingStatus.pending,
              ),
              paymentStatus: PaymentStatus.values.firstWhere(
                (s) =>
                    s.name == (data['paymentStatus'] as String? ?? 'pending'),
                orElse: () => PaymentStatus.pending,
              ),
              deliveryAddress: data['deliveryAddress'] as String?,
              deliveryStatus: data['deliveryStatus'] as String?,
            ),
          );
        } catch (_) {
          // ignore corrupted entries
        }
      }
    }
  }

  // Cart service getter
  CartService get cartService => _cartService;
}
