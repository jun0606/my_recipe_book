# 11. 모니터링 가이드

## 📋 개요

수쉐프 모드 v2.0의 운영 및 유지보수 모니터링 방법을 설명합니다.

## 📊 실시간 모니터링

### 1. 시스템 건강도 모니터링

#### Health Check Dashboard
```dart
// lib/monitoring/health_dashboard.dart
class HealthDashboard extends StatefulWidget {
  const HealthDashboard({Key? key}) : super(key: key);

  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  late Timer _healthCheckTimer;
  Map<String, HealthStatus> _componentHealth = {};

  @override
  void initState() {
    super.initState();
    _startHealthMonitoring();
  }

  void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performHealthChecks();
    });
  }

  Future<void> _performHealthChecks() async {
    final healthChecks = {
      'api': _checkApiHealth(),
      'database': _checkDatabaseHealth(),
      'cache': _checkCacheHealth(),
      'modules': _checkModulesHealth(),
      'ui': _checkUiHealth(),
    };

    final results = await Future.wait(healthChecks.values);

    setState(() {
      _componentHealth = Map.fromIterables(healthChecks.keys, results);
    });

    // 건강도 이벤트 발행
    SousChefEventBus().publish('health:status', {
      'components': _componentHealth,
      'timestamp': DateTime.now(),
    });
  }

  Future<HealthStatus> _checkApiHealth() async {
    try {
      final response = await ApiClient.healthCheck();
      return response.success ? HealthStatus.healthy : HealthStatus.unhealthy;
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  Future<HealthStatus> _checkDatabaseHealth() async {
    try {
      final connected = await DatabaseManager.isConnected();
      return connected ? HealthStatus.healthy : HealthStatus.unhealthy;
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  Future<HealthStatus> _checkCacheHealth() async {
    try {
      final cacheSize = await CacheManager.getCacheSize();
      return cacheSize < 100 * 1024 * 1024 ? HealthStatus.healthy : HealthStatus.unhealthy;
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  Future<HealthStatus> _checkModulesHealth() async {
    try {
      final modules = ModuleManager.getAllModules();
      final allHealthy = modules.every((module) => module.isHealthy);
      return allHealthy ? HealthStatus.healthy : HealthStatus.unhealthy;
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  Future<HealthStatus> _checkUiHealth() async {
    try {
      final uiErrors = ErrorTracker.getUiErrors();
      return uiErrors.isEmpty ? HealthStatus.healthy : HealthStatus.unhealthy;
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Health Dashboard')),
      body: _buildHealthGrid(),
    );
  }

  Widget _buildHealthGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: _componentHealth.entries.map((entry) {
        return _buildHealthCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildHealthCard(String component, HealthStatus status) {
    final color = _getHealthColor(status);
    final icon = _getHealthIcon(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(component.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(status.name, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.unhealthy:
        return Colors.orange;
      case HealthStatus.critical:
        return Colors.red;
    }
  }

  IconData _getHealthIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Icons.check_circle;
      case HealthStatus.unhealthy:
        return Icons.warning;
      case HealthStatus.critical:
        return Icons.error;
    }
  }

  @override
  void dispose() {
    _healthCheckTimer.cancel();
    super.dispose();
  }
}

enum HealthStatus {
  healthy,
  unhealthy,
  critical,
}
```

## 📈 성능 메트릭 수집

### 1. 메트릭 수집기

#### Metrics Collector
```dart
// lib/monitoring/metrics_collector.dart
class MetricsCollector {
  final Map<String, MetricSeries> _metrics = {};
  final AlertManager _alertManager;

  MetricsCollector({required AlertManager alertManager})
      : _alertManager = alertManager;

  void recordMetric(String name, double value, {Map<String, String>? tags}) {
    _metrics.putIfAbsent(name, () => MetricSeries(name));
    _metrics[name]!.addPoint(value, tags: tags);

    // 임계값 검증
    _checkThresholds(name, value);
  }

  void _checkThresholds(String metricName, double value) {
    final threshold = _getThreshold(metricName);
    if (threshold != null && value > threshold) {
      _alertManager.sendAlert(Alert(
        type: AlertType.performance,
        severity: Severity.medium,
        message: '$metricName exceeded threshold: $value > $threshold',
        metric: metricName,
        value: value,
        threshold: threshold,
      ));
    }
  }

  double? _getThreshold(String metricName) {
    const thresholds = {
      'response_time': 5000.0, // 5초
      'memory_usage': 100 * 1024 * 1024, // 100MB
      'cpu_usage': 80.0, // 80%
      'error_rate': 0.05, // 5%
    };
    return thresholds[metricName];
  }

  Map<String, dynamic> getCurrentMetrics() {
    final result = <String, dynamic>{};
    for (final entry in _metrics.entries) {
      final latest = entry.value.getLatest();
      if (latest != null) {
        result[entry.key] = latest.value;
      }
    }
    return result;
  }

  MetricSeries? getMetricSeries(String name) => _metrics[name];
}

class MetricSeries {
  final String name;
  final List<MetricPoint> _points = [];

  MetricSeries(this.name);

  void addPoint(double value, {Map<String, String>? tags}) {
    _points.add(MetricPoint(value, DateTime.now(), tags));
    _cleanupOldPoints();
  }

  void _cleanupOldPoints() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _points.removeWhere((point) => point.timestamp.isBefore(cutoff));
  }

  MetricPoint? getLatest() => _points.isEmpty ? null : _points.last;

  List<MetricPoint> getPointsInRange(DateTime start, DateTime end) {
    return _points.where((point) {
      return point.timestamp.isAfter(start) && point.timestamp.isBefore(end);
    }).toList();
  }
}

class MetricPoint {
  final double value;
  final DateTime timestamp;
  final Map<String, String>? tags;

  const MetricPoint(this.value, this.timestamp, this.tags);
}
```

