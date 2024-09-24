import 'package:flutter/material.dart';
import '../Screens/login.dart'
    as supAuth; 
import 'package:go_router/go_router.dart';

final TextEditingController _nameController = TextEditingController();
final TextEditingController _addressController = TextEditingController();
final TextEditingController _contactController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _clearTextFields() {
    _nameController.clear();
    _addressController.clear();
    _contactController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  void _handleSignUp(supAuth.AuthProvider authProvider) async {
    print('Intentando registrar al usuario');
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final contact = _contactController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty ||
        address.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos';
      });
      return;
    }

    try {
      await authProvider.signUp(
        context: context,
        name: name,
        address: address,
        contact: contact,
        email: email,
        password: password,
      );
      GoRouter.of(context).go('/login');
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _clearTextFields();
    final authProvider = supAuth
        .AuthProvider(); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contacto'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed: () => _handleSignUp(authProvider), // Aquí se maneja la creación de cuenta
            child: Text('Crear Cuenta'),
            ),
            TextButton(
            onPressed: () {
            Navigator.of(context).pop(); // Vuelve a la pantalla anterior (login)
            },
            child: Text('Regresar al Login'),
            ),
          ],
        ),
      ),
    );
  }
}
