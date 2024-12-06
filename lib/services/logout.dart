import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Método para hacer logout
  Future<bool> logout(String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$ngrokLink/api/auth/logout'),
        body: jsonEncode({'userId': userId}),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return true; // Logout exitoso
      } else {
        print('Error al hacer logout en el servidor: ${response.body}');
        return false; // Error en el servidor
      }
    } catch (e) {
      print('Error al hacer logout: $e');
      return false; // Error en la conexión
    }
  }

  // Método para eliminar los datos de usuario de SharedPreferences
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar todas las preferencias guardadas
  }
}
