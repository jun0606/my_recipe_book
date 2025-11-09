import 'package:hive/hive.dart';

/// 오븐 타입
@HiveType(typeId: 9)
enum OvenType {
  @HiveField(0)
  home,
  @HiveField(1)
  professionalConvection,
  @HiveField(2)
  deck,
  @HiveField(3)
  steam,
  @HiveField(4)
  conventional, // 일반 오븐
  @HiveField(5)
  convection, // 컨벡션 오븐
  @HiveField(6)
  combi, // 콤비 오븐
}

extension OvenTypeExtension on OvenType {
  String get displayName {
    switch (this) {
      case OvenType.home:
        return '가정용 오븐';
      case OvenType.professionalConvection:
        return '전문가용 컨벡션';
      case OvenType.deck:
        return '데크 오븐';
      case OvenType.steam:
        return '스팀 오븐';
      case OvenType.conventional:
        return '일반 오븐';
      case OvenType.convection:
        return '컨벡션 오븐';
      case OvenType.combi:
        return '콤비 오븐';
    }
  }

  /// 기본 유형 계수
  double get defaultTypeCoefficient {
    switch (this) {
      case OvenType.home:
        return 0.9;
      case OvenType.professionalConvection:
        return 1.0;
      case OvenType.deck:
        return 1.1;
      case OvenType.steam:
        return 1.2;
      case OvenType.conventional:
        return 0.95;
      case OvenType.convection:
        return 1.05;
      case OvenType.combi:
        return 1.15;
    }
  }
}

/// OvenType 헬퍼 클래스
class OvenTypeHelper {
  /// 문자열에서 OvenType 변환
  static OvenType fromString(String value) {
    switch (value) {
      case 'home':
        return OvenType.home;
      case 'professional_convection':
        return OvenType.professionalConvection;
      case 'deck':
        return OvenType.deck;
      case 'steam':
        return OvenType.steam;
      case 'conventional':
        return OvenType.conventional;
      case 'convection':
        return OvenType.convection;
      case 'combi':
        return OvenType.combi;
      default:
        return OvenType.convection;
    }
  }
}
