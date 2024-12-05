import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/comment_sceen.dart';
import 'package:objetos_perdidos/pages/my_post_screen.dart';
import 'package:objetos_perdidos/pages/porfile_screen.dart';
import 'package:objetos_perdidos/pages/post_create_screen.dart';
import 'package:objetos_perdidos/services/comments_get.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/posts_get.dart';

// Pantalla de comentarios
import 'package:intl/intl.dart'; // Para formatear la fecha

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> futurePosts;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = fetchPosts();
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Evitar recargar la pantalla actual

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreatePublicationScreen(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyPostsScreen(userId: ''),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Perdidos'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No hay publicaciones disponibles.'));
            }

            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue, // Color de fondo igual al banner
        selectedItemColor:
            Colors.red, // Color de los íconos seleccionados (rojo)
        unselectedItemColor:
            Colors.grey, // Color para los íconos no seleccionados
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Publicaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        // Modificar la apariencia de los íconos cuando son presionados
        selectedIconTheme:
            const IconThemeData(color: Colors.red), // Rojo al presionar
        unselectedIconTheme: const IconThemeData(
            color: Colors.grey), // Blanco cuando no está seleccionado
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Future<List<Comment>> futureComments;

  @override
  void initState() {
    super.initState();
    // Cargar los comentarios asociados a la publicación
    futureComments = fetchCommentsByPostId(widget.post.id);
  }

  Widget _buildImage() {
    try {
      if (widget.post.lostItem.image.isNotEmpty) {
        try {
          Uint8List imageBytes = base64Decode(widget.post.lostItem.image);
          if (imageBytes.isNotEmpty) {
            return Image.memory(
              imageBytes,
              height: 250,
              width: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/skibidihomero.png',
                  height: 250,
                  width: 300,
                  fit: BoxFit.cover,
                );
              },
            );
          }
        } catch (e) {
          print('Error decodificando imagen: $e');
        }
      }
      return Image.asset(
        'assets/images/skibidihomero.png',
        height: 250,
        width: 300,
        fit: BoxFit.cover,
      );
    } catch (e) {
      print('Error inesperado con la imagen: $e');
      return Image.asset(
        'assets/images/skibidihomero.png',
        height: 250,
        width: 300,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.post.lostItem.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descripción: ${widget.post.lostItem.description}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ubicación: ${widget.post.lostItem.location}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Carrera: ${widget.post.lostItem.career}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Botón para comentarios
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateCommentScreen(postId: widget.post.id),
                        ),
                      );
                    },
                    child: const Text('Comentar'),
                  ),

                  // Cargar y mostrar los comentarios
                  const SizedBox(height: 10),
                  FutureBuilder<List<Comment>>(
                    future: futureComments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No hay comentarios aún.');
                      }

                      final comments = snapshot.data!;
                      return Column(
                        children: comments
                            .map((comment) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          comment.user.isNotEmpty
                                              ? comment.user[
                                                  0] // Mostrar inicial del autor
                                              : 'U', // Valor por defecto
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Usuario: ${comment.user}', // Aquí puedes mostrar el nombre de usuario
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(comment.content),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Publicado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comment.createdAt))}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
