import './category.dart';
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final Category category; 
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: Category.fromJson(json['category']), // Manejo de la categoría como objeto
      stock: (json['stock'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.toJson(), // Convertimos el objeto categoría a JSON
      'stock': stock,
    };
  }
}
