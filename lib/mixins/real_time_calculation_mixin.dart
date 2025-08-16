import 'dart:async';
import 'package:flutter/material.dart';

/// 실시간 계산을 위한 믹스인
/// 디바운싱 기능을 제공하여 성능 최적화
mixin RealTimeCalculationMixin {
  Timer? _debounceTimer;
  Timer? _immediateTimer;
  
  /// 계산 대기 중 여부
  bool get isCalculationPending => _debounceTimer?.isActive ?? false;
  
  /// 디바운싱된 계산 실행 (300ms 지연)
  void debounceCalculation(VoidCallback calculation) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), calculation);
  }
  
  /// 즉시 계산 실행 (디바운싱 없음)
  void immediateCalculation(VoidCallback calculation) {
    _debounceTimer?.cancel();
    _immediateTimer?.cancel();
    _immediateTimer = Timer(Duration.zero, calculation);
  }
  
  /// 디바운싱된 계산 실행 (사용자 정의 지연 시간)
  void debouncedCalculate(VoidCallback calculation, {int delayMs = 300}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: delayMs), calculation);
  }
  
  /// 리소스 정리
  void disposeRealTimeCalculation() {
    _debounceTimer?.cancel();
    _immediateTimer?.cancel();
    _debounceTimer = null;
    _immediateTimer = null;
  }
}