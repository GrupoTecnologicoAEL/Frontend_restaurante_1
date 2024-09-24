import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import './edit_product.dart'; 
import './add_product.dart'; 
import '../../../models/product.dart'; // Importa tu clase Product y Category

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carga
          : errorMessage != null
              ? Center(child: Text(errorMessage!)) // Mostrar el error si lo hay
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(products[index]['imageUrl']),
                      title: Text(products[index]['name']),
                      subtitle: Text('Precio: \$${products[index]['price']}'),
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
                                    productId: products[index]['_id'],
                                    productData: Product.fromJson(products[index]), // Convertimos correctamente el JSON a Product
                                  ),
                                ),
                              ).then((_) => _fetchProducts()); // Refrescar los productos después de editar uno
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteProduct(products[index]['_id']); // Eliminar producto
                            },
                          ),
                        ],
                      ),
                    );
                  },
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

