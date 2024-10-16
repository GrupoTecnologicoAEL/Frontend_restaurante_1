class Cart {
  final String userId;
  final List<CartItem> products;

  Cart({required this.userId, required this.products});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'],
      products: List<CartItem>.from(
        json['products'].map((item) => CartItem.fromJson(item)),
      ),
    );
  }
}

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']['_id'],
      name: json['productId']['name'],
      price: json['productId']['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['productId']['imageUrl'],
    );
  }
}
