import 'package:flutter/material.dart';

class CountyIndustryViewScreen extends StatelessWidget {
  const CountyIndustryViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('縣市產業視圖'),
      ),
      body: const Center(
        child: Text(
          '這是縣市產業視圖頁面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
