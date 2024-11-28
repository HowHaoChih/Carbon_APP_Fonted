import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 假設有一組收藏項目
    final List<String> favoriteItems = [
      'Taipei - Transportation',
      'Taichung - Electricity',
      'Kaohsiung - Residential',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                'No Favorites Yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(favoriteItems[index]),
                );
              },
            ),
    );
  }
}
