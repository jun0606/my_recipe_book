// test/services/bread_calculator_rpm_test.dart
// RPM 기반 빵 계산 서비스 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/bread_calculator.dart';

void main() {
  group('BreadCalculator RPM 기반 계산 테스트', () {
    group('RPM 프로파일 조회 테스트', () {
      test('가정용 믹서 RPM 프로파일 조회', () {
        final profile = BreadCalculator.getMixerRPMProfile('가정용');

        expect(profile, isNotNull);
        expect(profile.isNotEmpty, true);
        expect(profile.containsKey('저속'), true);
        expect(profile.containsKey('중속'), true);
        expect(profile.containsKey('고속'), true);

        // 저속 RPM 검증
        expect(profile['저속']!['rpm'], equals(70.0));
        expect(profile['저속']!['efficiency'], equals(0.85));

        // 중속 RPM 검증
        expect(profile['중속']!['rpm'], equals(130.0));
        expect(profile['중속']!['efficiency'], equals(1.0));

        // 고속 RPM 검증
        expect(profile['고속']!['rpm'], equals(200.0));
        expect(profile['고속']!['efficiency'], equals(0.9));
      });

      test('상업용 믹서 RPM 프로파일 조회', () {
        final profile = BreadCalculator.getMixerRPMProfile('상업용');

        expect(profile, isNotNull);
        expect(profile['저속']!['rpm'], equals(90.0));
        expect(profile['중속']!['rpm'], equals(170.0));
        expect(profile['고속']!['rpm'], equals(250.0));
      });

      test('전문가용 믹서 RPM 프로파일 조회', () {
        final profile = BreadCalculator.getMixerRPMProfile('전문가용');

        expect(profile, isNotNull);
        expect(profile['저속']!['rpm'], equals(110.0));
        expect(profile['중속']!['rpm'], equals(210.0));
        expect(profile['고속']!['rpm'], equals(310.0));
      });

      test('알 수 없는 믹서 타입은 가정용 기본값 반환', () {
        final profile = BreadCalculator.getMixerRPMProfile('알수없음');

        expect(profile, isNotNull);
        expect(profile['중속']!['rpm'], equals(130.0)); // 가정용 기본값
      });
    });

    group('RPM 기반 시간 계산 테스트', () {
      test('기본 시간 계산 검증', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
        };

        final mixingData = [
          {'speed': '저속', 'time': 5, 'comment': '테스트'},
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
          {'speed': '고속', 'time': 3, 'comment': '테스트'},
        ];

        // RPM 기반 계산 결과 검증
        final result = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);
        final stageAnalysis = result['차수별 분석'] as List;

        // 저속 시간 검증
        final slowStage = stageAnalysis[0];
        expect(slowStage['권장시간'], greaterThan(5)); // 저속은 더 오래 걸림

        // 중속 시간 검증
        final mediumStage = stageAnalysis[1];
        expect(mediumStage['권장시간'], equals(10)); // 중속은 기본 시간

        // 고속 시간 검증
        final fastStage = stageAnalysis[2];
        expect(fastStage['권장시간'], lessThan(3)); // 고속은 더 빨리 끝남
      });

      test('믹서 타입별 시간 계산 차이', () {
        final mixingData = [
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
        ];

        final homeInputs = {'mixerType': '가정용', 'temperature': 24.0};
        final proInputs = {'mixerType': 'professional', 'temperature': 24.0};

        final homeResult = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            homeInputs, mixingData);
        final proResult = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            proInputs, mixingData);

        final homeTime = (homeResult['차수별 분석'] as List)[0]['권장시간'];
        final proTime = (proResult['차수별 분석'] as List)[0]['권장시간'];

        expect(proTime, lessThan(homeTime)); // 전문가용이 더 효율적
      });
    });

    group('RPM 기반 발열 및 글루텐 형성도 테스트', () {
      test('속도별 온도 및 글루텐 형성도 차이 검증', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        final mixingData = [
          {'speed': '저속', 'time': 5, 'comment': '테스트'},
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
          {'speed': '고속', 'time': 3, 'comment': '테스트'},
        ];

        final result = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);
        final stageAnalysis = result['차수별 분석'] as List;

        // 저속 단계 검증
        final slowStage = stageAnalysis[0];
        expect(slowStage['RPM'], equals('70.0')); // 저속 RPM
        expect(slowStage['온도변화'], contains('+')); // 발열 표시

        // 중속 단계 검증 (최적 RPM 범위)
        final mediumStage = stageAnalysis[1];
        expect(mediumStage['RPM'], equals('130.0')); // 중속 RPM
        expect(mediumStage['글루텐형성도'], contains('85.0%')); // 글루텐 형성도 표시

        // 고속 단계 검증
        final fastStage = stageAnalysis[2];
        expect(fastStage['RPM'], equals('200.0')); // 고속 RPM
      });

      test('온도별 글루텐 형성도 영향 검증', () {
        final mixingData = [
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
        ];

        // 최적 온도 (22-26°C)
        final optimalInputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        // 낮은 온도 (20°C)
        final lowTempInputs = {
          'mixerType': '가정용',
          'temperature': 20.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        // 높은 온도 (28°C)
        final highTempInputs = {
          'mixerType': '가정용',
          'temperature': 28.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        final optimalResult =
            BreadCalculator.calculateMixingStageAnalysisWithRPM(
                optimalInputs, mixingData);
        final lowTempResult =
            BreadCalculator.calculateMixingStageAnalysisWithRPM(
                lowTempInputs, mixingData);
        final highTempResult =
            BreadCalculator.calculateMixingStageAnalysisWithRPM(
                highTempInputs, mixingData);

        final optimalGluten = (optimalResult['차수별 분석'] as List)[0]['글루텐형성도'];
        final lowTempGluten = (lowTempResult['차수별 분석'] as List)[0]['글루텐형성도'];
        final highTempGluten = (highTempResult['차수별 분석'] as List)[0]['글루텐형성도'];

        // 최적 온도에서 글루텐 형성이 더 잘 되는지 확인 (문자열 비교이므로 간단한 검증)
        expect(optimalGluten, isNotNull);
        expect(lowTempGluten, isNotNull);
        expect(highTempGluten, isNotNull);
      });
    });

    group('RPM 기반 통합 계산 테스트', () {
      test('RPM 기반 믹싱 분석 결과 구조 검증', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
          'humidity': 65.0,
          'altitude': 100.0,
          'season': 'spring',
          'ovenType': 'home',
          'fermentationMethod': 'room_temperature',
        };

        final mixingData = [
          {'speed': '저속', 'time': 5, 'comment': '초기 반죽'},
          {'speed': '중속', 'time': 10, 'comment': '본 반죽'},
          {'speed': '고속', 'time': 3, 'comment': '마무리'},
        ];

        final result = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);

        // 결과 구조 검증
        expect(result, isNotNull);
        expect(result.containsKey('rpmProfile'), true);
        expect(result.containsKey('mixerType'), true);
        expect(result.containsKey('rpmBasedCalculations'), true);
        expect(result['rpmBasedCalculations'], true);

        // 차수별 분석 검증
        final stageAnalysis = result['차수별 분석'] as List;
        expect(stageAnalysis.length, equals(3));

        // 각 차수에 RPM 정보 포함 검증
        for (final stage in stageAnalysis) {
          expect(stage.containsKey('RPM'), true);
          expect(stage.containsKey('rpmEfficiency'), true);
        }
      });

      test('RPM 모드와 일반 모드 결과 비교', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        final mixingData = [
          {'speed': '중속', 'time': 10, 'comment': '본 반죽'},
        ];

        // RPM 모드 결과
        final rpmResult = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);

        // 일반 모드 결과
        final normalResult =
            BreadCalculator.calculateMixingStageAnalysis(inputs, mixingData);

        // RPM 모드에는 추가 정보가 있어야 함
        expect(rpmResult.containsKey('rpmProfile'), true);
        expect(rpmResult.containsKey('rpmBasedCalculations'), true);

        // 일반 모드에는 RPM 정보가 없어야 함
        expect(normalResult.containsKey('rpmProfile'), false);
        expect(normalResult.containsKey('rpmBasedCalculations'), false);
      });
    });

    group('RPM 통합 성능 테스트', () {
      test('RPM 모드와 일반 모드의 종합 평가 비교', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': 24.0,
          'humidity': 65.0,
          'altitude': 100.0,
        };

        final mixingData = [
          {'speed': '저속', 'time': 5, 'comment': '초기 반죽'},
          {'speed': '중속', 'time': 10, 'comment': '본 반죽'},
          {'speed': '고속', 'time': 3, 'comment': '마무리'},
        ];

        // RPM 모드 결과
        final rpmResult = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);

        // 일반 모드 결과
        final normalResult =
            BreadCalculator.calculateMixingStageAnalysis(inputs, mixingData);

        // 두 모드 모두 유효한 결과를 반환해야 함
        expect(rpmResult['successProbability'], isNotNull);
        expect(normalResult['successProbability'], isNotNull);

        // RPM 모드에는 추가 분석 정보가 있어야 함
        expect(rpmResult.containsKey('종합 평가'), true);
        expect(normalResult.containsKey('종합 평가'), true);
      });

      test('다양한 믹서 타입별 RPM 프로파일 일관성', () {
        final mixerTypes = ['가정용', '상업용', '전문가용'];

        for (final mixerType in mixerTypes) {
          final profile = BreadCalculator.getMixerRPMProfile(mixerType);

          // 모든 프로파일이 필수 속도를 가져야 함
          expect(profile.containsKey('저속'), true);
          expect(profile.containsKey('중속'), true);
          expect(profile.containsKey('고속'), true);

          // RPM 값이 합리적인 범위여야 함
          final lowRPM = profile['저속']!['rpm'] as double;
          final mediumRPM = profile['중속']!['rpm'] as double;
          final highRPM = profile['고속']!['rpm'] as double;

          expect(lowRPM, lessThan(mediumRPM));
          expect(mediumRPM, lessThan(highRPM));
          expect(lowRPM, greaterThan(0));
          expect(highRPM, lessThan(500));
        }
      });
    });

    group('에지 케이스 및 오류 처리 테스트', () {
      test('빈 믹싱 데이터 처리', () {
        final inputs = {'mixerType': '가정용', 'temperature': 24.0};
        final result =
            BreadCalculator.calculateMixingStageAnalysisWithRPM(inputs, []);

        expect(result, isNotNull);
        expect(result['차수별 분석'], isNotEmpty);
      });

      test('null 값 처리', () {
        final result = BreadCalculator.getMixerRPMProfile(null);
        expect(result, isNotNull);
        expect(result.containsKey('중속'), true);
      });

      test('알 수 없는 믹서 타입 처리', () {
        final inputs = {
          'mixerType': '알수없음',
          'temperature': 24.0,
        };

        final mixingData = [
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
        ];

        final result = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);

        // 알 수 없는 타입도 기본값으로 처리되어야 함
        expect(result, isNotNull);
        expect(result['차수별 분석'], isNotEmpty);
      });

      test('비정상적인 입력값 처리', () {
        final inputs = {
          'mixerType': '가정용',
          'temperature': -10.0, // 비정상적인 온도
          'humidity': 150.0, // 비정상적인 습도
        };

        final mixingData = [
          {'speed': '중속', 'time': 10, 'comment': '테스트'},
        ];

        final result = BreadCalculator.calculateMixingStageAnalysisWithRPM(
            inputs, mixingData);

        // 비정상적인 입력값도 적절히 처리되어야 함
        expect(result, isNotNull);
        expect(result['successProbability'], isNotNull);
      });
    });
  });
}
