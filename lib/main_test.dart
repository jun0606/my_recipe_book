import 'package:flutter/material.dart';
import 'screens/basic_calculator_test_screen.dart';

/// 기본 분할 계산기 테스트용 메인 파일
/// flutter run -t lib/main_test.dart 로 실행
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실용적 레시피 계산기 테스트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'NotoSansKR',
      ),
      home: const BasicCalculatorTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
