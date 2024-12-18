import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class CityUtils {
  // 獲取完整的縣市清單
  static List<String> getFullCityList(BuildContext context) {
    return [
      context.l10n.entire_country,
      context.l10n.taipei_city,
      context.l10n.new_taipei_city,
      context.l10n.taoyuan_city,
      context.l10n.taizhong_city,
      context.l10n.tainan_city,
      context.l10n.kaohsiung_city,
      context.l10n.hsinchu_city,
      context.l10n.hsinchu_county,
      context.l10n.miaoli_county,
      context.l10n.changhua_county,
      context.l10n.nantou_county,
      context.l10n.yunlin_county,
      context.l10n.chiayi_city,
      context.l10n.chiayi_county,
      context.l10n.pingtung_county,
      context.l10n.yilan_county,
      context.l10n.hualien_county,
      context.l10n.taizhong_city,
      context.l10n.penghu_county,
      context.l10n.kinmen_county,
      context.l10n.lienchiang_county,
      context.l10n.keelung_city,
    ];
  }

  // 獲取無 "Total" 的縣市清單
  static List<String> getCountyList(BuildContext context) {
    return [
      context.l10n.taipei_city,
      context.l10n.new_taipei_city,
      context.l10n.taoyuan_city,
      context.l10n.taizhong_city,
      context.l10n.tainan_city,
      context.l10n.kaohsiung_city,
      context.l10n.hsinchu_city,
      context.l10n.hsinchu_county,
      context.l10n.miaoli_county,
      context.l10n.changhua_county,
      context.l10n.nantou_county,
      context.l10n.yunlin_county,
      context.l10n.chiayi_city,
      context.l10n.chiayi_county,
      context.l10n.pingtung_county,
      context.l10n.yilan_county,
      context.l10n.hualien_county,
      context.l10n.taitung_county,
      context.l10n.penghu_county,
      context.l10n.kinmen_county,
      context.l10n.lienchiang_county,
      context.l10n.keelung_city,
    ];
  }

  // 獲取包含 "全國" 的縣市清單
  static List<String> getCountiesWithNation(BuildContext context) {
    return [
      context.l10n.entire_country,
      ...getCountyList(context),
    ];
  }

  // 獲取城市對應的索引
  static int getCityIndex(String city, BuildContext context) {
    final cities = getFullCityList(context);
    return cities.indexOf(city) + 2;
  }
}
