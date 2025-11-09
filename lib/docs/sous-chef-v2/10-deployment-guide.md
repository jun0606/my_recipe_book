# 10. 배포 가이드

## 📋 개요

수쉐프 모드 v2.0의 CI/CD 파이프라인과 배포 자동화 전략을 설명합니다.

## 🚀 CI/CD 파이프라인

### 1. GitHub Actions 워크플로우

#### 메인 브랜치 배포
```yaml
# .github/workflows/deploy-main.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test --coverage
    - uses: codecov/codecov-action@v3

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/apk/release/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
    - uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-firebase:
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    steps:
    - uses: actions/download-artifact@v3
      with:
        name: android-apk
    - uses: actions/download-artifact@v3
      with:
        name: ios-build
    - uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: live
        projectId: souschef-app
```

#### 개발 브랜치 배포
```yaml
# .github/workflows/deploy-dev.yml
name: Deploy to Development

on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-and-lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - run: flutter pub get
    - run: flutter analyze --fatal-infos
    - run: flutter format --set-exit-if-changed .
    - run: flutter test --coverage
    - uses: codecov/codecov-action@v3

  build-dev:
    needs: test-and-lint
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - run: flutter pub get
    - run: flutter build apk --debug
    - uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: dev
        projectId: souschef-dev
```

## 📦 빌드 자동화

### 1. 버전 관리

#### Version Manager
```dart
// lib/core/version_manager.dart
class VersionManager {
  static const String version = '2.0.0';
  static const int buildNumber = 1;
  static const String buildType = String.fromEnvironment('BUILD_TYPE', defaultValue: 'development');

  static String get fullVersion => '$version+$buildNumber';

  static bool get isProduction => buildType == 'production';
  static bool get isDevelopment => buildType == 'development';

  static Map<String, dynamic> get versionInfo => {
    'version': version,
    'buildNumber': buildNumber,
    'buildType': buildType,
    'buildTime': DateTime.now().toIso8601String(),
    'platform': Platform.operatingSystem,
  };

  static void printVersionInfo() {
    print('SousChef Mode v$fullVersion ($buildType)');
    print('Built on ${Platform.operatingSystem}');
    print('Build time: ${DateTime.now()}');
  }
}
```

### 2. 환경 설정

#### Environment Configuration
```dart
// lib/core/environment_config.dart
class EnvironmentConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.souschef.com'
  );

  static const String apiKey = String.fromEnvironment('API_KEY');
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true);
  static const bool enableCrashReporting = bool.fromEnvironment('ENABLE_CRASH_REPORTING', defaultValue: true);

  static const Map<String, dynamic> get config => {
    'apiUrl': apiUrl,
    'apiKey': apiKey,
    'enableAnalytics': enableAnalytics,
    'enableCrashReporting': enableCrashReporting,
    'version': VersionManager.fullVersion,
  };

  static void validate() {
    if (apiKey.isEmpty) {
      throw Exception('API_KEY environment variable is required');
    }

    if (!apiUrl.startsWith('https://') && !apiUrl.startsWith('http://')) {
      throw Exception('Invalid API URL format');
    }
  }
}
```

## 🚀 배포 전략

### 1. 단계적 배포

#### Blue-Green Deployment
```dart
// lib/deployment/blue_green_manager.dart
class BlueGreenDeploymentManager {
  static const String currentEnvironment = 'blue';
  static const String nextEnvironment = 'green';

  static Future<void> prepareDeployment() async {
    // 새로운 버전 준비
    await _prepareGreenEnvironment();

    // 헬스 체크
    await _healthCheckGreenEnvironment();

    // 데이터베이스 마이그레이션
    await _runDatabaseMigrations();
  }

  static Future<void> executeDeployment() async {
    // 로드 밸런서 전환
    await _switchLoadBalancer();

    // 이전 환경 정리
    await _cleanupBlueEnvironment();

    // 모니터링 시작
    await _startPostDeploymentMonitoring();
  }

  static Future<void> rollback() async {
    // 로드 밸런서 복원
    await _switchLoadBalancerBack();

    // 롤백 완료 알림
    await _sendRollbackNotification();
  }

  static Future<void> _prepareGreenEnvironment() async {
    // 그린 환경에 새 버전 배포
    Logger.info('Preparing green environment...');
  }

  static Future<void> _healthCheckGreenEnvironment() async {
    // 헬스 체크 수행
    Logger.info('Health checking green environment...');
  }

  static Future<void> _runDatabaseMigrations() async {
    // 데이터베이스 마이그레이션 실행
    Logger.info('Running database migrations...');
  }

  static Future<void> _switchLoadBalancer() async {
    // 트래픽을 그린 환경으로 전환
    Logger.info('Switching traffic to green environment...');
  }

  static Future<void> _switchLoadBalancerBack() async {
    // 트래픽을 블루 환경으로 복원
    Logger.info('Rolling back to blue environment...');
  }

  static Future<void> _cleanupBlueEnvironment() async {
    // 블루 환경 정리
    Logger.info('Cleaning up blue environment...');
  }

  static Future<void> _startPostDeploymentMonitoring() async {
    // 배포 후 모니터링 시작
    Logger.info('Starting post-deployment monitoring...');
  }

  static Future<void> _sendRollbackNotification() async {
    // 롤백 알림 발송
    Logger.error('Deployment rolled back');
  }
}
```

### 2. 롤링 업데이트

