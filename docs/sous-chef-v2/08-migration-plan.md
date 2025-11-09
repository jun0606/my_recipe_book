# 08. 마이그레이션 계획

## 📋 개요

기존 수쉐프 모드에서 수쉐프 모드 v2.0으로의 마이그레이션 계획을 수립합니다. 레거시 코드를 완전히 새로운 아키텍처로 전환하는 체계적인 접근 방식을 제시합니다.

## 📊 현재 상태 분석

### 1. 기존 수쉐프 모드 문제점

#### 기술적 문제점:
```dart
// 현재 상태:
- 200+ 개의 빌드 오류
- 타입 시스템 불일치
- 인터페이스 일관성 부족
- Null safety 미준수
- 이벤트 기반 아키텍처 부재
- 코드 중복 심각
- 테스트 부족
- 성능 모니터링 부재
```

#### 구조적 문제점:
```dart
// 기존 구조:
lib/modules/bread/           // 빵 모듈
├── services/               // 서비스들
├── models/                 // 모델들
├── core/                   // 코어 로직
└── *.dart                  // 기타 파일들

// 문제점:
- 모듈 간 결합도 높음
- 인터페이스 표준화 부족
- 확장성 제한적
- 유지보수 어려움
```

### 2. 목표 상태

#### 새로운 수쉐프 모드 v2.0:
```dart
// 목표 상태:
lib/
├── types/                  // 통합 타입 시스템
│   ├── recipe_types.dart
│   ├── analysis_types.dart
│   └── event_types.dart
├── communication/          // 통신 시스템
│   ├── event_bus.dart
│   ├── protocols/
│   └── adapters/
├── modules/               // 플러그인 모듈들
│   ├── base_module.dart
│   ├── bread/
│   ├── cake/
│   └── ...
├── ui/                     // UI 컴포넌트
│   ├── dynamic_components/
│   └── themes/
└── utils/                  // 유틸리티
    ├── converters/
    ├── validators/
    └── extractors/
```

## 🚀 마이그레이션 전략

### 1. 병렬 개발 전략

#### Phase 1: 코어 시스템 구축 (1-2주)
```dart
// 기존 시스템 유지하면서 새로운 시스템 구축
1. 통합 타입 시스템 설계 및 구현
2. 이벤트 기반 통신 시스템 구축
3. 모듈 인터페이스 및 관리자 구현
4. UI 컴포넌트 시스템 구축
```

#### Phase 2: 모듈별 전환 (2-4주)
```dart
// 모듈 단위로 점진적 전환
1. 빵 모듈 전환 (첫 번째 모듈)
2. 케이크 모듈 전환
3. 쿠키 모듈 전환
4. 디저트 모듈 전환
```

#### Phase 3: 통합 및 안정화 (1-2주)
```dart
// 최종 통합 및 기존 시스템 제거
1. 메인 앱 연동
2. 성능 최적화
3. 기존 시스템 제거
4. 최종 테스트 및 배포
```

### 2. 마이그레이션 접근 방식

#### A. 빅뱅 접근 (권장하지 않음)
```dart
// 단점:
- 높은 위험성
- 긴 다운타임
- 복잡한 롤백
- 사용자 영향 큼
```

#### B. 점진적 전환 (권장)
```dart
// 장점:
- 위험 분산
- 지속적 배포 가능
- 쉬운 롤백
- 사용자 영향 최소화
```

#### C. 하이브리드 접근 (채택)
```dart
// 전략:
- 코어 시스템을 먼저 구축
- 모듈별로 점진적 전환
- 기존 시스템과 병렬 운영
- 최종 단계에서 기존 시스템 제거
```

## 📋 상세 마이그레이션 계획

### Phase 1: 코어 시스템 구축

#### Week 1: 기초 설계 및 구현
```dart
[Day 1-2] 통합 타입 시스템 설계
- UnifiedRecipe, UnifiedIngredient 등 코어 타입 정의
- 변환기 및 검증기 구현
- 타입 안전성 보장

[Day 3-4] 이벤트 기반 통신 시스템
- SousChefEventBus 구현
- 이벤트 타입 및 데이터 클래스 정의
- 에러 처리 및 재시도 메커니즘

[Day 5] 모듈 인터페이스 및 관리자
- SousChefModule 인터페이스 정의
- ModuleManager 구현
- 모듈 생명주기 관리
```

#### Week 2: UI 및 통합 시스템
```dart
[Day 1-2] 동적 UI 컴포넌트 시스템
- DynamicAnalysisTab 구현
- 모듈별 UI 설정 시스템
- 테마 및 스타일링

[Day 3-4] 레시피 연동 시스템
- RecipeAdapter 구현
- ModuleDataExtractor 구현
- 실시간 동기화 프로토콜

[Day 5] 테스트 및 문서화
- 코어 시스템 테스트
- 문서 작성 및 검토
- 성능 벤치마크
```

