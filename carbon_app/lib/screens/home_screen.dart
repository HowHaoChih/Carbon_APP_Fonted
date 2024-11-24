import 'package:flutter/material.dart';
import '../widgets/national_chart.dart';
import '../widgets/city_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = "台北市"; // 預設城市

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carbon Emission Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 全國碳排放趨勢圖
            const Expanded(
              flex: 2,
              child: NationalChart(),
            ),
            const SizedBox(height: 16),
            // 城市碳排放趨勢圖
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // 城市選擇下拉選單
                  DropdownButton<String>(
                    value: selectedCity,
                    items: const [
                      "南投縣",
                      "台中市",
                      "台北市",
                      "台南市",
                      "台東縣",
                      "嘉義市",
                      "嘉義縣",
                      "基隆市",
                      "宜蘭縣",
                      "屏東縣",
                      "彰化縣",
                      "新北市",
                      "新竹市",
                      "新竹縣",
                      "桃園市",
                      "澎湖縣",
                      "花蓮縣",
                      "苗栗縣",
                      "連江縣",
                      "金門縣",
                      "雲林縣",
                      "高雄市"
                    ].map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                      });
                    },
                  ),
                  // 城市碳排放圖表，當選擇不同的縣市時重新刷新
                  Expanded(
                    child: CityChart(city: selectedCity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
