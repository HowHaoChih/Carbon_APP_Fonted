import 'package:flutter/material.dart';

/// 提供與部門相關的工具方法
class DepartmentUtils {
  /// 返回所有部門的英文名稱列表
  static List<String> getAllDepartments() {
    return [
      "Residential",
      "Services",
      "Energy",
      "Manufacturing",
      "Transportation",
      "Electricity"
    ];
  }

  /// 根據部門的英文名稱回傳對應的中文名稱
  static String getDepartmentName(String key) {
    switch (key) {
      case "Residential":
        return "住宅部門";
      case "Services":
        return "服務業　";
      case "Energy":
        return "能源部門";
      case "Manufacturing":
        return "製造部門";
      case "Transportation":
        return "運輸部門";
      case "Electricity":
        return "電力部門";
      default:
        return key; // 如果沒有對應的中文名稱，則直接回傳原始值
    }
  }

  /// 根據部門的英文名稱回傳對應的顏色
  static Color getDepartmentColor(String department) {
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
        return Colors.grey; // 預設顏色
    }
  }
}
