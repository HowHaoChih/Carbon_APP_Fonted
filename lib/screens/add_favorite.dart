import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AddFavoritePage extends StatefulWidget {
  const AddFavoritePage({super.key});

  @override
  State<AddFavoritePage> createState() => _AddFavoritePageState();
}

class _AddFavoritePageState extends State<AddFavoritePage> {
  String? selectedCity;
  List<String> industries = [
    "residential",
    "services",
    "energy",
    "manufacturing",
    "transportation",
    "electricity"
  ];
  List<String> selectedIndustries = [];

  Future<File> _getFavoriteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/favorite.json';
    return File(filePath);
  }

  Future<void> saveFavorite() async {
    try {
      if (selectedCity == null || selectedIndustries.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("輸入錯誤"),
              content: Text("請選擇縣市與至少一個產業"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("確定"),
                ),
              ],
            );
          },
        );
        return;
      }

      final newFavorite = {
        "縣市": selectedCity,
        "產業": selectedIndustries
      };

      final file = await _getFavoriteFile();
      List<dynamic> currentFavorites = [];

      if (await file.exists()) {
        final content = await file.readAsString();
        currentFavorites = content.isNotEmpty ? jsonDecode(content) : [];
      }

      currentFavorites.add(newFavorite);
      await file.writeAsString(jsonEncode(currentFavorites));

      Navigator.pop(context); // 返回上一頁
    } catch (e) {
      print("儲存失敗: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("新增我的最愛")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "選擇縣市"),
              value: selectedCity,
              items: ["entire_country",
                      "nantou_county",
                      "taizhong_city",
                      "taipei_city",
                      "tainan_city",
                      "taitung_city",
                      "chiayi_city",
                      "chiayi_county",
                      "keelung_city",
                      "yilan_county",
                      "pingtung_county",
                      "changhua_county",
                      "new_taipei_city",
                      "hsinchu_city",
                      "hsinchu_county",
                      "taoyuan_city",
                      "penghu_county",
                      "hualien_county",
                      "miaoli_county",
                      "lienchiang_county",
                      "kinmen_county",
                      "yunlin_county",
                      "kaohsiung_city"]
                  .map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text("選擇產業", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ...industries.map((industry) {
              return CheckboxListTile(
                title: Text(industry),
                value: selectedIndustries.contains(industry),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedIndustries.add(industry);
                    } else {
                      selectedIndustries.remove(industry);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveFavorite,
        tooltip: "完成",
        child: Icon(Icons.check),
      ),
    );
  }
}
