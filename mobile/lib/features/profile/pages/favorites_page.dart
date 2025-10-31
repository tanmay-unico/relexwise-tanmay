import 'package:flutter/material.dart';
import '../../../core/storage/favorites_store.dart';
import '../../../core/routes/app_routes.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavoriteItem> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    final favs = await FavoritesStore.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Text('No favorites yet.'),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final f = _favorites[index];
                      return ListTile(
                        leading: f.thumbnailUrl != null && f.thumbnailUrl!.isNotEmpty
                            ? Image.network(f.thumbnailUrl!, width: 56, height: 56, fit: BoxFit.cover)
                            : const Icon(Icons.video_library),
                        title: Text(
                          f.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.videoPlayer,
                            arguments: {
                              'videoId': f.videoId,
                              'videoTitle': f.title,
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}


