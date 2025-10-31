import 'package:flutter/material.dart';

class CachedVideosPage extends StatelessWidget {
  const CachedVideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Videos')),
      body: const Center(
        child: Text('No cached videos yet.'),
      ),
    );
  }
}


