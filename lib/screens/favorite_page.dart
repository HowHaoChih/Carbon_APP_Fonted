import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'add_favorite.dart';
import 'industry_page.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favorites = [];

  Future<File> _getFavoriteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorite.json');
  }

  Future<void> loadFavorites() async {
    try {
      final file = await _getFavoriteFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = content.isNotEmpty ? jsonDecode(content) : [];
        setState(() {
          favorites = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("讀取失敗: $e");
      setState(() => favorites = []);
      final file = await _getFavoriteFile();
      await file.writeAsString(jsonEncode([]));
      print("已創建 favorite.json 文件");
    }
  }

  Future<void> deleteFavorite(int index) async {
    try {
      favorites.removeAt(index);
      final file = await _getFavoriteFile();
      await file.writeAsString(jsonEncode(favorites));
      setState(() {});
    } catch (e) {
      print("刪除失敗: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
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
              title: Text("縣市: ${favorite['縣市']}"),
              subtitle: Text("產業: ${(favorite['產業'] as List).join(', ')}"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("選擇操作"),
                    content: Text("請選擇要執行的操作"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndustryViewScreen(
                                initialCity: favorite['縣市'],
                                initialIndustries: List<String>.from(favorite['產業']),
                              ),
                            ),
                          );
                        },
                        child: Text("跳轉至指定頁面"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await deleteFavorite(index);
                        },
                        child: Text("刪除最愛"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFavoritePage()),
          );
          loadFavorites();
        },
        tooltip: "新增我的最愛",
        child: const Icon(Icons.add),
      ),
    );
  }
}