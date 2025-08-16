/// 레시피 프리셋 관리자
/// 다양한 베이킹 타입별 최적화된 프리셋을 제공합니다.

import '../models/recipe_target.dart';

class RecipePresetManager {
  /// 모든 프리셋 목록 가져오기
  static List<RecipePreset> getAllPresets() {
    return [
      // 식빵류
      RecipePreset(
        id: 'basic_bread',
        name: '기본 식빵',
        description: '클래식한 식빵 레시피',
        category: '식빵',
        target: RecipeTarget.basicBread(),
        tags: ['기본', '클래식', '일반'],
        difficulty: PresetDifficulty.beginner,
        estimatedTime: 180,
        keyFeatures: ['균형잡힌 맛', '표준 식감', '초보자 친화적'],
      ),
      
      RecipePreset(
        id: 'moist_bread',
        name: '촉촉한 식빵',
        description: '부드럽고 촉촉한 식감의 식빵',
        category: '식빵',
        target: RecipeTarget.moistBread(),
        tags: ['촉촉', '부드러운', '고수분'],
        difficulty: PresetDifficulty.intermediate,
        estimatedTime: 200,
        keyFeatures: ['높은 수분율', '부드러운 식감', '오래 보관 가능'],
      ),
      
      RecipePreset(
        id: 'chewy_bread',
        name: '쫄깃한 식빵',
        description: '탄력있고 쫄깃한 식감의 식빵',
        category: '식빵',
        target: RecipeTarget.chewyBread(),
        tags: ['쫄깃', '탄력', '글루텐'],
        difficulty: PresetDifficulty.intermediate,
        estimatedTime: 220,
        keyFeatures: ['강한 글루텐', '쫄깃한 식감', '높은 포만감'],
      ),
      
      RecipePreset(
        id: 'crispy_bread',
        name: '바삭한 크러스트 빵',
        description: '겉은 바삭하고 속은 부드러운 빵',
        category: '하드브레드',
        target: RecipeTarget.crispyBread(),
        tags: ['바삭', '크러스트', '하드'],
        difficulty: PresetDifficulty.advanced,
        estimatedTime: 240,
        keyFeatures: ['바삭한 겉면', '부드러운 속', '긴 발효'],
      ),
      
      RecipePreset(
        id: 'sweet_bread',
        name: '달콤한 단빵',
        description: '달콤하고 부드러운 단빵',
        category: '단빵',
        target: RecipeTarget.sweetBread(),
        tags: ['달콤', '단빵', '브리오슈'],
        difficulty: PresetDifficulty.intermediate,
        estimatedTime: 210,
        keyFeatures: ['달콤한 맛', '버터 풍미', '부드러운 식감'],
      ),
      
      // 특수 식빵류
      RecipePreset(
        id: 'milk_bread',
        name: '우유 식빵',
        description: '우유의 고소함이 가득한 부드러운 식빵',
        category: '식빵',
        target: RecipeTarget(
          targetBakingType: '촉촉한 식빵',
          moistureTarget: 0.8,
          softnessTarget: 0.9,
          richnessTarget: 0.7,
          sweetnessTarget: 0.4,
          chewinessTarget: 0.6,
          crispinessTarget: 0.2,
          saltinessTarget: 0.3,
          crustColorTarget: CrustColorTarget.lightBrown,
          heightTarget: 0.8,
          porosityTarget: 0.7,
        ),
        tags: ['우유', '고소한', '부드러운'],
        difficulty: PresetDifficulty.beginner,
        estimatedTime: 190,
        keyFeatures: ['우유 풍미', '부드러운 식감', '연한 색상'],
      ),
      
      RecipePreset(
        id: 'whole_wheat_bread',
        name: '통밀 식빵',
        description: '건강한 통밀로 만든 고소한 식빵',
        category: '건강빵',
        target: RecipeTarget(
          targetBakingType: '식빵',
          moistureTarget: 0.7,
          softnessTarget: 0.6,
          richnessTarget: 0.6,
          sweetnessTarget: 0.3,
          chewinessTarget: 0.8,
          crispinessTarget: 0.3,
          saltinessTarget: 0.4,
          crustColorTarget: CrustColorTarget.darkBrown,
          heightTarget: 0.7,
          porosityTarget: 0.6,
        ),
        tags: ['통밀', '건강', '고소한'],
        difficulty: PresetDifficulty.intermediate,
        estimatedTime: 200,
        keyFeatures: ['통밀 풍미', '건강한 재료', '진한 색상'],
      ),
      
      RecipePreset(
        id: 'butter_bread',
        name: '버터 브리오슈',
        description: '버터가 풍부한 프랑스식 브리오슈',
        category: '브리오슈',
        target: RecipeTarget(
          targetBakingType: '브리오슈',
          moistureTarget: 0.7,
          softnessTarget: 0.9,
          richnessTarget: 0.9,
          sweetnessTarget: 0.6,
          chewinessTarget: 0.5,
          crispinessTarget: 0.2,
          saltinessTarget: 0.2,
          crustColorTarget: CrustColorTarget.golden,
          heightTarget: 0.8,
          porosityTarget: 0.8,
        ),
        tags: ['버터', '브리오슈', '프랑스'],
        difficulty: PresetDifficulty.advanced,
        estimatedTime: 300,
        keyFeatures: ['풍부한 버터', '부드러운 식감', '황금색 크러스트'],
      ),
      
      // 케이크류
      RecipePreset(
        id: 'sponge_cake',
        name: '스펀지 케이크',
        description: '부드럽고 촉촉한 기본 스펀지 케이크',
        category: '케이크',
        target: RecipeTarget(
          targetBakingType: '케이크',
          moistureTarget: 0.8,
          softnessTarget: 0.9,
          richnessTarget: 0.6,
          sweetnessTarget: 0.7,
          chewinessTarget: 0.3,
          crispinessTarget: 0.1,
          saltinessTarget: 0.1,
          crustColorTarget: CrustColorTarget.lightBrown,
          heightTarget: 0.9,
          porosityTarget: 0.9,
        ),
        tags: ['케이크', '스펀지', '부드러운'],
        difficulty: PresetDifficulty.intermediate,
        estimatedTime: 90,
        keyFeatures: ['부드러운 식감', '높은 부풀림', '촉촉함'],
      ),
      
      // 쿠키류
      RecipePreset(
        id: 'crispy_cookie',
        name: '바삭한 쿠키',
        description: '바삭하고 고소한 기본 쿠키',
        category: '쿠키',
        target: RecipeTarget(
          targetBakingType: '쿠키',
          moistureTarget: 0.2,
          softnessTarget: 0.3,
          richnessTarget: 0.8,
          sweetnessTarget: 0.7,
          chewinessTarget: 0.2,
          crispinessTarget: 0.9,
          saltinessTarget: 0.2,
          crustColorTarget: CrustColorTarget.golden,
          heightTarget: 0.3,
          porosityTarget: 0.4,
        ),
        tags: ['쿠키', '바삭한', '고소한'],
        difficulty: PresetDifficulty.beginner,
        estimatedTime: 45,
        keyFeatures: ['바삭한 식감', '버터 풍미', '간편 제작'],
      ),
    ];
  }

