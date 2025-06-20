import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropdownWidget<T> extends StatelessWidget {
  final T selectedValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final Color? fillColor;
  final TextStyle? textStyle;
  final EdgeInsets? contentPadding;

  const DropdownWidget({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.fillColor,
    this.textStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: selectedValue,
      style: textStyle,
      icon: Icon(CupertinoIcons.chevron_down),
      iconSize: 18,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        fillColor: fillColor ?? Colors.grey[100],
        filled: true,
      ),
      items: items.map<DropdownMenuItem<T>>((T item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
