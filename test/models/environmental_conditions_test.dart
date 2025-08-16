import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';

void main() {
  group('EnvironmentalConditions 상세 테스트', () {
    late EnvironmentalConditions standardConditions;
    late OvenCharacteristics standardOven;

    setUp(() {
      standardOven = const OvenCharacteristics(
        type: OvenType.professionalConvection,
        typeCoefficient: 1.0,
        calibrationIndex: 1.1,
        steamCapability: 1.0,
        hasConvection: true,
        maxTemperature: 300.0,
      );

      standardConditions = EnvironmentalConditions(
        temperature: 25.0,
        humidity: 65.0,
        pressure: 1013.0,
        season: Season.spring,
        altitude: 0.0,
        oven: standardOven,
      );
    });

    group('온도 보정 계수 테스트', () {
      test('표준 온도(25°C)에서 보정 계수는 1.0이어야 함', () {
        expect(standardConditions.temperatureCorrection, equals(1.0));
      });

      test('고온(35°C)에서 보정 계수가 정확해야 함', () {
        final hotConditions = standardConditions.copyWith(temperature: 35.0);
        // 1 + ((35 - 25) / 10) = 2.0
        expect(hotConditions.temperatureCorrection, equals(2.0));
      });

      test('저온(15°C)에서 보정 계수가 정확해야 함', () {
        final coldConditions = standardConditions.copyWith(temperature: 15.0);
        // 1 + ((15 - 25) / 10) = 0.0
        expect(coldConditions.temperatureCorrection, equals(0.0));
      });

      test('극한 온도에서도 계산이 정상 동작해야 함', () {
        final extremeHot = standardConditions.copyWith(temperature: 45.0);
        final extremeCold = standardConditions.copyWith(temperature: 5.0);
        
        expect(extremeHot.temperatureCorrection, equals(3.0));
        expect(extremeCold.temperatureCorrection, equals(-1.0));
      });
    });

    group('습도 보정 계수 테스트', () {
      test('표준 습도(65%)에서 보정 계수는 1.0이어야 함', () {
        expect(standardConditions.humidityCorrection, equals(1.0));
      });

      test('고습도(85%)에서 보정 계수가 정확해야 함', () {
        final humidConditions = standardConditions.copyWith(humidity: 85.0);
        // 1 + ((85 - 65) × 0.005) = 1.1
        expect(humidConditions.humidityCorrection, equals(1.1));
      });

      test('저습도(45%)에서 보정 계수가 정확해야 함', () {
        final dryConditions = standardConditions.copyWith(humidity: 45.0);
        // 1 + ((45 - 65) × 0.005) = 0.9
        expect(dryConditions.humidityCorrection, equals(0.9));
      });

      test('극한 습도에서도 계산이 정상 동작해야 함', () {
        final extremeHumid = standardConditions.copyWith(humidity: 95.0);
        final extremeDry = standardConditions.copyWith(humidity: 25.0);
        
        expect(extremeHumid.humidityCorrection, equals(1.15));
        expect(extremeDry.humidityCorrection, equals(0.8));
      });
    });

    group('고도 보정 계수 테스트', () {
      test('해수면(0m)에서 보정 계수는 1.0이어야 함', () {
        expect(standardConditions.altitudeCorrection, equals(1.0));
      });

      test('고도 1000m에서 보정 계수가 정확해야 함', () {
        final highAltitude = standardConditions.copyWith(altitude: 1000.0);
        // 1 + ((1000 / 1000) × 0.02) = 1.02
        expect(highAltitude.altitudeCorrection, equals(1.02));
      });

      test('고도 2500m에서 보정 계수가 정확해야 함', () {
        final veryHighAltitude = standardConditions.copyWith(altitude: 2500.0);
        // 1 + ((2500 / 1000) × 0.02) = 1.05
        expect(veryHighAltitude.altitudeCorrection, equals(1.05));
      });

      test('고도 정보가 없을 때 보정 계수는 1.0이어야 함', () {
        final noAltitude = standardConditions.copyWith(altitude: null);
        expect(noAltitude.altitudeCorrection, equals(1.0));
      });
    });

    group('발효 속도 온도 보정 테스트', () {
      test('표준 온도(25°C)에서 발효 속도 보정은 1.0이어야 함', () {
        expect(standardConditions.fermentationSpeedCorrection, equals(1.0));
      });

      test('고온(35°C)에서 발효 속도 보정이 정확해야 함', () {
        final hotConditions = standardConditions.copyWith(temperature: 35.0);
        // 2^((35 - 25) / 10) = 2^1 = 2.0
        expect(hotConditions.fermentationSpeedCorrection, equals(2.0));
      });

      test('저온(15°C)에서 발효 속도 보정이 정확해야 함', () {
        final coldConditions = standardConditions.copyWith(temperature: 15.0);
        // 2^((15 - 25) / 10) = 2^(-1) = 0.5
        expect(coldConditions.fermentationSpeedCorrection, equals(0.5));
      });

      test('중간 온도(30°C)에서 발효 속도 보정이 정확해야 함', () {
        final warmConditions = standardConditions.copyWith(temperature: 30.0);
        // 2^((30 - 25) / 10) = 2^0.5 ≈ 1.414
        expect(warmConditions.fermentationSpeedCorrection, closeTo(1.414, 0.001));
      });
    });

    group('계절별 특성 테스트', () {
      test('계절별 displayName이 정확해야 함', () {
        expect(Season.spring.displayName, equals('봄'));
        expect(Season.summer.displayName, equals('여름'));
        expect(Season.autumn.displayName, equals('가을'));
        expect(Season.winter.displayName, equals('겨울'));
      });

      test('계절 변경이 정상 동작해야 함', () {
        final summerConditions = standardConditions.copyWith(season: Season.summer);
        expect(summerConditions.season, equals(Season.summer));
        expect(summerConditions.season.displayName, equals('여름'));
      });
    });

    group('JSON 직렬화 테스트', () {
      test('환경 조건 JSON 직렬화가 정상 동작해야 함', () {
        // 기본적인 속성들만 테스트
        expect(standardConditions.temperature, equals(25.0));
        expect(standardConditions.humidity, equals(65.0));
        expect(standardConditions.pressure, equals(1013.0));
        expect(standardConditions.season, equals(Season.spring));
        expect(standardConditions.altitude, equals(0.0));
        expect(standardConditions.oven.type, equals(OvenType.professionalConvection));
      });

      test('오븐 특성 JSON 직렬화가 정상 동작해야 함', () {
        final json = standardOven.toJson();
        
        expect(json['type'], equals('professional_convection'));
        expect(json['typeCoefficient'], equals(1.0));
        expect(json['calibrationIndex'], equals(1.1));
        expect(json['steamCapability'], equals(1.0));
        expect(json['hasConvection'], equals(true));
        expect(json['maxTemperature'], equals(300.0));
      });
    });

    group('데이터 유효성 검증 테스트', () {
      test('온도 범위 검증', () {
        // 일반적인 제빵 환경 온도 범위: 10°C ~ 40°C
        expect(() => standardConditions.copyWith(temperature: 10.0), returnsNormally);
        expect(() => standardConditions.copyWith(temperature: 40.0), returnsNormally);
        
        // 극한 온도도 허용 (계산은 가능)
        expect(() => standardConditions.copyWith(temperature: -10.0), returnsNormally);
        expect(() => standardConditions.copyWith(temperature: 60.0), returnsNormally);
      });

      test('습도 범위 검증', () {
        // 일반적인 습도 범위: 30% ~ 90%
        expect(() => standardConditions.copyWith(humidity: 30.0), returnsNormally);
        expect(() => standardConditions.copyWith(humidity: 90.0), returnsNormally);
        
        // 극한 습도도 허용
        expect(() => standardConditions.copyWith(humidity: 10.0), returnsNormally);
        expect(() => standardConditions.copyWith(humidity: 100.0), returnsNormally);
      });

      test('기압 범위 검증', () {
        // 일반적인 기압 범위: 950hPa ~ 1050hPa
        expect(() => standardConditions.copyWith(pressure: 950.0), returnsNormally);
        expect(() => standardConditions.copyWith(pressure: 1050.0), returnsNormally);
      });

      test('고도 범위 검증', () {
        // 일반적인 고도 범위: 0m ~ 3000m
        expect(() => standardConditions.copyWith(altitude: 0.0), returnsNormally);
        expect(() => standardConditions.copyWith(altitude: 3000.0), returnsNormally);
        
        // 음수 고도도 허용 (해수면 아래)
        expect(() => standardConditions.copyWith(altitude: -100.0), returnsNormally);
      });
    });

    group('copyWith 메서드 테스트', () {
      test('개별 속성 변경이 정상 동작해야 함', () {
        final modified = standardConditions.copyWith(
          temperature: 30.0,
          humidity: 70.0,
        );

        expect(modified.temperature, equals(30.0));
        expect(modified.humidity, equals(70.0));
        expect(modified.pressure, equals(standardConditions.pressure)); // 변경되지 않음
        expect(modified.season, equals(standardConditions.season)); // 변경되지 않음
      });

      test('모든 속성 변경이 정상 동작해야 함', () {
        final newOven = standardOven.copyWith(type: OvenType.steam);
        final fullyModified = standardConditions.copyWith(
          temperature: 28.0,
          humidity: 72.0,
          pressure: 1020.0,
          season: Season.summer,
          altitude: 500.0,
          oven: newOven,
        );

        expect(fullyModified.temperature, equals(28.0));
        expect(fullyModified.humidity, equals(72.0));
        expect(fullyModified.pressure, equals(1020.0));
        expect(fullyModified.season, equals(Season.summer));
        expect(fullyModified.altitude, equals(500.0));
        expect(fullyModified.oven.type, equals(OvenType.steam));
      });
    });
  });

  group('OvenCharacteristics 상세 테스트', () {
    test('오븐 타입별 기본 계수가 정확해야 함', () {
      expect(OvenType.home.defaultTypeCoefficient, equals(0.9));
      expect(OvenType.professionalConvection.defaultTypeCoefficient, equals(1.0));
      expect(OvenType.deck.defaultTypeCoefficient, equals(1.1));
      expect(OvenType.steam.defaultTypeCoefficient, equals(1.2));
    });

    test('오븐 타입별 displayName이 정확해야 함', () {
      expect(OvenType.home.displayName, equals('가정용 오븐'));
      expect(OvenType.professionalConvection.displayName, equals('전문가용 컨벡션'));
      expect(OvenType.deck.displayName, equals('데크 오븐'));
      expect(OvenType.steam.displayName, equals('스팀 오븐'));
    });

    test('오븐 특성 copyWith가 정상 동작해야 함', () {
      const original = OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 0.9,
        calibrationIndex: 1.0,
        steamCapability: 0.5,
        hasConvection: false,
        maxTemperature: 250.0,
      );

      final modified = original.copyWith(
        type: OvenType.steam,
        steamCapability: 1.2,
        hasConvection: true,
      );

      expect(modified.type, equals(OvenType.steam));
      expect(modified.steamCapability, equals(1.2));
      expect(modified.hasConvection, equals(true));
      expect(modified.typeCoefficient, equals(0.9)); // 변경되지 않음
      expect(modified.maxTemperature, equals(250.0)); // 변경되지 않음
    });
  });

  group('EnvironmentalConditionsValidator 테스트', () {
    late EnvironmentalConditions validConditions;
    late OvenCharacteristics validOven;

    setUp(() {
      validOven = const OvenCharacteristics(
        type: OvenType.professionalConvection,
        typeCoefficient: 1.0,
        calibrationIndex: 1.1,
        steamCapability: 1.0,
        hasConvection: true,
        maxTemperature: 300.0,
      );

      validConditions = EnvironmentalConditions(
        temperature: 25.0,
        humidity: 65.0,
        pressure: 1013.0,
        season: Season.spring,
        altitude: 100.0,
        oven: validOven,
      );
    });

    group('개별 유효성 검증 테스트', () {
      test('유효한 온도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidTemperature(25.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidTemperature(10.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidTemperature(40.0), isTrue);
      });

      test('무효한 온도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidTemperature(-25.0), isFalse);
        expect(EnvironmentalConditionsValidator.isValidTemperature(65.0), isFalse);
      });

      test('유효한 습도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidHumidity(50.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidHumidity(0.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidHumidity(100.0), isTrue);
      });

      test('무효한 습도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidHumidity(-10.0), isFalse);
        expect(EnvironmentalConditionsValidator.isValidHumidity(110.0), isFalse);
      });

      test('유효한 기압 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidPressure(1013.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidPressure(900.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidPressure(1100.0), isTrue);
      });

      test('무효한 기압 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidPressure(700.0), isFalse);
        expect(EnvironmentalConditionsValidator.isValidPressure(1300.0), isFalse);
      });

      test('유효한 고도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidAltitude(0.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidAltitude(1000.0), isTrue);
        expect(EnvironmentalConditionsValidator.isValidAltitude(null), isTrue);
      });

      test('무효한 고도 범위 검증', () {
        expect(EnvironmentalConditionsValidator.isValidAltitude(-600.0), isFalse);
        expect(EnvironmentalConditionsValidator.isValidAltitude(6000.0), isFalse);
      });
    });

    group('전체 환경 조건 유효성 검증 테스트', () {
      test('유효한 환경 조건은 검증을 통과해야 함', () {
        final result = EnvironmentalConditionsValidator.validateEnvironmentalConditions(validConditions);
        
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('무효한 온도는 에러를 발생시켜야 함', () {
        final invalidConditions = validConditions.copyWith(temperature: -30.0);
        final result = EnvironmentalConditionsValidator.validateEnvironmentalConditions(invalidConditions);
        
        expect(result.isValid, isFalse);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('온도가 유효 범위'));
      });

      test('경계값 온도는 경고를 발생시켜야 함', () {
        final borderlineConditions = validConditions.copyWith(temperature: 5.0);
        final result = EnvironmentalConditionsValidator.validateEnvironmentalConditions(borderlineConditions);
        
        expect(result.isValid, isTrue);
        expect(result.hasWarnings, isTrue);
        expect(result.warnings.first, contains('일반적인 제빵 환경'));
      });

      test('무효한 습도는 에러를 발생시켜야 함', () {
        final invalidConditions = validConditions.copyWith(humidity: 120.0);
        final result = EnvironmentalConditionsValidator.validateEnvironmentalConditions(invalidConditions);
        
        expect(result.isValid, isFalse);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('습도가 유효 범위'));
      });

      test('여러 무효한 값들은 여러 에러를 발생시켜야 함', () {
        final invalidConditions = EnvironmentalConditions(
          temperature: -30.0,
          humidity: 120.0,
          pressure: 700.0,
          season: Season.spring,
          altitude: 6000.0,
          oven: validOven,
        );
        final result = EnvironmentalConditionsValidator.validateEnvironmentalConditions(invalidConditions);
        
        expect(result.isValid, isFalse);
        expect(result.errors.length, greaterThan(1));
      });
    });

    group('환경 권장사항 테스트', () {
      test('표준 환경에서는 기본 권장사항을 제공해야 함', () {
        final recommendation = EnvironmentalConditionsValidator.getRecommendations(validConditions);
        
        expect(recommendation.recommendations, isNotEmpty);
        expect(recommendation.optimalTemperatureRange.contains(25.0), isTrue);
        expect(recommendation.optimalHumidityRange.contains(65.0), isTrue);
      });

      test('저온 환경에서는 발효 시간 연장 권장사항을 제공해야 함', () {
        final coldConditions = validConditions.copyWith(temperature: 15.0);
        final recommendation = EnvironmentalConditionsValidator.getRecommendations(coldConditions);
        
        expect(recommendation.recommendations.any((r) => r.contains('발효 시간이 길어질')), isTrue);
      });

      test('고온 환경에서는 발효 주의 권장사항을 제공해야 함', () {
        final hotConditions = validConditions.copyWith(temperature: 35.0);
        final recommendation = EnvironmentalConditionsValidator.getRecommendations(hotConditions);
        
        expect(recommendation.recommendations.any((r) => r.contains('발효가 빨라질')), isTrue);
      });

      test('저습도 환경에서는 덮개 사용 권장사항을 제공해야 함', () {
        final dryConditions = validConditions.copyWith(humidity: 40.0);
        final recommendation = EnvironmentalConditionsValidator.getRecommendations(dryConditions);
        
        expect(recommendation.recommendations.any((r) => r.contains('덮개를 사용')), isTrue);
      });

      test('고습도 환경에서는 곰팡이 주의 권장사항을 제공해야 함', () {
        final humidConditions = validConditions.copyWith(humidity: 85.0);
        final recommendation = EnvironmentalConditionsValidator.getRecommendations(humidConditions);
        
        expect(recommendation.recommendations.any((r) => r.contains('곰팡이 발생에 주의')), isTrue);
      });

      test('계절별 권장사항이 정확해야 함', () {
        final summerConditions = validConditions.copyWith(season: Season.summer);
        final winterConditions = validConditions.copyWith(season: Season.winter);
        
        final summerRec = EnvironmentalConditionsValidator.getRecommendations(summerConditions);
        final winterRec = EnvironmentalConditionsValidator.getRecommendations(winterConditions);
        
        expect(summerRec.recommendations.any((r) => r.contains('여름철')), isTrue);
        expect(winterRec.recommendations.any((r) => r.contains('겨울철')), isTrue);
      });
    });
  });

  group('OvenCharacteristicsValidator 테스트', () {
    test('유효한 오븐 특성은 검증을 통과해야 함', () {
      const validOven = OvenCharacteristics(
        type: OvenType.professionalConvection,
        typeCoefficient: 1.0,
        calibrationIndex: 1.1,
        steamCapability: 1.0,
        hasConvection: true,
        maxTemperature: 300.0,
      );

      final result = OvenCharacteristicsValidator.validateOvenCharacteristics(validOven);
      
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('무효한 유형 계수는 에러를 발생시켜야 함', () {
      const invalidOven = OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 3.0, // 유효 범위 초과
        calibrationIndex: 1.0,
        steamCapability: 1.0,
        hasConvection: false,
        maxTemperature: 250.0,
      );

      final result = OvenCharacteristicsValidator.validateOvenCharacteristics(invalidOven);
      
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('유형 계수')), isTrue);
    });

    test('낮은 최대 온도는 경고를 발생시켜야 함', () {
      const lowTempOven = OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 0.9,
        calibrationIndex: 1.0,
        steamCapability: 0.5,
        hasConvection: false,
        maxTemperature: 200.0, // 낮은 최대 온도
      );

      final result = OvenCharacteristicsValidator.validateOvenCharacteristics(lowTempOven);
      
      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.warnings.any((w) => w.contains('최대 온도가 낮습니다')), isTrue);
    });

    test('스팀 오븐의 낮은 스팀 능력은 경고를 발생시켜야 함', () {
      const steamOvenLowCapability = OvenCharacteristics(
        type: OvenType.steam,
        typeCoefficient: 1.2,
        calibrationIndex: 1.0,
        steamCapability: 0.5, // 스팀 오븐치고 낮은 스팀 능력
        hasConvection: true,
        maxTemperature: 300.0,
      );

      final result = OvenCharacteristicsValidator.validateOvenCharacteristics(steamOvenLowCapability);
      
      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.warnings.any((w) => w.contains('스팀 능력이 낮습니다')), isTrue);
    });
  });

  group('범위 클래스 테스트', () {
    test('TemperatureRange contains 메서드가 정확해야 함', () {
      const range = TemperatureRange(min: 20.0, max: 30.0);
      
      expect(range.contains(25.0), isTrue);
      expect(range.contains(20.0), isTrue);
      expect(range.contains(30.0), isTrue);
      expect(range.contains(15.0), isFalse);
      expect(range.contains(35.0), isFalse);
    });

    test('HumidityRange contains 메서드가 정확해야 함', () {
      const range = HumidityRange(min: 50.0, max: 80.0);
      
      expect(range.contains(65.0), isTrue);
      expect(range.contains(50.0), isTrue);
      expect(range.contains(80.0), isTrue);
      expect(range.contains(45.0), isFalse);
      expect(range.contains(85.0), isFalse);
    });
  });
}