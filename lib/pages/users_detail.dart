import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailScreen({super.key, required this.user});

  Future<void> deleteUser(BuildContext context) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        final response = await http.delete(
          Uri.parse('http://localhost:3000/api/users/user/${user['_id']}'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado con éxito')),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Error deleting user');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(
                  base64Decode(user['image']),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Nombre: ${user['name']}',
                style: const TextStyle(fontSize: 18)),
            Text('Carrera: ${user['carrera']}',
                style: const TextStyle(fontSize: 18)),
            Text('Email: ${user['email']}',
                style: const TextStyle(fontSize: 18)),
            Text('Teléfono: ${user['phone']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => deleteUser(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