  /// 카테고리별 프리셋 가져오기
  static List<RecipePreset> getPresetsByCategory(String category) {
    return getAllPresets().where((preset) => preset.category == category).toList();
  }

  /// 태그로 프리셋 검색
  static List<RecipePreset> searchPresetsByTag(String tag) {
    return getAllPresets()
        .where((preset) => preset.tags.any((t) => t.contains(tag)))
        .toList();
  }

  /// 난이도별 프리셋 가져오기
  static List<RecipePreset> getPresetsByDifficulty(PresetDifficulty difficulty) {
    return getAllPresets().where((preset) => preset.difficulty == difficulty).toList();
  }

  /// 텍스트 기반 프리셋 추천
  static List<RecipePreset> recommendPresets(String inputText) {
    final normalizedText = inputText.toLowerCase();
    final allPresets = getAllPresets();
    final recommendations = <RecipePreset>[];

    // 정확한 매칭 우선
    for (final preset in allPresets) {
      int matchScore = 0;
      
      // 이름 매칭
      if (normalizedText.contains(preset.name.toLowerCase())) {
        matchScore += 10;
      }
      
      // 태그 매칭
      for (final tag in preset.tags) {
        if (normalizedText.contains(tag.toLowerCase())) {
          matchScore += 5;
        }
      }
      
      // 카테고리 매칭
      if (normalizedText.contains(preset.category.toLowerCase())) {
        matchScore += 3;
      }
      
      // 특징 매칭
      for (final feature in preset.keyFeatures) {
        if (normalizedText.contains(feature.toLowerCase())) {
          matchScore += 2;
        }
      }
      
      if (matchScore > 0) {
        recommendations.add(preset);
      }
    }

    // 점수순으로 정렬
    recommendations.sort((a, b) => _calculateMatchScore(b, inputText).compareTo(_calculateMatchScore(a, inputText)));
    
    return recommendations.take(5).toList(); // 상위 5개만 반환
  }

