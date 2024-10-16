import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importar Image Picker
import 'dart:io'; // Importar para manejar archivos locales
import 'package:flutter/foundation.dart'; // Importar kIsWeb para Flutter web
import 'package:image_picker_web/image_picker_web.dart'; // Solo para Web

import '../../../models/product.dart';
import '../../../models/category.dart' as myCategory;
import '../../../services/API_service.dart';
import '../../../services/Category_service.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importar para Firebase Storage
import 'dart:typed_data'; // Para manejar Uint8List en web

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
  myCategory.Category? _selectedCategory; // Campo para la categoría seleccionada
  bool _isLoading = false;
  List<myCategory.Category> _categories = []; // Lista para almacenar categorías
  File? _pickedImage; // Para manejar la imagen seleccionada (solo móvil)
  Uint8List? _webPickedImage; // Imagen seleccionada (solo web)

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
      List<myCategory.Category> fetchedCategories = await ServiceCategories().getCategories();
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

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('product_images/$fileName.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  // Subir imagen en formato Uint8List (para web) y obtener la URL
  Future<String> _uploadImageWeb(Uint8List imageData) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('product_images/$fileName.jpg');

      UploadTask uploadTask = ref.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));  // Asegúrate de que el tipo MIME sea correcto
      TaskSnapshot snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error uploading image in web: $error');
      return '';
    }
  }

  // Función para seleccionar una nueva imagen (móvil)
  Future<void> _pickImageMobile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path); // Guardar la imagen seleccionada
      });
    }
  }

  // Función para seleccionar una nueva imagen (web)
  Future<void> _pickImageWeb() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();  // Usamos ImagePickerWeb para obtener bytes
    if (pickedFile != null) {
      setState(() {
        _webPickedImage = pickedFile; // Guardar la imagen seleccionada en Uint8List
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Obtener datos del formulario
        String name = _nameController.text.trim();
        String description = _descriptionController.text.trim();
        double price = double.tryParse(_priceController.text.trim()) ?? 0;
        int stock = int.tryParse(_stockController.text.trim()) ?? 0;
        String imageUrl = _imageUrlController.text.trim(); // Usar la imagen actual si no se cambia

        // Si se seleccionó una imagen en la web, subirla
        if (kIsWeb && _webPickedImage != null) {
          imageUrl = await _uploadImageWeb(_webPickedImage!); // Subir Uint8List a Firebase en la web
        } 
        // Si se seleccionó una imagen en móvil, subirla
        else if (_pickedImage != null) {
          imageUrl = await _uploadImage(_pickedImage!); // Subir archivo File a Firebase en móvil
        }

        // Validar si se seleccionó una categoría
        if (_selectedCategory == null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Por favor selecciona una categoría")),
          );
          return;
        }

        // Crear o actualizar el producto con los datos y la URL de la imagen
        final updatedProduct = Product(
          id: widget.productId ?? '',
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: imageUrl, // Usar la URL de la imagen, nueva o existente
          category: _selectedCategory!, // Categoría seleccionada
        );

        if (widget.productId == null) {
          // Crear nuevo producto
          await ApiService().createProduct(updatedProduct);
        } else {
          // Actualizar producto existente
          await ApiService().updateProduct(updatedProduct);
        }

        // Navegar hacia atrás después de guardar
        Navigator.pop(context);
      } catch (e) {
        print('Error saving product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el producto: $e')),
        );
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (_webPickedImage != null)
                        Image.memory(_webPickedImage!, height: 200) // Mostrar la imagen seleccionada en la web
                      else if (_pickedImage != null)
                        Image.file(_pickedImage!, height: 200) // Mostrar la imagen seleccionada en móvil
                      else if (_imageUrlController.text.isNotEmpty)
                        Image.network(_imageUrlController.text, height: 200), // Mostrar la imagen actual
                      ElevatedButton(
                        onPressed: kIsWeb ? _pickImageWeb : _pickImageMobile, // Seleccionar una nueva imagen
                        child: Text("Seleccionar Imagen"),
                      ),
                      DropdownButtonFormField<myCategory.Category>(
                        value: _categories.isNotEmpty
                            ? _categories.firstWhere(
                                (category) => category.id == _selectedCategory?.id,
                                orElse: () => _categories.first,
                              )
                            : null,
                        items: _categories.map((category) {
                          return DropdownMenuItem<myCategory.Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (myCategory.Category? newValue) {
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
