/// 시럽류(물엿/올리고당) 전문 분석기
/// 제빵 과학 기반으로 시럽류가 반죽과 굽기에 미치는 영향을 분석

import 'dart:math' as math;

class SyrupAnalyzer {
  /// 시럽류 종합 분석
  static SyrupAnalysisResult analyzeSyrupEffects({
    required List<Map<String, dynamic>> ingredients,
    required double flourWeight,
    String? recipeTitle,
    String breadType = 'bread',
  }) {
    try {
      // 1. 시럽류 재료 분류 및 감지
      final syrupIngredients = _findSyrupIngredients(ingredients);
      if (syrupIngredients.isEmpty) {
        return SyrupAnalysisResult.noSyrup();
      }
      
      // 2. 시럽 타입별 분류
      final syrupClassification = _classifySyrupTypes(syrupIngredients);
      
      // 3. 총 시럽 함량 계산 (밀가루 대비 %)
      final totalSyrupWeight = _calculateTotalSyrupWeight(syrupIngredients);
      final syrupPercentage = (totalSyrupWeight / flourWeight) * 100;
      
      // 4. 화학적 작용 분석
      final chemicalEffects = _analyzeChemicalEffects(syrupClassification, syrupPercentage);
      
      // 5. 물리적 작용 분석 (레올로지)
      final physicalEffects = _analyzePhysicalEffects(syrupClassification, syrupPercentage);
      
      // 6. 미생물학적 영향 분석 (발효)
      final fermentationEffects = _analyzeFermentationEffects(syrupClassification, syrupPercentage);
      
      // 7. 굽기 특성 변화 분석
      final bakingEffects = _analyzeBakingEffects(syrupClassification, syrupPercentage);
      
      // 8. 저장성 및 품질 영향
      final storageEffects = _analyzeStorageEffects(syrupClassification, syrupPercentage);
      
      // 9. 권장 조정사항 생성
      final recommendations = _generateRecommendations(
        syrupClassification, syrupPercentage, breadType
      );
      
      return SyrupAnalysisResult(
        syrupClassification: syrupClassification,
        totalSyrupWeight: totalSyrupWeight,
        syrupPercentage: syrupPercentage,
        chemicalEffects: chemicalEffects,
        physicalEffects: physicalEffects,
        fermentationEffects: fermentationEffects,
        bakingEffects: bakingEffects,
        storageEffects: storageEffects,
        recommendations: recommendations,
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('시럽 분석 오류: $e');
      return SyrupAnalysisResult.empty();
    }
  }
  
  /// 시럽류 재료 찾기 (확장된 키워드)
  static List<Map<String, dynamic>> _findSyrupIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final syrupKeywords = [
        // 한국어
        '물엿', '올리고당', '시럽', '메이플시럽', '현미시럽', '쌀시럽', '아가베시럽',
        '프락토올리고당', '이소말토올리고당', '갈락토올리고당', '자일로올리고당',
        '말토덱스트린', '포도당시럽', '과당시럽', '전화당시럽',
        // 영어
        'syrup', 'corn syrup', 'maple syrup', 'rice syrup', 'agave syrup',
        'oligosaccharide', 'fructooligosaccharide', 'isomaltooligosaccharide',
        'galactooligosaccharide', 'xylooligosaccharide', 'fos', 'imo', 'gos', 'xos',
        'maltodextrin', 'glucose syrup', 'fructose syrup', 'invert syrup',
        'golden syrup', 'brown rice syrup', 'tapioca syrup',
      ];
      return syrupKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }
  
  /// 시럽 타입별 분류
  static Map<String, dynamic> _classifySyrupTypes(List<Map<String, dynamic>> syrupIngredients) {
    double cornSyrupWeight = 0.0; // 물엿 (환원당 높음)
    double oligosaccharideWeight = 0.0; // 올리고당 (환원당 낮음)
    double otherSyrupWeight = 0.0; // 기타 시럽
    
    for (final syrup in syrupIngredients) {
      final name = (syrup['name'] as String? ?? '').toLowerCase();
      final weight = (syrup['amount'] as double? ?? 0.0);
      
      // 물엿류 (환원당 높음)
      if (name.contains('물엿') || name.contains('corn syrup') || 
          name.contains('포도당') || name.contains('glucose') ||
          name.contains('말토스') || name.contains('maltose')) {
        cornSyrupWeight += weight;
      }
      // 올리고당류 (환원당 낮음)
      else if (name.contains('올리고당') || name.contains('oligosaccharide') ||
               name.contains('fos') || name.contains('imo') || 
               name.contains('gos') || name.contains('xos')) {
        oligosaccharideWeight += weight;
      }
      // 기타 시럽
      else {
        otherSyrupWeight += weight;
      }
    }
    
    return {
      'cornSyrupWeight': cornSyrupWeight,
      'oligosaccharideWeight': oligosaccharideWeight,
      'otherSyrupWeight': otherSyrupWeight,
      'dominantType': _determineDominantSyrupType(cornSyrupWeight, oligosaccharideWeight, otherSyrupWeight),
    };
  }
  
