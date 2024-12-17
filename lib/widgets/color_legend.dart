import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class ColorLegend extends StatelessWidget {
  const ColorLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.carbon, // 顯示標題
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            height: 16,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                stops: [
                  0.0, // 0%
                  0.25, // 25%
                  0.5, // 50%
                  0.625, // 62.5%
                  0.75, // 75%
                  1.0, // 100%
                ],
                colors: [
                  Color(0xFF00FF00), // 綠色
                  Color(0xFFFFFF00), // 黃色
                  Color(0xFFFFA500), // 橘色
                  Color(0xFFFF4500), // 深橘色
                  Color(0xFFFF0000), // 紅色
                  Color(0xFF000000), // 黑色
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0', style: TextStyle(fontSize: 10)),
              Text('25', style: TextStyle(fontSize: 10)),
              Text('50', style: TextStyle(fontSize: 10)),
              Text('100', style: TextStyle(fontSize: 10)),
              Text('250', style: TextStyle(fontSize: 10)),
              Text('500+', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