### Phase 2: 모듈별 전환

#### 빵 모듈 전환 (Week 1-2)
```dart
[Day 1-3] 빵 모듈 설계 및 구현
- BreadModule 인터페이스 구현
- 빵 분석 로직 재설계
- UI 컴포넌트 구현

[Day 4-5] 통합 및 테스트
- 기존 빵 모듈과 병렬 테스트
- 데이터 일관성 검증
- 성능 비교 테스트

[Day 6-7] 전환 및 안정화
- 프로덕션 환경 전환
- 모니터링 및 최적화
- 사용자 피드백 수집
```

#### 케이크 모듈 전환 (Week 3-4)
```dart
[Day 1-3] 케이크 모듈 설계 및 구현
- CakeModule 인터페이스 구현
- 케이크 분석 로직 재설계
- UI 컴포넌트 구현

[Day 4-5] 통합 및 테스트
- 기존 케이크 모듈과 병렬 테스트
- 데이터 일관성 검증
- 사용자 경험 테스트

[Day 6-7] 전환 및 안정화
- 프로덕션 환경 전환
- 모니터링 및 최적화
```

#### 나머지 모듈 전환 (Week 5-6)
```dart
// 쿠키 및 디저트 모듈을 같은 방식으로 전환
- 각 모듈별 1주일씩 할당
- 동일한 프로세스 반복
- 모듈 간 상호작용 테스트
```

### Phase 3: 최종 통합 및 안정화

#### Week 1: 메인 앱 연동
```dart
[Day 1-2] 메인 앱 통합
- Recipe ↔ UnifiedRecipe 변환 시스템 통합
- 이벤트 버스 메인 앱 연결
- UI 네비게이션 통합

[Day 3-4] 데이터 마이그레이션
- 기존 사용자 데이터 마이그레이션
- 설정 및 환경설정 이전
- 호환성 테스트

[Day 5] 보안 및 권한 설정
- 모듈별 권한 설정
- 데이터 접근 제어
- 에러 처리 강화
```

#### Week 2: 성능 최적화 및 테스트
```dart
[Day 1-2] 성능 최적화
- 메모리 사용량 최적화
- 분석 속도 개선
- UI 렌더링 최적화

[Day 3-4] 종합 테스트
- 모든 모듈 통합 테스트
- 부하 테스트
- 사용자 시나리오 테스트

[Day 5] 최종 배포 준비
- 롤백 계획 수립
- 모니터링 시스템 구축
- 배포 체크리스트 작성
```

## 🔄 롤백 계획

### 1. 각 단계별 롤백 포인트

#### Phase 1 롤백 (코어 시스템)
```dart
// 롤백 절차:
1. 새로운 코어 시스템 비활성화
2. 기존 이벤트 시스템 복원
3. 임시 타입 변환기 제거
4. 메인 앱 원래 상태로 복원
```

#### Phase 2 롤백 (모듈별)
```dart
// 모듈별 롤백:
1. 새로운 모듈 비활성화
2. 기존 모듈 재활성화
3. 데이터 일관성 복원
4. 사용자 세션 복원
```

#### Phase 3 롤백 (최종 통합)
```dart
// 최종 롤백:
1. 새로운 수쉐프 모드 비활성화
2. 기존 수쉐프 모드 복원
3. 모든 마이그레이션 데이터 롤백
4. 사용자에게 공지
```

### 2. 데이터 백업 및 복구

#### 백업 전략:
```dart
// 정기적 백업:
- 매일 자정 전체 데이터 백업
- 모듈 전환 전 스냅샷 백업
- 사용자 세션 및 설정 백업

// 백업 저장소:
- 로컬 파일 시스템
- 클라우드 스토리지
- git 태그를 통한 코드 백업
```

#### 복구 절차:
```dart
// 데이터 복구:
1. 백업 데이터 검증
2. 점진적 데이터 복원
3. 무결성 검증
4. 사용자 영향 최소화
```

## 🧪 테스트 전략

### 1. 단위 테스트

#### 각 컴포넌트별 테스트:
```dart
// 필수 테스트 케이스:
- 타입 변환기 테스트
- 이벤트 시스템 테스트
- 모듈 인터페이스 테스트
- UI 컴포넌트 테스트
- 데이터 추출기 테스트
```

### 2. 통합 테스트

#### 모듈 통합 테스트:
```dart
// 통합 테스트 시나리오:
- 단일 모듈 분석 플로우
- 모듈 전환 시나리오
- 레시피 업데이트 동기화
- 에러 상황 처리
```

