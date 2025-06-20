import 'package:flutter/material.dart';

import '../app_colors.dart';

class ScreenHelpers {
  static const String userImage =
      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D';
  static final List<Map<String, dynamic>> categories = [
    {
      'name': 'Groceries',
      'icon': Icons.shopping_cart,
      'color': AppColors.primary,
    },
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': AppColors.primary},
    {
      'name': 'Gas',
      'icon': Icons.local_gas_station,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFFFD93D),
    },
    {
      'name': 'News Paper',
      'icon': Icons.newspaper,
      'color': const Color(0xFFFFB347),
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': const Color(0xFF9B59B6),
    },
    {'name': 'Rent', 'icon': Icons.home, 'color': const Color(0xFFE67E22)},
  ];

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      case 'rent':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return const Color(0xFF4A90E2);
      case 'entertainment':
        return const Color(0xFFFF9500);
      case 'transportation':
        return const Color(0xFF9B59B6);
      case 'rent':
        return const Color(0xFFE67E22);
      case 'food':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return 'Today ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
