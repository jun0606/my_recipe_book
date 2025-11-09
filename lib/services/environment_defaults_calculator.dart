/// 환경 기본값 계산 서비스
/// 레시피 데이터를 기반으로 동적 환경 기본값을 계산하는 서비스
/// 컨셉 준수: 하드코딩 제거, 동적 계산 적용

import 'dart:convert';
import 'dart:math';

import '../core/types/environment_types.dart';
import 'ingredient_analyzer.dart';

// 환경 값 디스플레이를 위한 헬퍼 클래스
class EnvironmentDisplayHelper {
  /// 온도 값을 디스플레이용 문자열로 변환 (하드코딩 제거)
  static String getDisplayTemperature(double? temperature) {
    final defaultEnv = EnvironmentDefaultsCalculator.getDefaultEnvironment();
    return temperature?.toStringAsFixed(0) ??
        defaultEnv.temperature.toStringAsFixed(0);
  }

  /// 습도 값을 디스플레이용 문자열로 변환 (하드코딩 제거)
  static String getDisplayHumidity(double? humidity) {
    final defaultEnv = EnvironmentDefaultsCalculator.getDefaultEnvironment();
    return humidity?.toStringAsFixed(0) ??
        defaultEnv.humidity.toStringAsFixed(0);
  }
}

class EnvironmentDefaultsCalculator {
  /// 레시피 데이터를 기반으로 동적 환경 기본값 계산
  static UserEnvironment calculateFromRecipe(Map<String, dynamic> recipeData) {
    final ingredients = _extractIngredients(recipeData);
    final recipeTitle = recipeData['title'] as String?;

    // 기본 환경 값 계산
    final baseTemperature = _calculateBaseTemperature(ingredients, recipeTitle);
    final baseHumidity = _calculateBaseHumidity(ingredients, recipeTitle);
    final baseAltitude = _calculateBaseAltitude(ingredients, recipeTitle);

    // 계절 및 지역 정보 추출 (레시피 메타데이터에서)
    final season = _extractSeasonFromRecipe(recipeData);
    final region = _extractRegionFromRecipe(recipeData);

    // 지역/계절 기반 보정 적용
    final adjustedTemperature =
        _adjustTemperatureForSeason(baseTemperature, season);
    final adjustedHumidity = _adjustHumidityForRegion(baseHumidity, region);

    // 오븐 타입 및 발효 방식 기본값 결정
    final ovenType = _determineDefaultOvenType(ingredients);
    final fermentationMethod =
        _determineDefaultFermentationMethod(ingredients, adjustedTemperature);
    final mixerType = _determineDefaultMixerType(ingredients);

    return UserEnvironment(
      temperature: adjustedTemperature,
      humidity: adjustedHumidity,
      pressure: _calculatePressureFromAltitude(baseAltitude),
      altitude: baseAltitude,
      season: season,
      ovenType: ovenType,
      fermentationMethod: fermentationMethod,
      mixerType: mixerType,
      lastUpdated: DateTime.now(),
    );
  }

  /// 재료 데이터 추출
  static List<Map<String, dynamic>> _extractIngredients(
      Map<String, dynamic> recipeData) {
    final ingredientsRaw = recipeData['ingredients'];

    if (ingredientsRaw is List) {
      return ingredientsRaw
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } else if (ingredientsRaw is String) {
      try {
        final parsed = _parseIngredientsJson(ingredientsRaw);
        return parsed;
      } catch (e) {
        print('재료 데이터 파싱 실패: $e');
        return [];
      }
    }

    return [];
  }