### 3. 종단간 테스트 (E2E)

#### 사용자 시나리오 테스트:
```dart
// E2E 테스트 케이스:
- 레시피 선택 → 모듈 선택 → 분석 실행
- 분석 결과 확인 → 조언 확인 → 개선 제안 확인
- 모듈 전환 → 다른 분석 실행
- 에러 상황 → 복구 → 재시도
```

### 4. 성능 테스트

#### 성능 벤치마크:
```dart
// 성능 테스트 항목:
- 분석 실행 시간 (< 30초)
- 메모리 사용량 (< 100MB)
- UI 렌더링 시간 (< 100ms)
- 이벤트 처리 시간 (< 10ms)
```

## 📊 타임라인 및 리소스

### 1. 타임라인

#### 총 기간: 8-10주
```
Week 1-2: 코어 시스템 구축
Week 3-6: 모듈별 전환 (빵, 케이크, 쿠키, 디저트)
Week 7-8: 메인 앱 연동 및 최종 통합
Week 9-10: 테스트 및 안정화
```

### 2. 리소스 요구사항

#### 개발 리소스:
```dart
// 개발 팀:
- 수석 개발자: 1명 (아키텍처 설계)
- 프론트엔드 개발자: 2명 (모듈 및 UI 개발)
- 백엔드 개발자: 1명 (통신 및 데이터)
- QA 엔지니어: 1명 (테스트 및 검증)

// 기술 스택:
- Flutter SDK: 최신 버전
- Dart: 2.19+
- 테스트 프레임워크: flutter_test
- CI/CD: GitHub Actions
```

#### 인프라 리소스:
```dart
// 개발 환경:
- 개발 서버: 2대
- 테스트 디바이스: Android/iOS
- 모니터링 도구: Firebase Crashlytics

// 저장소:
- 코드: GitHub
- 문서: GitHub Wiki
- 이슈: GitHub Issues
```

## 📈 모니터링 및 평가

### 1. 진행 상황 모니터링

#### 주간 보고:
```dart
// 매주 금요일 보고:
- 완료된 작업
- 진행 중인 작업
- 차단 요소
- 다음 주 계획
- 리스크 및 이슈
```

#### KPI 모니터링:
```dart
// 핵심 지표:
- 빌드 성공률 (> 95%)
- 테스트 커버리지 (> 80%)
- 평균 분석 시간 (< 30초)
- 사용자 만족도 (> 4.0/5.0)
```

### 2. 품질 게이트

#### 각 단계별 품질 기준:
```dart
// Phase 1:
- 모든 코어 타입이 Null Safety 준수
- 이벤트 시스템 100% 테스트 커버리지
- 문서 100% 완성

// Phase 2:
- 각 모듈별 90%+ 테스트 커버리지
- 모듈 간 호환성 검증 완료
- 사용자 피드백 양호

// Phase 3:
- 전체 시스템 통합 테스트 통과
- 성능 벤치마크 달성
- 보안 취약점 없음
```

## 🎯 결론

### 마이그레이션 성공을 위한 핵심 요소

✅ **철저한 계획** - 단계별 계획 및 롤백 전략
✅ **지속적 테스트** - 각 단계별 품질 검증
✅ **사용자 중심** - 사용자 경험 유지 및 개선
✅ **안전한 전환** - 데이터 백업 및 롤백 계획
✅ **모니터링 강화** - 실시간 모니터링 및 피드백

### 기대 효과

#### 단기적 효과:
- 레거시 코드 문제 해결
- 타입 시스템 통일
- 빌드 오류 제거
- 유지보수성 향상

#### 장기적 효과:
- 무한한 확장성 확보
- 새로운 모듈 빠른 추가
- 코드 품질 향상
- 사용자 경험 개선

### 최종 목표

**기존 수쉐프 모드의 모든 문제를 해결하면서도 훨씬 더 강력하고 확장 가능한 시스템을 구축하는 것**

이 마이그레이션 계획을 통해 안전하고 체계적으로 새로운 수쉐프 모드 v2.0으로 전환할 수 있습니다! 🚀

## 🔐 보안 마이그레이션

### 1. 보안 취약점 마이그레이션

#### 기존 시스템 보안 문제점:
```dart
// 기존 취약점들:
- 데이터 암호화 부재
- 사용자 권한 관리 부족
- SQL 인젝션 취약점
- 세션 관리 미흡
- 민감한 데이터 노출 위험
```

#### 마이그레이션 보안 강화:
```dart
// 새로운 보안 기능들:
- AES-256 암호화 적용
- 모듈별 권한 시스템 구축
- 입력 검증 및 SQL 인젝션 방지
- 사용자 세션 보안 강화
- 데이터 익명화 및 해싱 적용
```

