import 'package:flutter/material.dart';
import 'package:restaurante_1/services/order_service.dart';
import 'package:intl/intl.dart'; // Para manejar las fechas
import '../orders/state_order_screen.dart'; // Pantalla para los detalles de cada orden

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderService orderService = OrderService();
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  // Filtros
  String? _selectedStatus;
  String? _searchQuery;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Cargar las órdenes desde el backend
  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true; // Mostrar el loading mientras cargan los pedidos
      });
      List<Map<String, dynamic>> fetchedOrders = await orderService.getOrders();
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

  // Abrir un cuadro de diálogo para aplicar filtros
  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Fondo negro
          title: Text(
            'Filtrar Pedidos',
            style: TextStyle(color: Colors.orange), // Texto en color naranja
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por estado
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Estado del pedido',
                  labelStyle: TextStyle(color: Colors.orange),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                value: _selectedStatus,
                dropdownColor: Colors.grey[900], // Color del dropdown
                items: ['Todos', 'Pendiente', 'En Cocina', 'Preparado', 'Listo Para Entregar', 'En camino', 'Entregado']
                    .map((status) => DropdownMenuItem(
                          child: Text(status, style: TextStyle(color: Colors.white)),
                          value: status,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Filtro por rango de fechas
              TextButton(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange: _selectedDateRange,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: Colors.orange,
                            onPrimary: Colors.black,
                            surface: Colors.black,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDateRange = picked;
                    });
                  }
                },
                child: Text(
                  _selectedDateRange == null
                      ? 'Seleccionar rango de fechas'
                      : 'Rango: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aplicar Filtros',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  // Construcción de la lista filtrada y buscada de órdenes
  Widget _buildOrderList() {
    List<Map<String, dynamic>> filteredOrders = orders;

    // Filtro por estado
    if (_selectedStatus != null && _selectedStatus != 'Todos') {
      filteredOrders = filteredOrders
          .where((order) => order['status'] == _selectedStatus)
          .toList();
    }

    // Filtro por rango de fechas
    if (_selectedDateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        String? dateString = order['createdAt']; // Verifica que el campo de fecha esté bien definido
        if (dateString == null) return false;
        DateTime orderDate = DateTime.parse(dateString);
        return orderDate.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
               orderDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    // Filtro por búsqueda
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        final query = _searchQuery!.toLowerCase();
        final name = order['name']?.toString()?.toLowerCase() ?? '';
        final orderId = order['_id']?.toString()?.toLowerCase() ?? '';
        return name.contains(query) || orderId.contains(query);
      }).toList();
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          _selectedDateRange != null
              ? 'No tienes pedidos para el rango de fechas seleccionado'
              : 'No hay pedidos con los criterios seleccionados',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];

        // Usar valores predeterminados si algún campo es null
        final String customerName = order['name'] ?? 'Sin nombre';
        final String totalPrice = order['totalPrice']?.toString() ?? '0.00';
        final String orderStatus = _getDisplayStatus(order['status']);

        return Card(
          color: Color(0xFF4A4A4A),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(orderStatus),
              child: Icon(Icons.assignment, color: Colors.white),
            ),
            title: Text('Cliente: $customerName', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            )),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: Q$totalPrice', style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                )),
                Text('Estado: $orderStatus', style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                )),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () async {
              // Llama al servicio para obtener el pedido actualizado
              final updatedOrder = await orderService.getOrderById(order['_id']);
              
              // Luego navega a la pantalla de detalles con los datos actualizados
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(order: updatedOrder),
                ),
              ).then((_) {
                // Cuando regrese a esta pantalla, recarga las órdenes
                _loadOrders();
              });
            },
          ),
        );
      },
    );
  }

  String _getDisplayStatus(String? status) {
    switch (status) {
      case 'Pendiente':
      case 'En Cocina':
      case 'Preparado':
      case 'Listo Para Entregar':
      case 'En camino':
      case 'Entregado':
        return status!;
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Cocina':
        return Colors.yellow;
      case 'Preparado':
        return Colors.blue;
      case 'Listo Para Entregar':
        return Colors.purple;
      case 'En camino':
        return Colors.green;
      case 'Entregado':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Pedidos',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Colors.orange,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.orangeAccent),
            onPressed: _openFilterDialog,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente o ID de pedido',
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildOrderList(),
            ),
          ],
        ),
      ),
    );
  }
}
