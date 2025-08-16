/// 반죽 믹싱 시간 어드바이저
/// 반죽 상태 분석을 기반으로 최적의 믹싱 시간과 속도를 제안

import 'dart:math' as math;
import '../services/dough_state_analyzer.dart';

class MixingTimeAdvisor {
  /// 최적 믹싱 시간 계산
  static MixingTimeResult calculateOptimalMixingTime({
    required DoughStateAnalysisResult doughState,
    required List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    String mixerType = 'stand_mixer', // stand_mixer, hand_mixer, hand_kneading
    double doughWeight = 1000.0, // 반죽 총 무게 (g)
  }) {
    try {
      // 1. 기본 믹싱 특성 분석
      final mixingCharacteristics = _analyzeMixingCharacteristics(doughState, ingredients, recipeTitle);
      
      // 2. 믹서 타입별 효율성 계산
      final mixerEfficiency = _calculateMixerEfficiency(mixerType, doughWeight);
      
      // 3. 단계별 믹싱 시간 계산
      final lowSpeedTime = _calculateLowSpeedTime(mixingCharacteristics, mixerEfficiency);
      final mediumSpeedTime = _calculateMediumSpeedTime(mixingCharacteristics, mixerEfficiency);
      final highSpeedTime = _calculateHighSpeedTime(mixingCharacteristics, mixerEfficiency);
      
      // 4. 총 믹싱 시간 계산
      final totalMixingTime = lowSpeedTime + mediumSpeedTime + highSpeedTime;
      
      // 5. 글루텐 발달 예측
      final glutenDevelopmentPrediction = _predictGlutenDevelopment(
        doughState, totalMixingTime, mixerEfficiency
      );
      
      // 6. 믹싱 완료 판단 기준 제공
      final completionCriteria = _generateCompletionCriteria(doughState, mixingCharacteristics);
      
      return MixingTimeResult(
        lowSpeedTime: lowSpeedTime,
        mediumSpeedTime: mediumSpeedTime,
        highSpeedTime: highSpeedTime,
        totalMixingTime: totalMixingTime,
        mixerType: mixerType,
        glutenDevelopmentPrediction: glutenDevelopmentPrediction,
        completionCriteria: completionCriteria,
        mixingCharacteristics: mixingCharacteristics,
        calculationTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('믹싱 시간 계산 오류: $e');
      return MixingTimeResult.empty();
    }
  }
  
  /// 믹싱 특성 분석
  static Map<String, dynamic> _analyzeMixingCharacteristics(
    DoughStateAnalysisResult doughState,
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
  ) {
    // 글루텐 강도에 따른 믹싱 난이도
    final glutenDifficulty = doughState.glutenStrengthIndex > 12.0 ? 'high' :
                           doughState.glutenStrengthIndex > 8.0 ? 'medium' : 'low';
    
    // 수분율에 따른 믹싱 특성
    final hydrationEffect = doughState.hydrationLevel > 0.75 ? 'sticky' :
                          doughState.hydrationLevel > 0.65 ? 'normal' : 'stiff';
    
    // 점성에 따른 저항력
    final viscosityResistance = doughState.viscosityIndex > 2.0 ? 'high' :
                              doughState.viscosityIndex > 1.0 ? 'medium' : 'low';
    
    // 지방 함량 확인 (믹싱 시간에 영향)
    final fatIngredients = _findFatIngredients(ingredients);
    final fatWeight = _calculateTotalWeight(fatIngredients);
    final fatEffect = fatWeight > 50 ? 'high_fat' : fatWeight > 20 ? 'medium_fat' : 'low_fat';
    
    return {
      'glutenDifficulty': glutenDifficulty,
      'hydrationEffect': hydrationEffect,
      'viscosityResistance': viscosityResistance,
      'fatEffect': fatEffect,
      'overallComplexity': _calculateOverallComplexity(glutenDifficulty, hydrationEffect, viscosityResistance),
    };
  }
  
  /// 믹서 효율성 계산
  static Map<String, double> _calculateMixerEfficiency(String mixerType, double doughWeight) {
    switch (mixerType.toLowerCase()) {
      case 'stand_mixer':
      case '스탠드믹서':
        return {
          'efficiency': 1.0,
          'lowSpeedFactor': 1.0,
          'mediumSpeedFactor': 1.0,
          'highSpeedFactor': 1.0,
          'weightCapacity': doughWeight > 2000 ? 0.8 : 1.0, // 용량 초과 시 효율 감소
        };
      case 'hand_mixer':
      case '핸드믹서':
        return {
          'efficiency': 0.7,
          'lowSpeedFactor': 0.8,
          'mediumSpeedFactor': 0.9,
          'highSpeedFactor': 0.6, // 고속에서 효율 떨어짐
          'weightCapacity': doughWeight > 1000 ? 0.6 : 1.0,
        };
      case 'hand_kneading':
      case '손반죽':
        return {
          'efficiency': 0.5,
          'lowSpeedFactor': 1.2, // 손반죽은 저속이 더 효과적
          'mediumSpeedFactor': 0.8,
          'highSpeedFactor': 0.3, // 손으로는 고속 불가능
          'weightCapacity': doughWeight > 1500 ? 0.4 : 1.0,
        };
      default:
        return {
          'efficiency': 1.0,
          'lowSpeedFactor': 1.0,
          'mediumSpeedFactor': 1.0,
          'highSpeedFactor': 1.0,
          'weightCapacity': 1.0,
        };
    }
  }
  
  /// 저속 믹싱 시간 계산 (재료 혼합 단계)
  static int _calculateLowSpeedTime(
    Map<String, dynamic> characteristics,
    Map<String, double> mixerEfficiency,
  ) {
    // 기본 저속 시간: 재료 혼합
    int baseTime = 3; // 3분 기본
    
    // 수분율에 따른 조정
    if (characteristics['hydrationEffect'] == 'sticky') {
      baseTime += 1; // 끈적한 반죽은 더 오래
    } else if (characteristics['hydrationEffect'] == 'stiff') {
      baseTime += 2; // 딱딱한 반죽은 훨씬 더 오래
    }
    
    // 지방 함량에 따른 조정
    if (characteristics['fatEffect'] == 'high_fat') {
      baseTime += 1; // 지방이 많으면 혼합 시간 증가
    }
    
    // 믹서 효율성 적용
    final adjustedTime = (baseTime / mixerEfficiency['lowSpeedFactor']! / mixerEfficiency['weightCapacity']!).round();
    
    return adjustedTime.clamp(2, 8); // 2-8분 범위
  }
  
  /// 중속 믹싱 시간 계산 (글루텐 발달 시작)
  static int _calculateMediumSpeedTime(
    Map<String, dynamic> characteristics,
    Map<String, double> mixerEfficiency,
  ) {
    // 기본 중속 시간: 글루텐 발달
    int baseTime = 5; // 5분 기본
    
    // 글루텐 난이도에 따른 조정
    if (characteristics['glutenDifficulty'] == 'high') {
      baseTime += 3; // 강한 글루텐은 더 오래
    } else if (characteristics['glutenDifficulty'] == 'low') {
      baseTime -= 1; // 약한 글루텐은 짧게
    }
    
    // 점성 저항에 따른 조정
    if (characteristics['viscosityResistance'] == 'high') {
      baseTime += 2;
    } else if (characteristics['viscosityResistance'] == 'low') {
      baseTime -= 1;
    }
    
    // 믹서 효율성 적용
    final adjustedTime = (baseTime / mixerEfficiency['mediumSpeedFactor']! / mixerEfficiency['weightCapacity']!).round();
    
    return adjustedTime.clamp(3, 12); // 3-12분 범위
  }
  
  /// 고속 믹싱 시간 계산 (글루텐 신장 및 완성)
  static int _calculateHighSpeedTime(
    Map<String, dynamic> characteristics,
    Map<String, double> mixerEfficiency,
  ) {
    // 기본 고속 시간: 글루텐 신장
    int baseTime = 3; // 3분 기본
    
    // 글루텐 난이도에 따른 조정
    if (characteristics['glutenDifficulty'] == 'high') {
      baseTime += 2; // 강한 글루텐은 더 신장 필요
    } else if (characteristics['glutenDifficulty'] == 'low') {
      baseTime = 1; // 약한 글루텐은 과도한 믹싱 금지
    }
    
    // 수분율에 따른 조정 (고수분은 과믹싱 위험)
    if (characteristics['hydrationEffect'] == 'sticky') {
      baseTime = math.max(1, baseTime - 1); // 끈적한 반죽은 짧게
    }
    
    // 믹서 효율성 적용
    final adjustedTime = (baseTime / mixerEfficiency['highSpeedFactor']! / mixerEfficiency['weightCapacity']!).round();
    
    return adjustedTime.clamp(1, 6); // 1-6분 범위
  }
  
  /// 글루텐 발달 예측
  static String _predictGlutenDevelopment(
    DoughStateAnalysisResult doughState,
    int totalMixingTime,
    Map<String, double> mixerEfficiency,
  ) {
    final developmentScore = (doughState.glutenStrengthIndex / 15.0) * 
                           (totalMixingTime / 15.0) * 
                           mixerEfficiency['efficiency']!;
    
    if (developmentScore >= 0.8) return "완전한 글루텐 발달 예상";
    if (developmentScore >= 0.6) return "양호한 글루텐 발달 예상";
    if (developmentScore >= 0.4) return "적당한 글루텐 발달 예상";
    return "글루텐 발달 부족 우려";
  }
  
  /// 믹싱 완료 판단 기준
  static List<String> _generateCompletionCriteria(
    DoughStateAnalysisResult doughState,
    Map<String, dynamic> characteristics,
  ) {
    List<String> criteria = [];
    
    // 기본 완료 기준
    criteria.add("반죽이 그릇에서 깔끔하게 떨어짐");
    criteria.add("표면이 매끄럽고 탄력적");
    
    // 수분율에 따른 기준
    if (characteristics['hydrationEffect'] == 'sticky') {
      criteria.add("약간 끈적하지만 모양을 유지");
    } else if (characteristics['hydrationEffect'] == 'stiff') {
      criteria.add("단단하지만 균열이 없음");
    } else {
      criteria.add("부드럽고 탄력적인 질감");
    }
    
    // 글루텐 강도에 따른 기준
    if (characteristics['glutenDifficulty'] == 'high') {
      criteria.add("윈도우 테스트 시 얇은 막 형성");
    } else {
      criteria.add("적당한 신축성 확인");
    }
    
    return criteria;
  }
  
  /// 전체 복잡도 계산
  static String _calculateOverallComplexity(String glutenDifficulty, String hydrationEffect, String viscosityResistance) {
    int complexityScore = 0;
    
    if (glutenDifficulty == 'high') complexityScore += 2;
    else if (glutenDifficulty == 'medium') complexityScore += 1;
    
    if (hydrationEffect == 'sticky') complexityScore += 2;
    else if (hydrationEffect == 'stiff') complexityScore += 1;
    
    if (viscosityResistance == 'high') complexityScore += 1;
    
    if (complexityScore >= 4) return 'high';
    if (complexityScore >= 2) return 'medium';
    return 'low';
  }
  
  /// 지방 재료 찾기
  static List<Map<String, dynamic>> _findFatIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        '버터', '마가린', '쇼트닝', '라드', '코코넛오일', '올리브오일', '식용유',
        'butter', 'margarine', 'shortening', 'lard', 'coconut oil', 'olive oil', 'oil'
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }
  
