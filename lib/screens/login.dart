import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Screens/Admin/admin_screen.dart';
import 'Client/client_screen.dart';
import '../Screens/singUp.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> _getUserRole(User user) async {
    final doc = await _firestore.collection('Users').doc(user.uid).get();
    return doc.data()?['role'] ?? 'client'; // Asume 'client' si no hay rol.
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Correo de restablecimiento de contraseña enviado a $email");
    } catch (error) {
      print("Error al enviar el correo de restablecimiento de contraseña: $error");
      throw error;
    }
  }

  // Función para iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        final AdditionalUserInfo? additionalUserInfo = authResult.additionalUserInfo;

        if (user != null) {
          final role = await _getUserRole(user);
          if (additionalUserInfo?.isNewUser == true) {
            context.go('/client');
          } else {
            context.go(role == 'admin' ? '/admin' : '/client');
          }
          notifyListeners();
        }
      }
    } catch (error) {
      print("Error en Google Sign-In: $error");
    }
  }

  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String address,
    required String contact,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;

      if (user != null) {
        // Almacenar los datos adicionales en Firestore
        await _firestore.collection('Users').doc(user.uid).set({
          'name': name,
          'address': address,
          'contact': contact,
          'email': email,
          'role': 'client', //Rol por defecto
        });

        context.go('/client'); // Redirigir al usuario a la pantalla del cliente
        notifyListeners();
      }
    } catch (error) {
      print("Error en el registro: $error");
      throw error;
    }
  }

  // Función para iniciar sesión con email y contraseña
  Future<String> signIn(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;

      if (user != null) {
        final role = await _getUserRole(user);
        context.go(role == 'admin' ? '/admin' : '/client');
        notifyListeners();
        return "Inicio de sesión exitoso";
      } else {
        return "El usuario no existe, debe registrarse";
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        return "No se encontró un usuario con ese correo electrónico";
      } else if (error.code == 'wrong-password') {
        return "Contraseña incorrecta";
      } else {
        return "Error en el inicio de sesión";
      }
    } catch (error) {
      print("Error en el inicio de sesión");
      return "Error desconocido, inténtelo de nuevo más tarde";
    }
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
      notifyListeners();
    } catch (error) {
      print("Error al cerrar sesión: $error");
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _handleSignIn(AuthProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos';
      });
      return;
    }

    final result = await authProvider.signIn(context, email, password);
    if (result != "Inicio de sesión exitoso") {
      setState(() {
        _errorMessage = result;
      });
    }
  }

  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController _resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restablecer Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Por favor, ingrese su correo electrónico:'),
              TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'ejemplo@correo.com',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    final authProvider = AuthProvider();
                    await authProvider.resetPassword(email);
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Correo de restablecimiento enviado')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al enviar el correo')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Por favor, ingrese un correo válido')),
                  );
                }
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Logo or Title
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email TextField
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      prefixIcon: Icon(Icons.email, color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      prefixIcon: Icon(Icons.lock, color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleSignIn(authProvider),
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Sign in with Google Button (resaltado)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => authProvider.signInWithGoogle(context),
                    icon: Icon(Icons.login, color: Colors.orangeAccent),
                    label: Text(
                      'Iniciar sesión con Google',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Forgot password and Sign Up Button
                  TextButton(
                    onPressed: () {
                      _showResetPasswordDialog(context);
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpScreen(), // Redirige a la pantalla de registro
                      ));
                    },
                    child: Text(
                      'Crear una nueva cuenta',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