  /// 주요 시럽 타입 결정
  static String _determineDominantSyrupType(double cornSyrup, double oligo, double other) {
    if (cornSyrup >= oligo && cornSyrup >= other) return 'corn_syrup';
    if (oligo >= cornSyrup && oligo >= other) return 'oligosaccharide';
    return 'other_syrup';
  }
  
  /// 총 시럽 무게 계산
  static double _calculateTotalSyrupWeight(List<Map<String, dynamic>> syrupIngredients) {
    double totalWeight = 0.0;
    for (final syrup in syrupIngredients) {
      totalWeight += (syrup['amount'] as double? ?? 0.0);
    }
    return totalWeight;
  }
  
  /// 화학적 작용 분석 (갈변, pH, 환원당)
  static Map<String, dynamic> _analyzeChemicalEffects(
    Map<String, dynamic> classification, 
    double syrupPercentage
  ) {
    final dominantType = classification['dominantType'] as String;
    final cornSyrupWeight = classification['cornSyrupWeight'] as double;
    final oligoWeight = classification['oligosaccharideWeight'] as double;
    
    // 환원당 지수 계산 (0-10)
    double reducingSugarIndex = 0.0;
    if (dominantType == 'corn_syrup') {
      reducingSugarIndex = math.min(10.0, syrupPercentage * 1.5); // 물엿은 환원당 높음
    } else if (dominantType == 'oligosaccharide') {
      reducingSugarIndex = math.min(6.0, syrupPercentage * 0.8); // 올리고당은 환원당 낮음
    } else {
      reducingSugarIndex = math.min(8.0, syrupPercentage * 1.2);
    }
    
    // 갈변 속도 예측
    String browningSpeed = 'normal';
    if (reducingSugarIndex >= 7.0) browningSpeed = 'fast';
    else if (reducingSugarIndex >= 4.0) browningSpeed = 'moderate';
    else browningSpeed = 'slow';
    
    // 마이야르 반응 강도
    String maillardIntensity = 'medium';
    if (cornSyrupWeight > 0 && syrupPercentage >= 5.0) maillardIntensity = 'high';
    else if (oligoWeight > cornSyrupWeight) maillardIntensity = 'low';
    
    return {
      'reducingSugarIndex': reducingSugarIndex,
      'browningSpeed': browningSpeed,
      'maillardIntensity': maillardIntensity,
      'caramelizationRisk': syrupPercentage >= 8.0 ? 'high' : 'low',
    };
  }
  
  /// 물리적 작용 분석 (점도, 글루텐, 레올로지)
  static Map<String, dynamic> _analyzePhysicalEffects(
    Map<String, dynamic> classification, 
    double syrupPercentage
  ) {
    // 점도 증가 지수
    final viscosityIncrease = math.min(5.0, syrupPercentage * 0.3);
    
    // 글루텐 수화 영향
    String glutenHydrationEffect = 'normal';
    if (syrupPercentage >= 8.0) glutenHydrationEffect = 'reduced';
    else if (syrupPercentage >= 5.0) glutenHydrationEffect = 'slightly_reduced';
    
    // 반죽 질감 변화
    String doughTexture = 'normal';
    if (syrupPercentage >= 10.0) doughTexture = 'very_soft';
    else if (syrupPercentage >= 6.0) doughTexture = 'soft';
    else if (syrupPercentage >= 3.0) doughTexture = 'slightly_soft';
    
    // 가스 보유력 영향
    String gasRetentionEffect = 'normal';
    if (syrupPercentage >= 12.0) gasRetentionEffect = 'reduced';
    else if (syrupPercentage >= 8.0) gasRetentionEffect = 'slightly_reduced';
    else gasRetentionEffect = 'improved';
    
    return {
      'viscosityIncrease': viscosityIncrease,
      'glutenHydrationEffect': glutenHydrationEffect,
      'doughTexture': doughTexture,
      'gasRetentionEffect': gasRetentionEffect,
    };
  }
  
