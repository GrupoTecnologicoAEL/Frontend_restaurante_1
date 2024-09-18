import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Screens/Admin/admin_screen.dart';
import 'client/client_screen.dart';
import '../Screens/singUp.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> _getUserRole(User user) async {
    final doc = await _firestore.collection('Users').doc(user.uid).get();
    return doc.data()?['role'] ?? 'client'; 
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Correo de restablecimiento de contraseña enviado a $email");
    } catch (error) {
      print(
          "Error al enviar el correo de restablecimiento de contraseña: $error");
      throw error;
    }
  }

  // Función para iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        final AdditionalUserInfo? additionalUserInfo =
            authResult.additionalUserInfo;

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
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
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

// Implementación de GoRouter con la lógica de redirección según el rol

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (isLoggedIn) {
      final user = FirebaseAuth.instance.currentUser!;
      final role = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((doc) => doc.data()?['role'] ?? 'client');

      if (state.uri.toString() == '/login') {
        return role == 'admin' ? '/admin' : '/client';
      }
    } else if (state.uri.toString() != '/login') {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminHomeScreen(),
    ),
    GoRoute(
      path: '/client',
      builder: (context, state) => ClientHomeScreen(),
    ),
  ],
);

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
      appBar: AppBar(
        title: Text('Login'),
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
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _handleSignIn(authProvider),
              child: Text('Iniciar sesión'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => authProvider.signInWithGoogle(context),
              child: Text('Iniciar Sesión con Google'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
              MaterialPageRoute(builder: (context) => SignUpScreen());
            },
              child: Text('Crear Cuenta'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showResetPasswordDialog(context);
              },
              child: Text('Olvidé mi contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
