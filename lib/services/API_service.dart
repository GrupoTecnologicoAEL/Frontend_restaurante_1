import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String apiUrl = 'http://localhost:5002/api/products';

  Future<List<Product>> getProduct() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products =
          body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Fail to load products');
    }
  }
  Future<void> createProduct(Product product) async {
    final url = Uri.parse('$apiUrl/products'); 
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      print('Producto creado correctamente');
    } else {
      throw Exception('Error al crear el producto: ${response.body}');
    }
  }

    Future<void> updateProduct(Product product) async {
    final url = Uri.parse('$apiUrl/products/${product.id}'); // Asegúrate de que esta sea la ruta correcta en tu API.
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      print('Producto actualizado correctamente');
    } else {
      throw Exception('Error al actualizar el producto: ${response.body}');
    }
  }

}
