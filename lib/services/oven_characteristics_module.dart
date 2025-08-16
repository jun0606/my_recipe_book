// 오븐 특성 보정 모듈

import '../models/sous_chef_models.dart';

abstract class AdjustmentModule {
  String get name;
  List<BakingType> get supportedTypes;
  
  Map<String, double> calculate(Map<String, dynamic> inputs);
  List<String> getExplanations(Map<String, dynamic> inputs);
}

class OvenCharacteristicsModule extends AdjustmentModule {
  @override
  String get name => '오븐 특성 보정';
  @override
  List<BakingType> get supportedTypes => [BakingType.bread, BakingType.cake, BakingType.cookie];
  
  @override
  Map<String, double> calculate(Map<String, dynamic> inputs) {
    final ovenType = inputs['ovenType'] ?? 'convection';
    final recipeTemp = inputs['recipeTemperature'] ?? 180.0;
    final recipeTime = inputs['recipeTime'] ?? 30.0;
    final topHeat = inputs['topHeat'] as double?;
    final bottomHeat = inputs['bottomHeat'] as double?;
    final useFan = inputs['useFan'] ?? true;
    final fanSpeed = inputs['fanSpeed'] ?? 'medium';
    final steamAmount = inputs['steamAmount'] ?? 'none';
    final combiMode = inputs['combiMode'] ?? 'dry';
    
    Map<String, double> adjustments = {};
    
    // 열 제어 방식에 따른 보정
    final heatControlAdjustments = _calculateHeatControlAdjustments(
      topHeat, bottomHeat, recipeTemp, ovenType);
    adjustments.addAll(heatControlAdjustments);
    
    // 오븐 타입별 기본 보정값
    final typeAdjustments = _calculateOvenTypeAdjustments(
      ovenType, useFan, fanSpeed, steamAmount, combiMode);
    adjustments.addAll(typeAdjustments);
    
    // 레시피 특성에 따른 추가 보정
    final recipeAdjustments = _calculateRecipeAdjustments(recipeTemp, recipeTime);
    adjustments.addAll(recipeAdjustments);

    return adjustments;
  }

  Map<String, double> _calculateHeatControlAdjustments(
    double? topHeat, double? bottomHeat, double recipeTemp, String ovenType) {
    
    final adjustments = <String, double>{};
    
    if (topHeat != null && bottomHeat != null) {
      // 상하 모든 열 사용 - 균등한 굽기
      final avgTemp = (topHeat + bottomHeat) / 2;
      final tempDiff = (topHeat - bottomHeat).abs();
      
      if (tempDiff > 20.0) {
        // 온도 차이가 클 때
        if (topHeat > bottomHeat) {
          adjustments['topBrowning'] = 15.0; // 상단 브라우닝 증가
        } else {
          adjustments['bottomCrisping'] = 15.0; // 하단 바삭함 증가
        }
      }
      
      // 평균 온도와 레시피 온도 차이 보정
      final tempAdjustment = avgTemp - recipeTemp;
      if (tempAdjustment.abs() > 5.0) {
        adjustments['temperature'] = tempAdjustment * 0.8;
      }
      
    } else if (topHeat != null && bottomHeat == null) {
      // 상단열만 사용 - 브라우닝 중심
      adjustments['time'] = 3.0; // 시간 연장 필요
      
      final tempAdjustment = topHeat - recipeTemp;
      if (tempAdjustment.abs() > 5.0) {
        adjustments['temperature'] = tempAdjustment * 0.6;
      }
      
    } else if (topHeat == null && bottomHeat != null) {
      // 하단열만 사용 - 바닥 굽기 중심
      adjustments['time'] = 2.0; // 시간 약간 연장
      
      final tempAdjustment = bottomHeat - recipeTemp;
      if (tempAdjustment.abs() > 5.0) {
        adjustments['temperature'] = tempAdjustment * 0.6;
      }
    }
    
    return adjustments;
  }

