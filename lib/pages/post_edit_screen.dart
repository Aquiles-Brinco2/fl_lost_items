import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:objetos_perdidos/pages/my_post_screen.dart';
import 'package:objetos_perdidos/services/posts_update.dart';
import 'package:objetos_perdidos/services/posts_delete.dart';
import 'package:objetos_perdidos/services/main_class.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();

  String? base64Image;
  String? selectedCategory;
  String? selectedLocation;
  String? selectedStatus;
  bool isLoading = false;

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
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.post.lostItem.name;
    _descriptionController.text = widget.post.lostItem.description;
    _careerController.text = widget.post.lostItem.career;
    selectedCategory = widget.post.lostItem.category;
    selectedLocation = widget.post.lostItem.location;
    selectedStatus = widget.post.lostItem.found ? 'Encontrado' : 'Perdido';
    // Convertir la imagen actual a base64 si es necesario
    base64Image = widget.post.lostItem.image; // Asume que ya está en base64
  }

  Future<void> _pickImage() async {
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

  Future<void> _updateLostItem() async {
    setState(() {
      isLoading = true;
    });

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final career = _careerController.text.trim();
    final status = selectedStatus!;

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

    try {
      await updateLostItem(
        lostItemId: widget.post.lostItem.id,
        name: name,
        description: description,
        image: base64Image!,
        found: status == 'Encontrado',
        status: status,
        category: selectedCategory!,
        location: selectedLocation!,
        career: career,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objeto actualizado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Error al actualizar: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deletePost() async {
    // Mostrar el cuadro de confirmación antes de eliminar
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta publicación?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // El usuario cancela
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // El usuario confirma
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    // Si el usuario confirma, proceder con la eliminación
    if (confirmDelete == true) {
      try {
        await deletePost(widget.post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada con éxito')),
        );
        // Redirige a la pantalla 'my_posts' (cambia '/my_posts' por la ruta que uses)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPostsScreen(userId: ''),
          ),
        );
      } catch (e) {
        _showError('Error al eliminar: $e');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                'Edita la publicación',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del objeto perdido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
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
              TextField(
                controller: _careerController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
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
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16),
              if (base64Image != null)
                const Text('Imagen seleccionada',
                    style: TextStyle(color: Colors.green)),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateLostItem,
                            child: const Text('Guardar Cambios'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deletePost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Eliminar'),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
