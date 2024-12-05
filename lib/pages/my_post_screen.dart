import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/post_edit_screen.dart';
import 'package:objetos_perdidos/services/post_user_get.dart';
import 'package:objetos_perdidos/services/main_class.dart';

class MyPostsScreen extends StatefulWidget {
  final String userId;

  const MyPostsScreen({super.key, required this.userId});

  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    // Filtrar solo las publicaciones del usuario actual
    futurePosts = fetchMyPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = fetchMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Publicaciones'),
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
              return const Center(child: Text('No tienes publicaciones'));
            }

            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return MyPostCard(post: post);
              },
            );
          },
        ),
      ),
    );
  }
}

class MyPostCard extends StatelessWidget {
  final Post post;

  const MyPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.lostItem.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Descripción: ${post.lostItem.description}'),
            const SizedBox(height: 5),
            Text('Estado: ${post.status}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(post: post),
                  ),
                );
              },
              child: const Text('Editar Publicación'),
            ),
          ],
        ),
      ),
    );
  }
}
