import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

// SharedAxisTransition을 사용하는 페이지 라우트 빌더
Route<T> buildPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal, // 가로 방향 전환
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 700), // 애니메이션 지속 시간
  );
}