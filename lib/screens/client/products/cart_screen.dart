import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import '../../../models/cart.dart';
import '../../../services/Cart_service.dart';
import '../products/order_screen.dart'; // Importar la pantalla de información para hacer la orden

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ServiceCart cartService = ServiceCart(); // Instancia del servicio del carrito
  bool isLoading = true;
  Cart? cart; // Almacena los datos del carrito
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de Firebase Auth

  @override
  void initState() {
    super.initState();
    _loadCartProducts();
  }

  // Cargar productos del carrito
  Future<void> _loadCartProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener el usuario autenticado desde Firebase
      final User? user = _auth.currentUser;

      if (user != null) {
        String userId = user.uid; // Obtener el UID del usuario autenticado

        Cart fetchedCart = await cartService.getCartProducts(userId); // Obtener datos del carrito

        setState(() {
          cart = fetchedCart;
        });
      } else {
        // Si no hay un usuario autenticado, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes iniciar sesión para ver el carrito')),
        );
      }
    } catch (error) {
      print('Error cargando el carrito: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el carrito')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
    // Función para eliminar un producto del carrito
  Future<void> _removeFromCart(String productId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        await cartService.removeFromCart(userId, productId);
        _loadCartProducts(); // Recargar los productos del carrito después de eliminar
      }
    } catch (error) {
      print('Error eliminando el producto del carrito: $error');
    }
  }

  Future<void> _updateProductQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeFromCart(productId); // Si la cantidad es 0 o menos, se elimina el producto
    } else {
      try {
        final User? user = _auth.currentUser;
        if (user != null) {
          String userId = user.uid;
          await cartService.updateProductQuantity(userId, productId, newQuantity);
          _loadCartProducts(); // Recargar los productos del carrito después de la actualización
        }
      } catch (error) {
        print('Error actualizando la cantidad del producto: $error');
      }
    }
  }


  // Navegar a la pantalla de información para hacer la orden
  void _goToOrderInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderInformationScreen(totalPrice: _calculateTotalPrice()),
      ),
    );
  }

  // Calcular el total del carrito
  double _calculateTotalPrice() {
  return cart?.products.fold(0.0, (sum, item) {
    double itemPrice = item.price ?? 0.0; // Asegurar que el precio no sea nulo
    int itemQuantity = item.quantity ?? 0; // Asegurar que la cantidad no sea nula
    return sum! + itemPrice * itemQuantity;
  }) ?? 0.0;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Carrito',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : cart == null || cart!.products.isEmpty
              ? Center(
                  child: Text(
                    'Tu carrito está vacío',
                    style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: cart!.products.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart!.products[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.grey[900],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Imagen del producto
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      cartItem.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 15.0),
                                  // Información del producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Cantidad: ${cartItem.quantity}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        // Botones para sumar/restar cantidad
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.orangeAccent),
                                              onPressed: () {
                                                _updateProductQuantity(cartItem.productId, cartItem.quantity - 1);
                                              },
                                            ),
                                            Text(
                                              '${cartItem.quantity}',
                                              style: TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.orangeAccent),
                                              onPressed: () {
                                                _updateProductQuantity(cartItem.productId, cartItem.quantity + 1);
                                              },
                                            ),
                                      ],
                                    ),
                                    ],
                                  ),
                                  ),
                                  // Total por producto
                                  Text(
                                    '\Q${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      _removeFromCart(cartItem.productId);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Total general
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total a pagar:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '\Q${_calculateTotalPrice().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de continuar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: _goToOrderInformation, // Navegar a la pantalla de información de la orden
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag, size: 28, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Proceder a la compra',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
