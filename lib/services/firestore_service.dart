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

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static CollectionReference get usersCollection =>
      _firestore.collection('users');
  static CollectionReference get machinesCollection =>
      _firestore.collection('machines');
  static CollectionReference get bookingsCollection =>
      _firestore.collection('bookings');
  static CollectionReference get productsCollection =>
      _firestore.collection('products');
  static CollectionReference get ordersCollection =>
      _firestore.collection('orders');
  static CollectionReference get reviewsCollection =>
      _firestore.collection('reviews');
  static CollectionReference get driversCollection =>
      _firestore.collection('drivers');
  static CollectionReference get maintenanceCollection =>
      _firestore.collection('maintenance');
  static CollectionReference get notificationsCollection =>
      _firestore.collection('notifications');
  static CollectionReference get favoritesCollection =>
      _firestore.collection('favorites');

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await usersCollection.doc(user.userId).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Machine operations
  static Future<void> createMachine(MachineModel machine) async {
    try {
      await machinesCollection.doc(machine.machineId).set(machine.toMap());
    } catch (e) {
      throw Exception('Failed to create machine: $e');
    }
  }

  static Future<List<MachineModel>> getMachines({
    String? ownerId,
    bool? isAvailable,
  }) async {
    try {
      Query query = machinesCollection;

      if (ownerId != null) {
        query = query.where('ownerId', isEqualTo: ownerId);
      }
      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => MachineModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get machines: $e');
    }
  }

  static Future<void> updateMachine(
    String machineId,
    Map<String, dynamic> data,
  ) async {
    try {
      await machinesCollection.doc(machineId).update(data);
    } catch (e) {
      throw Exception('Failed to update machine: $e');
    }
  }

  // Booking operations
  static Future<void> createBooking(BookingModel booking) async {
    try {
      await bookingsCollection.doc(booking.bookingId).set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  static Future<List<BookingModel>> getBookingsForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await bookingsCollection
          .where('renterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => BookingModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  static Future<void> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await bookingsCollection.doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Product operations
  static Future<void> createProduct(ProductModel product) async {
    try {
      await productsCollection.doc(product.productId).set(product.toMap());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  static Future<List<ProductModel>> getProducts({
    String? sellerId,
    String? category,
  }) async {
    try {
      Query query = productsCollection.where('isAvailable', isEqualTo: true);

      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Order operations
  static Future<void> createOrder(OrderModel order) async {
    try {
      await ordersCollection.doc(order.orderId).set(order.toMap());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await ordersCollection
          .where('buyerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Review operations
  static Future<void> createReview(ReviewModel review) async {
    try {
      await reviewsCollection.doc(review.reviewId).set(review.toMap());
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  static Future<List<ReviewModel>> getReviewsForItem(
    String itemId,
    String type,
  ) async {
    try {
      QuerySnapshot snapshot = await reviewsCollection
          .where('targetId', isEqualTo: itemId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  // Driver operations
  static Future<void> createDriver(DriverModel driver) async {
    try {
      await driversCollection.doc(driver.driverId).set(driver.toMap());
    } catch (e) {
      throw Exception('Failed to create driver: $e');
    }
  }

  static Future<List<DriverModel>> getAvailableDrivers() async {
    try {
      QuerySnapshot snapshot = await driversCollection
          .where('isAvailable', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['driverId'] = doc.id; // Add the document ID
        return DriverModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get drivers: $e');
    }
  }

  // Maintenance operations
  static Future<void> createMaintenanceRecord(
    MaintenanceModel maintenance,
  ) async {
    try {
      await maintenanceCollection
          .doc(maintenance.maintenanceId)
          .set(maintenance.toMap());
    } catch (e) {
      throw Exception('Failed to create maintenance record: $e');
    }
  }

  static Future<List<MaintenanceModel>> getMaintenanceForMachine(
    String machineId,
  ) async {
    try {
      QuerySnapshot snapshot = await maintenanceCollection
          .where('machineId', isEqualTo: machineId)
          .orderBy('serviceDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => MaintenanceModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get maintenance records: $e');
    }
  }

  // Notification operations
  static Future<void> createNotification(NotificationModel notification) async {
    try {
      await notificationsCollection
          .doc(notification.notificationId)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Future<List<NotificationModel>> getNotificationsForUser(
    String userId,
  ) async {
    try {
      QuerySnapshot snapshot = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => NotificationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Favorite operations
  static Future<void> addToFavorites(FavoriteModel favorite) async {
    try {
      await favoritesCollection.doc(favorite.favoriteId).set(favorite.toMap());
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  static Future<void> removeFromFavorites(String favoriteId) async {
    try {
      await favoritesCollection.doc(favoriteId).delete();
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  static Future<List<FavoriteModel>> getFavoritesForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await favoritesCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map(
            (doc) => FavoriteModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Stream operations for real-time updates
  static Stream<List<MachineModel>> streamMachines({String? ownerId}) {
    Query query = machinesCollection;
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => MachineModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  static Stream<List<BookingModel>> streamBookingsForUser(String userId) {
    return bookingsCollection
        .where('renterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BookingModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  static Stream<List<OrderModel>> streamOrdersForUser(String userId) {
    return ordersCollection
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Batch operations
  static Future<void> batchWrite(List<WriteOperation> operations) async {
    WriteBatch batch = _firestore.batch();

    for (var operation in operations) {
      switch (operation.type) {
        case WriteOperationType.create:
          batch.set(operation.reference!, operation.data!);
          break;
        case WriteOperationType.update:
          batch.update(operation.reference!, operation.data!);
          break;
        case WriteOperationType.delete:
          batch.delete(operation.reference!);
          break;
      }
    }

    await batch.commit();
  }
}

class WriteOperation {
  final WriteOperationType type;
  final DocumentReference? reference;
  final Map<String, dynamic>? data;

  WriteOperation({required this.type, this.reference, this.data});
}

enum WriteOperationType { create, update, delete }
