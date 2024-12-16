class CityUtils {
  // 獲取完整的縣市清單
  static List<String> getFullCityList() {
    return [
      "Total",
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
    ];
  }

  // 獲取無 "Total" 的縣市清單
  static List<String> getCountyList() {
    return [
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
    ];
  }

  // 獲取包含 "全國" 的縣市清單
  static List<String> getCountiesWithNation() {
    return [
      "全國",
      ...getCountyList(),
    ];
  }

  // 獲取城市對應的索引
  static int getCityIndex(String city) {
    final cities = getFullCityList();
    return cities.indexOf(city) + 2;
  }
}
