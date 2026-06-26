import 'package:flutter/foundation.dart';
import '../models/item_model.dart';

class CartItem {
  final LeftoverItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'name': item.name,
      'quantity': item.quantity,
      'discount': item.discount,
      'price': item.price,
      'seller': item.seller,
      'distance': item.distance,
      'sellerId': item.sellerId,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'cartQuantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      item: LeftoverItem(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'],
        discount: json['discount'],
        price: json['price'],
        seller: json['seller'],
        distance: json['distance'],
        sellerId: json['sellerId'],
        description: json['description'],
        imageUrl: json['imageUrl'],
      ),
      quantity: json['cartQuantity'],
    );
  }
}

class CartService extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount =>
      _cartItems.fold(0, (sum, cartItem) => sum + cartItem.quantity);

  double get subtotal => _cartItems.fold(
    0.0,
    (sum, cartItem) =>
        sum + (cartItem.item.discountedPrice * cartItem.quantity),
  );

  double get originalSubtotal => _cartItems.fold(
    0.0,
    (sum, cartItem) => sum + (cartItem.item.price * cartItem.quantity),
  );

  double get savings => originalSubtotal - subtotal;

  double get deliveryCharge => subtotal > 500 ? 0 : 40;

  double get total => subtotal + deliveryCharge;

  void addToCart(LeftoverItem item) {
    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex != -1) {
      // Increase quantity if item exists
      _cartItems[existingIndex].quantity++;
    } else {
      // Add new item to cart
      _cartItems.add(CartItem(item: item));
    }

    notifyListeners();
    _saveCart();
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
    _saveCart();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );
    if (index != -1) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
      _saveCart();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCart();
  }

  bool isInCart(String itemId) {
    return _cartItems.any((cartItem) => cartItem.item.id == itemId);
  }

  int getItemQuantity(String itemId) {
    final cartItem = _cartItems
        .where((item) => item.item.id == itemId)
        .firstOrNull;
    return cartItem?.quantity ?? 0;
  }

  void _saveCart() {
    // In a real app, this would save to SharedPreferences or local storage
    // For now, we'll just print the cart data
    if (kDebugMode) {
      print('Cart saved: ${_cartItems.length} items, Total: ₹$total');
    }
  }

  void loadCart() {
    // In a real app, this would load from SharedPreferences or local storage
    // For now, we'll start with an empty cart
    _cartItems.clear();
    notifyListeners();
  }
}