  /// 재료 그룹의 총 무게 계산
  static double _calculateTotalWeight(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      totalWeight += amount; // 단위 변환은 생략 (간단화)
    }
    return totalWeight;
  }
}

/// 믹싱 시간 결과 클래스
class MixingTimeResult {
  final int lowSpeedTime; // 저속 시간 (분)
  final int mediumSpeedTime; // 중속 시간 (분)
  final int highSpeedTime; // 고속 시간 (분)
  final int totalMixingTime; // 총 믹싱 시간 (분)
  final String mixerType; // 믹서 타입
  final String glutenDevelopmentPrediction; // 글루텐 발달 예측
  final List<String> completionCriteria; // 완료 판단 기준
  final Map<String, dynamic> mixingCharacteristics; // 믹싱 특성
  final DateTime calculationTimestamp;

  MixingTimeResult({
    required this.lowSpeedTime,
    required this.mediumSpeedTime,
    required this.highSpeedTime,
    required this.totalMixingTime,
    required this.mixerType,
    required this.glutenDevelopmentPrediction,
    required this.completionCriteria,
    required this.mixingCharacteristics,
    required this.calculationTimestamp,
  });

  /// 빈 결과 생성 (오류 시 사용)
  factory MixingTimeResult.empty() {
    return MixingTimeResult(
      lowSpeedTime: 3,
      mediumSpeedTime: 5,
      highSpeedTime: 2,
      totalMixingTime: 10,
      mixerType: "알 수 없음",
      glutenDevelopmentPrediction: "예측 불가",
      completionCriteria: ["기본 완료 기준 적용"],
      mixingCharacteristics: {},
      calculationTimestamp: DateTime.now(),
    );
  }

