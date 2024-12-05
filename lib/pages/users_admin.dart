import 'dart:convert'; // Para decodificar la imagen base64
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/pages/users_detail.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Método para obtener los usuarios directamente del servidor
  Future<void> fetchUsers() async {
    try {
      // Aquí se hace la solicitud a la ruta que ya filtra los usuarios
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/users/users/normal'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data; // Aquí ya obtenemos los usuarios filtrados por 'normal'
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading users: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64Decode(user['image']),
                          ),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailScreen(user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
