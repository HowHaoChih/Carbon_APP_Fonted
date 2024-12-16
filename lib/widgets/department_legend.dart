import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class DepartmentLegend extends StatelessWidget {
  final List<String> departmentList;

  const DepartmentLegend({
    required this.departmentList,
    super.key, // 使用 super 的簡化參數形式
  });

  String _getDepartmentName(BuildContext context, String key) {
    switch (key) {
      case "Residential":
        return context.l10n.residential;
      case "Services":
        return context.l10n.services;
      case "Energy":
        return context.l10n.energy;
      case "Manufacturing":
        return context.l10n.manufacturing;
      case "Transportation":
        return context.l10n.transportation;
      case "Electricity":
        return context.l10n.electricity;
      default:
        return key;
    }
  }

  Color _getColorForDepartment(String department) {
    switch (department) {
      case "Residential":
        return Colors.orange;
      case "Services":
        return Colors.blue;
      case "Energy":
        return Colors.green;
      case "Manufacturing":
        return Colors.purple;
      case "Transportation":
        return Colors.red;
      case "Electricity":
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> legendItems = departmentList.map((departmentKey) {
      final color = _getColorForDepartment(departmentKey);
      final departmentName = _getDepartmentName(context, departmentKey);
      return Row(
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
      children: rows.map((row) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: row.map((item) => Expanded(child: item)).toList(),
        );
      }).toList(),
    );
  }
}