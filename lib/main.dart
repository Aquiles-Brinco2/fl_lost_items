import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Objetos Perdidos',
      theme: ThemeData(
        primaryColor: const Color(0xFFA50050), // Color personalizado
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Fondo personalizado
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Parkinsans'),
          bodyMedium: TextStyle(fontFamily: 'Parkinsans'),
          displayLarge: TextStyle(fontFamily: 'Parkinsans'),
          displayMedium: TextStyle(fontFamily: 'Parkinsans'),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFFA50050), // Color personalizado para AppBar
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Parkinsans', // Fuente personalizada
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA50050),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Parkinsans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.3),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA50050)),
          ),
          prefixIconColor: const Color(0xFFA50050),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
