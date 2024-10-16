import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId = order['_id'];
    final totalPrice = order['totalPrice'] ?? '0.00';
    final orderStatus = order['status'] ?? 'Desconocido';
    final createdAt = DateTime.parse(order['createdAt']).toLocal();
    final formattedDate = "${createdAt.day}/${createdAt.month}/${createdAt.year}";
    final items = order['items'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Pedido',
          style: TextStyle(color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // Fondo negro para toda la pantalla
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número de Pedido: $orderId',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text('Fecha: $formattedDate', style: TextStyle(color: Colors.white)),
            Text('Total: Q$totalPrice', style: TextStyle(color: Colors.white)),
            Text(
              'Estado: $orderStatus',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Productos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final productName = item['productId']['name'] ?? 'Producto desconocido';
                  final quantity = item['quantity'] ?? 0;

                  return Card(
                    color: Color(0xFF1A1A1A), // Fondo oscuro para los productos
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        productName,
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Cantidad: $quantity',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Icon(
                        Icons.fastfood,
                        color: Colors.orangeAccent,
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
}