#### Rolling Update Manager
```dart
// lib/deployment/rolling_update_manager.dart
class RollingUpdateManager {
  static const int batchSize = 3; // 한 번에 업데이트할 인스턴스 수
  static const Duration batchInterval = Duration(minutes: 5);

  static Future<void> performRollingUpdate() async {
    final instances = await _getAllInstances();

    for (int i = 0; i < instances.length; i += batchSize) {
      final batch = instances.skip(i).take(batchSize).toList();

      // 배치 업데이트
      await _updateBatch(batch);

      // 헬스 체크
      await _waitForBatchHealth(batch);

      // 다음 배치까지 대기
      if (i + batchSize < instances.length) {
        await Future.delayed(batchInterval);
      }
    }
  }

  static Future<List<String>> _getAllInstances() async {
    // 모든 인스턴스 목록 가져오기
    return ['instance-1', 'instance-2', 'instance-3', 'instance-4', 'instance-5'];
  }

  static Future<void> _updateBatch(List<String> instances) async {
    Logger.info('Updating batch: $instances');

    // 각 인스턴스 업데이트
    for (final instance in instances) {
      await _updateInstance(instance);
    }
  }

  static Future<void> _updateInstance(String instanceId) async {
    // 인스턴스 업데이트 로직
    Logger.info('Updating instance: $instanceId');
  }

  static Future<void> _waitForBatchHealth(List<String> instances) async {
    // 배치 헬스 체크
    const maxRetries = 10;
    const retryInterval = Duration(seconds: 30);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final allHealthy = await _checkBatchHealth(instances);

      if (allHealthy) {
        Logger.info('Batch health check passed');
        return;
      }

      if (attempt == maxRetries) {
        throw Exception('Batch health check failed');
      }

      await Future.delayed(retryInterval);
    }
  }

  static Future<bool> _checkBatchHealth(List<String> instances) async {
    // 각 인스턴스의 헬스 체크
    for (final instance in instances) {
      final healthy = await _checkInstanceHealth(instance);
      if (!healthy) return false;
    }
    return true;
  }

  static Future<bool> _checkInstanceHealth(String instanceId) async {
    // 인스턴스 헬스 체크 로직
    Logger.info('Checking health of instance: $instanceId');
    return true; // 실제 헬스 체크 구현 필요
  }
}
```

## 📊 모니터링 및 알림

### 1. 배포 모니터링

#### Deployment Monitor
```dart
// lib/deployment/deployment_monitor.dart
class DeploymentMonitor {
  final PerformanceMonitor _performanceMonitor;
  final AlertManager _alertManager;

  DeploymentMonitor({
    required PerformanceMonitor performanceMonitor,
    required AlertManager alertManager,
  }) : _performanceMonitor = performanceMonitor,
       _alertManager = alertManager;

  Future<void> monitorDeployment(String deploymentId) async {
    // 배포 시작 모니터링
    await _startDeploymentMonitoring(deploymentId);

    // 실시간 메트릭 수집
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _collectDeploymentMetrics(deploymentId);
    });

    // 배포 완료까지 모니터링
    await _waitForDeploymentCompletion(deploymentId);
  }

  Future<void> _startDeploymentMonitoring(String deploymentId) async {
    Logger.info('Starting deployment monitoring: $deploymentId');

    // 배포 이벤트 발행
    SousChefEventBus().publish('deployment:started', {
      'deploymentId': deploymentId,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _collectDeploymentMetrics(String deploymentId) async {
    // CPU, 메모리, 응답 시간 등 메트릭 수집
    final metrics = await _performanceMonitor.collectCurrentMetrics();

    // 임계값 검증
    if (metrics.cpuUsage > 90) {
      await _alertManager.sendAlert(Alert(
        type: AlertType.resource,
        severity: Severity.critical,
        message: 'High CPU usage during deployment',
        metric: 'cpu_usage',
        value: metrics.cpuUsage,
        threshold: 90,
      ));
    }

    if (metrics.errorRate > 0.05) {
      await _alertManager.sendAlert(Alert(
        type: AlertType.error,
        severity: Severity.high,
        message: 'High error rate during deployment',
        metric: 'error_rate',
        value: metrics.errorRate,
        threshold: 0.05,
      ));
    }
  }

  Future<void> _waitForDeploymentCompletion(String deploymentId) async {
    // 배포 완료 이벤트 대기
    final completer = Completer<void>();

    final subscription = SousChefEventBus().subscribe('deployment:completed').listen((event) {
      if (event['deploymentId'] == deploymentId) {
        completer.complete();
      }
    });

    await completer.future;
    subscription.cancel();

    Logger.info('Deployment monitoring completed: $deploymentId');
  }
}
```

## 🎯 결론

### 배포 자동화의 이점

✅ **신속한 배포** - 자동화된 CI/CD 파이프라인
✅ **안정성 보장** - 철저한 테스트와 모니터링
✅ **롤백 용이성** - Blue-Green 및 Rolling 업데이트
✅ **품질 관리** - 자동화된 품질 게이트
✅ **모니터링 강화** - 실시간 배포 모니터링

### 배포 전략 선택 가이드

| 전략 | 장점 | 단점 | 사용 케이스 |
|------|------|------|-------------|
| Blue-Green | 빠른 롤백, 제로 다운타임 | 리소스 2배 사용 | 프로덕션 환경 |
| Rolling Update | 리소스 효율적, 점진적 배포 | 복잡한 롤백 | 대규모 시스템 |
| Canary | 위험 감소, 피드백 빠름 | 복잡한 관리 | 새로운 기능 배포 |

이 배포 가이드를 통해 수쉐프 모드 v2.0은 안정적이고 효율적인 배포 프로세스를 구축할 수 있습니다.
