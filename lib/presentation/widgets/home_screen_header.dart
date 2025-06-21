import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../data/models/filter_type_enum.dart';
import 'dropdown_widget.dart';

class HomeScreenHeader extends StatelessWidget {
  final String userImage;
  final FilterTypeEnum selectedFilter;
  final Function(FilterTypeEnum? value)? onFilterChanged;

  const HomeScreenHeader({
    super.key,
    required this.userImage,
    required this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF357ABD)],
          ),
        ),
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.35,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: CachedNetworkImageProvider(userImage),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kareem Muhammad',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 115,
                  child: DropdownWidget<FilterTypeEnum>(
                    selectedValue: selectedFilter,
                    items: FilterTypeEnum.values.toList(),
                    onChanged: (FilterTypeEnum? value) {
                      if (onFilterChanged != null) {
                        onFilterChanged!.call(value);
                      }
                    },
                    itemLabel: (FilterTypeEnum type) => type.title,
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
