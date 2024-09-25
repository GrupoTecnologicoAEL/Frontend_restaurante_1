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
        // Decodificar la respuesta JSON
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
      // Comparar el ID de la categoría seleccionada con el campo _id dentro del objeto category del producto
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
      title: Text('Lista de Productos'),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            ).then((_) => _fetchProducts()); // Refrescar productos después de agregar uno
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Filtro de categorías
          DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: Text("Filtrar por Categoría"),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                _filterProducts(); // Filtrar productos cuando se selecciona una categoría
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: Text("Todas las categorías"), // Opción para mostrar todos los productos
              ),
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
            ],
          ),
          SizedBox(height: 10),
          // Búsqueda por nombre de producto
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar por nombre',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
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
                ? Center(child: CircularProgressIndicator()) // Indicador de carga
                : errorMessage != null
                    ? Center(child: Text(errorMessage!)) // Mostrar el error si lo hay
                    : filteredProducts.isEmpty
                        ? Center(child: Text("No hay productos que coincidan con los filtros"))
                        : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                                  title: Text(product['name']),
                                  subtitle: Text('Precio: \$${product['price']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          // Navegar a la pantalla de edición
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditProductScreen(
                                                productId: product['_id'],
                                                productData: Product.fromJson(product),
                                              ),
                                            ),
                                          ).then((_) => _fetchProducts()); // Refrescar los productos después de editar uno
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteProduct(product['_id']); // Eliminar producto
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
        // Producto eliminado con éxito, volver a cargar los productos
        _fetchProducts();
      } else {
        print('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
