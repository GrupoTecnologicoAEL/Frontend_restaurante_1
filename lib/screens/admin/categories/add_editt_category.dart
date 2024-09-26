import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../services/Category_service.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category; // Si está presente, se edita, si no, se agrega una nueva

  AddEditCategoryScreen({this.category});

  @override
  _AddEditCategoryScreenState createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
    }
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        String name = _nameController.text.trim();
        String description = _descriptionController.text.trim();

        if (widget.category == null) {
          // Agregar nueva categoría
          await ServiceCategories().addCategory(Category(
            id: '', // La ID será generada por el backend
            name: name,
            description: description,
          ));
        } else {
          // Editar categoría existente
          await ServiceCategories().editCategory(Category(
            id: widget.category!.id,
            name: name,
            description: description,
          ));
        }

        Navigator.pop(context); // Volver a la pantalla anterior después de guardar
      } catch (e) {
        print('Error al guardar la categoría: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la categoría')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Agregar Categoría' : 'Editar Categoría'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descripción de la Categoría'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveCategory,
                      child: Text(widget.category == null ? 'Agregar' : 'Actualizar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
