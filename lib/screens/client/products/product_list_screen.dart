import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/product.dart';
import '../../../services/API_service.dart';
import '../../../services/Cart_service.dart'; // Importa el servicio del carrito
import '../products/cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with SingleTickerProviderStateMixin {
  late Future<List<Product>> futureProducts;
  final ApiService apiService = ApiService();
  final ServiceCart serviceCart = ServiceCart(); // Instancia del servicio del carrito
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = "";
  TabController? _tabController;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    futureProducts = apiService.getProduct();
    futureProducts.then((products) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  // Función para agregar producto al carrito
  Future<void> _addToCart(Product product) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtén el userId desde Firebase Auth
      final User? user = _auth.currentUser; // Obtener el usuario autenticado

      if (user != null) {
        String userId = user.uid; // El ID del usuario autenticado en Firebase

        // Llamar al servicio del carrito para agregar el producto
        await serviceCart.addToCart(userId, product.id, 1); // Agregar 1 unidad del producto

        // Mostrar un mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado al carrito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes iniciar sesión para agregar productos al carrito')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar producto al carrito: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 600 ? 3 : 2; // Ajuste de columnas en PC y móvil
    double childAspectRatio = screenWidth > 600 ? 1 / 1.1 : 1 / 1.4; // Ajuste de proporciones de los elementos

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Productos',
          style: TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orangeAccent,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Inicio'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
            Tab(icon: Icon(Icons.category), text: 'Categorías'),
            Tab(icon: CircleAvatar(backgroundColor: Colors.white, radius: 12), text: 'Perfil'),
          ],
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.orangeAccent)),
            );
          } else if (_filteredProducts.isEmpty) {
            return Center(
              child: Text(
                'No se encontraron productos',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 18),
              ),
            );
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    // Implementa la lógica de navegación o detalles del producto
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.orangeAccent.withOpacity(0.5),
                    color: Colors.black,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              product.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    'Imagen no disponible',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.orangeAccent),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '\Q${product.price.toString()}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              _addToCart(product); 
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color.fromARGB(255, 194, 133, 71), Colors.orangeAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 175, 140, 93).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Agregar al carrito',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
