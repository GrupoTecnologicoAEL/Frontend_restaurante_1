import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Client/client_screen.dart';
import '../login.dart' as supAuth;
import 'package:go_router/go_router.dart';

class ClientDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000), // Negro
              Color(0xFF333333), // Gris oscuro
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            _buildListTile(
              context: context,
              icon: Icons.home,
              label: 'Inicio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientHomeScreen()),
                );
              },
            ),
            _buildListTile(
              context: context,
              icon: Icons.shopping_cart,
              label: 'Carrito',
              onTap: () {
                // Lógica para ir al carrito
              },
            ),
            _buildListTile(
              context: context,
              icon: Icons.list,
              label: 'Mis Pedidos',
              onTap: () {
                // Lógica para ver pedidos
              },
            ),
            _buildListTile(
              context: context,
              icon: Icons.library_books,
              label: 'Mi Guía Nutricional',
              onTap: () {
                // Lógica para la guía nutricional
              },
            ),
            Divider(color: Colors.orangeAccent.shade200),
            _buildListTile(
              context: context,
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              onTap: () async {
                final authProvider = supAuth.AuthProvider();
                await authProvider.signOut();
                GoRouter.of(context).go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
        color: Color(0xFF222222), // Negro suave
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4), // Sombra sutil
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFF7F16), // Tono naranja
            radius: 40,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menú del Cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bienvenido(a)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.orangeAccent, // Naranja acentuado para los íconos
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white, // Texto blanco para el contraste
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.orangeAccent.shade100, size: 16),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: Color(0xFF333333).withOpacity(0.8), // Gris oscuro translúcido
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
