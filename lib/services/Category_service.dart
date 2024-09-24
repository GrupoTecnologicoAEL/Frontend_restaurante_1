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
}
