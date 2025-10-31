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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 72, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text('No favorites yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final f = _favorites[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: f.thumbnailUrl != null && f.thumbnailUrl!.isNotEmpty
                                ? Image.network(f.thumbnailUrl!, width: 56, height: 56, fit: BoxFit.cover)
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.play_circle_outline),
                                  ),
                          ),
                          title: Text(
                            f.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.play_arrow),
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


