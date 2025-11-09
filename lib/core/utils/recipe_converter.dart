import 'dart:convert';

import '../../../../core/types/unified_types.dart';
import '../../../../core/utils/analysis_helpers.dart';
import '../../../../core/utils/mixing_data_helper.dart';
import '../../../features/chef/module/bread/types/bread_types.dart';

/// 레시피 데이터 변환을 담당하는 헬퍼 클래스
/// 중복 코드 제거 및 재사용성 향상을 위해 생성
class RecipeConverter {
  /// 레거시 레시피 데이터를 새로운 통합 시스템으로 변환
  static UnifiedRecipe fromLegacy(Map<String, dynamic> recipeData) {
    print('=== [DEBUG] RecipeConverter.fromLegacy 시작 ===');
    print('레시피 제목: ${recipeData['title']}');

    // 폴백용 ingredients 변수 선언
    List<UnifiedIngredient> ingredients = [];

    // 실제 JSON 데이터를 시뮬레이션해서 fromJson() 사용
    final jsonData = convertLegacyToJsonFormat(recipeData);
    print('🔄 [DEBUG] JSON 형식으로 변환 시도');
    print('📄 [DEBUG] 변환된 JSON 데이터 키들: ${jsonData.keys.toList()}');

    try {
      final unifiedRecipe = UnifiedRecipe.fromJson(jsonData);
      print('✅ [DEBUG] UnifiedRecipe.fromJson() 성공');
      print('📦 [DEBUG] 생성된 레시피 재료 수: ${unifiedRecipe.ingredients.length}');
      return unifiedRecipe;
    } catch (e) {
      print('❌ [DEBUG] UnifiedRecipe.fromJson() 실패: $e');
      print('📄 [DEBUG] 폴백: 수동 생성 사용');

      // 폴백: 수동 생성
      // 재료 변환
      ingredients = <UnifiedIngredient>[];
      final ingredientsData = recipeData['ingredients'];

      if (ingredientsData is List) {
        for (final item in ingredientsData) {
          if (item is Map<String, dynamic>) {
            ingredients.add(
              UnifiedIngredient(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: item['name']?.toString() ?? 'Unknown',
                amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
                unit: item['unit']?.toString() ?? 'g',
                properties: {},
              ),
            );
          }
        }
      }

      print('재료 변환 완료: ${ingredients.length}개');
    }

    // 프로세스 변환 - 실제 믹싱 데이터를 사용 (헬퍼 클래스 사용)
    final processes = <UnifiedProcess>[];
    final mixingData =
        MixingDataHelper.ensureMixingDataExists(recipeData); // 강화된 믹싱 데이터 가져오기

    print('=== [DEBUG] 믹싱 데이터 변환 디버깅 ===');
    print('1. 원본 믹싱 데이터: ${mixingData.length}개');
    print('2. 변환 전 프로세스 수: ${processes.length}개');

    // 믹싱 단계들을 프로세스로 변환
    for (int i = 0; i < mixingData.length; i++) {
      final mixingStep = mixingData[i];
      final speed = mixingStep['speed'] as String? ?? '중속';
      final durationMinutes = mixingStep['durationMinutes'] as int? ?? 5;

      // 빈 문자열도 기본값으로 처리하도록 수정
      final rawComment = mixingStep['comment'] as String? ?? '';
      final comment =
          rawComment.trim().isNotEmpty ? rawComment : '믹싱 단계 ${i + 1}';

      processes.add(
        UnifiedProcess(
          id: 'mixing_process_${i + 1}',
          type: 'mixing',
          name: comment, // 이제 빈 문자열도 기본값으로 처리됨
          duration: Duration(minutes: durationMinutes),
          parameters: {
            'speed': speed,
            'step': i + 1,
          },
        ),
      );
    }

    // 다른 프로세스들 추가 (발효, 베이킹 등)
    processes.addAll([
      UnifiedProcess(
        id: 'fermentation_process',
        type: 'fermentation',
        name: '발효',
        duration: const Duration(hours: 2),
        parameters: {},
      ),
      UnifiedProcess(
        id: 'baking_process',
        type: 'baking',
        name: '굽기',
        duration: const Duration(minutes: 30),
        parameters: {},
      ),
    ]);

    print('생성된 프로세스 수: ${processes.length}');
    print('믹싱 프로세스 수: ${processes.where((p) => p.type == 'mixing').length}');

    return UnifiedRecipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: recipeData['title']?.toString() ?? '제목 없음',
      ingredients: ingredients,
      processes: processes,
      equipment: EquipmentConfig.defaultConfig(),
      metadata: RecipeMetadata.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 레거시 레시피 데이터를 JSON 형식으로 변환 (public 메소드)
  static Map<String, dynamic> convertLegacyToJsonFormat(
      Map<String, dynamic> recipeData) {
    // 재료 변환 - JSON 문자열 또는 List 모두 처리
    final ingredients = <Map<String, dynamic>>[];
    final ingredientsData = recipeData['ingredients'];

    print(
        '🔍 [DEBUG] RecipeConverter.convertLegacyToJsonFormat 재료 데이터 타입: ${ingredientsData.runtimeType}');
    print(
        '🔍 [DEBUG] RecipeConverter.convertLegacyToJsonFormat 재료 데이터 값: $ingredientsData');

    if (ingredientsData is String) {
      // JSON 문자열인 경우 파싱
      try {
        final parsed = jsonDecode(ingredientsData);
        if (parsed is List) {
          for (final item in parsed) {
            if (item is Map<String, dynamic>) {
              ingredients.add({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': item['name']?.toString() ?? 'Unknown',
                'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
                'unit': item['unit']?.toString() ?? 'g',
                'properties': {},
              });
            }
          }
        }
        print('✅ [DEBUG] JSON 문자열 재료 파싱 성공: ${ingredients.length}개');
      } catch (e) {
        print('❌ [DEBUG] JSON 문자열 재료 파싱 실패: $e');
      }
    } else if (ingredientsData is List) {
      // 이미 List인 경우 직접 사용
      for (final item in ingredientsData) {
        if (item is Map<String, dynamic>) {
          ingredients.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': item['name']?.toString() ?? 'Unknown',
            'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
            'unit': item['unit']?.toString() ?? 'g',
            'properties': {},
          });
        }
      }
      print('✅ [DEBUG] List 재료 변환 성공: ${ingredients.length}개');
    } else {
      print('⚠️ [DEBUG] 재료 데이터가 지원되지 않는 타입: ${ingredientsData.runtimeType}');
    }

