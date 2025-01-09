import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'add_favorite.dart';
import 'industry_page.dart';
import '../utils/city_utils.dart';
import '../l10n/l10n.dart';

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
    final l10n = context.l10n;

    // 動態翻譯縣市與產業名稱
    String translateCity(String cityKey) {
      final cityMap = {
        "context.l10n.taipei_city": l10n.taipei_city,
        "context.l10n.new_taipei_city": l10n.new_taipei_city,
        "context.l10n.taoyuan_city": l10n.taoyuan_city,
        "context.l10n.taizhong_city": l10n.taizhong_city,
        "context.l10n.tainan_city": l10n.tainan_city,
        "context.l10n.kaohsiung_city": l10n.kaohsiung_city,
        "context.l10n.hsinchu_city": l10n.hsinchu_city,
        "context.l10n.hsinchu_county": l10n.hsinchu_county,
        "context.l10n.miaoli_county": l10n.miaoli_county,
        "context.l10n.changhua_county": l10n.changhua_county,
        "context.l10n.nantou_county": l10n.nantou_county,
        "context.l10n.yunlin_county": l10n.yunlin_county,
        "context.l10n.chiayi_city": l10n.chiayi_city,
        "context.l10n.chiayi_county": l10n.chiayi_county,
        "context.l10n.pingtung_county": l10n.pingtung_county,
        "context.l10n.yilan_county": l10n.yilan_county,
        "context.l10n.hualien_county": l10n.hualien_county,
        "context.l10n.taitung_county": l10n.taitung_county,
        "context.l10n.penghu_county": l10n.penghu_county,
        "context.l10n.kinmen_county": l10n.kinmen_county,
        "context.l10n.lienchiang_county": l10n.lienchiang_county,
        "context.l10n.keelung_city": l10n.keelung_city,
      };
      return cityMap[cityKey] ?? cityKey;
    }

    String translateIndustry(String industryKey) {
      final industryMap = {
        "context.l10n.residential": l10n.residential,
        "context.l10n.services": l10n.services,
        "context.l10n.energy": l10n.energy,
        "context.l10n.manufacturing": l10n.manufacturing,
        "context.l10n.transportation": l10n.transportation,
        "context.l10n.electricity": l10n.electricity,
      };
      return industryMap[industryKey] ?? industryKey;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites_title)),
      body: favorites.isEmpty
          ? Center(child: Text(l10n.no_favorites_message))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          final translatedCity = translateCity(favorite['縣市']);
          final translatedIndustries = (favorite['產業'] as List)
              .map((industry) => translateIndustry(industry))
              .join(', ');

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("${l10n.city_label}: $translatedCity"),
              subtitle: Text("${l10n.industry_label}: $translatedIndustries"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.action_prompt),
                    content: Text(l10n.choose_action_message),
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
                        child: Text(l10n.navigate_action),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await deleteFavorite(index);
                        },
                        child: Text(l10n.delete_action),
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
        tooltip: l10n.add_favorite_tooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
