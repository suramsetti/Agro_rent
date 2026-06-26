class LeftoverItem {
  LeftoverItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.discount,
    required this.price,
    required this.seller,
    required this.distance,
    this.sellerId,
    this.description,
    this.imageUrl,
    this.inStock = true, // Default to in stock
  });

  final String id;
  final String name;
  final String quantity;
  final double discount;
  final double price;
  final String seller;
  final String distance;
  final String?
  sellerId; // Phone number of the seller (current user if they own it)
  final String? description;
  final String? imageUrl;
  final bool inStock; // Stock availability status

  bool isOwnedBy(String? userId) => sellerId == userId;

  double get discountedPrice => price * (1 - discount);
}