  /// JSON에서 생성
  factory MixingTimeResult.fromJson(Map<String, dynamic> json) {
    return MixingTimeResult(
      lowSpeedTime: json['lowSpeedTime']?.toInt() ?? 3,
      mediumSpeedTime: json['mediumSpeedTime']?.toInt() ?? 5,
      highSpeedTime: json['highSpeedTime']?.toInt() ?? 2,
      totalMixingTime: json['totalMixingTime']?.toInt() ?? 10,
      mixerType: json['mixerType'] ?? "알 수 없음",
      glutenDevelopmentPrediction: json['glutenDevelopmentPrediction'] ?? "예측 불가",
      completionCriteria: List<String>.from(json['completionCriteria'] ?? ["기본 완료 기준 적용"]),
      mixingCharacteristics: Map<String, dynamic>.from(json['mixingCharacteristics'] ?? {}),
      calculationTimestamp: DateTime.parse(json['calculationTimestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 단계별 믹싱 가이드 텍스트
  String get mixingGuideText {
    return "저속 ${lowSpeedTime}분 → 중속 ${mediumSpeedTime}분 → 고속 ${highSpeedTime}분";
  }

  /// 믹서 타입 표시 텍스트
  String get mixerTypeText {
    switch (mixerType.toLowerCase()) {
      case 'stand_mixer': return '스탠드믹서';
      case 'hand_mixer': return '핸드믹서';
      case 'hand_kneading': return '손반죽';
      default: return mixerType;
    }
  }

  /// 복잡도 텍스트
  String get complexityText {
    final complexity = mixingCharacteristics['overallComplexity'] as String? ?? 'medium';
    switch (complexity) {
      case 'high': return '높음 (주의 필요)';
      case 'medium': return '보통';
      case 'low': return '낮음 (쉬움)';
      default: return '보통';
    }
  }

  /// 완료 기준 요약 텍스트
  String get completionSummary {
    if (completionCriteria.isEmpty) return "기본 완료 기준 적용";
    return completionCriteria.first;
  }
}