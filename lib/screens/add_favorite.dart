import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/l10n.dart';
import '../utils/city_utils.dart';

class AddFavoritePage extends StatefulWidget {
  const AddFavoritePage({super.key});

  @override
  State<AddFavoritePage> createState() => _AddFavoritePageState();
}

class _AddFavoritePageState extends State<AddFavoritePage> {
  String? selectedCity;

  // 原始產業 key
  final List<String> industries = [
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity",
  ];

  List<String> selectedIndustries = []; // 儲存選中的產業

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
              title: Text(context.l10n.error),
              content: Text(context.l10n.least_choose),
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

      // 產業對應翻譯映射
      final Map<String, String> industryTranslations = {
        "Residential": "context.l10n.residential",
        "Services": "context.l10n.services",
        "Energy": "context.l10n.energy",
        "Manufacturing": "context.l10n.manufacturing",
        "Transportation": "context.l10n.transportation",
        "Electricity": "context.l10n.electricity",
      };

      // 使用 context.l10n 格式產業名稱作為存儲格式
      final translatedIndustries = selectedIndustries.map((industry) {
        return industryTranslations[industry]!; // 確保統一儲存為 context.l10n 格式
      }).toList();

      final cityTranslations = {
        context.l10n.taipei_city: "context.l10n.taipei_city",
        context.l10n.new_taipei_city: "context.l10n.new_taipei_city",
        context.l10n.taoyuan_city: "context.l10n.taoyuan_city",
        context.l10n.taizhong_city: "context.l10n.taizhong_city",
        context.l10n.tainan_city: "context.l10n.tainan_city",
        context.l10n.kaohsiung_city: "context.l10n.kaohsiung_city",
        context.l10n.hsinchu_city: "context.l10n.hsinchu_city",
        context.l10n.hsinchu_county: "context.l10n.hsinchu_county",
        context.l10n.miaoli_county: "context.l10n.miaoli_county",
        context.l10n.changhua_county: "context.l10n.changhua_county",
        context.l10n.nantou_county: "context.l10n.nantou_county",
        context.l10n.yunlin_county: "context.l10n.yunlin_county",
        context.l10n.chiayi_city: "context.l10n.chiayi_city",
        context.l10n.chiayi_county: "context.l10n.chiayi_county",
        context.l10n.pingtung_county: "context.l10n.pingtung_county",
        context.l10n.yilan_county: "context.l10n.yilan_county",
        context.l10n.hualien_county: "context.l10n.hualien_county",
        context.l10n.taitung_county: "context.l10n.taitung_county",
        context.l10n.penghu_county: "context.l10n.penghu_county",
        context.l10n.kinmen_county: "context.l10n.kinmen_county",
        context.l10n.lienchiang_county: "context.l10n.lienchiang_county",
        context.l10n.keelung_city: "context.l10n.keelung_city",
      };

      final translatedCity = cityTranslations[selectedCity] ?? selectedCity;

      final newFavorite = {"縣市": translatedCity, "產業": translatedIndustries};

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
    final l10n = context.l10n; // 獲取 l10n 實例

    // 產業對應翻譯映射
    final Map<String, String> industryTranslations = {
      "Residential": l10n.residential,
      "Services": l10n.services,
      "Energy": l10n.energy,
      "Manufacturing": l10n.manufacturing,
      "Transportation": l10n.transportation,
      "Electricity": l10n.electricity,
    };

    final cities = CityUtils.getCountiesWithNation(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.add_favorite)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCity,
              items: cities.map((county) {
                return DropdownMenuItem(
                  value: county,
                  child: Text(county),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value; // 更新選中的縣市
                  });
                }
              },
              decoration: InputDecoration(
                labelText: l10n.select_city,
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 400, // 設置最大展開高度
            ),
            SizedBox(height: 16.0),
            Text(context.l10n.choose_industry,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ...industries.map((industry) {
              return CheckboxListTile(
                title: Text(industryTranslations[industry]!),
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
