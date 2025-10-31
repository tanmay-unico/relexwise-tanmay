import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/api/services.dart';
import '../../../core/storage/favorites_store.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../bloc/videos_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _videos = [];
  bool _isLoading = false;
  Set<String> _favoriteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadVideosCubit(BuildContext context, {bool refresh = false}) async {
    await context.read<VideosCubit>().load(refresh: refresh);
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesStore.getFavorites();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favs.map((e) => e.videoId).toSet();
    });
  }

  Future<void> _toggleFavorite(Map<String, dynamic> v) async {
    final videoId = v['videoId']?.toString() ?? '';
    final title = v['title']?.toString() ?? 'Video';
    final thumbnailUrl = v['thumbnailUrl']?.toString();
    if (videoId.isEmpty) return;
    if (_favoriteIds.contains(videoId)) {
      await FavoritesStore.remove(videoId);
      if (!mounted) return;
      setState(() {
        _favoriteIds.remove(videoId);
      });
      return;
    }
    await FavoritesStore.add(FavoriteItem(videoId: videoId, title: title, thumbnailUrl: thumbnailUrl));
    if (!mounted) return;
    setState(() {
      _favoriteIds.add(videoId);
    });
  }

  Future<void> _shareVideo(Map<String, dynamic> v) async {
    final title = v['title']?.toString() ?? 'Video';
    final videoId = v['videoId']?.toString() ?? '';
    final url = videoId.isNotEmpty ? 'https://www.youtube.com/watch?v=$videoId' : '';
    final text = url.isNotEmpty ? '$title\n$url' : title;
    await Share.share(text, subject: title);
  }

  

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VideosCubit>()..load(),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Relexwise'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: BlocBuilder<VideosCubit, VideosState>(
        builder: (context, state) {
          if (state is VideosLoading && _videos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideosLoaded) {
            _videos = state.videos;
          }
          if (state is VideosError && _videos.isEmpty) {
            return Center(child: Text(state.message));
          }
          return RefreshIndicator(
            onRefresh: () => _loadVideosCubit(context, refresh: true),
            child: ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(index);
              },
            ),
          );
        },
      ),
    ));
  }

  Widget _buildVideoCard(int index) {
    final v = _videos[index] as Map<String, dynamic>;
    final title = v['title']?.toString() ?? 'Video';
    final videoId = v['videoId']?.toString() ?? '';
    final thumbnailUrl = v['thumbnailUrl']?.toString();
    final channelName = v['channelName']?.toString() ?? '';
    final publishedAt = v['publishedAt']?.toString() ?? '';
    final durationSeconds = v['durationSeconds'] is int ? v['durationSeconds'] as int? : null;
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.videoPlayer,
            arguments: {
              'videoId': videoId,
              'videoTitle': title,
            },
          );
        },
        onLongPress: () {
          _showVideoMenu(index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                thumbnailUrl != null && thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey[600]),
                      ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      IconButton(
                        icon: Icon(_favoriteIds.contains(videoId) ? Icons.favorite : Icons.favorite_border,
                            color: _favoriteIds.contains(videoId) ? Colors.red : null),
                        onPressed: () {
                          _toggleFavorite(v);
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'favorite',
                            child: Text('Add to Favorites'),
                          ),
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Text('Share'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'favorite') {
                            // TODO: Implement favorite
                          } else if (value == 'details') {
                            // TODO: Show details
                          } else if (value == 'share') {
                            _shareVideo(v);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gate smashers',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2 days ago',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Add to Favorites'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareVideo(_videos[index] as Map<String, dynamic>);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

