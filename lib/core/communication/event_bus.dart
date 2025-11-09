// 🎯 수쉐프 모드 v2.0 이벤트 기반 통신 시스템
// 모듈 간 실시간 데이터 동기화 및 이벤트 처리

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 수쉐프 모드 이벤트 타입들
enum SousChefEvent {
  // 모듈 관리 이벤트
  moduleRegistered,
  moduleActivated,
  moduleDeactivated,
  moduleSwitched,

  // 레시피 관련 이벤트
  recipeUpdated,
  recipeAnalyzed,
  recipeModified,

  // 분석 관련 이벤트
  analysisCompleted,
  analysisError,
  analysisProgress,

  // UI 관련 이벤트
  uiUpdated,
  tabSwitched,

  // 환경 조건 변경 이벤트
  environmentChanged,
  equipmentChanged,
  userPreferencesChanged,

  // 실시간 분석 이벤트
  realTimeAnalysisStarted,
  realTimeAnalysisUpdated,
  realTimeAnalysisStopped,

  // 에러 및 경고 이벤트
  errorOccurred,
  warningIssued,
  infoMessage,
}

/// 이벤트 데이터 베이스 클래스
abstract class EventData {
  final DateTime timestamp;

  EventData({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap();
}

/// 모듈 관련 이벤트 데이터
class ModuleEventData extends EventData {
  final String moduleId;
  final String? previousModuleId;

  ModuleEventData({
    required this.moduleId,
    this.previousModuleId,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'previousModuleId': previousModuleId,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 레시피 관련 이벤트 데이터
class RecipeEventData extends EventData {
  final String recipeId;
  final String? title;
  final Map<String, dynamic>? data;

  RecipeEventData({
    required this.recipeId,
    this.title,
    this.data,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() => {
        'recipeId': recipeId,
        'title': title,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AnalysisEventData extends EventData {
  final String moduleId;
  final String recipeId;
  final double progress;
  final dynamic result;
  final String? error;

  AnalysisEventData({
    required this.moduleId,
    required this.recipeId,
    required this.progress,
    this.result,
    this.error,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'recipeId': recipeId,
        'progress': progress,
        'result': result,
        'error': error,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 환경 조건 변경 이벤트 데이터
class EnvironmentEventData extends EventData {
  final Map<String, dynamic> conditions;
  final List<String> changedFields;

  EnvironmentEventData({
    required this.conditions,
    required this.changedFields,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() => {
        'conditions': conditions,
        'changedFields': changedFields,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 수쉐프 모드 이벤트 버스
/// 모듈 간 실시간 통신을 위한 중앙 이벤트 시스템
class SousChefEventBus {
  static final SousChefEventBus _instance = SousChefEventBus._internal();
  static SousChefEventBus get instance => _instance;

  final Map<SousChefEvent, StreamController<EventData>> _controllers = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  SousChefEventBus._internal();

  /// 이벤트 구독
  Stream<T> subscribe<T extends EventData>(SousChefEvent event) {
    _controllers.putIfAbsent(event, () => StreamController<T>.broadcast());
    return _controllers[event]!.stream as Stream<T>;
  }

  /// 이벤트 발행
  void publish(SousChefEvent event, EventData data) {
    if (_controllers.containsKey(event)) {
      _controllers[event]!.add(data);
      debugPrint('📡 Event published: $event - ${data.toMap()}');
    } else {
      debugPrint('⚠️ No subscribers for event: $event');
    }
  }

  /// 일회성 이벤트 구독 (한 번만 수신)
  Future<T> subscribeOnce<T extends EventData>(SousChefEvent event) {
    Completer<T> completer = Completer<T>();

    late StreamSubscription subscription;
    subscription = subscribe<T>(event).listen((data) {
      completer.complete(data);
      subscription.cancel();
    });

    return completer.future;
  }

  /// 이벤트 구독 취소
  void unsubscribe(SousChefEvent event, {String? subscriptionId}) {
    if (subscriptionId != null) {
      _subscriptions[subscriptionId]?.cancel();
      _subscriptions.remove(subscriptionId);
    } else if (_controllers.containsKey(event)) {
      _controllers[event]!.close();
      _controllers.remove(event);
    }
  }

  /// 모든 이벤트 구독 취소 및 정리
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();

    debugPrint('🧹 SousChefEventBus disposed');
  }

  /// 디버깅을 위한 이벤트 리스너 수 확인
  int getListenerCount(SousChefEvent event) {
    if (_controllers.containsKey(event)) {
      return _controllers[event]!.hasListener ? 1 : 0;
    }
    return 0;
  }

  /// 모든 이벤트의 상태 확인
  Map<String, int> getEventStats() {
    return _controllers.map((event, controller) {
      return MapEntry(event.name, getListenerCount(event));
    });
  }
}

/// 편의를 위한 글로벌 함수들
SousChefEventBus get eventBus => SousChefEventBus.instance;

void publishEvent(SousChefEvent event, EventData data) {
  eventBus.publish(event, data);
}

Stream<T> subscribeToEvent<T extends EventData>(SousChefEvent event) {
  return eventBus.subscribe<T>(event);
}

Future<T> waitForEvent<T extends EventData>(SousChefEvent event) {
  return eventBus.subscribeOnce<T>(event);
}

void initializeSousChefEventBus() {
  debugPrint('✅ SousChefEventBus initialized');
}