### 2. 단계별 보안 적용

#### Phase 1: 코어 보안 구축
```dart
[Week 1 보안 작업]
- 데이터 암호화 시스템 구현
- 사용자 권한 관리 시스템 구축
- 입력 검증 시스템 구현
- 세션 보안 강화

[Week 2 보안 작업]
- SQL 인젝션 방지 적용
- 민감한 데이터 보호
- 보안 감사 로그 시스템
- 보안 테스트 케이스 작성
```

#### Phase 2: 모듈별 보안 적용
```dart
[모듈별 보안 적용]
- 각 모듈별 권한 설정
- 모듈 간 데이터 접근 제어
- 보안 취약점 스캔 및 수정
- 모듈별 보안 테스트
```

#### Phase 3: 최종 보안 검증
```dart
[보안 최종 검증]
- 전체 시스템 보안 취약점 스캔
- 침투 테스트 실시
- 보안 인증 획득
- 보안 모니터링 시스템 구축
```

## 📊 성능 모니터링 구축

### 1. 실시간 모니터링 시스템

#### Performance Monitoring Infrastructure
```dart
// lib/monitoring/performance_monitoring_system.dart
class PerformanceMonitoringSystem {
  final PerformanceCollector _collector;
  final MetricsAggregator _aggregator;
  final AlertManager _alertManager;
  final DashboardUpdater _dashboardUpdater;

  PerformanceMonitoringSystem({
    required PerformanceCollector collector,
    required MetricsAggregator aggregator,
    required AlertManager alertManager,
    required DashboardUpdater dashboardUpdater,
  }) : _collector = collector,
       _aggregator = aggregator,
       _alertManager = alertManager,
       _dashboardUpdater = dashboardUpdater;

  Future<void> startMonitoring() async {
    // 실시간 메트릭 수집 시작
    Timer.periodic(const Duration(seconds: 5), (_) async {
      await _collectAndProcessMetrics();
    });

    // 일일 리포트 생성
    Timer.periodic(const Duration(hours: 24), (_) async {
      await _generateDailyReport();
    });
  }

  Future<void> _collectAndProcessMetrics() async {
    try {
      // 메트릭 수집
      final metrics = await _collector.collectAllMetrics();

      // 메트릭 집계
      final aggregatedMetrics = await _aggregator.aggregate(metrics);

      // 임계값 검증 및 알림
      await _checkThresholdsAndAlert(aggregatedMetrics);

      // 대시보드 업데이트
      await _dashboardUpdater.update(aggregatedMetrics);

    } catch (e) {
      Logger.error('Performance monitoring error: $e');
    }
  }

  Future<void> _checkThresholdsAndAlert(Map<String, dynamic> metrics) async {
    final alerts = <Alert>[];

    // 응답 시간 임계값 검증
    if (metrics['averageResponseTime'] > const Duration(seconds: 5)) {
      alerts.add(Alert(
        type: AlertType.performance,
        severity: Severity.high,
        message: 'High response time detected: ${metrics['averageResponseTime']}',
        metric: 'response_time',
        value: metrics['averageResponseTime'],
        threshold: const Duration(seconds: 5),
      ));
    }

    // 메모리 사용량 검증
    if (metrics['memoryUsage'] > 100 * 1024 * 1024) {
      alerts.add(Alert(
        type: AlertType.resource,
        severity: Severity.critical,
        message: 'High memory usage: ${metrics['memoryUsage']}',
        metric: 'memory_usage',
        value: metrics['memoryUsage'],
        threshold: 100 * 1024 * 1024,
      ));
    }

    // 에러율 검증
    if (metrics['errorRate'] > 0.05) {
      alerts.add(Alert(
        type: AlertType.error,
        severity: Severity.medium,
        message: 'High error rate: ${metrics['errorRate']}',
        metric: 'error_rate',
        value: metrics['errorRate'],
        threshold: 0.05,
      ));
    }

    // 알림 발송
    for (final alert in alerts) {
      await _alertManager.sendAlert(alert);
    }
  }

  Future<void> _generateDailyReport() async {
    try {
      final reportData = await _aggregator.generateDailyReport();
      await _saveReport(reportData);
      await _sendReportEmail(reportData);
    } catch (e) {
      Logger.error('Daily report generation failed: $e');
    }
  }

  Future<void> _saveReport(Map<String, dynamic> reportData) async {
    // 로컬 파일로 리포트 저장
    final fileName = 'performance_report_${DateTime.now().toIso8601String().split('T')[0]}.json';
    await File(fileName).writeAsString(jsonEncode(reportData));
  }

  Future<void> _sendReportEmail(Map<String, dynamic> reportData) async {
    // 이메일로 리포트 발송 (구현 필요)
    Logger.info('Daily performance report generated');
  }
}

class Alert {
  final AlertType type;
  final Severity severity;
  final String message;
  final String metric;
  final dynamic value;
  final dynamic threshold;

  const Alert({
    required this.type,
    required this.severity,
    required this.message,
    required this.metric,
    required this.value,
    required this.threshold,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'metric': metric,
      'value': value,
      'threshold': threshold,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

enum AlertType {
  performance,
  resource,
  error,
  security,
}
```

