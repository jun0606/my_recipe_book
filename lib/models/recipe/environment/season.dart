import 'package:hive/hive.dart';

/// 계절 정보
@HiveType(typeId: 7)
enum Season {
  @HiveField(0)
  spring,
  @HiveField(1)
  summer,
  @HiveField(2)
  autumn,
  @HiveField(3)
  winter;

  /// 현재 날짜 기반 계절 계산
  static Season fromDate(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }
}

extension SeasonExtension on Season {
  String get displayName {
    switch (this) {
      case Season.spring:
        return '봄';
      case Season.summer:
        return '여름';
      case Season.autumn:
        return '가을';
      case Season.winter:
        return '겨울';
    }
  }
}
