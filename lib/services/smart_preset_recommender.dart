/// 스마트 프리셋 추천 시스템
/// 사용자의 베이킹 패턴과 현재 레시피를 분석하여 최적의 프리셋을 추천합니다.

library smart_preset_recommender;

import '../models/favorite_preset.dart';
import '../models/recipe.dart';
import '../models/recipe_history.dart';
import '../services/favorite_preset_service.dart';
import '../services/recipe_history_service.dart';
import '../services/real_time_recipe_analyzer.dart';
import '../services/baking_science_engine.dart';

class SmartPresetRecommender {
  static SmartPresetRecommender? _instance;
  static SmartPresetRecommender get instance => _instance ??= SmartPresetRecommender._();
  
  SmartPresetRecommender._();

  /// 현재 레시피에 기반한 프리셋 추천
  Future<List<PresetRecommendation>> getRecommendationsForRecipe(
    Recipe recipe,
    List<Map<String, dynamic>> calculatedIngredients,
  ) async {
    try {
      // 1. 현재 레시피 분석
      final analysis = RealTimeRecipeAnalyzer.analyzeIngredients(calculatedIngredients);
      
      // 2. 사용자 히스토리 분석
      final userPattern = await _analyzeUserPattern();
      
      // 3. 즐겨찾기 프리셋 로드
      await FavoritePresetService.instance.loadFavorites();
      final favorites = await FavoritePresetService.instance.getAllFavorites();
      
      // 4. 추천 점수 계산
      final recommendations = <PresetRecommendation>[];
      
      for (final favorite in favorites) {
        final score = _calculateRecommendationScore(
          favorite,
          analysis,
          userPattern,
          recipe,
        );
        
        if (score > 0.3) { // 최소 추천 점수
          recommendations.add(PresetRecommendation(
            preset: favorite,
            score: score,
            reason: _generateRecommendationReason(favorite, analysis, score),
            expectedImprovement: _calculateExpectedImprovement(favorite, analysis),
          ));
        }
      }
      
      // 5. 점수순 정렬
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      
      return recommendations.take(5).toList(); // 상위 5개만 반환
      
    } catch (e) {
      print('Error getting preset recommendations: $e');
      return [];
    }
  }

  /// 사용자 베이킹 패턴 분석
  Future<UserBakingPattern> _analyzeUserPattern() async {
    try {
      final historyService = RecipeHistoryService.instance;
      await historyService.loadHistories();
      
      final recentHistory = await historyService.getRecentHistories(limit: 20);
      
      // 최근 베이킹 패턴 분석
      final categoryFrequency = <String, int>{};
      final successfulOptimizations = <String, double>{};
      var totalOptimizations = 0;
      var successfulCount = 0;
      
      for (final history in recentHistory) {
        // 카테고리 빈도
        categoryFrequency[history.recipeCategory] = 
            (categoryFrequency[history.recipeCategory] ?? 0) + 1;
        
        // 최적화 성공률
        if (history.type == RecipeHistoryType.optimization) {
          totalOptimizations++;
          if (history.metadata['success'] == true) {
            successfulCount++;
            final optimizationType = history.metadata['optimization_type'] as String?;
            if (optimizationType != null) {
              successfulOptimizations[optimizationType] = 
                  (successfulOptimizations[optimizationType] ?? 0.0) + 1.0;
            }
          }
        }
      }
      
      return UserBakingPattern(
        preferredCategories: categoryFrequency,
        successfulOptimizations: successfulOptimizations,
        overallSuccessRate: totalOptimizations > 0 ? successfulCount / totalOptimizations : 0.0,
        recentActivityCount: recentHistory.length,
      );
      
    } catch (e) {
      print('Error analyzing user pattern: $e');
      return UserBakingPattern.empty();
    }
  }

