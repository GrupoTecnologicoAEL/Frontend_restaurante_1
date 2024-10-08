import 'package:flutter/material.dart';
import 'package:restaurante_1/services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  OrderDetailsScreen({required this.order});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService orderService = OrderService();
  String? _selectedStatus;
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _orderDetails = Map.from(widget.order);
    _selectedStatus = _orderDetails!['status'] ?? 'Pendiente';
  }

  Future<void> _updateOrderStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await orderService.updateOrderStatus(_orderDetails!['_id'], _selectedStatus!);
      final updatedOrder = await orderService.getOrderById(_orderDetails!['_id']);

      setState(() {
        _orderDetails = updatedOrder;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado del pedido actualizado')),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Pedido', style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${_orderDetails!['name']}', style: _infoTextStyle()),
                  SizedBox(height: 8),
                  Text('Dirección: ${_orderDetails!['address']}', style: _infoTextStyle()),
                  SizedBox(height: 8),
                  Text('Total: Q${_orderDetails!['totalPrice']}', style: _infoTextStyle()),
                  SizedBox(height: 16),
                  Text('Productos:', style: _sectionTitleStyle()),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _orderDetails!['items'].length,
                    itemBuilder: (context, index) {
                      final item = _orderDetails!['items'][index];
                      return ListTile(
                        title: Text('Producto: ${item['productId']['name']}', style: _infoTextStyle()),
                        subtitle: Text('Cantidad: ${item['quantity']}', style: _infoTextStyle()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _orderDetails!['notes'] != null && _orderDetails!['notes'].isNotEmpty
                      ? Text('Notas: ${_orderDetails!['notes']}', style: _infoTextStyle())
                      : Text('Notas: Sin notas', style: _infoTextStyle()),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ['Pendiente', 'En Cocina', 'Preparado', 'Listo Para Entregar', 'En camino', 'Entregado']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status, style: TextStyle(color: Colors.orange)),
                            ))
                        .toList(),
                    onChanged: (newStatus) {
                      setState(() {
                        _selectedStatus = newStatus;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Estado del Pedido',
                      labelStyle: TextStyle(color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedStatus != null) {
                          _updateOrderStatus();
                        }
                      },
                      icon: Icon(Icons.update, color: Colors.black),
                      label: Text('Actualizar Estado', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.black,
    );
  }

  TextStyle _infoTextStyle() {
    return TextStyle(color: Colors.white, fontSize: 18);
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold);
  }
}
