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
            color: Colors.orangeAccent, // Cambiado al color naranja
          ),
        ),
        backgroundColor: Colors.black, // Fondo negro para la elegancia
        elevation: 0,
        // Personalizamos el ícono del Drawer
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.orangeAccent, size: 30), // Cambiamos el color a naranja y aumentamos el tamaño
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Abre el drawer
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.orangeAccent, size: 26), // Aumentado el tamaño del ícono
              onPressed: () async {
                final authProvider = supAuth.AuthProvider();
                await authProvider.signOut();
                GoRouter.of(context).go('/login');
              },
            ),
          ),
        ],
      ),
      drawer: ClientDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(), // Encabezado con los nuevos colores
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
        color: Colors.black, // Cambiado el fondo a negro
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
              color: Colors.orangeAccent, // Cambiado el color a naranja
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Explora nuestras categorías y ofertas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orangeAccent.withOpacity(0.7),
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
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.5),
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
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.orangeAccent),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
