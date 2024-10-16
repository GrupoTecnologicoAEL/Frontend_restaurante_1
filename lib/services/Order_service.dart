import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderService {
  final String baseUrl = 'https://backend-restaurante-1.onrender.com/api/order';

   // Obtener todas las órdenes
  Future<List<Map<String, dynamic>>> getOrders() async {
    final url = Uri.parse('$baseUrl');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar las órdenes');
    }
  }
  //Obtener ordenes por usuario 
  Future<List<Map<String, dynamic>>> getOrdersByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener las órdenes');
    }
  }
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
  final url = Uri.parse('$baseUrl/$orderId');
  
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener el pedido');
  }
}

   // Actualizar el estado de una orden
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final url = Uri.parse('$baseUrl/update-status/$orderId');
    final body = jsonEncode({
      'status': newStatus,
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado del pedido');
    }
  }

  // Enviar una orden
  Future<void> placeOrder(
    String userId,
    List<Map<String, dynamic>> items,
    double totalPrice,
    String name,      // Se añaden los nuevos parámetros
    String address,   // Dirección
    String phone,     // Teléfono
    String email,     // Correo electrónico
    {String? notes}   // Notas opcionales
  ) async {
    final url = Uri.parse('$baseUrl/create');

    // Construir el cuerpo de la petición
    final body = jsonEncode({
      'userId': userId,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'notes': notes,
      'items': items,
      'totalPrice': totalPrice,
    });

    // Enviar la petición al backend
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,  // Enviar el JSON en el body
    );

    if (response.statusCode == 201) {
      print('Order created successfully');
    } else {
      throw Exception('Failed to create order');
    }
  }
}

