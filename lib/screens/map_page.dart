import 'package:flutter/material.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖視角'),
      ),
      body: const Center(
        child: Text(
          '這是地圖視角頁面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
