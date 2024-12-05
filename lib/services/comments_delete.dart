import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetos_perdidos/services/token.dart';

Future<void> deleteComment(String commentId) async {
  final response = await http.delete(
    Uri.parse(
        'http://localhost:3000/api/comments/delete/$commentId'), // Cambia la URL a la correcta
    headers: {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      // 'Authorization': 'Bearer $token', // Si necesitas autenticación con token, descomenta esta línea
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar el comentario');
  }
}
