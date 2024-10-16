import 'package:flutter/material.dart';
import 'package:restaurante_1/services/order_service.dart';
import '../products/details_order.dart'; // Importar la pantalla de detalles de la orden

class CustomerOrderListScreen extends StatefulWidget {
  final String userId; // Id del usuario autenticado
  CustomerOrderListScreen({required this.userId});

  @override
  _CustomerOrderListScreenState createState() => _CustomerOrderListScreenState();
}

class _CustomerOrderListScreenState extends State<CustomerOrderListScreen> {
  final OrderService orderService = OrderService();
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerOrders();
  }

  // Cargar las órdenes del cliente desde el backend
  Future<void> _loadCustomerOrders() async {
    try {
      setState(() {
        isLoading = true;
      });
      List<Map<String, dynamic>> fetchedOrders = await orderService.getOrdersByUserId(widget.userId);
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (error) {
      print('Error al cargar las órdenes: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Generar una barra de progreso según el estado del pedido
  Widget _buildProgressBar(String status) {
    double progress = 0.0;
    switch (status) {
      case 'Pendiente':
        progress = 0.2;
        break;
      case 'En Cocina':
        progress = 0.4;
        break;
      case 'Preparado':
        progress = 0.6;
        break;
      case 'Listo Para Entregar':
        progress = 0.8;
        break;
      case 'En camino':
        progress = 0.9;
        break;
      case 'Entregado':
        progress = 1.0;
        break;
      default:
        progress = 0.0;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        color: Colors.orangeAccent,
        minHeight: 8,
      ),
    );
  }

  // Método para construir las tarjetas de las órdenes
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderStatus = order['status'] ?? 'Desconocido';
    final orderId = order['_id'];
    final totalPrice = order['totalPrice'] ?? '0.00';
    final createdAt = DateTime.parse(order['createdAt']).toLocal();
    final formattedDate = "${createdAt.day}/${createdAt.month}/${createdAt.year}";

    return Card(
      elevation: 4,
      color: Color(0xFF1A1A1A), // Fondo oscuro
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido: $orderId',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                Text(
                  'Total: Q$totalPrice',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Fecha: $formattedDate', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            _buildProgressBar(orderStatus), // Barra de progreso
            SizedBox(height: 10),
            Text(
              'Estado: $orderStatus',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent, // Color del botón
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              },
              child: Text(
                'Ver Detalles',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Órdenes',
          style: TextStyle(color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // Fondo negro para toda la pantalla
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
            : orders.isEmpty
                ? Center(
                    child: Text(
                      'No tienes órdenes en este momento.',
                      style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(orders[index]);
                    },
                  ),
      ),
    );
  }
}
