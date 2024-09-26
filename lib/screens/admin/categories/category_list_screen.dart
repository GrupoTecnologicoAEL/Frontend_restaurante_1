import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../services/Category_service.dart';
import '../categories/add_editt_category.dart';

class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> categories = [];
  List<Category> filteredCategories = []; // Para mostrar las categorías filtradas
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = ''; // Almacenar la consulta de búsqueda

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Obtener categorías
  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await ServiceCategories().getCategories();
      setState(() {
        categories = fetchedCategories;
        filteredCategories = fetchedCategories; // Inicialmente, mostrar todas las categorías
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // Función para filtrar categorías por nombre
  void _filterCategories(String query) {
    List<Category> filteredList = categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchQuery = query;
      filteredCategories = filteredList;
    });
  }

  // Función para eliminar una categoría
  Future<void> _deleteCategory(String id) async {
    bool hasProductsAssociated = await ServiceCategories().hasProducts(id);

    if (hasProductsAssociated) {
      // Mostrar alerta si la categoría tiene productos asociados
      _showAlertDialog('No se puede eliminar', 'Esta categoría tiene productos asociados y no puede ser eliminada.');
    } else {
      // Si no tiene productos asociados, proceder con la eliminación
      try {
        await ServiceCategories().deleteCategory(id);
        _fetchCategories(); // Actualizar la lista después de eliminar
      } catch (error) {
        _showAlertDialog('Error', 'Ocurrió un error al eliminar la categoría.');
      }
    }
  }

  // Mostrar un diálogo de alerta
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administrar Categorías',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9A641),
          ),
        ),
        backgroundColor: Color(0xFF002929),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditCategoryScreen()),
              ).then((_) => _fetchCategories()); // Refrescar categorías después de agregar/editar
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF002929), // Fondo principal oscuro
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              onChanged: (value) => _filterCategories(value), // Filtrar categorías en tiempo real
              style: TextStyle(color: Color(0xFFD9A641)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF004F4F),
                labelText: 'Buscar por nombre',
                labelStyle: TextStyle(color: Color(0xFFD9A641)),
                prefixIcon: Icon(Icons.search, color: Color(0xFFD9A641)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Contenido principal (lista de categorías)
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFD9A641))) // Indicador de carga
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : filteredCategories.isEmpty
                          ? Center(
                              child: Text(
                                "No se encontraron categorías",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                return Card(
                                  color: Color(0xFF004F4F), // Fondo de la tarjeta
                                  child: ListTile(
                                    title: Text(
                                      category.name,
                                      style: TextStyle(color: Color(0xFFD9A641)),
                                    ),
                                    subtitle: Text(
                                      category.description,
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Color(0xFFD9A641)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddEditCategoryScreen(category: category),
                                              ),
                                            ).then((_) => _fetchCategories()); // Refrescar después de editar
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            _deleteCategory(category.id); // Verificar y eliminar categoría
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