  /// 미생물학적 영향 분석 (발효, 삼투압)
  static Map<String, dynamic> _analyzeFermentationEffects(
    Map<String, dynamic> classification, 
    double syrupPercentage
  ) {
    final dominantType = classification['dominantType'] as String;
    
    // 삼투압 스트레스 계산
    double osmoticStress = syrupPercentage * 0.15; // 시럽 1%당 0.15 스트레스
    
    // 발효 속도 영향
    String fermentationSpeed = 'normal';
    double yeastAdjustmentNeeded = 0.0;
    
    if (osmoticStress >= 1.5) {
      fermentationSpeed = 'very_slow';
      yeastAdjustmentNeeded = 0.3; // 30% 증량 필요
    } else if (osmoticStress >= 1.0) {
      fermentationSpeed = 'slow';
      yeastAdjustmentNeeded = 0.2; // 20% 증량 필요
    } else if (osmoticStress >= 0.6) {
      fermentationSpeed = 'slightly_slow';
      yeastAdjustmentNeeded = 0.1; // 10% 증량 필요
    }
    
    // 당 이용성 (효모가 사용할 수 있는 정도)
    String sugarUtilization = 'good';
    if (dominantType == 'corn_syrup') {
      sugarUtilization = 'excellent'; // 포도당, 말토스 풍부
    } else if (dominantType == 'oligosaccharide') {
      sugarUtilization = 'poor'; // 효모가 잘 못 씀
    }
    
    return {
      'osmoticStress': osmoticStress,
      'fermentationSpeed': fermentationSpeed,
      'yeastAdjustmentNeeded': yeastAdjustmentNeeded,
      'sugarUtilization': sugarUtilization,
    };
  }
  
  /// 굽기 특성 변화 분석
  static Map<String, dynamic> _analyzeBakingEffects(
    Map<String, dynamic> classification, 
    double syrupPercentage
  ) {
    final chemicalEffects = _analyzeChemicalEffects(classification, syrupPercentage);
    final browningSpeed = chemicalEffects['browningSpeed'] as String;
    
    // 오븐 온도 조정 권장
    int temperatureAdjustment = 0;
    if (browningSpeed == 'fast') {
      temperatureAdjustment = -10; // 10°C 낮춤
    } else if (browningSpeed == 'moderate') {
      temperatureAdjustment = -5; // 5°C 낮춤
    }
    
    // 굽기 시간 영향
    String bakingTimeEffect = 'normal';
    if (syrupPercentage >= 8.0) {
      bakingTimeEffect = 'slightly_longer'; // 내부 익힘 시간 증가
    }
    
    // 크러스트 특성
    String crustCharacteristics = 'normal';
    if (browningSpeed == 'fast') {
      crustCharacteristics = 'dark_glossy';
    } else if (browningSpeed == 'slow') {
      crustCharacteristics = 'light_matte';
    }
    
    return {
      'temperatureAdjustment': temperatureAdjustment,
      'bakingTimeEffect': bakingTimeEffect,
      'crustCharacteristics': crustCharacteristics,
      'steamAdjustment': syrupPercentage >= 6.0 ? 'reduce' : 'normal',
    };
  }
  
  /// 저장성 및 품질 영향 분석
  static Map<String, dynamic> _analyzeStorageEffects(
    Map<String, dynamic> classification, 
    double syrupPercentage
  ) {
    // 보습 효과
    String moistureRetention = 'normal';
    if (syrupPercentage >= 8.0) moistureRetention = 'excellent';
    else if (syrupPercentage >= 4.0) moistureRetention = 'good';
    
    // 노화 지연 효과
    String agingDelay = 'normal';
    if (syrupPercentage >= 6.0) agingDelay = 'significant';
    else if (syrupPercentage >= 3.0) agingDelay = 'moderate';
    
    // 냉동 안정성
    String freezingStability = 'normal';
    if (syrupPercentage >= 5.0) freezingStability = 'improved';
    
    return {
      'moistureRetention': moistureRetention,
      'agingDelay': agingDelay,
      'freezingStability': freezingStability,
      'shelfLifeExtension': syrupPercentage >= 4.0 ? 'extended' : 'normal',
    };
  }
  