  /// 매칭 점수 계산
  static int _calculateMatchScore(RecipePreset preset, String inputText) {
    final normalizedText = inputText.toLowerCase();
    int score = 0;
    
    if (normalizedText.contains(preset.name.toLowerCase())) score += 10;
    
    for (final tag in preset.tags) {
      if (normalizedText.contains(tag.toLowerCase())) score += 5;
    }
    
    if (normalizedText.contains(preset.category.toLowerCase())) score += 3;
    
    for (final feature in preset.keyFeatures) {
      if (normalizedText.contains(feature.toLowerCase())) score += 2;
    }
    
    return score;
  }

  /// 프리셋 ID로 찾기
  static RecipePreset? getPresetById(String id) {
    try {
      return getAllPresets().firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 모든 카테고리 목록
  static List<String> getAllCategories() {
    return getAllPresets()
        .map((preset) => preset.category)
        .toSet()
        .toList()
        ..sort();
  }

  /// 인기 프리셋 (초보자용)
  static List<RecipePreset> getPopularPresets() {
    return [
      getPresetById('basic_bread')!,
      getPresetById('moist_bread')!,
      getPresetById('milk_bread')!,
      getPresetById('sponge_cake')!,
      getPresetById('crispy_cookie')!,
    ];
  }

  /// 고급 프리셋
  static List<RecipePreset> getAdvancedPresets() {
    return getPresetsByDifficulty(PresetDifficulty.advanced);
  }
}

/// 레시피 프리셋 모델
class RecipePreset {
  final String id;
  final String name;
  final String description;
  final String category;
  final RecipeTarget target;
  final List<String> tags;
  final PresetDifficulty difficulty;
  final int estimatedTime; // 분 단위
  final List<String> keyFeatures;

  const RecipePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.target,
    required this.tags,
    required this.difficulty,
    required this.estimatedTime,
    required this.keyFeatures,
  });

  /// 프리셋을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'target': target.toJson(),
      'tags': tags,
      'difficulty': difficulty.name,
      'estimatedTime': estimatedTime,
      'keyFeatures': keyFeatures,
    };
  }

  /// JSON에서 프리셋 생성
  factory RecipePreset.fromJson(Map<String, dynamic> json) {
    return RecipePreset(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      target: RecipeTarget.fromJson(json['target']),
      tags: List<String>.from(json['tags']),
      difficulty: PresetDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => PresetDifficulty.beginner,
      ),
      estimatedTime: json['estimatedTime'],
      keyFeatures: List<String>.from(json['keyFeatures']),
    );
  }
}

/// 프리셋 난이도
enum PresetDifficulty {
  beginner('초급'),
  intermediate('중급'),
  advanced('고급');

  const PresetDifficulty(this.displayName);
  final String displayName;
}