  Map<String, double> _calculateOvenTypeAdjustments(
    String ovenType, bool useFan, String fanSpeed, String steamAmount, String combiMode) {
    
    Map<String, double> adjustments = {};
    
    switch (ovenType) {
      case 'convection':
        if (useFan) {
          // 팬 속도에 따른 보정
          final fanAdjustment = switch (fanSpeed) {
            'low' => -10.0,
            'medium' => -15.0,
            'high' => -20.0,
            _ => -15.0,
          };
          adjustments['temperature'] = fanAdjustment;
          adjustments['time'] = -2.0;
        } else {
          // 팬 사용 안함 - 일반 전기 오븐과 유사
          adjustments['temperature'] = 0.0;
          adjustments['time'] = 1.0;
        }
        break;
        
      case 'deck':
        adjustments['temperature'] = 5.0;
        adjustments['time'] = 3.0;
        break;
        
      case 'steam':
        final steamAdjustment = switch (steamAmount) {
          'none' => -5.0,
          'low' => -10.0,
          'medium' => -15.0,
          'high' => -20.0,
          _ => -10.0,
        };
        adjustments['temperature'] = steamAdjustment;
        adjustments['time'] = 5.0;
        break;
        
      case 'gas':
        if (useFan) {
          // 가스 컨벡션 오븐
          adjustments['temperature'] = 5.0;  // 직화 + 팬으로 효율적
          adjustments['time'] = -2.0;
        } else {
          // 일반 가스 오븐
          adjustments['temperature'] = 10.0; // 직화로 인한 높은 온도
          adjustments['time'] = -1.0;
        }
        break;
        
      case 'electricHome':
        if (useFan) {
          // 가정용 컨벡션 오븐
          adjustments['temperature'] = -12.0; // 컨벡션 효과
          adjustments['time'] = -1.0;
        } else {
          // 일반 가정용 전기 오븐
          adjustments['temperature'] = 0.0;
          adjustments['time'] = 2.0;
        }
        break;
        
      case 'combi':
        final modeAdjustment = switch (combiMode) {
          'dry' => {'temperature': -5.0, 'time': 0.0},
          'steam' => {'temperature': -15.0, 'time': 3.0},
          'combi' => {'temperature': -10.0, 'time': 1.0},
          _ => {'temperature': -8.0, 'time': 1.0},
        };
        adjustments.addAll(modeAdjustment.cast<String, double>());
        break;
    }
    
    return adjustments;
  }

  Map<String, double> _calculateRecipeAdjustments(double recipeTemp, double recipeTime) {
    final adjustments = <String, double>{};
    
    // 레시피 온도 범위별 보정
    if (recipeTemp > 220.0) {
      // 매우 높은 온도 (220°C 이상) - 피자, 바게트 등
      final highTempFactor = (recipeTemp - 220.0) / 30.0;
      adjustments['temperature'] = -highTempFactor * 8.0; // 더 큰 보정
      adjustments['time'] = highTempFactor * 2.0; // 시간 약간 증가
    } else if (recipeTemp > 200.0) {
      // 높은 온도 (200-220°C) - 식빵, 쿠키 등
      final highTempFactor = (recipeTemp - 200.0) / 20.0;
      adjustments['temperature'] = -highTempFactor * 5.0;
      adjustments['time'] = highTempFactor * 1.0;
    } else if (recipeTemp < 160.0) {
      // 낮은 온도 (160°C 미만) - 머랭, 저온 건조 등
      final lowTempFactor = (160.0 - recipeTemp) / 20.0;
      adjustments['temperature'] = lowTempFactor * 3.0; // 온도 약간 높임
      adjustments['time'] = -lowTempFactor * 2.0; // 시간 약간 단축
    }

    // 레시피 시간 범위별 보정
    if (recipeTime > 60.0) {
      // 긴 시간 (60분 이상) - 케이크, 로스팅 등
      final longTimeFactor = (recipeTime - 60.0) / 30.0;
      adjustments['temperature'] = (adjustments['temperature'] ?? 0.0) + (longTimeFactor * 2.0);
      // 긴 시간일수록 온도를 약간 높여서 효율성 증대
    } else if (recipeTime < 15.0) {
      // 짧은 시간 (15분 미만) - 쿠키, 토스트 등
      final shortTimeFactor = (15.0 - recipeTime) / 10.0;
      adjustments['temperature'] = (adjustments['temperature'] ?? 0.0) + (shortTimeFactor * 5.0);
      // 짧은 시간일수록 온도를 높여서 빠른 굽기
    }
    
    // 온도-시간 조합별 특별 보정
    if (recipeTemp > 200.0 && recipeTime < 20.0) {
      // 고온 단시간 (쿠키, 피자 등)
      adjustments['temperature'] = (adjustments['temperature'] ?? 0.0) - 3.0;
      // 과도한 갈변 방지
    } else if (recipeTemp < 180.0 && recipeTime > 45.0) {
      // 저온 장시간 (케이크, 브레드 등)
      adjustments['temperature'] = (adjustments['temperature'] ?? 0.0) + 2.0;
      // 충분한 익힘 보장
    }
    
    return adjustments;
  }

