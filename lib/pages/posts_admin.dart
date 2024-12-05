import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:objetos_perdidos/services/comments_delete.dart';
import 'package:objetos_perdidos/services/comments_get.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/posts_delete.dart';
import 'package:objetos_perdidos/services/posts_get.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

// Pantalla de comentarios
class PostsAdmin extends StatefulWidget {
  const PostsAdmin({super.key});

  @override
  _PostsAdminState createState() => _PostsAdminState();
}

class _PostsAdminState extends State<PostsAdmin> {
  late Future<List<Post>> futurePosts;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                return PostCard(
                  post: post,
                  onPostDeleted: () => _refreshPosts(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onPostDeleted;

  const PostCard({super.key, required this.post, required this.onPostDeleted});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Future<List<Comment>> futureComments;

  @override
  void initState() {
    super.initState();
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

  Future<void> _deletePost() async {
    try {
      await deletePost(widget
          .post.id); // Llamamos a la nueva función deletePost pasando el postId
      widget.onPostDeleted(); // Refrescamos la lista de posts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la publicación')),
      );
    }
  }

  // Método para eliminar un comentario
  Future<void> _deleteComment(String commentId) async {
    try {
      await deleteComment(
          commentId); // Llamamos al servicio de eliminación del comentario
      setState(() {
        futureComments = fetchCommentsByPostId(
            widget.post.id); // Refrescamos los comentarios
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el comentario')),
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
                  const SizedBox(height: 12),

                  // Botón para eliminar el post
                  ElevatedButton(
                    onPressed: _deletePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar publicación'),
                  ),

                  const SizedBox(height: 10),

                  // Cargar y mostrar los comentarios con botón de eliminar
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
                            .map((comment) => ListTile(
                                  title: Text(comment.content),
                                  subtitle: Text(
                                    'Publicado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comment.createdAt))}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _deleteComment(comment.id),
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
