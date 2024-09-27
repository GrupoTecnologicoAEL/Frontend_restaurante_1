import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category.dart';

class ServiceCategories {
  final String baseUrl = 'http://localhost:5002/api/categories'; // Ajusta tu URL base

  // Método para obtener las categorías
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Category> categories =
          body.map((dynamic item) => Category.fromJson(item)).toList();
      return categories;
    } else {
      throw Exception('Fail to load categories');
    }
  }
  // Agregar una categoría
  Future<void> addCategory(Category category) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar la categoría');
    }
  }

  // Editar una categoría
  Future<void> editCategory(Category category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${category.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar la categoría');
    }
  }

  // Eliminar una categoría
  Future<void> deleteCategory(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la categoría');
    }
  }
  // Verificar si una categoría tiene productos asociados
  Future<bool> hasProducts(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/$categoryId/hasProducts'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['hasProducts'];
    } else {
      throw Exception('Error verificando si la categoría tiene productos');
    }
  }
}
