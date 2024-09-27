import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './edit_product.dart';
import './add_product.dart';
import '../../../models/product.dart'; // Importa tu clase Product y Category
import '../../../models/category.dart'; // Importa tu clase Category

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Category> categories = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedCategory;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
  }

  // Función para obtener productos desde la API
  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/api/products'));
      if (response.statusCode == 200) {
        final List<dynamic> productData = json.decode(response.body);
        setState(() {
          products = productData.cast<Map<String, dynamic>>();
          filteredProducts = products; // Inicialmente todos los productos se muestran
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al obtener productos: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
    }
  }

  // Función para obtener categorías desde la API
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categoryData = json.decode(response.body);
        setState(() {
          categories = categoryData.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        print('Error al obtener categorías: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Función para filtrar productos por categoría o por nombre
  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesCategory = selectedCategory == '' || (product['category'] != null && product['category']['_id'] == selectedCategory);
        final matchesSearchQuery = product['name'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearchQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Productos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD9A641)),
        ),
        backgroundColor: Color(0xFF4A4A4A), // Fondo oscuro del AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFFD9A641), // Icono de agregar producto con el color dorado
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              ).then((_) => _fetchProducts());
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C1E), Color(0xFF3A3A3C)], // Degradado oscuro elegante
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ), // Fondo oscuro de la pantalla
        child: Column(
          children: [
            // Filtro de categorías
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filtrar por Categoría',
                labelStyle: TextStyle(color: Color(0xFFD9A641)),
                filled: true,
                fillColor: Color.fromARGB(255, 51, 51, 51), // Color de fondo del Dropdown
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Color.fromARGB(255, 51, 51, 51), // Color del dropdown desplegado
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFFD9A641)),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  _filterProducts(); // Filtrar productos cuando se selecciona una categoría
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text("Todas las categorías", style: TextStyle(color: Color(0xFFD9A641))),
                ),
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name, style: TextStyle(color: Color(0xFFD9A641))),
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 10),
            // Búsqueda por nombre de producto
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                labelStyle: TextStyle(color: Color(0xFFD9A641)),
                filled: true,
                fillColor: Color.fromARGB(255, 51, 51, 51), // Fondo del TextField
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.search, color: Color(0xFFD9A641)),
              ),
              style: TextStyle(color: Color(0xFFD9A641)),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterProducts(); // Filtrar productos cuando se busca un nombre
                });
              },
            ),
            SizedBox(height: 10),
            // Mostrar productos
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFD9A641)))
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.white)))
                      : filteredProducts.isEmpty
                          ? Center(child: Text("No hay productos que coincidan con los filtros", style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  color: Color(0xFF4A4A4A), // Fondo de las tarjetas
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                                    title: Text(product['name'], style: TextStyle(color: Color(0xFFD9A641))),
                                    subtitle: Text('Precio: Q${product['price']}', style: TextStyle(color: Colors.white70)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Color(0xFFD9A641)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditProductScreen(
                                                  productId: product['_id'],
                                                  productData: Product.fromJson(product),
                                                ),
                                              ),
                                            ).then((_) => _fetchProducts());
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            _deleteProduct(product['_id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para eliminar un producto
  Future<void> _deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:5002/api/products/$productId'));
      if (response.statusCode == 200) {
        _fetchProducts();
      } else {
        print('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