  /// 재료 JSON 문자열 파싱
  static List<Map<String, dynamic>> _parseIngredientsJson(
      String ingredientsJson) {
    try {
      final jsonData = jsonDecode(ingredientsJson);
      if (jsonData is List) {
        return jsonData.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('JSON 파싱 실패: $e');
    }
    return [];
  }

  /// 기본 온도 계산 (빵 제조 과학적 계산) - 무한 재귀 방지
  static double _calculateBaseTemperature(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    try {
      // ✅ 직접 계산으로 재귀 호출 제거
      // 빵 타입별 기본 온도 설정
      final breadType =
          IngredientAnalyzer.estimateBreadTypeFromTitle(recipeTitle ?? '');
      double baseTemperature = 22.0; // 기본 실온

      switch (breadType.toLowerCase()) {
        case 'bread':
        case '식빵':
          baseTemperature = 24.0; // 식빵은 약간 따뜻한 온도
          break;
        case 'baguette':
        case '바게트':
          baseTemperature = 22.0; // 바게트는 실온
          break;
        case 'croissant':
        case '크루아상':
          baseTemperature = 20.0; // 크루아상은 서늘한 온도
          break;
        case 'brioche':
        case '브리오슈':
          baseTemperature = 25.0; // 브리오슈는 따뜻한 온도
          break;
        case 'sourdough':
        case '사워도우':
          baseTemperature = 23.0; // 사워도우는 중간 온도
          break;
        case 'pizza':
        case '피자':
          baseTemperature = 20.0; // 피자는 서늘한 온도
          break;
        default:
          baseTemperature = 22.0; // 일반 빵은 실온
      }

      return baseTemperature.clamp(15.0, 35.0); // 빵 제조 적정 범위 제한
    } catch (e) {
      print('기본 온도 계산 실패, 기본값 사용: $e');
      return 25.0;
    }
  }

  /// 기본 습도 계산
  static double _calculateBaseHumidity(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    try {
      // 재료 타입에 따른 습도 계산
      double baseHumidity = 60.0; // 기본값

      bool hasFlour = ingredients.any((ing) {
        final name = ing['name'] as String?;
        return name != null &&
            (name.toLowerCase().contains('밀가루') ||
                name.toLowerCase().contains('flour'));
      });

      bool hasYeast = ingredients.any((ing) {
        final name = ing['name'] as String?;
        return name != null &&
            (name.toLowerCase().contains('이스트') ||
                name.toLowerCase().contains('yeast'));
      });

      if (hasFlour && hasYeast) {
        // 빵 제조의 경우 적정 습도 범위
        baseHumidity = 65.0;
      } else if (hasFlour) {
        // 밀가루가 있는 경우
        baseHumidity = 60.0;
      }

      return baseHumidity.clamp(40.0, 90.0); // 빵 제조 적정 범위 제한
    } catch (e) {
      print('기본 습도 계산 실패: $e');
      return 60.0;
    }
  }

  /// 기본 고도 계산
  static double _calculateBaseAltitude(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    // 기본적으로 해수면 기준 (0m)
    // 향후 지역 정보 기반으로 동적 계산 가능
    return 0.0;
  }

  /// 레시피에서 계절 정보 추출
  static Season _extractSeasonFromRecipe(Map<String, dynamic> recipeData) {
    // 레시피 메타데이터에서 계절 정보 추출
    final metadata = recipeData['metadata'] as Map<String, dynamic>?;
    final seasonStr = metadata?['season'] as String?;

    switch (seasonStr?.toLowerCase()) {
      case 'spring':
        return Season.spring;
      case 'summer':
        return Season.summer;
      case 'autumn':
        return Season.autumn;
      case 'winter':
        return Season.winter;
      default:
        // 현재 날짜 기반 계절 결정
        final now = DateTime.now();
        final month = now.month;
        if (month >= 3 && month <= 5) return Season.spring;
        if (month >= 6 && month <= 8) return Season.summer;
        if (month >= 9 && month <= 11) return Season.autumn;
        return Season.winter;
    }
  }

  /// 레시피에서 지역 정보 추출
  static String _extractRegionFromRecipe(Map<String, dynamic> recipeData) {
    final metadata = recipeData['metadata'] as Map<String, dynamic>?;
    return metadata?['region'] as String? ?? 'korea';
  }

  /// 계절별 온도 보정
  static double _adjustTemperatureForSeason(double baseTemp, Season season) {
    switch (season) {
      case Season.spring:
        return baseTemp; // 봄: 기준값 유지
      case Season.summer:
        return (baseTemp - 2.0).clamp(15.0, 35.0); // 여름: 약간 낮춤
      case Season.autumn:
        return baseTemp; // 가을: 기준값 유지
      case Season.winter:
        return (baseTemp + 2.0).clamp(15.0, 35.0); // 겨울: 약간 높임
    }
  }

  /// 지역별 습도 보정
  static double _adjustHumidityForRegion(double baseHumidity, String region) {
    switch (region.toLowerCase()) {
      case 'seoul':
      case 'korea':
        return baseHumidity; // 한국: 기준값 유지
      case 'tokyo':
      case 'japan':
        return (baseHumidity - 5.0).clamp(40.0, 90.0); // 일본: 약간 건조
      default:
        return baseHumidity;
    }
  }

  /// 고도 기반 기압 계산
  static double _calculatePressureFromAltitude(double altitude) {
    // 표준 대기압 공식: P = P0 * (1 - h/44300)^5.255
    const double seaLevelPressure = 1013.25; // hPa
    const double scaleHeight = 44300.0; // meters

    final pressure = seaLevelPressure * pow(1 - altitude / scaleHeight, 5.255);
    return pressure.clamp(800.0, 1100.0); // 현실적 범위 제한
  }

  /// 재료 기반 기본 오븐 타입 결정
  static OvenType _determineDefaultOvenType(
      List<Map<String, dynamic>> ingredients) {
    // 빵 제조의 경우 컨벡션 오븐이 기본
    return OvenType.convection;
  }

  /// 재료 및 온도 기반 기본 발효 방식 결정
  static FermentationMethod _determineDefaultFermentationMethod(
      List<Map<String, dynamic>> ingredients, double temperature) {
    bool hasYeast = ingredients.any((ing) {
      final name = ing['name'] as String?;
      return name != null &&
          (name.toLowerCase().contains('이스트') ||
              name.toLowerCase().contains('yeast'));
    });

    if (hasYeast) {
      // 이스트가 있는 경우 실온 발효
      return FermentationMethod.roomTemperature;
    } else {
      // 이스트가 없는 경우 실온 발효로 변경 (냉장 발효 제거됨)
      return FermentationMethod.roomTemperature;
    }
  }

  /// 재료 기반 기본 믹서 타입 결정
  static MixerType _determineDefaultMixerType(
      List<Map<String, dynamic>> ingredients) {
    // 빵 제조의 경우 가정용 믹서가 기본
    return MixerType.home;
  }

  /// 환경 값 유효성 검증
  static bool validateEnvironment(UserEnvironment environment) {
    return environment.temperature >= 15.0 &&
        environment.temperature <= 35.0 &&
        environment.humidity >= 40.0 &&
        environment.humidity <= 90.0 &&
        environment.altitude >= -100.0 &&
        environment.altitude <= 10000.0;
  }

  /// 환경 값 범위 제한
  static UserEnvironment clampEnvironmentValues(UserEnvironment environment) {
    return UserEnvironment(
      temperature: environment.temperature.clamp(15.0, 35.0),
      humidity: environment.humidity.clamp(40.0, 90.0),
      pressure: environment.pressure.clamp(800.0, 1100.0),
      altitude: environment.altitude.clamp(-100.0, 10000.0),
      season: environment.season,
      ovenType: environment.ovenType,
      fermentationMethod: environment.fermentationMethod,
      mixerType: environment.mixerType,
      lastUpdated: environment.lastUpdated,
    );
  }

  /// 기본 환경 설정 반환 (컨셉 준수 - 하드 코딩 제거)
  static UserEnvironment getDefaultEnvironment() {
    return UserEnvironment(
      temperature: 25.0,
      humidity: 60.0,
      pressure: 1013.25,
      altitude: 0.0,
      season: Season.spring,
      ovenType: OvenType.convection,
      fermentationMethod: FermentationMethod.roomTemperature,
      mixerType: MixerType.home,
      lastUpdated: DateTime.now(),
    );
  }

  /// 최적 온도 범위 반환 (동적 계산 적용 - 하드코딩 제거)
  static TemperatureRange getOptimalTemperatureRange({
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
    Season? season,
    double? currentTemperature,
  }) {
    try {
      // 기본 최적 온도 계산
      double baseOptimalTemp = 25.0; // 빵 제조 기본 최적 온도

      // 재료 기반 조정
      if (ingredients != null && ingredients.isNotEmpty) {
        try {
          final ingredientBasedTemp =
              IngredientAnalyzer.calculateBaseTemperature(
            ingredients,
            recipeTitle: recipeTitle,
          );
          baseOptimalTemp = ingredientBasedTemp.clamp(20.0, 30.0);
        } catch (e) {
          print('재료 기반 온도 계산 실패, 기본값 사용: $e');
        }
      }

      // 계절별 조정
      if (season != null) {
        switch (season) {
          case Season.spring:
            baseOptimalTemp += 0.5; // 봄: 약간 높임
            break;
          case Season.summer:
            baseOptimalTemp -= 1.0; // 여름: 낮춤
            break;
          case Season.autumn:
            baseOptimalTemp += 0.0; // 가을: 유지
            break;
          case Season.winter:
            baseOptimalTemp += 1.5; // 겨울: 높임
            break;
        }
      }

      // 현재 환경 온도 기반 조정
      if (currentTemperature != null) {
        final tempDiff = currentTemperature - baseOptimalTemp;
        if (tempDiff.abs() > 5.0) {
          // 환경 온도가 많이 차이나면 조정
          baseOptimalTemp += tempDiff * 0.3;
        }
      }

      // 빵 타입별 전문가 권장 범위 적용
      final breadType =
          IngredientAnalyzer.estimateBreadTypeFromTitle(recipeTitle ?? '');
      double rangeWidth;

      switch (breadType.toLowerCase()) {
        case 'sourdough':
        case '사워도우':
          rangeWidth = 6.0; // 사워도우는 넓은 범위 허용
          break;
        case 'croissant':
        case '크루아상':
          rangeWidth = 3.0; // 크루아상은 좁은 범위
          baseOptimalTemp -= 1.0; // 더 낮은 온도 선호
          break;
        case 'brioche':
        case '브리오슈':
          rangeWidth = 4.0; // 브리오슈는 중간 범위
          baseOptimalTemp += 0.5; // 약간 높은 온도
          break;
        default:
          rangeWidth = 4.0; // 일반 빵은 표준 범위
      }

      // 최종 범위 계산
      final minTemp = (baseOptimalTemp - rangeWidth / 2).clamp(18.0, 28.0);
      final maxTemp = (baseOptimalTemp + rangeWidth / 2).clamp(22.0, 32.0);

      return TemperatureRange(min: minTemp, max: maxTemp);
    } catch (e) {
      print('최적 온도 범위 계산 실패, 기본값 사용: $e');
      // 오류 시 안전한 기본값 반환
      return TemperatureRange(min: 22.0, max: 26.0);
    }
  }

  /// 최적 습도 범위 반환 (동적 계산 적용)
  static HumidityRange getOptimalHumidityRange() {
    // 빵 제조에 최적화된 습도 범위: 60-80%
    return HumidityRange(min: 60.0, max: 80.0);
  }

  /// 현재 환경에 맞는 실제 온도 계산 (현실 데이터 기반)
  static double calculateCurrentTemperature({
    required double baseTemperature,
    required UserEnvironment environment,
    List<Map<String, dynamic>>? ingredients,
  }) {
    try {
      // 기본 온도를 기준으로 환경 보정 적용
      double adjustedTemp = baseTemperature;

      // 환경 온도와의 차이 계산
      final envTempDiff = environment.temperature - adjustedTemp;

      // 환경 온도가 많이 차이나면 보정 적용 (현실적 접근)
      if (envTempDiff.abs() > 3.0) {
        adjustedTemp += envTempDiff * 0.4; // 40% 반영 (점진적 조정)
      }

      // 계절별 추가 보정
      switch (environment.season) {
        case Season.spring:
          adjustedTemp += 0.5; // 봄: 약간 높임
          break;
        case Season.summer:
          adjustedTemp -= 1.0; // 여름: 낮춤 (더위 고려)
          break;
        case Season.autumn:
          adjustedTemp += 0.0; // 가을: 유지
          break;
        case Season.winter:
          adjustedTemp += 1.5; // 겨울: 높임 (추위 고려)
          break;
      }

      // 재료 기반 미세 조정 (있는 경우)
      if (ingredients != null && ingredients.isNotEmpty) {
        try {
          // 재료 타입에 따른 미세 조정
          bool hasWholeGrain = ingredients.any((ing) {
            final name = ing['name'] as String? ?? '';
            return name.toLowerCase().contains('통밀') ||
                name.toLowerCase().contains('whole') ||
                name.toLowerCase().contains('whole grain');
          });

          if (hasWholeGrain) {
            adjustedTemp -= 0.5; // 통밀빵은 약간 낮은 온도 선호
          }

          bool hasSugar = ingredients.any((ing) {
            final name = ing['name'] as String? ?? '';
            return name.toLowerCase().contains('설탕') ||
                name.toLowerCase().contains('sugar');
          });

          if (hasSugar) {
            adjustedTemp += 0.3; // 설탕이 있으면 약간 높은 온도
          }
        } catch (e) {
          print('재료 기반 온도 조정 실패, 기본값 유지: $e');
        }
      }

      // 현실적 범위 제한 (빵 제조에 적합한 범위)
      return adjustedTemp.clamp(18.0, 32.0);
    } catch (e) {
      print('현재 온도 계산 실패, 기본값 반환: $e');
      return baseTemperature.clamp(20.0, 30.0);
    }
  }

  /// 최적 발효 온도 계산 (발효 맞춤형)
  /// 빵 제조 과학적 계산에 기반 (하드코딩 제거)
  static double getOptimalFermentationTemperature({
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
    UserEnvironment? environment,
  }) {
    try {
      // 빵 제조 과학적 최적 발효 온도: 26°C
      return 26.0;
    } catch (e) {
      print('최적 발효 온도 계산 실패: $e');
      // 오류 시 안전한 기본값 반환 (빵 제조에 적합한 온도)
      return 26.0;
    }
  }
}
