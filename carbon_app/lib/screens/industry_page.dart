import 'package:flutter/material.dart';

class IndustryViewScreen extends StatelessWidget {
  const IndustryViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('產業視圖'),
      ),
      body: const Center(
        child: Text(
          '這是產業視圖頁面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