    // 프로세스 변환
    final processes = <Map<String, dynamic>>[];
    final mixingData = MixingDataHelper.ensureMixingDataExists(recipeData);

    for (int i = 0; i < mixingData.length; i++) {
      final mixingStep = mixingData[i];
      final speed = mixingStep['speed'] as String? ?? '중속';
      final durationMinutes = mixingStep['durationMinutes'] as int? ?? 5;
      final rawComment = mixingStep['comment'] as String? ?? '';
      final comment =
          rawComment.trim().isNotEmpty ? rawComment : '믹싱 단계 ${i + 1}';

      processes.add({
        'id': 'mixing_process_${i + 1}',
        'type': 'mixing',
        'name': comment,
        'duration_minutes': durationMinutes,
        'parameters': {
          'speed': speed,
          'step': i + 1,
        },
      });
    }

    // 개선된 발효 데이터 추출
    final fermentationData = _extractFermentationData(recipeData);
    processes.add({
      'id': 'fermentation_process',
      'type': 'fermentation',
      'name': fermentationData['name'] ?? '발효',
      'duration_minutes': fermentationData['duration'] ??
          AnalysisConstants.defaultFermentationTime,
      'parameters': {
        'method': fermentationData['method'],
        'temperature': fermentationData['temperature'],
        'humidity': fermentationData['humidity'],
      },
    });

