import 'package:flutter/material.dart';
import '../../../core/storage/videos_cache_store.dart';
import '../../../core/routes/app_routes.dart';

class CachedVideosPage extends StatefulWidget {
  const CachedVideosPage({super.key});

  @override
  State<CachedVideosPage> createState() => _CachedVideosPageState();
}

class _CachedVideosPageState extends State<CachedVideosPage> {
  List<dynamic> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final cached = await VideosCacheStore.getLatest();
    if (!mounted) return;
    setState(() {
      _videos = cached;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Videos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'No cached videos yet. Open the app online to populate recent videos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _videos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final v = _videos[index] as Map<String, dynamic>;
                      final title = v['title']?.toString() ?? 'Video';
                      final videoId = v['videoId']?.toString() ?? '';
                      final thumbnailUrl = v['thumbnailUrl']?.toString();
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                                ? Image.network(thumbnailUrl, width: 56, height: 56, fit: BoxFit.cover)
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.play_circle_outline),
                                  ),
                          ),
                          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.play_arrow),
                          onTap: () {
                            if (videoId.isEmpty) return;
                            Navigator.pushNamed(
                              context,
                              AppRoutes.videoPlayer,
                              arguments: {
                                'videoId': videoId,
                                'videoTitle': title,
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


