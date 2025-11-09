// lib/core/models/season.dart
// 계절 정보 모델

/// 계절 열거형
enum SeasonType {
  spring, // 봄 (3-5월)
  summer, // 여름 (6-8월)
  autumn, // 가을 (9-11월)
  winter, // 겨울 (12-2월)
}

/// 계절 정보 클래스
class Season {
  final String name;
  final SeasonType type;
  final int month;
  final double averageTemperature;
  final double averageHumidity;
  final Map<String, dynamic> characteristics;

  const Season({
    required this.name,
    required this.type,
    required this.month,
    required this.averageTemperature,
    required this.averageHumidity,
    this.characteristics = const {},
  });

  /// 열거형처럼 사용하기 위한 index
  int get index => type.index;

  /// 모든 Season 값들 (열거형처럼 사용)
  static List<Season> get values => [
        spring,
        summer,
        autumn,
        winter,
      ];

  /// 봄
  static Season get spring => Season.fromMonth(4);

  /// 여름
  static Season get summer => Season.fromMonth(7);

  /// 가을
  static Season get autumn => Season.fromMonth(10);

  /// 겨울
  static Season get winter => Season.fromMonth(1);

  /// 추천 빵 굽기 스타일
  List<String> get recommendedBakingStyles {
    switch (type) {
      case SeasonType.spring:
        return ['샌드위치 빵', '식빵', '롤빵'];
      case SeasonType.summer:
        return ['바게트', '크루아상', '냉장 발효 빵'];
      case SeasonType.autumn:
        return ['호밀빵', '곡물빵', '단호박 빵'];
      case SeasonType.winter:
        return ['치아바타', '포카치아', '난빵'];
    }
  }

  /// 온도 보정 값
  double get temperatureCorrection {
    switch (type) {
      case SeasonType.spring:
        return 0.0;
      case SeasonType.summer:
        return -2.0;
      case SeasonType.autumn:
        return 0.0;
      case SeasonType.winter:
        return 3.0;
    }
  }

  /// 발효 시간 보정 값 (분 단위)
  int get fermentationTimeCorrection {
    switch (type) {
      case SeasonType.spring:
        return -10;
      case SeasonType.summer:
        return -15;
      case SeasonType.autumn:
        return 0;
      case SeasonType.winter:
        return 20;
    }
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'] as String? ?? '',
      type: _parseSeasonType(json['type'] as String?),
      month: (json['month'] as num?)?.toInt() ?? 1,
      averageTemperature:
          (json['averageTemperature'] as num?)?.toDouble() ?? 20.0,
      averageHumidity: (json['averageHumidity'] as num?)?.toDouble() ?? 50.0,
      characteristics: Map<String, dynamic>.from(json['characteristics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'month': month,
      'averageTemperature': averageTemperature,
      'averageHumidity': averageHumidity,
      'characteristics': characteristics,
    };
  }

  static SeasonType _parseSeasonType(String? type) {
    if (type == null) return SeasonType.spring;

    switch (type.toLowerCase()) {
      case 'spring':
        return SeasonType.spring;
      case 'summer':
        return SeasonType.summer;
      case 'autumn':
        return SeasonType.autumn;
      case 'winter':
        return SeasonType.winter;
      default:
        return SeasonType.spring;
    }
  }

  /// 현재 날짜 기반 계절 생성
  factory Season.current() {
    final now = DateTime.now();
    return Season.fromMonth(now.month);
  }

  /// 월 번호로부터 계절 생성
  factory Season.fromMonth(int month) {
    SeasonType type;
    String name;
    double avgTemp;
    double avgHumidity;

    switch (month) {
      case 3:
      case 4:
      case 5:
        type = SeasonType.spring;
        name = '봄';
        avgTemp = 15.0;
        avgHumidity = 60.0;
        break;
      case 6:
      case 7:
      case 8:
        type = SeasonType.summer;
        name = '여름';
        avgTemp = 25.0;
        avgHumidity = 70.0;
        break;
      case 9:
      case 10:
      case 11:
        type = SeasonType.autumn;
        name = '가을';
        avgTemp = 15.0;
        avgHumidity = 65.0;
        break;
      case 12:
      case 1:
      case 2:
        type = SeasonType.winter;
        name = '겨울';
        avgTemp = 5.0;
        avgHumidity = 55.0;
        break;
      default:
        type = SeasonType.spring;
        name = '봄';
        avgTemp = 15.0;
        avgHumidity = 60.0;
    }

    return Season(
      name: name,
      type: type,
      month: month,
      averageTemperature: avgTemp,
      averageHumidity: avgHumidity,
    );
  }

  /// 계절에 따른 빵 굽기 특성
  Map<String, dynamic> get bakingCharacteristics {
    switch (type) {
      case SeasonType.spring:
        return {
          'humidityEffect': '높은 습도로 인해 발효 시간이 단축될 수 있음',
          'temperatureEffect': '적정 온도로 빵 굽기에 유리함',
          'recommendation': '발효 시간을 10-15분 단축 권장',
        };
      case SeasonType.summer:
        return {
          'humidityEffect': '높은 습도로 빵이 무거워질 수 있음',
          'temperatureEffect': '고온으로 발효가 빨라짐',
          'recommendation': '냉장 발효 또는 발효 시간 단축 권장',
        };
      case SeasonType.autumn:
        return {
          'humidityEffect': '적정 습도로 빵 질감이 좋아짐',
          'temperatureEffect': '적정 온도로 빵 굽기에 유리함',
          'recommendation': '표준 발효 시간 유지',
        };
      case SeasonType.winter:
        return {
          'humidityEffect': '낮은 습도로 빵이 건조해질 수 있음',
          'temperatureEffect': '저온으로 발효가 느려짐',
          'recommendation': '발효 시간 20-30분 연장 권장',
        };
    }
  }

  @override
  String toString() {
    return '$name ($month월)';
  }
}
