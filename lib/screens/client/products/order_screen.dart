import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurante_1/models/order.dart';
import 'package:restaurante_1/services/order_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final double totalPrice;
  final List<OrderItem> items;

  OrderConfirmationScreen({required this.totalPrice, required this.items});

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _name, _address, _phone, _email, _notes;

  Future<void> _confirmOrder() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final User? user = _auth.currentUser;

      if (user != null) {
        try {
          await _orderService.placeOrder(
            user.uid,
            widget.items.map((item) => item.toJson()).toList(),
            widget.totalPrice,
            _name!,
            _address!,
            _phone!,
            _email!,
            notes: _notes,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order placed successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to place order: $error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your details:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person,
                  onSaved: (value) => _name = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Address',
                  icon: Icons.location_on,
                  onSaved: (value) => _address = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  onSaved: (value) => _phone = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  onSaved: (value) => _email = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Notes (Optional)',
                  icon: Icons.note,
                  onSaved: (value) => _notes = value,
                  validator: (value) => null, // No validation needed
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    'Total: \$${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método reutilizable para crear campos de texto personalizados con fondo negro
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.white), // Texto blanco sobre fondo negro
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black, // Fondo negro para los campos
        labelText: label,
        labelStyle: TextStyle(color: Colors.orangeAccent),
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