  @override
  List<String> getExplanations(Map<String, dynamic> inputs) {
    final ovenType = inputs['ovenType'] ?? 'convection';
    final topHeat = inputs['topHeat'] as double?;
    final bottomHeat = inputs['bottomHeat'] as double?;
    final useFan = inputs['useFan'] ?? true;
    final fanSpeed = inputs['fanSpeed'] ?? 'medium';
    final steamAmount = inputs['steamAmount'] ?? 'none';
    final combiMode = inputs['combiMode'] ?? 'dry';
    final recipeTemp = inputs['recipeTemperature'] as double? ?? 180.0;
    final recipeTime = inputs['recipeTime'] as double? ?? 30.0;
    final explanations = <String>[];
    
    // 레시피 특성 기반 설명 추가 (최우선)
    _addRecipeBasedExplanations(explanations, recipeTemp, recipeTime);
    
    // 열 제어 방식 설명
    if (topHeat != null && bottomHeat != null) {
      final tempDiff = (topHeat - bottomHeat).abs();
      if (tempDiff > 20.0) {
        if (topHeat > bottomHeat) {
          explanations.add('상단열이 높아 표면 브라우닝이 강화됩니다.');
        } else {
          explanations.add('하단열이 높아 바닥이 바삭해집니다.');
        }
      } else {
        explanations.add('상하 균등한 열 분포로 고른 굽기가 가능합니다.');
      }
    } else if (topHeat != null && bottomHeat == null) {
      explanations.add('상단열만 사용하여 표면 브라우닝에 집중합니다.');
    } else if (topHeat == null && bottomHeat != null) {
      explanations.add('하단열만 사용하여 바닥 굽기에 집중합니다.');
    } else {
      explanations.add('열 설정이 필요합니다. 상단열 또는 하단열을 설정해주세요.');
    }
    
    // 오븐 타입별 설명
    switch (ovenType) {
      case 'convection':
        if (useFan) {
          explanations.add('컨벡션 오븐: 팬으로 균등한 열 순환, 온도와 시간 단축');
        } else {
          explanations.add('컨벡션 오븐 (팬 사용 안함): 일반 전기 오븐과 유사한 굽기');
        }
        break;
      case 'deck':
        explanations.add('데크 오븐: 복사열로 인한 강한 바닥 굽기');
        break;
      case 'steam':
        explanations.add('스팀 오븐: 수분 공급으로 크러스트 형성');
        break;
      case 'gas':
        if (useFan) {
          explanations.add('가스 컨벡션 오븐: 직화와 팬의 조합으로 효율적인 굽기');
        } else {
          explanations.add('가스 오븐: 직화로 인한 빠른 가열과 높은 온도');
        }
        break;
      case 'electricHome':
        if (useFan) {
          explanations.add('가정용 컨벡션 오븐: 팬으로 균등한 열분포와 효율적인 굽기');
        } else {
          explanations.add('가정용 전기 오븐: 안정적인 온도 유지, 예열 시간 고려');
        }
        break;
      case 'combi':
        explanations.add('콤비 오븐: 다양한 조리 모드 지원');
        break;
    }

    // 팬 속도별 추가 설명
    if (useFan && ovenType == 'convection') {
      switch (fanSpeed) {
        case 'low':
          explanations.add('낮은 팬 속도: 부드러운 열 순환으로 섬세한 굽기');
          break;
        case 'medium':
          explanations.add('중간 팬 속도: 균형잡힌 열 순환으로 일반적인 굽기');
          break;
        case 'high':
          explanations.add('높은 팬 속도: 강한 열 순환으로 빠른 굽기');
          break;
      }
    }

    // 스팀 양별 추가 설명
    if (ovenType == 'steam' && steamAmount != 'none') {
      switch (steamAmount) {
        case 'low':
          explanations.add('적은 스팀: 가벼운 수분 공급으로 부드러운 크러스트');
          break;
        case 'medium':
          explanations.add('중간 스팀: 적절한 수분 공급으로 균형잡힌 크러스트');
          break;
        case 'high':
          explanations.add('많은 스팀: 충분한 수분 공급으로 두꺼운 크러스트');
          break;
      }
    }

    return explanations;
  }

