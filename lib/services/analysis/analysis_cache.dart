import 'package:my_recipe_book/models/analysis_result.dart';

/// 분석 결과 캐시 인터페이스
///
/// 분석 결과를 저장하고 검색하는 기능을 정의합니다.
abstract class AnalysisCache {
  /// 캐시에 분석 결과를 저장합니다.
  /// [key]는 캐시 키, [result]는 저장할 분석 결과, [ttl]은 유효 시간(초)입니다.
  Future<void> set(String key, AnalysisResult result, {int? ttl});

  /// 캐시에서 분석 결과를 가져옵니다.
  /// [key]에 해당하는 분석 결과가 없거나 만료되었으면 null을 반환합니다.
  Future<AnalysisResult?> get(String key);

  /// 캐시에서 특정 키에 해당하는 분석 결과를 제거합니다.
  Future<void> remove(String key);

  /// 캐시를 비웁니다.
  Future<void> clear();

  /// 캐시 통계를 가져옵니다.
  Map<String, dynamic> getStats();

  /// 캐시를 초기화합니다.
  Future<void> initialize();

  /// 캐시를 정리합니다.
  Future<void> dispose();
}