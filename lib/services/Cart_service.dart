import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart.dart'; // Asegúrate de tener un modelo de carrito


class ServiceCart {
  final String baseUrl = 'http://localhost:5002/api/cart';

  // Obtener el carrito por el ID del usuario
  Future<Cart> getCartProducts(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);

      // Aquí convertimos el Map a un objeto de tipo Cart
      Cart cart = Cart.fromJson(body);
      return cart;
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Agregar un producto al carrito
  Future<void> addToCart(String userId, String productId, int quantity) async {
    final url = Uri.parse('http://localhost:5002/api/cart/add');
  final body = jsonEncode({
    'userId': userId,
    'productId': productId,
    'quantity': quantity,
  });

  print('Enviando al servidor: $body'); // Para depurar qué datos se están enviando

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('Producto agregado al carrito');
  } else {
    print('Error al agregar al carrito: ${response.statusCode} ${response.body}');
  }
  }

  // Eliminar un producto del carrito
  Future<void> removeFromCart(String userId, String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$userId/product/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el producto del carrito');
    }
  }
  Future<void> updateProductQuantity(String userId, String productId, int quantity) async {
    final url = Uri.parse('$baseUrl/$userId/product/$productId');
    final body = jsonEncode({'quantity': quantity});

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la cantidad del producto en el carrito');
    }
  }
}