  /// 추천 점수 계산
  double _calculateRecommendationScore(
    FavoritePreset preset,
    RecipeAnalysisResult analysis,
    UserBakingPattern userPattern,
    Recipe recipe,
  ) {
    double score = 0.0;
    
    // 1. 카테고리 일치도 (30%)
    if (preset.category == recipe.category) {
      score += 0.3;
    } else if (userPattern.preferredCategories.containsKey(preset.category)) {
      score += 0.15; // 사용자가 선호하는 카테고리
    }
    
    // 2. 성공률 기반 점수 (25%)
    score += preset.successRate * 0.25;
    
    // 3. 사용 빈도 기반 점수 (20%)
    final usageScore = (preset.usageCount / 100.0).clamp(0.0, 1.0);
    score += usageScore * 0.20;
    
    // 4. 품질 등급 기반 점수 (15%)
    switch (preset.quality) {
      case PresetQuality.excellent:
        score += 0.15;
        break;
      case PresetQuality.good:
        score += 0.10;
        break;
      case PresetQuality.fair:
        score += 0.05;
        break;
      case PresetQuality.poor:
        score += 0.0;
        break;
      case PresetQuality.untested:
        score += 0.02;
        break;
    }
    
    // 5. 최근 사용 여부 (10%)
    if (preset.isRecentlyUsed) {
      score += 0.10;
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// 추천 이유 생성
  String _generateRecommendationReason(
    FavoritePreset preset,
    RecipeAnalysisResult analysis,
    double score,
  ) {
    final reasons = <String>[];
    
    if (preset.successRate > 0.8) {
      reasons.add('높은 성공률 (${(preset.successRate * 100).toInt()}%)');
    }
    
    if (preset.usageCount > 10) {
      reasons.add('자주 사용됨 (${preset.usageCount}회)');
    }
    
    if (preset.quality == PresetQuality.excellent) {
      reasons.add('최고 품질 프리셋');
    }
    
    if (preset.isRecentlyUsed) {
      reasons.add('최근 사용');
    }
    
    if (reasons.isEmpty) {
      reasons.add('유사한 레시피 타입');
    }
    
    return reasons.join(', ');
  }

  /// 예상 개선 효과 계산
  Map<String, double> _calculateExpectedImprovement(
    FavoritePreset preset,
    RecipeAnalysisResult analysis,
  ) {
    // 프리셋 적용 시 예상되는 개선 효과
    return {
      'texture_improvement': preset.successRate * 0.2,
      'flavor_improvement': preset.successRate * 0.15,
      'appearance_improvement': preset.successRate * 0.18,
      'overall_satisfaction': preset.successRate * 0.25,
    };
  }

  /// 컨텍스트 기반 프리셋 필터링
  Future<List<FavoritePreset>> getContextualPresets({
    required String category,
    required String difficulty,
    required List<String> availableIngredients,
  }) async {
    await FavoritePresetService.instance.loadFavorites();
    final allFavorites = await FavoritePresetService.instance.getAllFavorites();
    
    return allFavorites.where((preset) {
      // 카테고리 일치
      if (preset.category != category) return false;
      
      // 난이도 적합성 (간단한 매핑)
      final presetDifficulty = _mapQualityToDifficulty(preset.quality);
      if (presetDifficulty != difficulty && difficulty != 'any') return false;
      
      // 재료 가용성 (기본적인 체크)
      // 실제로는 더 정교한 재료 매칭 로직이 필요
      
      return true;
    }).toList();
  }

  /// 품질을 난이도로 매핑
  String _mapQualityToDifficulty(PresetQuality quality) {
    switch (quality) {
      case PresetQuality.excellent:
        return 'advanced';
      case PresetQuality.good:
        return 'intermediate';
      case PresetQuality.fair:
        return 'beginner';
      case PresetQuality.poor:
        return 'beginner';
      case PresetQuality.untested:
        return 'intermediate';
    }
  }
}

/// 프리셋 추천 결과
class PresetRecommendation {
  final FavoritePreset preset;
  final double score;
  final String reason;
  final Map<String, double> expectedImprovement;

  const PresetRecommendation({
    required this.preset,
    required this.score,
    required this.reason,
    required this.expectedImprovement,
  });

  /// 추천 신뢰도 (점수 기반)
  String get confidenceLevel {
    if (score >= 0.8) return 'high';
    if (score >= 0.6) return 'medium';
    return 'low';
  }

  /// 추천 강도 텍스트
  String get recommendationStrength {
    if (score >= 0.8) return '강력 추천';
    if (score >= 0.6) return '추천';
    return '고려해볼만함';
  }
}

/// 사용자 베이킹 패턴
class UserBakingPattern {
  final Map<String, int> preferredCategories;
  final Map<String, double> successfulOptimizations;
  final double overallSuccessRate;
  final int recentActivityCount;

  const UserBakingPattern({
    required this.preferredCategories,
    required this.successfulOptimizations,
    required this.overallSuccessRate,
    required this.recentActivityCount,
  });

  factory UserBakingPattern.empty() {
    return const UserBakingPattern(
      preferredCategories: {},
      successfulOptimizations: {},
      overallSuccessRate: 0.0,
      recentActivityCount: 0,
    );
  }

  /// 가장 선호하는 카테고리
  String? get mostPreferredCategory {
    if (preferredCategories.isEmpty) return null;
    
    return preferredCategories.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 베이킹 경험 수준
  String get experienceLevel {
    if (recentActivityCount >= 20 && overallSuccessRate >= 0.8) {
      return 'expert';
    } else if (recentActivityCount >= 10 && overallSuccessRate >= 0.6) {
      return 'intermediate';
    } else {
      return 'beginner';
    }
  }
}