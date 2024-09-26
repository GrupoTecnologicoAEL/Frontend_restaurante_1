import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Solo para Web
import 'package:flutter/foundation.dart' show kIsWeb;

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _selectedCategory;
  List<dynamic> _categories = [];
  bool _isLoading = true;
  dynamic _pickedImage; // Para web es dynamic porque puede ser Uint8List o String (URL)
  String? _uploadedImageUrl; // URL de la imagen subida

  final Dio _dio = Dio();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Obtener todas las categorías del backend
  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get('http://localhost:5002/api/categories');
      setState(() {
        _categories = response.data;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  // Función para seleccionar y subir imagen desde la galería
  Future<void> _pickAndUploadImage() async {
    if (kIsWeb) {
      // Seleccionar imagen desde web
      final pickedFile = await ImagePickerWeb.getImageAsBytes();
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        await _uploadImageToFirebase(pickedFile, isWeb: true);
      }
    } else {
      // Seleccionar imagen desde móvil o escritorio
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
        await _uploadImageToFirebase(File(pickedFile.path));
      }
    }
  }

  // Subir imagen a Firebase y obtener la URL
  Future<void> _uploadImageToFirebase(dynamic imageFile, {bool isWeb = false}) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('product_images/$fileName.jpg');

      if (isWeb) {
        await ref.putData(imageFile);  // Subir bytes para web
      } else {
        await ref.putFile(imageFile);  // Subir archivo para móvil/desktop
      }

      final downloadUrl = await ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl; // Asignar la URL de la imagen subida
      });

      print('Imagen subida: $downloadUrl');
    } catch (error) {
      print('Error al subir imagen: $error');
    }
  }

  // Función para agregar un producto
  Future<void> _addProduct() async {
    if (_uploadedImageUrl == null) {
      await _pickAndUploadImage(); // Subir imagen si no se ha subido
    }

    try {
      final response = await _dio.post('http://localhost:5002/api/products', data: {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'stock': int.parse(_stockController.text),
        'category': _selectedCategory,
        'imageUrl': _uploadedImageUrl, // Usar la URL de Firebase
      });

      print('Producto agregado: ${response.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto agregado exitosamente')),
      );
      _clearFields();
      
    } catch (error) {
      print('Error al agregar producto: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar el producto: $error')),
      );
    }
  }
  void _clearFields() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _stockController.clear();
      _selectedCategory = null;
      _pickedImage = null;
      _uploadedImageUrl = null;
    });
  }

  // Mostrar vista previa de la imagen o un mensaje si no se ha seleccionado ninguna imagen
  Widget _buildImagePreview() {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else if (_pickedImage != null && kIsWeb) {
      // Vista previa de imagen para web
      return Image.memory(_pickedImage, height: 150);
    } else if (_pickedImage != null && !kIsWeb) {
      // Vista previa de imagen para móvil/desktop
      return Image.file(_pickedImage, height: 150);
    } else if (_uploadedImageUrl != null) {
      // Mostrar imagen de la URL subida si existe
      return Image.network(_uploadedImageUrl!, height: 150);
    } else {
      return Text('No se ha seleccionado ninguna imagen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nombre del Producto'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Precio'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descripción'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Stock'),
                    ),
                    SizedBox(height: 16),

                    // Dropdown para seleccionar la categoría
                    DropdownButton<String>(
                      value: _selectedCategory,
                      hint: Text('Seleccionar Categoría'),
                      items: _categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Mostrar vista previa de la imagen subida
                    _buildImagePreview(),
                    ElevatedButton(
                      onPressed: _pickAndUploadImage,
                      child: Text('Seleccionar Imagen'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: Text('Agregar Producto'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
