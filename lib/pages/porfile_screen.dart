import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Método para obtener la información del usuario almacenada en SharedPreferences
  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('user_name');
    String? email = prefs.getString('user_email');
    String? phone = prefs.getString('user_phone');
    String? userType = prefs.getString('user_type');
    String? carrera = prefs.getString('user_carrera');
    String? userId = prefs.getString('user_id');
    String? image = prefs.getString('user_image'); // Imagen de usuario

    return {
      'username': username ?? 'No disponible',
      'email': email ?? 'No disponible',
      'phone': phone ?? 'No disponible',
      'userType': userType ?? 'No disponible',
      'carrera': carrera ?? 'No disponible',
      'userId': userId ?? 'No disponible',
      'image': image ?? '', // Si no hay imagen, será una cadena vacía
    };
  }

  // Método para mostrar la imagen de usuario
  Widget _buildProfileImage(String imageBase64) {
    if (imageBase64.isNotEmpty) {
      try {
        // Si la imagen está en formato base64, la decodificamos
        Uint8List imageBytes = base64Decode(imageBase64);
        return CircleAvatar(
          radius: 50,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        print("Error al decodificar la imagen base64: $e");
        return const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/skibidihomero.png'),
        );
      }
    } else {
      // Si no hay imagen o no se pudo cargar, mostramos una imagen por defecto
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/images/skibidihomero.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          } else {
            final userInfo = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mostrar la imagen de perfil
                    _buildProfileImage(userInfo['image']!),

                    const SizedBox(height: 20),

                    // Nombre del usuario
                    Text(
                      userInfo['username']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Información adicional
                    Text(
                      'Correo Electrónico: ${userInfo['email']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Teléfono: ${userInfo['phone']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Carrera: ${userInfo['carrera']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tipo de Usuario: ${userInfo['userType']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID de Usuario: ${userInfo['userId']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
