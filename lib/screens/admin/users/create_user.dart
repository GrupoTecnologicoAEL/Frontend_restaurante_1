import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateUserScreen extends StatefulWidget {
  @override
  _AdminCreateUserScreenState createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
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

  void _handleAdminCreateUser() async {
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
      // Crear el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Obtener el UID del usuario
      String uid = userCredential.user!.uid;

      // Guardar los datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'name': name,
        'address': address,
        'contact': contact,
        'email': email,
        'role': 'admin', // El rol es 'admin' porque lo está creando un administrador
      });

      // Limpiar campos de texto
      _clearTextFields();

      // Mostrar mensaje de éxito
      setState(() {
        _errorMessage = 'Usuario creado exitosamente';
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Usuario Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: _errorMessage.contains('exitosamente') ? Colors.green : Colors.red),
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
              onPressed: _handleAdminCreateUser,
              child: Text('Registrar Usuario Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