  /// 레시피 특성 기반 설명 추가
  void _addRecipeBasedExplanations(List<String> explanations, double recipeTemp, double recipeTime) {
    // 레시피 타입 자동 인식 및 설명
    final recipeType = _identifyRecipeType(recipeTemp, recipeTime);
    explanations.add('📋 레시피 분석: $recipeType');
    
    // 온도 범위별 상세 설명
    if (recipeTemp > 220.0) {
      explanations.add('🔥 매우 높은 온도(${recipeTemp.toInt()}°C): 빠른 갈변과 바삭한 식감을 위한 설정');
      explanations.add('   • 피자, 바게트, 나폴리탄 피자 등에 적합');
      explanations.add('   • 과도한 갈변 방지를 위해 온도를 약간 낮춤');
      explanations.add('   • 시간을 약간 늘려 내부까지 충분히 익힘');
    } else if (recipeTemp > 200.0) {
      explanations.add('🔥 높은 온도(${recipeTemp.toInt()}°C): 식빵, 쿠키 등에 적합한 온도');
      explanations.add('   • 표면 갈변과 내부 익힘의 균형 유지');
      explanations.add('   • 바삭한 식감과 골든 브라운 색상 구현');
    } else if (recipeTemp < 160.0) {
      explanations.add('🌡️ 낮은 온도(${recipeTemp.toInt()}°C): 부드러운 굽기를 위한 저온 설정');
      explanations.add('   • 머랭, 저온 건조, 디하이드레이션 등에 적합');
      explanations.add('   • 충분한 익힘을 위해 온도를 약간 높임');
      explanations.add('   • 수분 증발을 촉진하여 시간 단축');
    } else {
      explanations.add('🌡️ 적정 온도(${recipeTemp.toInt()}°C): 대부분의 베이킹에 적합한 온도');
      explanations.add('   • 케이크, 머핀, 일반 빵류에 최적화');
    }

    // 시간 범위별 상세 설명
    if (recipeTime > 60.0) {
      explanations.add('⏰ 긴 굽기 시간(${recipeTime.toInt()}분): 케이크, 로스팅 등 장시간 굽기');
      explanations.add('   • 내부까지 완전히 익히는 것이 중요한 레시피');
      explanations.add('   • 효율성을 위해 온도를 약간 높여 시간 단축 효과');
      explanations.add('   • 수분 손실 방지를 위한 주의 필요');
    } else if (recipeTime < 15.0) {
      explanations.add('⏰ 짧은 굽기 시간(${recipeTime.toInt()}분): 쿠키, 토스트 등 빠른 굽기');
      explanations.add('   • 빠른 열 전달이 중요한 레시피');
      explanations.add('   • 빠른 익힘을 위해 온도를 높여 효율성 증대');
      explanations.add('   • 과굽기 방지를 위한 세심한 관찰 필요');
    } else {
      explanations.add('⏰ 적정 굽기 시간(${recipeTime.toInt()}분): 일반적인 베이킹 시간');
      explanations.add('   • 표준적인 베이킹 프로세스에 적합');
    }

    // 온도-시간 조합별 특별 설명 및 팁
    if (recipeTemp > 200.0 && recipeTime < 20.0) {
      explanations.add('⚡ 고온 단시간 굽기: 쿠키, 피자 등에 최적화');
      explanations.add('   • 과도한 갈변 방지를 위한 온도 조정 적용');
      explanations.add('   • 💡 팁: 굽기 마지막 2-3분은 오븐 문을 열어 확인');
    } else if (recipeTemp < 180.0 && recipeTime > 45.0) {
      explanations.add('🕐 저온 장시간 굽기: 케이크, 브레드 등에 최적화');
      explanations.add('   • 충분한 익힘을 위한 온도 보정 적용');
      explanations.add('   • 💡 팁: 중간에 호일로 덮어 과도한 갈변 방지');
    } else if (recipeTemp > 180.0 && recipeTime > 30.0) {
      explanations.add('🔄 중온 중시간 굽기: 균형잡힌 베이킹');
      explanations.add('   • 💡 팁: 굽기 중간에 한 번 회전시켜 균등한 굽기');
    }

    // 레시피별 추가 조언
    _addRecipeSpecificTips(explanations, recipeTemp, recipeTime);
  }