### 2. 모니터링 대시보드

#### Real-time Dashboard
```dart
// lib/ui/performance_dashboard.dart
class PerformanceDashboard extends StatefulWidget {
  const PerformanceDashboard({Key? key}) : super(key: key);

  @override
  _PerformanceDashboardState createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  late StreamSubscription _metricsSubscription;
  Map<String, dynamic> _currentMetrics = {};

  @override
  void initState() {
    super.initState();
    _setupMetricsSubscription();
  }

  void _setupMetricsSubscription() {
    _metricsSubscription = SousChefEventBus().subscribe<Map<String, dynamic>>(
      'dashboard:update',
    ).listen((metrics) {
      if (mounted) {
        setState(() {
          _currentMetrics = metrics;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            _buildAlertsSection(),
            const SizedBox(height: 24),
            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Performance Overview',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString()}',
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          'Response Time',
          '${_currentMetrics['averageResponseTime'] ?? 0}ms',
          Icons.timer,
          Colors.green,
        ),
        _buildMetricCard(
          'Memory Usage',
          '${((_currentMetrics['memoryUsage'] ?? 0) / 1024 / 1024).toStringAsFixed(1)}MB',
          Icons.memory,
          Colors.blue,
        ),
        _buildMetricCard(
          'CPU Usage',
          '${(_currentMetrics['cpuUsage'] ?? 0).toStringAsFixed(1)}%',
          Icons.computer,
          Colors.orange,
        ),
        _buildMetricCard(
          'Error Rate',
          '${((_currentMetrics['errorRate'] ?? 0) * 100).toStringAsFixed(1)}%',
          Icons.error,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = _currentMetrics['alerts'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Alerts',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const Text('No active alerts')
            else
              ...alerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(dynamic alert) {
    final severity = alert['severity'] ?? 'low';
    final color = _getSeverityColor(severity);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert['message'] ?? '',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  Widget _buildChartsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Charts',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text('Chart implementation needed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _metricsSubscription.cancel();
    super.dispose();
  }
}
```

## 🚨 롤백 전략 강화

### 1. 자동화된 롤백 시스템

