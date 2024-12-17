import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'add_favorite.dart'; // 引入 AddFavoritePage

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> favorites = [];

  Future<File> _getFavoriteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/favorite.json';
    return File(filePath);
  }

  Future<void> loadFavorites() async {
    try {
      final file = await _getFavoriteFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = content.isNotEmpty ? jsonDecode(content) : [];
        setState(() {
          favorites = data;
        });
      } else {
        setState(() {
          favorites = [];
        });
      }
    } catch (e) {
      print("讀取失敗: $e");
      setState(() {
        favorites = [];
      });
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
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("操作選項"),
                      content: Text("請選擇操作："),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // 關閉彈窗
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddFavoritePage()),
                            );
                          },
                          child: Text("跳轉到頁面"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // 關閉彈窗
                            await deleteFavorite(index);
                          },
                          child: Text("刪除"),
                        ),
                      ],
                    );
                  },
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
          loadFavorites(); // 回到此頁面時重新加載資料
        },
        tooltip: "新增我的最愛",
        child: const Icon(Icons.add),
      ),
    );
  }
}
