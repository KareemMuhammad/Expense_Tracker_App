import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/add_expense/add_expense_bloc.dart';

class CategoriesGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoriesGridWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AddExpenseBloc, AddExpenseState>(
          buildWhen: (previous, current) =>
              previous is AddExpenseFormState &&
              current is AddExpenseFormState &&
              previous.selectedCategory != current.selectedCategory,
          builder: (context, state) {
            String selectedCategory = 'Entertainment'; // Default
            if (state is AddExpenseFormState) {
              selectedCategory = state.selectedCategory;
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length + 1,
              // +1 for "Add Category"
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return _buildAddCategoryItem();
                }

                final category = categories[index];
                final isSelected = category['name'] == selectedCategory;

                return GestureDetector(
                  onTap: () => context.read<AddExpenseBloc>().add(
                    ChangeCategory(category['name']),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category['color']
                              : category['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : category['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddCategoryItem() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Icon(Icons.add, color: Colors.grey[600], size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Add Category',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