#### Automated Rollback System
```dart
// lib/rollback/automated_rollback_system.dart
class AutomatedRollbackSystem {
  final RollbackManager _rollbackManager;
  final HealthChecker _healthChecker;
  final NotificationService _notificationService;

  AutomatedRollbackSystem({
    required RollbackManager rollbackManager,
    required HealthChecker healthChecker,
    required NotificationService notificationService,
  }) : _rollbackManager = rollbackManager,
       _healthChecker = healthChecker,
       _notificationService = notificationService;

  Future<void> startAutomatedMonitoring() async {
    // 시스템 건강도 모니터링
    Timer.periodic(const Duration(minutes: 5), (_) async {
      await _checkSystemHealth();
    });
  }

  Future<void> _checkSystemHealth() async {
    try {
      final healthStatus = await _healthChecker.checkOverallHealth();

      if (!healthStatus.isHealthy) {
        Logger.warning('System health degraded: ${healthStatus.issues}');

        // 심각도에 따른 조치
        if (healthStatus.severity == HealthSeverity.critical) {
          await _initiateEmergencyRollback(healthStatus);
        } else if (healthStatus.severity == HealthSeverity.high) {
          await _initiateGradualRollback(healthStatus);
        } else {
          await _sendHealthAlert(healthStatus);
        }
      }

    } catch (e) {
      Logger.error('Health check failed: $e');
      // 건강도 체크 자체가 실패한 경우
      await _handleHealthCheckFailure();
    }
  }

  Future<void> _initiateEmergencyRollback(HealthStatus healthStatus) async {
    Logger.error('Emergency rollback initiated: ${healthStatus.issues}');

    // 긴급 알림 발송
    await _notificationService.sendEmergencyNotification(
      'Emergency Rollback Initiated',
      'System health critical: ${healthStatus.issues.join(', ')}'
    );

    // 즉시 롤백 실행
    await _rollbackManager.performEmergencyRollback();

    // 재시작 시도
    await _attemptSystemRestart();
  }

  Future<void> _initiateGradualRollback(HealthStatus healthStatus) async {
    Logger.warning('Gradual rollback initiated: ${healthStatus.issues}');

    // 점진적 롤백 알림
    await _notificationService.sendWarningNotification(
      'Gradual Rollback Initiated',
      'System health degraded: ${healthStatus.issues.join(', ')}'
    );

    // 점진적 롤백 실행
    await _rollbackManager.performGradualRollback();
  }

  Future<void> _sendHealthAlert(HealthStatus healthStatus) async {
    // 일반 건강도 알림
    await _notificationService.sendInfoNotification(
      'System Health Alert',
      'Minor issues detected: ${healthStatus.issues.join(', ')}'
    );
  }

  Future<void> _handleHealthCheckFailure() async {
    Logger.error('Health check system failed');

    // 건강도 체크 시스템 자체의 문제
    await _notificationService.sendEmergencyNotification(
      'Health Check System Failure',
      'Unable to monitor system health'
    );

    // 안전 모드로 전환
    await _rollbackManager.switchToSafeMode();
  }

  Future<void> _attemptSystemRestart() async {
    try {
      // 시스템 재시작 로직
      await Future.delayed(const Duration(seconds: 30)); // 쿨다운

      final restartResult = await _rollbackManager.restartSystem();

      if (restartResult.success) {
        Logger.info('System restart successful');
        await _notificationService.sendInfoNotification(
          'System Restart Successful',
          'System has been successfully restarted'
        );
      } else {
        Logger.error('System restart failed');
        await _notificationService.sendEmergencyNotification(
          'System Restart Failed',
          'Manual intervention required'
        );
      }

    } catch (e) {
      Logger.error('System restart attempt failed: $e');
    }
  }
}

class HealthStatus {
  final bool isHealthy;
  final HealthSeverity severity;
  final List<String> issues;
  final DateTime timestamp;

  const HealthStatus({
    required this.isHealthy,
    required this.severity,
    required this.issues,
    required this.timestamp,
  });
}

enum HealthSeverity {
  healthy,
  low,
  medium,
  high,
  critical,
}
```

### 2. 롤백 검증 시스템

#### Rollback Verification System
```dart
// lib/rollback/rollback_verification_system.dart
class RollbackVerificationSystem {
  final SystemVerifier _systemVerifier;
  final DataVerifier _dataVerifier;
  final PerformanceVerifier _performanceVerifier;

  RollbackVerificationSystem({
    required SystemVerifier systemVerifier,
    required DataVerifier dataVerifier,
    required PerformanceVerifier performanceVerifier,
  }) : _systemVerifier = systemVerifier,
       _dataVerifier = dataVerifier,
       _performanceVerifier = performanceVerifier;

  Future<RollbackVerificationResult> verifyRollback({
    required String rollbackId,
    required RollbackType rollbackType,
  }) async {
    try {
      Logger.info('Starting rollback verification for $rollbackId');

      // 1. 시스템 무결성 검증
      final systemCheck = await _systemVerifier.verifySystemIntegrity();

      // 2. 데이터 일관성 검증
      final dataCheck = await _dataVerifier.verifyDataConsistency();

      // 3. 성능 검증
      final performanceCheck = await _performanceVerifier.verifyPerformance();

      // 4. 종합 결과 생성
      final overallSuccess = systemCheck.success && dataCheck.success && performanceCheck.success;

      final result = RollbackVerificationResult(
        rollbackId: rollbackId,
        rollbackType: rollbackType,
        overallSuccess: overallSuccess,
        systemCheck: systemCheck,
        dataCheck: dataCheck,
        performanceCheck: performanceCheck,
        verificationTime: DateTime.now(),
      );

      // 5. 결과 보고
      await _reportVerificationResult(result);

      return result;

    } catch (e) {
      Logger.error('Rollback verification failed: $e');

      return RollbackVerificationResult(
        rollbackId: rollbackId,
        rollbackType: rollbackType,
        overallSuccess: false,
        error: e.toString(),
        verificationTime: DateTime.now(),
      );
    }
  }

  Future<void> _reportVerificationResult(RollbackVerificationResult result) async {
    final report = {
      'rollbackId': result.rollbackId,
      'rollbackType': result.rollbackType.name,
      'overallSuccess': result.overallSuccess,
      'systemCheck': result.systemCheck?.toMap(),
      'dataCheck': result.dataCheck?.toMap(),
      'performanceCheck': result.performanceCheck?.toMap(),
      'error': result.error,
      'verificationTime': result.verificationTime.toIso8601String(),
    };

    // 로그에 기록
    Logger.info('Rollback verification result: $report');

    // 이벤트 발행
    SousChefEventBus().publish('rollback:verification_complete', report);

    // 파일로 저장
    await _saveVerificationReport(result);
  }

  Future<void> _saveVerificationReport(RollbackVerificationResult result) async {
    try {
      final fileName = 'rollback_verification_${result.rollbackId}_${result.verificationTime.millisecondsSinceEpoch}.json';
      final reportJson = jsonEncode(result.toMap());

      await File(fileName).writeAsString(reportJson);
      Logger.info('Verification report saved: $fileName');

    } catch (e) {
      Logger.error('Failed to save verification report: $e');
    }
  }
}

class RollbackVerificationResult {
  final String rollbackId;
  final RollbackType rollbackType;
  final bool overallSuccess;
  final VerificationResult? systemCheck;
  final VerificationResult? dataCheck;
  final VerificationResult? performanceCheck;
  final String? error;
  final DateTime verificationTime;

  const RollbackVerificationResult({
    required this.rollbackId,
    required this.rollbackType,
    required this.overallSuccess,
    this.systemCheck,
    this.dataCheck,
    this.performanceCheck,
    this.error,
    required this.verificationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'rollbackId': rollbackId,
      'rollbackType': rollbackType.name,
      'overallSuccess': overallSuccess,
      'systemCheck': systemCheck?.toMap(),
      'dataCheck': dataCheck?.toMap(),
      'performanceCheck': performanceCheck?.toMap(),
      'error': error,
      'verificationTime': verificationTime.toIso8601String(),
    };
  }
}

class VerificationResult {
  final bool success;
  final List<String> issues;
  final Map<String, dynamic> details;

  const VerificationResult({
    required this.success,
    this.issues = const [],
    this.details = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'issues': issues,
      'details': details,
    };
  }
}

enum RollbackType {
  emergency,
  gradual,
  scheduled,
}
```

