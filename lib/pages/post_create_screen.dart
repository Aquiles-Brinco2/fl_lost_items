import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:objetos_perdidos/services/posts_create.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() =>
      _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController careerController = TextEditingController();

  String? base64Image;
  String? selectedCategory;
  String? selectedLocation;
  String? selectedStatus = 'Perdido'; // Valor por defecto
  bool isLoading = false;

  // Listas para los dropdowns
  final List<String> categories = [
    'Ropa',
    'Electrónico',
    'Material',
    'Documentos',
    'Otros'
  ];
  final List<String> locations = [
    'Recepción',
    'Aulas PG',
    'Cafetería',
    'Aulas T',
    'Aulas M',
    'Estacionamiento',
    'Entrada',
  ];
  final List<String> statusOptions = [
    'Perdido',
    'Encontrado'
  ]; // Opciones para el estado

  @override
  void initState() {
    super.initState();
    _loadUserCareer();
  }

  Future<void> _loadUserCareer() async {
    final prefs = await SharedPreferences.getInstance();
    final userCareer = prefs.getString('user_carrera');
    if (userCareer != null) {
      careerController.text =
          userCareer; // Prellenar el campo con la carrera guardada
    }
  }

  Future<void> handleCreatePublication() async {
    setState(() {
      isLoading = true;
    });

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final career = careerController.text.trim();
    final status = selectedStatus!; // Obtener el valor del estado seleccionado

    if (name.isEmpty ||
        description.isEmpty ||
        career.isEmpty ||
        status.isEmpty ||
        selectedCategory == null ||
        selectedLocation == null ||
        base64Image == null) {
      setState(() {
        isLoading = false;
      });
      _showError('Por favor, completa todos los campos');
      return;
    }

    final result = await createPublication(
      name,
      description,
      base64Image!,
      selectedCategory!,
      selectedLocation!,
      career,
      status, // Pasar el estado como parte de la publicación
    );

    if (result['success']) {
      _showSuccess(result['message']);
    } else {
      _showError(result['message']);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes != null) {
        setState(() {
          base64Image = base64Encode(Uint8List.fromList(bytes));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                'Crea una nueva publicación',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del objeto perdido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                items: locations
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLocation = value),
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Cambiar a un TextField solo si es necesario (puedes ocultar el campo si ya tienes la carrera del usuario)
              TextField(
                controller: careerController,
                readOnly:
                    true, // Si solo quieres mostrar la carrera del usuario y no permitir edición
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Nuevo campo para el estado
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status[0].toUpperCase() +
                              status.substring(
                                  1)), // Capitalizar la primera letra
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedStatus = value),
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16),
              if (base64Image != null)
                const Text('Imagen seleccionada',
                    style: TextStyle(color: Colors.green)),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: handleCreatePublication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Crear Publicación'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
