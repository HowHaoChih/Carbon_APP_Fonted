import 'package:flutter/material.dart';
import '../widgets/readFavorite.dart';
import '../widgets/writeFavorite.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> favorites = [];

  // 調用 readFavorites 讀取數據
  Future<void> loadFavorites() async {
    final List<dynamic> data = await readFavorites();  // 確保這裡調用了正確的 method
    setState(() {
      favorites = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();  // 進入頁面時調用
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("我的最愛")),
      body: favorites.isEmpty
          ? Center(child: Text("尚未建立我的最愛，按下右下角按鈕新增"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("縣市: ${favorite['name']}"),
              subtitle: Text("產業: ${favorite['industries'].join(', ')}"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await loadFavorites(); // 按下按鈕執行讀取操作
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("我的最愛重置完成")),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Load Favorites",
      ),
    );
  }
}