  /// 레시피 타입 자동 인식
  String _identifyRecipeType(double temp, double time) {
    if (temp > 220.0 && time < 15.0) {
      return '피자/바게트 타입 (고온 단시간)';
    } else if (temp > 200.0 && time < 20.0) {
      return '쿠키/비스킷 타입 (고온 단시간)';
    } else if (temp < 160.0 && time > 60.0) {
      return '머랭/건조 타입 (저온 장시간)';
    } else if (temp < 180.0 && time > 45.0) {
      return '케이크/브레드 타입 (저온 장시간)';
    } else if (temp > 180.0 && time > 30.0 && time < 60.0) {
      return '일반 베이킹 타입 (중온 중시간)';
    } else if (time < 10.0) {
      return '토스트/그릴 타입 (초단시간)';
    } else {
      return '표준 베이킹 타입';
    }
  }

  /// 레시피별 구체적인 팁 제공
  void _addRecipeSpecificTips(List<String> explanations, double temp, double time) {
    if (temp > 220.0) {
      explanations.add('🔥 고온 베이킹 팁:');
      explanations.add('   • 오븐을 충분히 예열 (최소 20분)');
      explanations.add('   • 베이킹 스톤 사용 시 더욱 효과적');
      explanations.add('   • 수증기 분사로 크러스트 개선 가능');
    } else if (temp < 160.0) {
      explanations.add('🌡️ 저온 베이킹 팁:');
      explanations.add('   • 오븐 문을 자주 열지 말 것');
      explanations.add('   • 컨벡션 기능 활용으로 균등한 건조');
      explanations.add('   • 습도 조절이 중요함');
    }

    if (time > 60.0) {
      explanations.add('⏰ 장시간 베이킹 팁:');
      explanations.add('   • 중간에 위치 변경으로 균등한 굽기');
      explanations.add('   • 표면 갈변 방지용 호일 준비');
      explanations.add('   • 내부 온도계로 완성도 확인');
    } else if (time < 15.0) {
      explanations.add('⚡ 단시간 베이킹 팁:');
      explanations.add('   • 타이머 설정으로 과굽기 방지');
      explanations.add('   • 마지막 2-3분은 육안으로 확인');
      explanations.add('   • 예열 완료 후 즉시 투입');
    }
  }
}