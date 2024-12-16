import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

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

  /// 根據部門的英文名稱回傳對應的中英文名稱
  static String getDepartmentName(BuildContext context, String key) {
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

    /// 根據部門的英文名稱和當前主題模式回傳對應的顏色
  static Color getDepartmentColor(String department, {required bool isDarkMode}) {
    switch (department) {
      case "Residential":
        return isDarkMode ? Color(0xffffb171) : Color(0xfff59e0b);
      case "Services":
        return isDarkMode ? Color(0xfffdd147) : Color(0xffeab308);
      case "Energy":
        return isDarkMode ? Color(0xFFbaf264) : Color(0xff84cc16);
      case "Manufacturing":
        return isDarkMode ? Color(0xff09de76) : Color(0xff09de76);
      case "Transportation":
        return isDarkMode ? Color(0xFF6ee7bf) : Color(0xff10b981);
      case "Electricity":
        return isDarkMode ? Color(0xff06b6d4) : Color(0xff06b6d4);
      default:
        return isDarkMode ? Color(0xFFFF0000FF) : Colors.grey; // 預設顏色
    }
  }
}