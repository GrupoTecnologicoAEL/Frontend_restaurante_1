import 'package:flutter/material.dart';
import '../Screens/login.dart' as supAuth;
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

    if (name.isEmpty || address.isEmpty || contact.isEmpty || email.isEmpty || password.isEmpty) {
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
    final authProvider = supAuth.AuthProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Cuenta',
          style: TextStyle(color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                _buildTextField(_nameController, 'Nombre Completo', Icons.person),
                SizedBox(height: 16),
                _buildTextField(_addressController, 'Dirección', Icons.home),
                SizedBox(height: 16),
                _buildTextField(_contactController, 'Contacto', Icons.phone),
                SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', Icons.email),
                SizedBox(height: 16),
                _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
                SizedBox(height: 30),

                // Botón de creación de cuenta
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.orangeAccent,
                  ),
                  onPressed: () => _handleSignUp(authProvider),
                  child: Text(
                    'Crear Cuenta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Botón de regresar al login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Regresar al Login',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para crear los TextFields con diseño consistente
  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: isPassword,
    );
  }
}
