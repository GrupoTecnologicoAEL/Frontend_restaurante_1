import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/products/admin_product_screen.dart';
import'../admin/categories/category_list_screen.dart';
import '../admin/users/create_user.dart';

class AdminHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para cerrar sesión y redirigir al login
  void _logout(BuildContext context) async {
    await _auth.signOut();
    context.go('/login');  // Redirigir al login después de cerrar sesión
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panel de Administración',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFFFBBF24), // Naranja elegante
          ),
        ),
        backgroundColor: Color(0xFF1C1C1E), // Fondo oscuro elegante
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xFFFBBF24), // Icono de logout con el color correspondiente
            onPressed: () {
              _logout(context);  // Lógica para cerrar sesión
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C1E), Color(0xFF3A3A3C)], // Degradado oscuro elegante
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildAdminModuleCard(
                context,
                title: 'Gestión de Productos',
                icon: Icons.shopping_bag_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(),
                    ),
                  );
                },
              ),
              _buildAdminModuleCard(
                context,
                title: 'Gestión de Categorías',
                icon: Icons.category_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(),
                    ),
                  );
                },
              ),
              _buildAdminModuleCard(
                context,
                title: 'Usuarios',
                icon: Icons.people_alt_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminCreateUserScreen(),
                    ),
                  ); 
                },
              ),
              _buildAdminModuleCard(
                context,
                title: 'Reportes',
                icon: Icons.bar_chart_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  // Lógica para la pantalla de reportes
                },
              ),
              _buildAdminModuleCard(
                context,
                title: 'Configuración',
                icon: Icons.settings_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  // Lógica para la pantalla de configuración
                },
              ),
              _buildAdminModuleCard(
                context,
                title: 'Notificaciones',
                icon: Icons.notifications_outlined,
                color: Color(0xFF4A4A4A), // Fondo elegante
                onTap: () {
                  // Lógica para la pantalla de notificaciones
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir las tarjetas de cada módulo del panel de administración
  Widget _buildAdminModuleCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: Colors.orangeAccent.withOpacity(0.5),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFFBBF24).withOpacity(0.3),
                child: Icon(icon, size: 50, color: Color(0xFFFBBF24)),
              ),
              SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
