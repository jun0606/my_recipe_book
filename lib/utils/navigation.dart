// lib/utils/navigation.dart
// 내비게이션 유틸리티 함수들

import 'package:flutter/material.dart';

/// 페이지 라우트 빌더
/// 애니메이션 효과와 일관된 전환을 제공
Route<T> buildPageRoute<T>(Widget page) {
  return MaterialPageRoute<T>(
    builder: (context) => page,
  );
}

/// 슬라이드 전환 페이지 라우트
Route<T> buildSlidePageRoute<T>(
  Widget page, {
  Offset begin = const Offset(1.0, 0.0),
  Offset end = Offset.zero,
  Curve curve = Curves.easeInOut,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// 페이드 전환 페이지 라우트
Route<T> buildFadePageRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// 스케일 전환 페이지 라우트
Route<T> buildScalePageRoute<T>(
  Widget page, {
  double beginScale = 0.8,
  double endScale = 1.0,
  Curve curve = Curves.easeInOut,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scaleAnimation = Tween<double>(
        begin: beginScale,
        end: endScale,
      ).chain(CurveTween(curve: curve)).animate(animation);

      return ScaleTransition(
        scale: scaleAnimation,
        child: child,
      );
    },
  );
}

/// 내비게이터 확장 메소드들
extension NavigatorExtensions on BuildContext {
  /// 간단한 페이지 이동
  Future<T?> navigateTo<T>(Widget page) {
    return Navigator.of(this).push(buildPageRoute<T>(page));
  }

  /// 페이지 교체
  Future<T?> replaceWith<T>(Widget page) {
    return Navigator.of(this).pushReplacement(buildPageRoute<T>(page));
  }

  /// 모든 페이지 교체
  void replaceAllWith(Widget page) {
    Navigator.of(this).pushAndRemoveUntil(
      buildPageRoute(page),
      (route) => false,
    );
  }

  /// 뒤로가기
  void goBack<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
