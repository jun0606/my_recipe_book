/// 고급 발효 시나리오 서비스
/// 오버나이트, 저온, 실온 발효 등 세분화된 시나리오와 AI 추천 기능

import 'dart:convert';
import 'dart:math' as math;
import '../models/fermentation_scenario.dart';
import '../models/sous_chef_models.dart';
import '../models/environmental_conditions.dart';
import '../services/ingredient_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 발효 환경 타입
enum FermentationEnvironment {
  roomTemperature,  // 실온 발효 (20-26°C)
  warm,            // 따뜻한 환경 (28-32°C)
  cold,            // 저온 발효 (4-8°C)
  overnight,       // 오버나이트 (8-16시간)
  extended,        // 장시간 발효 (24시간+)
}

/// 빵 타입별 특성
enum BreadComplexity {
  simple,    // 단순한 빵 (식빵, 롤빵)
  moderate,  // 중간 복잡도 (바게트, 치아바타)
  complex,   // 복잡한 빵 (사워도우, 크루아상)
}

/// 고급 발효 시나리오 서비스
class AdvancedFermentationScenarios {
  static const String _customScenariosKey = 'custom_fermentation_scenarios';
  static const String _favoriteScenarioKey = 'favorite_scenario_id';

  /// 환경별 세분화된 시나리오 생성
  static List<FermentationScenario> getEnvironmentSpecificScenarios({
    double environmentTemperature = 26.0,
    double environmentHumidity = 60.0,
    double altitude = 0.0,
  }) {
    return [
      // 실온 발효 시나리오들
      ..._getRoomTemperatureScenarios(
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
      ),
      
      // 저온 발효 시나리오들
      ..._getColdFermentationScenarios(
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
      ),
      
      // 오버나이트 시나리오들
      ..._getOvernightScenarios(
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
      ),
      
      // 특수 시나리오들
      ..._getSpecialScenarios(
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
      ),
    ];
  }

