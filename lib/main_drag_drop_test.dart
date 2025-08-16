import 'package:flutter/material.dart';
import 'package:my_recipe_book/di/service_locator.dart';
import 'package:my_recipe_book/screens/drag_drop_test_screen.dart';

/// 드래그 앤 드롭 테스트용 메인 앱
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 로케이터 초기화
  ServiceLocator.instance.initOnce();
  
  runApp(const DragDropTestApp());
}

class DragDropTestApp extends StatelessWidget {
  const DragDropTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '드래그 앤 드롭 테스트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DragDropTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}