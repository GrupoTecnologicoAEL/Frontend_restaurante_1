import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Client/client_screen.dart';
import '../login.dart' as supAuth;
import 'package:go_router/go_router.dart';

class ClientDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú del Cliente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Carrito'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Mis Pedidos'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Mi Guía Nutricional'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () async {
              final authProvider = supAuth.AuthProvider();
              await authProvider.signOut();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
    );
  }
}