## 📈 품질 게이트 강화

### 1. 자동화된 품질 게이트

#### Automated Quality Gates
```dart
// lib/qa/automated_quality_gates.dart
class AutomatedQualityGates {
  final CodeQualityChecker _codeQualityChecker;
  final TestCoverageChecker _testCoverageChecker;
  final SecurityScanner _securityScanner;
  final PerformanceTester _performanceTester;

  AutomatedQualityGates({
    required CodeQualityChecker codeQualityChecker,
    required TestCoverageChecker testCoverageChecker,
    required SecurityScanner securityScanner,
    required PerformanceTester performanceTester,
  }) : _codeQualityChecker = codeQualityChecker,
       _testCoverageChecker = testCoverageChecker,
       _securityScanner = securityScanner,
       _performanceTester = performanceTester;

  Future<QualityGateResult> runAllGates({
    required String branch,
    required String commitHash,
  }) async {
    Logger.info('Running automated quality gates for $branch ($commitHash)');

    final results = await Future.wait([
      _runCodeQualityGate(),
      _runTestCoverageGate(),
      _runSecurityGate(),
      _runPerformanceGate(),
    ]);

    final overallSuccess = results.every((result) => result.success);

    final summary = QualityGateResult(
      branch: branch,
      commitHash: commitHash,
      overallSuccess: overallSuccess,
      codeQuality: results[0],
      testCoverage: results[1],
      security: results[2],
      performance: results[3],
      timestamp: DateTime.now(),
    );

    await _reportResults(summary);
    return summary;
  }

  Future<GateResult> _runCodeQualityGate() async {
    try {
      final qualityScore = await _codeQualityChecker.checkCodeQuality();

      final success = qualityScore >= 0.8; // 80% 이상
      final issues = success ? [] : ['Code quality score too low: $qualityScore'];

      return GateResult(
        name: 'Code Quality',
        success: success,
        score: qualityScore,
        issues: issues,
        details: {'qualityScore': qualityScore},
      );

    } catch (e) {
      return GateResult(
        name: 'Code Quality',
        success: false,
        issues: ['Code quality check failed: $e'],
        details: {'error': e.toString()},
      );
    }
  }

  Future<GateResult> _runTestCoverageGate() async {
    try {
      final coverage = await _testCoverageChecker.checkTestCoverage();

      final success = coverage >= 0.8; // 80% 이상
      final issues = success ? [] : ['Test coverage too low: ${(coverage * 100).toStringAsFixed(1)}%'];

      return GateResult(
        name: 'Test Coverage',
        success: success,
        score: coverage,
        issues: issues,
        details: {'coverage': coverage},
      );

    } catch (e) {
      return GateResult(
        name: 'Test Coverage',
        success: false,
        issues: ['Test coverage check failed: $e'],
        details: {'error': e.toString()},
      );
    }
  }

  Future<GateResult> _runSecurityGate() async {
    try {
      final vulnerabilities = await _securityScanner.scanForVulnerabilities();

      final success = vulnerabilities.isEmpty;
      final issues = vulnerabilities.map((v) => 'Security vulnerability: $v').toList();

      return GateResult(
        name: 'Security',
        success: success,
        issues: issues,
        details: {'vulnerabilities': vulnerabilities},
      );

    } catch (e) {
      return GateResult(
        name: 'Security',
        success: false,
        issues: ['Security scan failed: $e'],
        details: {'error': e.toString()},
      );
    }
  }

  Future<GateResult> _runPerformanceGate() async {
    try {
      final performanceMetrics = await _performanceTester.runPerformanceTests();

      final success = _checkPerformanceThresholds(performanceMetrics);
      final issues = success ? [] : ['Performance thresholds not met'];

      return GateResult(
        name: 'Performance',
        success: success,
        issues: issues,
        details: performanceMetrics,
      );

    } catch (e) {
      return GateResult(
        name: 'Performance',
        success: false,
        issues: ['Performance test failed: $e'],
        details: {'error': e.toString()},
      );
    }
  }

  bool _checkPerformanceThresholds(Map<String, dynamic> metrics) {
    const maxResponseTime = Duration(seconds: 5);
    const maxMemoryUsage = 100 * 1024 * 1024; // 100MB

    return metrics['averageResponseTime'] <= maxResponseTime.inMilliseconds &&
           metrics['memoryUsage'] <= maxMemoryUsage;
  }

  Future<void> _reportResults(QualityGateResult result) async {
    // CI/CD 시스템에 결과 보고
    Logger.info('Quality gates result: ${result.overallSuccess ? 'PASSED' : 'FAILED'}');

    // 이벤트 발행
    SousChefEventBus().publish('qa:quality_gates_complete', result.toMap());

    // 알림 발송
    if (!result.overallSuccess) {
      await _sendFailureNotification(result);
    }
  }

  Future<void> _sendFailureNotification(QualityGateResult result) async {
    final failedGates = [
      if (!result.codeQuality.success) 'Code Quality',
      if (!result.testCoverage.success) 'Test Coverage',
      if (!result.security.success) 'Security',
      if (!result.performance.success) 'Performance',
    ].join(', ');

    Logger.error('Quality gates failed: $failedGates');
  }
}

class QualityGateResult {
  final String branch;
  final String commitHash;
  final bool overallSuccess;
  final GateResult codeQuality;
  final GateResult testCoverage;
  final GateResult security;
  final GateResult performance;
  final DateTime timestamp;

  const QualityGateResult({
    required this.branch,
    required this.commitHash,
    required this.overallSuccess,
    required this.codeQuality,
    required this.testCoverage,
    required this.security,
    required this.performance,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'branch': branch,
      'commitHash': commitHash,
      'overallSuccess': overallSuccess,
      'codeQuality': codeQuality.toMap(),
      'testCoverage': testCoverage.toMap(),
      'security': security.toMap(),
      'performance': performance.toMap(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class GateResult {
  final String name;
  final bool success;
  final double? score;
  final List<String> issues;
  final Map<String, dynamic> details;

  const GateResult({
    required this.name,
    required this.success,
    this.score,
    this.issues = const [],
    this.details = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'success': success,
      'score': score,
      'issues': issues,
      'details': details,
    };
  }
}
```