  /// 권장 조정사항 생성
  static List<String> _generateRecommendations(
    Map<String, dynamic> classification, 
    double syrupPercentage, 
    String breadType
  ) {
    List<String> recommendations = [];
    
    // 발효 조정
    final fermentationEffects = _analyzeFermentationEffects(classification, syrupPercentage);
    final yeastAdjustment = fermentationEffects['yeastAdjustmentNeeded'] as double;
    if (yeastAdjustment > 0) {
      recommendations.add('효모 ${(yeastAdjustment * 100).toInt()}% 증량 권장');
    }
    
    // 온도 조정
    final bakingEffects = _analyzeBakingEffects(classification, syrupPercentage);
    final tempAdjustment = bakingEffects['temperatureAdjustment'] as int;
    if (tempAdjustment != 0) {
      recommendations.add('오븐 온도 ${tempAdjustment.abs()}°C ${tempAdjustment < 0 ? '낮춤' : '높임'} 권장');
    }
    
    // 물 조정
    if (syrupPercentage >= 8.0) {
      recommendations.add('배합수 1-2% 감량 고려 (시럽의 수분 고려)');
    }
    
    // 믹싱 조정
    if (syrupPercentage >= 6.0) {
      recommendations.add('믹싱 시간 약간 연장 (글루텐 수화 보완)');
    }
    
    // 발효 시간 조정
    final fermentationSpeed = fermentationEffects['fermentationSpeed'] as String;
    if (fermentationSpeed.contains('slow')) {
      recommendations.add('발효 시간 10-20% 연장 권장');
    }
    
    return recommendations;
  }
}

/// 시럽 분석 결과 클래스
class SyrupAnalysisResult {
  final Map<String, dynamic> syrupClassification;
  final double totalSyrupWeight;
  final double syrupPercentage;
  final Map<String, dynamic> chemicalEffects;
  final Map<String, dynamic> physicalEffects;
  final Map<String, dynamic> fermentationEffects;
  final Map<String, dynamic> bakingEffects;
  final Map<String, dynamic> storageEffects;
  final List<String> recommendations;
  final DateTime analysisTimestamp;

  SyrupAnalysisResult({
    required this.syrupClassification,
    required this.totalSyrupWeight,
    required this.syrupPercentage,
    required this.chemicalEffects,
    required this.physicalEffects,
    required this.fermentationEffects,
    required this.bakingEffects,
    required this.storageEffects,
    required this.recommendations,
    required this.analysisTimestamp,
  });

  /// 시럽 없음 결과
  factory SyrupAnalysisResult.noSyrup() {
    return SyrupAnalysisResult(
      syrupClassification: {'dominantType': 'none'},
      totalSyrupWeight: 0.0,
      syrupPercentage: 0.0,
      chemicalEffects: {},
      physicalEffects: {},
      fermentationEffects: {},
      bakingEffects: {},
      storageEffects: {},
      recommendations: [],
      analysisTimestamp: DateTime.now(),
    );
  }

  /// 빈 결과 (오류 시)
  factory SyrupAnalysisResult.empty() {
    return SyrupAnalysisResult(
      syrupClassification: {},
      totalSyrupWeight: 0.0,
      syrupPercentage: 0.0,
      chemicalEffects: {},
      physicalEffects: {},
      fermentationEffects: {},
      bakingEffects: {},
      storageEffects: {},
      recommendations: ["분석 불가"],
      analysisTimestamp: DateTime.now(),
    );
  }

  /// 시럽 사용 여부
  bool get hasSyrup => totalSyrupWeight > 0;

  /// 시럽 타입 텍스트
  String get syrupTypeText {
    final dominantType = syrupClassification['dominantType'] as String? ?? 'none';
    switch (dominantType) {
      case 'corn_syrup': return '물엿 주도형';
      case 'oligosaccharide': return '올리고당 주도형';
      case 'other_syrup': return '기타 시럽형';
      default: return '시럽 없음';
    }
  }

  /// 시럽 함량 텍스트
  String get syrupPercentageText {
    if (!hasSyrup) return '0%';
    return '${syrupPercentage.toStringAsFixed(1)}%';
  }

  /// 갈변 속도 텍스트
  String get browningSpeedText {
    final speed = chemicalEffects['browningSpeed'] as String? ?? 'normal';
    switch (speed) {
      case 'fast': return '빠름 (주의)';
      case 'moderate': return '보통';
      case 'slow': return '느림';
      default: return '보통';
    }
  }

  /// 발효 영향 텍스트
  String get fermentationEffectText {
    final speed = fermentationEffects['fermentationSpeed'] as String? ?? 'normal';
    switch (speed) {
      case 'very_slow': return '매우 느림';
      case 'slow': return '느림';
      case 'slightly_slow': return '약간 느림';
      default: return '정상';
    }
  }

  /// 보습 효과 텍스트
  String get moistureEffectText {
    final retention = storageEffects['moistureRetention'] as String? ?? 'normal';
    switch (retention) {
      case 'excellent': return '우수';
      case 'good': return '양호';
      default: return '보통';
    }
  }

  /// 권장사항 요약
  String get recommendationSummary {
    if (recommendations.isEmpty) return '조정 불필요';
    return recommendations.first;
  }
}