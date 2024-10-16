class Order {
  String userId;
  String name;
  String address;
  String phone;
  String email;
  String? notes;
  List<OrderItem> items;
  double totalPrice;

  Order({
    required this.userId,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.notes,
    required this.items,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),  // Importante mapear correctamente
      'totalPrice': totalPrice,
    };
  }
}

class OrderItem {
  String productId;
  int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
