import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// 獲取應用程序的文檔目錄
Future<String> _getFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/favorite.json';
}

// 讀取 JSON 文件
Future<List<dynamic>> readFavorites() async {
  try {
    final path = await _getFilePath();
    final file = File(path);

    // 如果文件存在，讀取數據
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      return data['favorite'] ?? [];
    } else {
      // 如果文件不存在，初始化文件
      await _initializeFavoriteFile();
      return readFavorites(); // 再次讀取
    }
  } catch (e) {
    print("Error reading JSON file: $e");
    return [];
  }
}

// 初始化文件
Future<void> _initializeFavoriteFile() async {
  try {
    final path = await _getFilePath();
    final file = File(path);

    // 初始數據
    const initialData = {
      "favorite": [
        {
          "name": "Taipei",
          "industries": ["Electricity", "Transportation"]
        },
        {
          "name": "Taichung",
          "industries": ["ServiceIndustry", "Manufacturing", "ResidentialSector"]
        }
      ]
    };

    // 寫入初始數據到文件
    await file.writeAsString(jsonEncode(initialData));
  } catch (e) {
    print("Error initializing file: $e");
  }
}