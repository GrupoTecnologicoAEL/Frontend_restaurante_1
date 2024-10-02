import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderService {
  final String baseUrl = 'http://localhost:5002/api/order';

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
