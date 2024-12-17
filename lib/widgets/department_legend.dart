import 'package:flutter/material.dart';
import '../utils/department_utils.dart';
import '../l10n/l10n.dart';


class DepartmentLegend extends StatelessWidget {
  final List<String> departmentList;

  const DepartmentLegend({
    required this.departmentList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 根據螢幕寬度動態計算每行顯示的項目數
    final double screenWidth = MediaQuery.of(context).size.width;
    final int itemsPerRow = (screenWidth ~/ 180).clamp(1, departmentList.length); // 每個項目約占 180 像素

    // 生成顏色塊和文字的 legend item
    final List<Widget> legendItems = departmentList.map((departmentKey) {
      final color = DepartmentUtils.getDepartmentColor(departmentKey, isDarkMode: isDarkMode);
      final departmentName = DepartmentUtils.getDepartmentName(context, departmentKey);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4), // 每個項目上下間距
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4), // 圓角設計
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.black,
                  width: 1, // 顏色塊邊框
                ),
              ),
            ),
            const SizedBox(width: 12), // 顏色塊與文字之間的間距
            Flexible(
              child: Text(
                departmentName,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis, // 防止文字超出邊界
              ),
            ),
          ],
        ),
      );
    }).toList();

    // 將 legend items 分組成多行
    List<Row> rows = [];
    for (int i = 0; i < legendItems.length; i += itemsPerRow) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // 整行靠左對齊
          children: legendItems.sublist(
            i,
            (i + itemsPerRow > legendItems.length) ? legendItems.length : i + itemsPerRow,
          ).map((item) => Expanded(
                child: Align(
                  alignment: Alignment.centerLeft, // 每項目靠左對齊
                  child: item,
                ),
              ))
          .toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 整體靠左對齊
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6), // 每行之間的間距
          child: row,
        );
      }).toList(),
    );
  }
}