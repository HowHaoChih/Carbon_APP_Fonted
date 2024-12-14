import 'package:flutter/material.dart';

class InfomationScreen extends StatelessWidget {
  const InfomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('有關'),
      ),
      body: const Center(
        child: Text(
          '這是有關頁面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
