import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String
  status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'refunded', 'failed'
  final String paymentMethod;
  final ShippingAddress shippingAddress;
  final String trackingNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    required this.paymentMethod,
    required this.shippingAddress,
    this.trackingNumber = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      buyerId: map['buyerId'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      shippingAddress: ShippingAddress.fromMap(map['shippingAddress'] ?? {}),
      trackingNumber: map['trackingNumber'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress.toMap(),
      'trackingNumber': trackingNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'productId': productId, 'quantity': quantity, 'price': price};
  }
}

class ShippingAddress {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  ShippingAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
