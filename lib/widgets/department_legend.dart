import 'package:flutter/material.dart';

class DepartmentLegend extends StatelessWidget {
  final List<String> departmentList;

  const DepartmentLegend({
    required this.departmentList,
    super.key,
  });

  String _getDepartmentName(String key) {
    switch (key) {
      case "Residential":
        return "住宅部門";
      case "Services":
        return "服務業　";
      case "Energy":
        return "能源部門";
      case "Manufacturing":
        return "製造業　";
      case "Transportation":
        return "運輸業　";
      case "Electricity":
        return "電力部門";
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
      final departmentName = _getDepartmentName(departmentKey);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center, // 內容置中
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            departmentName,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    }).toList();

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
