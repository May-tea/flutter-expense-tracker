import '../models/stats_filter.dart';

extension StatsFilterX on StatsFilter {
  String get label => switch (this) {
    .thisMonth => 'This Month',
    .threeMonths => '3M',
    .sixMonths => '6M',
    .all => 'All',
  };
}
