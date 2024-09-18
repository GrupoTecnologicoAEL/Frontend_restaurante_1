import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importaciones de las pantallas necesarias para la navegación
import '../screens/login.dart';
import '../Screens/Admin/admin_screen.dart';
import '../Screens/Client/client_screen.dart';
import '../Screens/singUp.dart';
/*import '../Screens/Admin/crud_product.dart';
import '../Screens/Client/product_list_screen.dart';
import '../Screens/Client/cart/cart_screen.dart';
import '../Screens/Client/cart/chekout_screen.dart';
import '../Screens/Client/cart/order_status_screen.dart';*/

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> _checkUserRole(String role) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    return userDoc['role'] == role;
  }
  return false;
}

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    final bool isLoggedIn = _auth.currentUser != null;
    final String location = state.uri.toString(); 

     // Redirigir si ya está logueado e intenta acceder al login
    if (isLoggedIn && location == '/login') {
      final bool isAdmin = await _checkUserRole('admin');
      return isAdmin ? '/admin' : '/client';
    }

    // Ruta de login
    if (!isLoggedIn && location != '/login') {
      return '/login';
    }

    // Ruta de admin protegida
    if (location.startsWith('/admin')) {
      final bool isAdmin = await _checkUserRole('admin');
      if (!isAdmin) {
        return '/client';
      }
    }

    // Ruta de cliente protegida
    if (location.startsWith('/client')) {
      final bool isClient = await _checkUserRole('client');
      if (!isClient) {
        return '/login';
      }
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
      path: '/admin/add-edit-product',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/client',
      builder: (context, state) => ClientHomeScreen(),
    ),
    GoRoute(
      path: '/admin/product-list',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/singUp',
      builder: (context, state) => SignUpScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/orders',
          builder: (context, state) => LoginScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Restaurante',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
