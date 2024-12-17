import 'package:flutter/material.dart';

class MapSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final double width; // 新增可調整的 width 參數

  const MapSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.width = 40, // 默認值為 40
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(label),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.toStringAsFixed(0),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: width, // 使用可調整的 width
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