## 🚨 알림 시스템

### 1. 다중 채널 알림

#### Notification Manager
```dart
// lib/monitoring/notification_manager.dart
class NotificationManager {
  final List<NotificationChannel> _channels = [];

  void registerChannel(NotificationChannel channel) {
    _channels.add(channel);
  }

  Future<void> sendNotification(Notification notification) async {
    final results = await Future.wait(
      _channels.map((channel) => channel.send(notification))
    );

    final failedChannels = <NotificationChannel>[];
    for (int i = 0; i < _channels.length; i++) {
      if (!results[i]) {
        failedChannels.add(_channels[i]);
      }
    }

    if (failedChannels.isNotEmpty) {
      Logger.error('Failed to send notification to channels: $failedChannels');
    }
  }
}

abstract class NotificationChannel {
  Future<bool> send(Notification notification);
}

class EmailNotificationChannel implements NotificationChannel {
  @override
  Future<bool> send(Notification notification) async {
    try {
      // 이메일 발송 로직
      Logger.info('Sending email notification: ${notification.title}');
      return true;
    } catch (e) {
      Logger.error('Email notification failed: $e');
      return false;
    }
  }
}

class SlackNotificationChannel implements NotificationChannel {
  @override
  Future<bool> send(Notification notification) async {
    try {
      // Slack 메시지 발송 로직
      Logger.info('Sending Slack notification: ${notification.title}');
      return true;
    } catch (e) {
      Logger.error('Slack notification failed: $e');
      return false;
    }
  }
}

class Notification {
  final String title;
  final String message;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;

  const Notification({
    required this.title,
    required this.message,
    this.priority = NotificationPriority.normal,
    this.data,
  });
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}
```

## 📋 유지보수 작업

### 1. 자동화된 유지보수

#### Maintenance Scheduler
```dart
// lib/maintenance/maintenance_scheduler.dart
class MaintenanceScheduler {
  final List<MaintenanceTask> _tasks = [];
  Timer? _schedulerTimer;

  void scheduleTask(MaintenanceTask task) {
    _tasks.add(task);
  }

  void startScheduler() {
    _schedulerTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _checkAndExecuteTasks();
    });
  }

  void _checkAndExecuteTasks() {
    final now = DateTime.now();

    for (final task in _tasks) {
      if (task.shouldExecute(now)) {
        _executeTask(task);
      }
    }
  }

  Future<void> _executeTask(MaintenanceTask task) async {
    try {
      Logger.info('Executing maintenance task: ${task.name}');

      await task.execute();

      Logger.info('Maintenance task completed: ${task.name}');
    } catch (e) {
      Logger.error('Maintenance task failed: ${task.name}, error: $e');
    }
  }

  void stopScheduler() {
    _schedulerTimer?.cancel();
  }
}

abstract class MaintenanceTask {
  String get name;
  Duration get interval;
  DateTime? _lastExecution;

  bool shouldExecute(DateTime now) {
    if (_lastExecution == null) return true;
    return now.difference(_lastExecution!) >= interval;
  }

  Future<void> execute();

  void markExecuted() {
    _lastExecution = DateTime.now();
  }
}

class CacheCleanupTask extends MaintenanceTask {
  @override
  String get name => 'Cache Cleanup';

  @override
  Duration get interval => const Duration(hours: 6);

  @override
  Future<void> execute() async {
    await CacheManager.cleanupExpired();
    markExecuted();
  }
}

class DatabaseMaintenanceTask extends MaintenanceTask {
  @override
  String get name => 'Database Maintenance';

  @override
  Duration get interval => const Duration(days: 1);

  @override
  Future<void> execute() async {
    await DatabaseManager.optimizeTables();
    await DatabaseManager.cleanupOldData();
    markExecuted();
  }
}
```

## 🎯 결론

### 모니터링 시스템의 이점

✅ **실시간 건강도 추적** - 시스템 컴포넌트 상태 모니터링
✅ **자동화된 알림** - 다중 채널을 통한 신속한 알림
✅ **성능 메트릭 분석** - 상세한 성능 데이터 수집 및 분석
✅ **예방적 유지보수** - 자동화된 유지보수 작업
✅ **문제 해결 가속화** - 중앙화된 모니터링 대시보드

이 모니터링 가이드를 통해 수쉐프 모드 v2.0은 안정적이고 효율적인 운영을 유지할 수 있습니다.
