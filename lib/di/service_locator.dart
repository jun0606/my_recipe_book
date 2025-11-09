import 'package:my_recipe_book/services/user_settings_service.dart';

/// 전역 서비스 로케이터 인스턴스
final getIt = ServiceLocator.instance;

/// 서비스 로케이터
///
/// 애플리케이션 전체에서 사용되는 서비스 인스턴스를 관리합니다.
class ServiceLocator {
  // 싱글톤 인스턴스
  static final ServiceLocator _instance = ServiceLocator._internal();

  // 팩토리 생성자
  factory ServiceLocator() => _instance;

  // 인스턴스 getter
  static ServiceLocator get instance => _instance;

  // 내부 생성자
  ServiceLocator._internal();

  // 서비스 인스턴스 맵
  final Map<Type, dynamic> _services = {};

  /// 서비스 등록
  ///
  /// [T] 서비스 타입
  /// [instance] 서비스 인스턴스
  void register<T>(T instance) {
    _services[T] = instance;
  }

  /// 서비스 가져오기
  ///
  /// [T] 서비스 타입
  ///
  /// 반환값: 서비스 인스턴스
  T get<T>() {
    final instance = _services[T];
    if (instance == null) {
      throw Exception('서비스 $T가 등록되지 않았습니다.');
    }
    return instance as T;
  }

  /// 서비스 등록 여부 확인
  ///
  /// [T] 서비스 타입
  ///
  /// 반환값: 등록 여부
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// 서비스 초기화
  ///
  /// 애플리케이션 시작 시 호출되어야 합니다.
  void init() {
    // UserSettingsService 등록
    register<UserSettingsService>(UserSettingsService());

    // 임시로 다른 서비스 등록 제거 - 기본 앱 실행을 위해
    // TODO: 나중에 통합 리포지토리 패턴 재구현 시 복원
  }

  /// 서비스 초기화 여부
  bool _initialized = false;

  /// 서비스 초기화 여부 확인
  bool get isInitialized => _initialized;

  /// 서비스 초기화 (한 번만 실행)
  void initOnce() {
    if (!_initialized) {
      init();
      _initialized = true;
    }
  }

  /// 서비스 리셋 (주로 테스트용)
  void reset() {
    _services.clear();
    _initialized = false;
  }
}