  /// 실온 발효 시나리오들 (사용자 환경 기반)
  static List<FermentationScenario> _getRoomTemperatureScenarios({
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
  }) {
    // 환경 조건에 따른 발효 온도 조정
    final baseTemp = environmentTemperature;
    final fermentationTemp = (baseTemp + 1.0).clamp(20.0, 30.0); // 실온보다 1도 높게
    final finalProofTemp = (baseTemp + 2.0).clamp(22.0, 32.0); // 실온보다 2도 높게
    
    // 환경 조건에 따른 습도 조정
    final baseHumidity = environmentHumidity;
    final fermentationHumidity = (baseHumidity + 5.0).clamp(60.0, 80.0);
    final finalProofHumidity = (baseHumidity + 10.0).clamp(65.0, 85.0);
    
    // 고도에 따른 시간 조정
    final altitudeFactor = 1.0 - (altitude * 0.00005);
    
    return [
      // 빠른 실온 발효 (고이스트)
      FermentationScenario(
        id: 'room_fast',
        name: '빠른 실온 발효 (${baseTemp.toInt()}°C 기반)',
        description: '이스트 많이 사용한 빠른 발효 (환경: ${baseTemp.toInt()}°C, ${baseHumidity.toInt()}%)',
        selectedStages: [FermentationStage.bulk, FermentationStage.finalProof],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (75 * altitudeFactor).clamp(60.0, 90.0),
            temperature: fermentationTemp,
            humidity: fermentationHumidity,
            notes: '실온 빠른 1차 발효 - 이스트 많이 사용 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (40 * altitudeFactor).clamp(30.0, 50.0),
            temperature: finalProofTemp,
            humidity: finalProofHumidity,
            notes: '실온 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),

      // 표준 실온 발효
      FermentationScenario(
        id: 'room_standard',
        name: '표준 실온 발효 (${baseTemp.toInt()}°C 기반)',
        description: '4단계 상세 발효 (환경: ${baseTemp.toInt()}°C, ${baseHumidity.toInt()}%)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.divided,
          FermentationStage.shaped,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (120 * altitudeFactor).clamp(90.0, 150.0),
            temperature: fermentationTemp,
            humidity: fermentationHumidity,
            notes: '실온 1차 발효 - 표준 이스트량 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.divided: FermentationStageConfig(
            duration: (20 * altitudeFactor).clamp(15.0, 25.0),
            temperature: baseTemp,
            humidity: baseHumidity,
            notes: '분할 후 실온 휴지 (${baseTemp.toInt()}°C)',
          ),
          FermentationStage.shaped: FermentationStageConfig(
            duration: (15 * altitudeFactor).clamp(10.0, 20.0),
            temperature: baseTemp,
            humidity: baseHumidity,
            notes: '성형 후 실온 휴지 (${baseTemp.toInt()}°C)',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (75 * altitudeFactor).clamp(60.0, 90.0),
            temperature: finalProofTemp,
            humidity: finalProofHumidity,
            notes: '실온 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),

      // 느린 실온 발효 (저이스트)
      FermentationScenario(
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.secondary,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: const FermentationStageConfig(
            duration: 180,   // 3시간
            temperature: 20,
            humidity: 60,
            notes: '실온 1차 발효 - 이스트 적게 사용',
          ),
          FermentationStage.secondary: const FermentationStageConfig(
            duration: 90,    // 1시간 30분
            temperature: 22,
            humidity: 65,
            notes: '실온 2차 발효',
          ),
          FermentationStage.finalProof: const FermentationStageConfig(
            duration: 60,    // 1시간
            temperature: 24,
            humidity: 70,
            notes: '실온 최종 발효',
          ),
        },
      ),
    ];
  }



  /// 저온 발효 시나리오들 (사용자 환경 기반)
  static List<FermentationScenario> _getColdFermentationScenarios({
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
  }) {
    // 환경 조건에 따른 조정
    final baseTemp = environmentTemperature;
    final baseHumidity = environmentHumidity;
    final altitudeFactor = 1.0 - (altitude * 0.00005);
    
    return [
      // 냉장 발효 시나리오 (환경 기반)
      FermentationScenario(
        id: 'cold_standard',
        name: '냉장 발효 (${baseTemp.toInt()}°C 환경)',
        description: '냉장고 저온 발효 + 실온 복귀',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.coldRetard,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (60 * altitudeFactor).clamp(45.0, 75.0),
            temperature: (baseTemp + 1.0).clamp(20.0, 28.0),
            humidity: (baseHumidity + 5.0).clamp(65.0, 80.0),
            notes: '실온 예비 발효 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.coldRetard: const FermentationStageConfig(
            duration: 720, // 12시간
            temperature: 4,
            humidity: 85,
            notes: '냉장 저온 발효 - 풍미 발달',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (120 * altitudeFactor).clamp(90.0, 150.0),
            temperature: (baseTemp + 2.0).clamp(22.0, 30.0),
            humidity: (baseHumidity + 10.0).clamp(70.0, 85.0),
            notes: '실온 복귀 후 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),
    ];
  }

  /// 오버나이트 시나리오들 (사용자 환경 기반)
  static List<FermentationScenario> _getOvernightScenarios({
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
  }) {
    // 환경 조건에 따른 조정
    final baseTemp = environmentTemperature;
    final baseHumidity = environmentHumidity;
    final altitudeFactor = 1.0 - (altitude * 0.00005);
    final overnightTemp = (baseTemp - 2.0).clamp(18.0, 24.0); // 실온보다 2도 낮게
    return [
      // 실온 오버나이트 (환경 기반)
      FermentationScenario(
        id: 'overnight_room',
        name: '실온 오버나이트 (${baseTemp.toInt()}°C 환경)',
        description: '8시간 장시간 발효 (환경: ${baseTemp.toInt()}°C, ${baseHumidity.toInt()}%)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.overnight,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (30 * altitudeFactor).clamp(20.0, 40.0),
            temperature: (baseTemp + 1.0).clamp(22.0, 28.0),
            humidity: (baseHumidity + 5.0).clamp(65.0, 80.0),
            notes: '짧은 예비 발효 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.overnight: FermentationStageConfig(
            duration: 480, // 8시간 (고도 영향 적음)
            temperature: overnightTemp,
            humidity: (baseHumidity + 0.0).clamp(55.0, 70.0),
            notes: '서늘한 오버나이트 발효 (${overnightTemp.toInt()}°C)',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (60 * altitudeFactor).clamp(45.0, 75.0),
            temperature: (baseTemp + 2.0).clamp(24.0, 30.0),
            humidity: (baseHumidity + 10.0).clamp(70.0, 85.0),
            notes: '아침 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),

      // 냉장 오버나이트 (환경 기반)
      FermentationScenario(
        id: 'overnight_cold',
        name: '냉장 오버나이트 (${baseTemp.toInt()}°C 환경)',
        description: '10시간 냉장 발효 (환경: ${baseTemp.toInt()}°C)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.overnight,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (60 * altitudeFactor).clamp(45.0, 75.0),
            temperature: (baseTemp + 1.0).clamp(22.0, 28.0),
            humidity: (baseHumidity + 5.0).clamp(65.0, 80.0),
            notes: '충분한 예비 발효 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.overnight: const FermentationStageConfig(
            duration: 600, // 10시간
            temperature: 8,
            humidity: 80,
            notes: '냉장 오버나이트 - 깊은 풍미',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (90 * altitudeFactor).clamp(75.0, 105.0),
            temperature: (baseTemp + 4.0).clamp(26.0, 32.0),
            humidity: (baseHumidity + 15.0).clamp(75.0, 90.0),
            notes: '따뜻한 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),

      // 혼합 오버나이트 (실온→냉장)
      FermentationScenario(
        id: 'overnight_mixed',
        name: '혼합 오버나이트 (${baseTemp.toInt()}°C 환경)',
        description: '실온→냉장 단계별 발효 (환경: ${baseTemp.toInt()}°C)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.overnight,
          FermentationStage.coldRetard,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (90 * altitudeFactor).clamp(75.0, 105.0),
            temperature: (baseTemp + 1.0).clamp(22.0, 28.0),
            humidity: (baseHumidity + 5.0).clamp(65.0, 80.0),
            notes: '실온 1차 발효 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.overnight: FermentationStageConfig(
            duration: 360, // 6시간
            temperature: overnightTemp,
            humidity: (baseHumidity + 0.0).clamp(60.0, 75.0),
            notes: '실온 오버나이트 (${overnightTemp.toInt()}°C)',
          ),
          FermentationStage.coldRetard: const FermentationStageConfig(
            duration: 240, // 4시간
            temperature: 4,
            humidity: 85,
            notes: '새벽 냉장 보관',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (75 * altitudeFactor).clamp(60.0, 90.0),
            temperature: (baseTemp + 2.0).clamp(24.0, 30.0),
            humidity: (baseHumidity + 15.0).clamp(75.0, 90.0),
            notes: '아침 최종 발효',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),
    ];
  }



  /// 특수 시나리오들 (사용자 환경 기반)
  static List<FermentationScenario> _getSpecialScenarios({
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
  }) {
    // 환경 조건에 따른 조정
    final baseTemp = environmentTemperature;
    final baseHumidity = environmentHumidity;
    final altitudeFactor = 1.0 - (altitude * 0.00005);
    
    return [
      // 고온 속성 발효 (여름 특화)
      FermentationScenario(
        id: 'special_fast_hot',
        name: '고온 속성 발효 (${baseTemp.toInt()}°C 환경)',
        description: '빠른 발효 - 여름철 특화 (환경: ${baseTemp.toInt()}°C)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (45 * altitudeFactor).clamp(35.0, 55.0),
            temperature: (baseTemp + 6.0).clamp(30.0, 38.0),
            humidity: (baseHumidity + 20.0).clamp(80.0, 95.0),
            notes: '고온 속성 1차 발효 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (25 * altitudeFactor).clamp(20.0, 30.0),
            temperature: (baseTemp + 8.0).clamp(32.0, 40.0),
            humidity: (baseHumidity + 25.0).clamp(85.0, 95.0),
            notes: '고온 속성 최종 발효 - 과발효 주의',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),
      
      // 저온 장시간 발효 (겨울 특화)
      FermentationScenario(
        id: 'special_slow_cold',
        name: '저온 장시간 발효 (${baseTemp.toInt()}°C 환경)',
        description: '겨울철 특화 장시간 발효 (환경: ${baseTemp.toInt()}°C)',
        selectedStages: [
          FermentationStage.bulk,
          FermentationStage.secondary,
          FermentationStage.coldRetard,
          FermentationStage.finalProof
        ],
        stageConfigs: {
          FermentationStage.bulk: FermentationStageConfig(
            duration: (240 * altitudeFactor).clamp(200.0, 280.0),
            temperature: (baseTemp - 2.0).clamp(14.0, 20.0),
            humidity: (baseHumidity - 5.0).clamp(50.0, 65.0),
            notes: '저온 1차 발효 - 겨울 특화 (${baseTemp.toInt()}°C 기반)',
          ),
          FermentationStage.secondary: FermentationStageConfig(
            duration: (120 * altitudeFactor).clamp(100.0, 140.0),
            temperature: (baseTemp - 1.0).clamp(16.0, 22.0),
            humidity: (baseHumidity + 0.0).clamp(55.0, 70.0),
            notes: '저온 2차 발효',
          ),
          FermentationStage.coldRetard: const FermentationStageConfig(
            duration: 480, // 8시간
            temperature: 2,
            humidity: 90,
            notes: '냉장 숙성',
          ),
          FermentationStage.finalProof: FermentationStageConfig(
            duration: (180 * altitudeFactor).clamp(150.0, 210.0),
            temperature: (baseTemp + 1.0).clamp(20.0, 28.0),
            humidity: (baseHumidity + 10.0).clamp(70.0, 85.0),
            notes: '긴 최종 발효 - 저온 보상',
          ),
        },
        environmentalConditions: EnvironmentalConditions(
          temperature: environmentTemperature,
          humidity: environmentHumidity,
          altitude: altitude,
        ),
      ),
    ];
  }

  /// AI 기반 시나리오 추천
  static FermentationScenario recommendScenario({
    required List<Map<String, dynamic>> ingredients,
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
    String? recipeTitle,
    int availableTimeHours = 8,
    String userExperience = 'beginner', // beginner, intermediate, expert
    String season = 'spring',
  }) {
    // 1. 재료 분석
    final hydration = IngredientAnalyzer.calculateHydration(ingredients, recipeTitle: recipeTitle);
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients, recipeTitle: recipeTitle);
    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients, recipeTitle: recipeTitle);
    
    // 2. 환경 분석
    final environmentType = _analyzeEnvironment(environmentTemperature, environmentHumidity, season);
    
    // 3. 빵 복잡도 분석
    final breadComplexity = _analyzeBreadComplexity(ingredients, recipeTitle, hydration);
    
    // 4. 시간 제약 분석
    final timeConstraint = _analyzeTimeConstraint(availableTimeHours);
    
    // 5. 사용자 경험 고려
    final experienceLevel = _parseExperienceLevel(userExperience);
    
    // 6. 최적 시나리오 선택
    return _selectOptimalScenario(
      environmentType: environmentType,
      breadComplexity: breadComplexity,
      timeConstraint: timeConstraint,
      experienceLevel: experienceLevel,
      yeastPercentage: yeastPercentage,
      hydration: hydration,
      environmentTemperature: environmentTemperature,
      environmentHumidity: environmentHumidity,
    );
  }

  /// 커스텀 시나리오 저장
  static Future<void> saveCustomScenario(String name, FermentationScenario scenario) async {
    final prefs = await SharedPreferences.getInstance();
    final customScenarios = await getCustomScenarios();
    
    final scenarioData = {
      'name': name,
      'scenario': scenario.toJson(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    customScenarios[name] = scenarioData;
    await prefs.setString(_customScenariosKey, jsonEncode(customScenarios));
  }

  /// 커스텀 시나리오 불러오기
  static Future<Map<String, Map<String, dynamic>>> getCustomScenarios() async {
    final prefs = await SharedPreferences.getInstance();
    final scenariosJson = prefs.getString(_customScenariosKey);
    
    if (scenariosJson == null) return {};
    
    try {
      final decoded = jsonDecode(scenariosJson) as Map<String, dynamic>;
      return decoded.cast<String, Map<String, dynamic>>();
    } catch (e) {
      return {};
    }
  }

  /// 커스텀 시나리오 삭제
  static Future<void> deleteCustomScenario(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final customScenarios = await getCustomScenarios();
    
    customScenarios.remove(name);
    await prefs.setString(_customScenariosKey, jsonEncode(customScenarios));
  }

  /// 즐겨찾기 시나리오 설정
  static Future<void> setFavoriteScenario(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoriteScenarioKey, scenarioId);
  }

  /// 즐겨찾기 시나리오 가져오기
  static Future<String?> getFavoriteScenario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoriteScenarioKey);
  }

  // Private Helper Methods

  static FermentationEnvironment _analyzeEnvironment(double temp, double humidity, String season) {
    if (temp >= 28) return FermentationEnvironment.warm;
    if (temp <= 8) return FermentationEnvironment.cold;
    if (temp >= 20 && temp <= 26) return FermentationEnvironment.roomTemperature;
    
    // 계절 고려
    if (season.toLowerCase().contains('summer') || season.contains('여름')) {
      return FermentationEnvironment.overnight;
    }
    
    return FermentationEnvironment.roomTemperature;
  }

  static BreadComplexity _analyzeBreadComplexity(List<Map<String, dynamic>> ingredients, String? title, double hydration) {
    // 제목 기반 분석
    if (title != null) {
      final titleLower = title.toLowerCase();
      if (titleLower.contains('sourdough') || titleLower.contains('사워도우') ||
          titleLower.contains('croissant') || titleLower.contains('크루아상')) {
        return BreadComplexity.complex;
      }
      if (titleLower.contains('baguette') || titleLower.contains('바게트') ||
          titleLower.contains('ciabatta') || titleLower.contains('치아바타')) {
        return BreadComplexity.moderate;
      }
    }
    
    // 수분율 기반 분석
    if (hydration >= 80) return BreadComplexity.complex;
    if (hydration >= 65) return BreadComplexity.moderate;
    
    return BreadComplexity.simple;
  }

  static String _analyzeTimeConstraint(int hours) {
    if (hours <= 3) return 'urgent';
    if (hours <= 8) return 'normal';
    if (hours <= 16) return 'extended';
    return 'unlimited';
  }

  static String _parseExperienceLevel(String experience) {
    switch (experience.toLowerCase()) {
      case 'expert':
      case '전문가':
        return 'expert';
      case 'intermediate':
      case '중급':
        return 'intermediate';
      default:
        return 'beginner';
    }
  }

  static FermentationScenario _selectOptimalScenario({
    required FermentationEnvironment environmentType,
    required BreadComplexity breadComplexity,
    required String timeConstraint,
    required String experienceLevel,
    required double yeastPercentage,
    required double hydration,
    required double environmentTemperature,
    required double environmentHumidity,
  }) {
    final allScenarios = getEnvironmentSpecificScenarios();
    
    // 시간 제약에 따른 필터링
    List<FermentationScenario> filteredScenarios;
    
    switch (timeConstraint) {
      case 'urgent':
        filteredScenarios = allScenarios.where((s) => s.totalEstimatedTime <= 180).toList(); // 3시간 이하
        break;
      case 'normal':
        filteredScenarios = allScenarios.where((s) => s.totalEstimatedTime <= 480).toList(); // 8시간 이하
        break;
      case 'extended':
        filteredScenarios = allScenarios.where((s) => s.totalEstimatedTime <= 960).toList(); // 16시간 이하
        break;
      default:
        filteredScenarios = allScenarios;
    }
    
    // 환경에 따른 점수 계산
    FermentationScenario? bestScenario;
    double bestScore = -1;
    
    for (final scenario in filteredScenarios) {
      double score = 0;
      
      // 환경 적합성 점수
      score += _calculateEnvironmentScore(scenario, environmentType, environmentTemperature);
      
      // 복잡도 적합성 점수
      score += _calculateComplexityScore(scenario, breadComplexity, experienceLevel);
      
      // 재료 적합성 점수
      score += _calculateIngredientScore(scenario, yeastPercentage, hydration);
      
      if (score > bestScore) {
        bestScore = score;
        bestScenario = scenario;
      }
    }
    
    // 환경 조건에 맞게 시간 조정
    if (bestScenario != null) {
      return _adjustScenarioForEnvironment(bestScenario, environmentTemperature, environmentHumidity);
    }
    
    // 기본값 반환
    return PredefinedScenarios.standardBread;
  }

  static double _calculateEnvironmentScore(FermentationScenario scenario, FermentationEnvironment envType, double temp) {
    double score = 0;
    
    // 온도 적합성
    for (final config in scenario.stageConfigs.values) {
      final tempDiff = (config.temperature - temp).abs();
      if (tempDiff <= 2) score += 3;
      else if (tempDiff <= 5) score += 2;
      else if (tempDiff <= 10) score += 1;
    }
    
    // 환경 타입 적합성
    switch (envType) {
      case FermentationEnvironment.cold:
        if (scenario.selectedStages.contains(FermentationStage.coldRetard)) score += 5;
        break;
      case FermentationEnvironment.warm:
        if (scenario.totalEstimatedTime <= 240) score += 5; // 4시간 이하
        break;
      case FermentationEnvironment.overnight:
        if (scenario.selectedStages.contains(FermentationStage.overnight)) score += 5;
        break;
      default:
        score += 2; // 기본 점수
    }
    
    return score;
  }

  static double _calculateComplexityScore(FermentationScenario scenario, BreadComplexity complexity, String experience) {
    double score = 0;
    final stageCount = scenario.selectedStages.length;
    
    switch (complexity) {
      case BreadComplexity.simple:
        if (stageCount <= 3) score += 3;
        else if (stageCount <= 4) score += 2;
        break;
      case BreadComplexity.moderate:
        if (stageCount >= 3 && stageCount <= 5) score += 3;
        break;
      case BreadComplexity.complex:
        if (stageCount >= 4) score += 3;
        break;
    }
    
    // 경험 수준 고려
    switch (experience) {
      case 'beginner':
        if (stageCount <= 3) score += 2;
        break;
      case 'expert':
        if (stageCount >= 5) score += 2;
        break;
    }
    
    return score;
  }

  static double _calculateIngredientScore(FermentationScenario scenario, double yeastPercentage, double hydration) {
    double score = 0;
    
    // 이스트 비율에 따른 시간 적합성
    if (yeastPercentage >= 1.0) {
      // 고이스트 - 짧은 시간 선호
      if (scenario.totalEstimatedTime <= 300) score += 3;
    } else if (yeastPercentage <= 0.3) {
      // 저이스트 - 긴 시간 선호
      if (scenario.totalEstimatedTime >= 480) score += 3;
    }
    
    // 수분율에 따른 복잡도 적합성
    if (hydration >= 75) {
      // 고수분 - 복잡한 시나리오 적합
      if (scenario.selectedStages.length >= 4) score += 2;
    }
    
    return score;
  }

  static FermentationScenario _adjustScenarioForEnvironment(
    FermentationScenario scenario,
    double envTemp,
    double envHumidity,
  ) {
    final adjustedConfigs = <FermentationStage, FermentationStageConfig>{};
    
    for (final entry in scenario.stageConfigs.entries) {
      final stage = entry.key;
      final config = entry.value;
      
      // 온도 차이에 따른 시간 조정
      final tempDiff = envTemp - config.temperature;
      double timeAdjustment = 1.0;
      
      if (tempDiff > 0) {
        // 환경이 더 따뜻함 - 시간 단축
        timeAdjustment = 1.0 - (tempDiff * 0.05);
      } else if (tempDiff < 0) {
        // 환경이 더 차가움 - 시간 연장
        timeAdjustment = 1.0 + ((-tempDiff) * 0.03);
      }
      
      timeAdjustment = timeAdjustment.clamp(0.5, 2.0);
      
      adjustedConfigs[stage] = config.copyWith(
        duration: (config.duration * timeAdjustment).clamp(5.0, 1440.0),
        temperature: envTemp, // 환경 온도로 조정
        humidity: envHumidity, // 환경 습도로 조정
      );
    }
    
    return FermentationScenario(
      selectedStages: scenario.selectedStages,
      stageConfigs: adjustedConfigs,
    );
  }

  /// 시나리오 이름 생성
  static String generateScenarioName(FermentationScenario scenario) {
    final type = scenario.scenarioType;
    final duration = scenario.totalEstimatedTime;
    final stageCount = scenario.selectedStages.length;
    
    String baseName;
    if (duration <= 180) {
      baseName = '빠른 발효';
    } else if (duration <= 480) {
      baseName = '표준 발효';
    } else if (duration <= 960) {
      baseName = '오버나이트 발효';
    } else {
      baseName = '장시간 발효';
    }
    
    if (scenario.selectedStages.contains(FermentationStage.coldRetard)) {
      baseName += ' (냉장)';
    }
    
    return '$baseName ${stageCount}단계';
  }
}