### 2. 품질 게이트 통합

#### CI/CD Integration
```yaml
# .github/workflows/quality-gates.yml
name: Quality Gates

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  quality-gates:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'

    - name: Install dependencies
      run: flutter pub get

    - name: Run code quality check
      run: flutter analyze

    - name: Run tests with coverage
      run: flutter test --coverage

    - name: Check test coverage
      run: |
        if (( $(lcov --summary coverage/lcov.info | grep -E "lines\.\.\.\.\." | awk '{print $2}' | sed 's/%//') < 80 )); then
          echo "Test coverage too low"
          exit 1
        fi

    - name: Run security scan
      run: |
        # 보안 스캔 도구 실행
        dart run security_scanner

    - name: Run performance tests
      run: |
        # 성능 테스트 실행
        dart run performance_tester

    - name: Create quality report
      run: |
        # 품질 리포트 생성
        dart run quality_reporter

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v2
      with:
        file: ./coverage/lcov.info

    - name: Fail if quality gates failed
      run: |
        # 품질 게이트 실패 시 워크플로우 실패
        if [ -f quality_gate_failed ]; then
          echo "Quality gates failed"
          exit 1
        fi
```

이 마이그레이션 계획을 통해 안전하고 체계적으로 새로운 수쉐프 모드 v2.0으로 전환할 수 있습니다! 🚀
