enum FilterTypeEnum {
  lastWeek(title: 'Last 7 Days'),
  thisMonth(title: 'This Month'),
  all(title: 'All');

  final String title;

  const FilterTypeEnum({required this.title});

  static FilterTypeEnum getFilter(String title) {
    for (FilterTypeEnum type in FilterTypeEnum.values) {
      if (type.title.toLowerCase() == title.toLowerCase()) return type;
    }
    return FilterTypeEnum.all;
  }
}
