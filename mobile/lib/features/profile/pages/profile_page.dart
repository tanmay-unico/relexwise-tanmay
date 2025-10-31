import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/api/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/favorites_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  List<FavoriteItem> _favorites = [];
  String? _userName;
  String? _userEmail;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadUser();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesStore.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favs;
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
    });
  }

  Future<void> _sendTestPush() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and body')),
      );
      return;
    }

    try {
      // Ensure user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again before sending a test push.')),
        );
        return;
      }

      await apiService.sendTestPush(
        _titleController.text.trim(),
        _bodyController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test push sent!')),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      String message = 'Failed to send test push';
      try {
        // Try to extract server message if DioException
        // ignore: avoid_dynamic_calls
        final data = (e as dynamic).response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;

              try {
                // Clear local auth state
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('access_token');
                await prefs.remove('user_id');
                await prefs.remove('user_name');
                await prefs.remove('user_email');
                await prefs.setBool('is_logged_in', false);
              } catch (_) {}

              if (!mounted) return;
              // Remove all routes and go to splash to re-evaluate auth
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.splash,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            _userName ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            _userEmail ?? '',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Test Push Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter notification title',
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    border: OutlineInputBorder(),
                    hintText: 'Enter notification body',
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _sendTestPush,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Push'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rate limit: 5 requests per minute',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