    // 개선된 오븐 데이터 추출
    final ovenData = _extractOvenData(recipeData);
    processes.add({
      'id': 'baking_process',
      'type': 'baking',
      'name': ovenData['name'] ?? '굽기',
      'duration_minutes': ovenData['duration'] ?? 30,
      'parameters': {
        'temperature': ovenData['temperature'],
        'ovenType': ovenData['type'],
        'steam': ovenData['steam'],
      },
    });

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': recipeData['title']?.toString() ?? '제목 없음',
      'ingredients': ingredients,
      'processes': processes,
      'equipment': {
        'settings': {
          'mixerType': 'stand_mixer',
          'ovenType': 'convection',
          'mixerPower': 300,
          'ovenPower': 2000,
        },
      },
      'metadata': {
        'data': {},
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 발효 데이터 추출 (개선된 버전)
  static Map<String, dynamic> _extractFermentationData(
      Map<String, dynamic> recipeData) {
    final fermentation = recipeData['fermentation'] as Map<String, dynamic>?;

    if (fermentation != null) {
      // 다양한 키 시도
      final possibleKeys = [
        'method',
        'type',
        'fermentationMethod',
        'fermentation_type'
      ];
      String method = 'roomTemperature';
      for (final key in possibleKeys) {
        if (fermentation.containsKey(key)) {
          method = fermentation[key]?.toString() ?? 'roomTemperature';
          break;
        }
      }

      // 온도 추출
      final temperatureKeys = ['temperature', 'temp', 'fermentationTemp'];
      double temperature = 25.0;
      for (final key in temperatureKeys) {
        if (fermentation.containsKey(key)) {
          final temp = fermentation[key];
          if (temp is num) {
            temperature = temp.toDouble();
          } else if (temp is String) {
            temperature = double.tryParse(temp) ?? 25.0;
          }
          break;
        }
      }

      // 습도 추출
      final humidityKeys = ['humidity', 'fermentationHumidity'];
      double humidity = 75.0;
      for (final key in humidityKeys) {
        if (fermentation.containsKey(key)) {
          final hum = fermentation[key];
          if (hum is num) {
            humidity = hum.toDouble();
          } else if (hum is String) {
            humidity = double.tryParse(hum) ?? 75.0;
          }
          break;
        }
      }

      // 시간 추출
      final durationKeys = [
        'duration',
        'time',
        'fermentationTime',
        'durationMinutes'
      ];
      int duration = AnalysisConstants.defaultFermentationTime;
      for (final key in durationKeys) {
        if (fermentation.containsKey(key)) {
          final dur = fermentation[key];
          if (dur is num) {
            duration = dur.toInt();
          } else if (dur is String) {
            // "2 hours" 또는 "120 minutes" 형태 파싱
            final parsed = _parseDurationString(dur);
            if (parsed > 0) {
              duration = parsed;
            }
          }
          break;
        }
      }

      return {
        'method': method,
        'temperature': temperature,
        'humidity': humidity,
        'duration': duration,
        'name': _getFermentationName(method),
      };
    }

    return _getDefaultFermentationData();
  }

  /// 오븐 데이터 추출 (개선된 버전)
  static Map<String, dynamic> _extractOvenData(
      Map<String, dynamic> recipeData) {
    final oven = recipeData['oven'] as Map<String, dynamic>?;

    if (oven != null) {
      // 온도 추출
      final temperatureKeys = ['temperature', 'temp', 'bakingTemp', 'ovenTemp'];
      double temperature = 200.0;
      for (final key in temperatureKeys) {
        if (oven.containsKey(key)) {
          final temp = oven[key];
          if (temp is num) {
            temperature = temp.toDouble();
          } else if (temp is String) {
            temperature = double.tryParse(temp) ?? 200.0;
          }
          break;
        }
      }

      // 시간 추출
      final durationKeys = [
        'duration',
        'time',
        'bakingTime',
        'durationMinutes'
      ];
      int duration = 30;
      for (final key in durationKeys) {
        if (oven.containsKey(key)) {
          final dur = oven[key];
          if (dur is num) {
            duration = dur.toInt();
          } else if (dur is String) {
            final parsed = _parseDurationString(dur);
            if (parsed > 0) {
              duration = parsed;
            }
          }
          break;
        }
      }

      // 오븐 타입 추출
      final typeKeys = ['type', 'ovenType', 'bakingMethod'];
      String type = 'convection';
      for (final key in typeKeys) {
        if (oven.containsKey(key)) {
          type = oven[key]?.toString() ?? 'convection';
          break;
        }
      }

      // 스팀 기능 추출
      final steamKeys = ['steam', 'steamInjection', 'useSteam'];
      bool steam = false;
      for (final key in steamKeys) {
        if (oven.containsKey(key)) {
          final steamVal = oven[key];
          if (steamVal is bool) {
            steam = steamVal;
          } else if (steamVal is String) {
            steam = steamVal.toLowerCase() == 'true' ||
                steamVal.toLowerCase() == 'yes';
          }
          break;
        }
      }

      return {
        'temperature': temperature,
        'duration': duration,
        'type': type,
        'steam': steam,
        'name': _getOvenName(type, steam),
      };
    }

    return _getDefaultOvenData();
  }

  /// 발효 방식에 따른 이름 반환
  static String _getFermentationName(String method) {
    switch (method.toLowerCase()) {
      case 'roomtemperature':
      case 'room_temperature':
        return '실온 발효';
      case 'overnight':
      case 'cold':
        return '냉장 발효';
      case 'fermenter':
      case 'proofing_box':
        return '발효기 발효';
      case 'natural':
        return '자연 발효';
      default:
        return '발효';
    }
  }

  /// 오븐 타입에 따른 이름 반환
  static String _getOvenName(String type, bool steam) {
    String baseName;
    switch (type.toLowerCase()) {
      case 'convection':
        baseName = '컨벡션 오븐';
        break;
      case 'conventional':
        baseName = '일반 오븐';
        break;
      case 'deck':
        baseName = '데크 오븐';
        break;
      case 'steam':
        baseName = '스팀 오븐';
        break;
      default:
        baseName = '오븐';
    }

    return steam ? '$baseName (스팀)' : baseName;
  }

  /// 기본 발효 데이터 반환
  static Map<String, dynamic> _getDefaultFermentationData() {
    return {
      'method': 'roomTemperature',
      'temperature': 25.0,
      'humidity': 75.0,
      'duration': AnalysisConstants.defaultFermentationTime,
      'name': '실온 발효',
    };
  }

  /// 기본 오븐 데이터 반환
  static Map<String, dynamic> _getDefaultOvenData() {
    return {
      'temperature': 200.0,
      'duration': 30,
      'type': 'convection',
      'steam': false,
      'name': '컨벡션 오븐',
    };
  }

  /// 시간 문자열 파싱 헬퍼 메소드
  static int _parseDurationString(String durationStr) {
    final lowerStr = durationStr.toLowerCase();

    // 숫자 추출 시도
    final numberMatch = RegExp(r'(\d+)').firstMatch(lowerStr);
    if (numberMatch != null) {
      final minutes = int.tryParse(numberMatch.group(1) ?? '30') ?? 30;

      // 시간 단위 확인
      if (lowerStr.contains('hour') || lowerStr.contains('시간')) {
        return minutes * 60; // 시간 -> 분 변환
      }

      return minutes; // 이미 분 단위
    }

    return 30; // 기본값
  }

  /// 레거시 데이터를 새로운 BreadUserData로 변환
  static BreadUserData createBreadUserData(
    Map<String, dynamic> inputs,
    List<Map<String, dynamic>> mixingData,
  ) {
    // 환경 데이터 변환
    final environment = BreadUserEnvironment(
      temperature: (inputs['temperature'] as num?)?.toDouble() ?? 25.0,
      humidity: (inputs['humidity'] as num?)?.toDouble() ?? 60.0,
      fermentationMethod:
          inputs['fermentationMethod']?.toString() ?? 'roomTemperature',
      ovenType: inputs['ovenType']?.toString() ?? 'convection',
    );

    // 장비 데이터 변환 - 믹서 타입을 명시적으로 설정
    final mixerType = AnalysisHelpers.normalizeMixerType(
        inputs['mixerType']?.toString() ?? 'home');

    final equipment = BreadUserEquipment(
      settings: {
        'mixerType': mixerType,
        'rpmMode': true,
        'mixingData': mixingData, // 믹싱 데이터를 장비 설정에 포함
        'mixingStepsCount': mixingData.length,
      },
    );

    // 사용자 선호사항 (기본값)
    final preferences = BreadUserPreferences(
      preferences: {
        'difficulty': 'intermediate',
        'automationLevel': 'medium',
      },
    );

    return BreadUserData(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      environment: environment,
      equipment: equipment,
      preferences: preferences,
    );
  }
}
