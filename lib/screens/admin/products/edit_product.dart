import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importar Image Picker
import 'dart:io'; // Importar para manejar archivos locales
import '../../../models/product.dart';
import '../../../models/category.dart';
import '../../../services/API_service.dart';
import '../../../services/Category_service.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;
  final Product? productData;

  EditProductScreen({this.productId, this.productData});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Controlador para la URL de la imagen
  Category? _selectedCategory; // Campo para la categoría seleccionada
  bool _isLoading = false;
  List<Category> _categories = []; // Lista para almacenar categorías
  File? _pickedImage; // Para manejar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _nameController.text = widget.productData?.name ?? '';
      _descriptionController.text = widget.productData?.description ?? '';
      _priceController.text = widget.productData?.price.toString() ?? '';
      _stockController.text = widget.productData?.stock.toString() ?? '';
      _imageUrlController.text = widget.productData?.imageUrl ?? ''; // Inicializar con la URL de la imagen
      _selectedCategory = widget.productData?.category; // Inicializar con la categoría existente
    }
    _fetchCategories(); // Obtener categorías al inicializar
  }

  // Función para obtener las categorías desde la API o algún servicio
  void _fetchCategories() async {
    try {
      List<Category> fetchedCategories = await ServiceCategories().getCategories();
      setState(() {
        _categories = fetchedCategories;

        // Verificar si la categoría seleccionada existe en la lista de categorías
        if (_selectedCategory != null && !_categories.any((category) => category.id == _selectedCategory!.id)) {
          _selectedCategory = null; // O asigna un valor por defecto si lo prefieres
        }
      });
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al obtener categorías")));
    }
  }

  // Función para seleccionar una nueva imagen
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path); // Guardar la imagen seleccionada
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String name = _nameController.text.trim();
        String description = _descriptionController.text.trim();
        double price = double.tryParse(_priceController.text.trim()) ?? 0;
        int stock = int.tryParse(_stockController.text.trim()) ?? 0;
        String imageUrl;

        if (_pickedImage != null) {
          // Aquí agregarías el código para subir la imagen a Firebase o cualquier otro servicio y obtener la URL
          imageUrl = 'URL_DE_LA_NUEVA_IMAGEN'; // Esta URL se actualizaría tras la subida de la imagen
        } else {
          // Si no se seleccionó una nueva imagen, usa la imagen existente
          imageUrl = _imageUrlController.text.trim();
        }

        if (_selectedCategory == null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Por favor selecciona una categoría")));
          return;
        }

        final updatedProduct = Product(
          id: widget.productId ?? '', // Si es nulo, usa una cadena vacía
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: imageUrl, // Imagen del producto
          category: _selectedCategory!, // Asegurarse de que la categoría está seleccionada
        );

        if (widget.productId == null) {
          // Crear nuevo producto
          await ApiService().createProduct(updatedProduct);
        } else {
          // Actualizar producto existente
          await ApiService().updateProduct(updatedProduct);
        }

        Navigator.pop(context);
      } catch (e) {
        print('Error saving product: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Envolver en un SingleChildScrollView para permitir desplazamiento
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nombre del Producto'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el nombre del producto';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el precio';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Descripción'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la descripción';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la cantidad de stock';
                          }
                          return null;
                        },
                      ),
                      _pickedImage == null && _imageUrlController.text.isNotEmpty
                          ? Image.network(_imageUrlController.text) // Mostrar la imagen actual
                          : _pickedImage != null
                              ? Image.file(_pickedImage!) // Mostrar la imagen seleccionada
                              : Container(),
                      ElevatedButton(
                        onPressed: _pickImage, // Seleccionar una nueva imagen
                        child: Text("Seleccionar Imagen"),
                      ),
                      DropdownButtonFormField<Category>(
  value: _categories.isNotEmpty
      ? _categories.firstWhere(
          (category) => category.id == _selectedCategory?.id,
          orElse: () => _categories.first, // Devolver la primera categoría si no se encuentra la seleccionada
        )
      : null, // Si no hay categorías, el valor inicial será null
  items: _categories.map((category) {
    return DropdownMenuItem<Category>(
      value: category,
      child: Text(category.name),
    );
  }).toList(),
  onChanged: (Category? newValue) {
    setState(() {
      _selectedCategory = newValue;
    });
  },
  decoration: InputDecoration(labelText: 'Categoría'),
  validator: (value) => value == null ? 'Por favor selecciona una categoría' : null,
),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProduct,
                        child: Text(widget.productId == null ? 'Agregar Producto' : 'Actualizar Producto'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
