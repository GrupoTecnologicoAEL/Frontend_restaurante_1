import 'package:flutter/material.dart';
import '../Client/products/product_list_screen.dart';
import '../login.dart' as supAuth;
import 'package:go_router/go_router.dart';
import '../Client/drawer.dart';

class ClientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pantalla Cliente',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authProvider = supAuth.AuthProvider();
              await authProvider.signOut();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
      drawer: ClientDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    padding: EdgeInsets.all(8),
                    children: [
                      _buildGridItem(
                        context,
                        icon: Icons.store,
                        label: 'Tienda',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductListScreen()),
                          );
                        },
                      ),
                      _buildGridItem(
                        context,
                        icon: Icons.shopping_cart,
                        label: 'Mi Carrito',
                        onTap: () {
                          // Implementar lógica para ir al carrito
                        },
                      ),
                      _buildGridItem(
                        context,
                        icon: Icons.receipt_long,
                        label: 'Mis Pedidos',
                        onTap: () {
                          // Implementar lógica para ir a pedidos
                        },
                      ),
                      _buildGridItem(
                        context,
                        icon: Icons.favorite,
                        label: 'Favoritos',
                        onTap: () {
                          // Implementar lógica para ir a favoritos
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Encabezado de bienvenida
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido de nuevo,',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Explora nuestras categorías y ofertas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Elemento del grid con diseño moderno
  Widget _buildGridItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.green.shade600),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
