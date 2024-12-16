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
    final List<Widget> legendItems = departmentList.map((departmentKey) {
      final color = DepartmentUtils.getDepartmentColor(departmentKey);
      final departmentName = DepartmentUtils.getDepartmentName(context, departmentKey);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center, // 內容置中
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              departmentName,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis, // 防止文字超出邊界
            ),
          ),
        ],
      );
    }).toList();

    // 計算每列最多項目數量
    final double screenWidth = MediaQuery.of(context).size.width;
    final int itemsPerRow = screenWidth ~/ 150; // 每個項目大約佔 150 像素的寬度

    // 將項目分組
    List<List<Widget>> rows = [];
    for (int i = 0; i < legendItems.length; i += itemsPerRow) {
      rows.add(legendItems.sublist(
        i,
        i + itemsPerRow > legendItems.length ? legendItems.length : i + itemsPerRow,
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // 整體置中
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 第一排置中
          crossAxisAlignment: CrossAxisAlignment.start,
          children: legendItems
              .sublist(0, 3)
              .map((item) => Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft, // 顏色部分對齊左側
                      child: item,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 第二排置中
          crossAxisAlignment: CrossAxisAlignment.start,
          children: legendItems
              .sublist(3)
              .map((item) => Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft, // 顏色部分對齊左側
                      child: item,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}