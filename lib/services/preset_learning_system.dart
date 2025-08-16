/// 프리셋 학습 시스템
/// 사용자의 베이킹 결과를 분석하여 프리셋의 효과를 학습하고 품질을 업데이트합니다.

library preset_learning_system;

import '../models/recipe_history.dart';
import '../services/recipe_history_service.dart';

class PresetLearningSystem {
  static PresetLearningSystem? _instance;
  static PresetLearningSystem get instance => _instance ??= PresetLearningSystem._();
  
  PresetLearningSystem._();

  /// 베이킹 결과를 기반으로 프리셋 학습
  Future<void> learnFromBakingResult({
    required String presetId,
    required BakingResult result,
    required Map<String, dynamic> recipeContext,
  }) async {
    try {
      // 학습 데이터 생성
      final learningData = LearningData(
        presetId: presetId,
        result: result,
        recipeContext: recipeContext,
        timestamp: DateTime.now(),
      );

      // 학습 히스토리 저장
      await _saveLearningHistory(learningData);

      print('Preset learning completed for preset: $presetId');
      
    } catch (e) {
      print('Error in preset learning: $e');
    }
  }

  /// 학습 히스토리 저장
  Future<void> _saveLearningHistory(LearningData learningData) async {
    try {
      final historyEntry = RecipeHistory.create(
        recipeTitle: 'Preset Learning: ${learningData.presetId}',
        recipeCategory: 'Learning',
        type: RecipeHistoryType.optimization,
        originalIngredients: {'preset_id': learningData.presetId},
        optimizedIngredients: {
          'texture_score': learningData.result.textureScore,
          'flavor_score': learningData.result.flavorScore,
          'appearance_score': learningData.result.appearanceScore,
          'satisfaction_score': learningData.result.satisfactionScore,
        },
        environmentalConditions: learningData.recipeContext['environmental_conditions'] ?? {},
        beforeStatus: ProductStatusHistory(
          textureProfile: '기본',
          flavorProfile: ['기본'],
          appearanceProfile: '기본',
          textureScore: 0.6,
          flavorScore: 0.6,
          appearanceScore: 0.6,
          confidenceLevel: 0.5,
        ),
        afterStatus: ProductStatusHistory(
          textureProfile: '피드백 완료',
          flavorProfile: ['피드백 완료'],
          appearanceProfile: '피드백 완료',
          textureScore: learningData.result.textureScore / 5.0,
          flavorScore: learningData.result.flavorScore / 5.0,
          appearanceScore: learningData.result.appearanceScore / 5.0,
          confidenceLevel: 0.8,
        ),

        optimizationNotes: [
          'Preset feedback learning',
          'Success: ${_evaluateSuccess(learningData.result)}',
          if (learningData.result.notes != null) learningData.result.notes!,
        ],
      );

      await RecipeHistoryService.instance.addHistory(historyEntry);
    } catch (e) {
      print('Error saving learning history: $e');
    }
  }

  /// 성공 여부 평가
  bool _evaluateSuccess(BakingResult result) {
    // 종합 점수 기반 성공 판정
    final overallScore = (
      result.textureScore +
      result.flavorScore +
      result.appearanceScore +
      result.satisfactionScore
    ) / 4.0;

    return overallScore >= 3.5; // 5점 만점에서 3.5점 이상이면 성공
  }
}

/// 베이킹 결과 데이터
class BakingResult {
  final double textureScore; // 1-5점
  final double flavorScore; // 1-5점
  final double appearanceScore; // 1-5점
  final double satisfactionScore; // 1-5점
  final String? notes;
  final List<String>? issues; // 발생한 문제점들

  const BakingResult({
    required this.textureScore,
    required this.flavorScore,
    required this.appearanceScore,
    required this.satisfactionScore,
    this.notes,
    this.issues,
  });

  /// 전체 평균 점수
  double get overallScore => 
      (textureScore + flavorScore + appearanceScore + satisfactionScore) / 4.0;

  /// 성공 여부 (3.5점 이상)
  bool get isSuccess => overallScore >= 3.5;
}

/// 학습 데이터
class LearningData {
  final String presetId;
  final BakingResult result;
  final Map<String, dynamic> recipeContext;
  final DateTime timestamp;

  const LearningData({
    required this.presetId,
    required this.result,
    required this.recipeContext,
    required this.timestamp,
  });
}