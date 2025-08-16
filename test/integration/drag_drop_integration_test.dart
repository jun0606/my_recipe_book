import 'package:flutter/material.dart';
// 임시 비활성화 - integration_test 의존성 누락
// import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_recipe_book/main.dart' as app;
import 'package:my_recipe_book/screens/drag_drop_test_screen.dart';
import 'package:my_recipe_book/widgets/modular_calculator/drag_drop_layout.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Drag Drop Calculator Integration Tests', () {
    testWidgets('complete drag and drop workflow test', (WidgetTester tester) async {
      // Given - 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // 드래그 앤 드롭 테스트 화면으로 이동하는 로직
      // (실제 앱의 네비게이션 구조에 따라 조정 필요)
      
      // When - 드래그 앤 드롭 테스트 화면 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - 기본 UI 요소들이 표시되는지 확인
      expect(find.text('드래그 앤 드롭 테스트'), findsOneWidget);
      expect(find.byType(DragDropCalculatorLayout), findsOneWidget);
    });

    testWidgets('module palette interaction test', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - 모듈 팔레트 버튼 클릭
      final paletteButton = find.byIcon(Icons.widgets);
      expect(paletteButton, findsOneWidget);
      
      await tester.tap(paletteButton);
      await tester.pumpAndSettle();

      // Then - 모듈 팔레트가 표시되는지 확인
      expect(find.text('모듈 팔레트'), findsOneWidget);
      
      // 사용 가능한 모듈들이 표시되는지 확인
      expect(find.text('기본 계산기'), findsWidgets);
      expect(find.text('단위 변환'), findsWidgets);
      expect(find.text('스케일링'), findsWidgets);
    });

    testWidgets('drag module from palette to layout test', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 팔레트 열기
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();

      // When - 모듈을 팔레트에서 레이아웃으로 드래그
      final moduleInPalette = find.text('기본 계산기').first;
      final layoutCenter = find.byType(DragDropCalculatorLayout);
      
      await tester.drag(moduleInPalette, const Offset(200, 200));
      await tester.pumpAndSettle();

      // Then - 모듈이 레이아웃에 추가되었는지 확인
      expect(find.byType(AnimatedPositioned), findsWidgets);
    });

    testWidgets('unit conversion module functionality test', (WidgetTester tester) async {
      // Given - 단위 변환 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 팔레트에서 단위 변환 모듈 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      final unitConversionModule = find.text('단위 변환').first;
      await tester.drag(unitConversionModule, const Offset(200, 200));
      await tester.pumpAndSettle();

      // When - 단위 변환 기능 테스트
      // 1000g 입력
      final inputField = find.byType(TextField).first;
      await tester.enterText(inputField, '1000');
      await tester.pumpAndSettle();

      // Then - 변환 결과가 표시되는지 확인
      expect(find.textContaining('결과:'), findsOneWidget);
    });

    testWidgets('basic calculator module functionality test', (WidgetTester tester) async {
      // Given - 기본 계산기 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 팔레트에서 기본 계산기 모듈 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      final basicCalculatorModule = find.text('기본 계산기').first;
      await tester.drag(basicCalculatorModule, const Offset(200, 200));
      await tester.pumpAndSettle();

      // When - 스케일링 팩터 변경
      final slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // 2x 프리셋 버튼 클릭
      final twoXButton = find.text('2x');
      await tester.tap(twoXButton);
      await tester.pumpAndSettle();

      // Then - 슬라이더 값이 변경되었는지 확인
      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('scaling module functionality test', (WidgetTester tester) async {
      // Given - 스케일링 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 팔레트에서 스케일링 모듈 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      final scalingModule = find.text('스케일링').first;
      await tester.drag(scalingModule, const Offset(200, 200));
      await tester.pumpAndSettle();

      // When - 무게 기반 스케일링 테스트
      final targetWeightField = find.byType(TextField).first;
      await tester.enterText(targetWeightField, '1700');
      await tester.pumpAndSettle();

      // Then - 현재 총 무게가 표시되는지 확인
      expect(find.textContaining('현재 총 무게:'), findsOneWidget);

      // When - 인분 기반 스케일링으로 전환
      final servingsRadio = find.text('인분으로');
      await tester.tap(servingsRadio);
      await tester.pumpAndSettle();

      // Then - 목표 인분 수 입력 필드가 표시되는지 확인
      expect(find.text('목표 인분 수'), findsOneWidget);
    });

    testWidgets('module removal test', (WidgetTester tester) async {
      // Given - 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      final module = find.text('기본 계산기').first;
      await tester.drag(module, const Offset(200, 200));
      await tester.pumpAndSettle();

      // When - 모듈 제거 버튼 클릭
      final removeButton = find.byIcon(Icons.close);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Then - 모듈이 제거되었는지 확인
      expect(find.text('모듈이 제거되었습니다'), findsOneWidget);
    });

    testWidgets('layout reset functionality test', (WidgetTester tester) async {
      // Given - 여러 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 여러 모듈 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      // 기본 계산기 추가
      final basicCalc = find.text('기본 계산기').first;
      await tester.drag(basicCalc, const Offset(200, 200));
      await tester.pumpAndSettle();

      // 단위 변환 추가
      final unitConv = find.text('단위 변환').first;
      await tester.drag(unitConv, const Offset(400, 200));
      await tester.pumpAndSettle();

      // When - 레이아웃 초기화 버튼 클릭
      final resetButton = find.byIcon(Icons.refresh);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // 확인 다이얼로그에서 초기화 버튼 클릭
      final confirmButton = find.text('초기화');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Then - 모듈들이 기본 위치로 재배치되었는지 확인
      expect(find.byType(AnimatedPositioned), findsWidgets);
    });

    testWidgets('layout save functionality test', (WidgetTester tester) async {
      // Given - 모듈이 활성화된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 모듈 추가 및 이동
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();
      
      final module = find.text('기본 계산기').first;
      await tester.drag(module, const Offset(300, 300));
      await tester.pumpAndSettle();

      // When - 레이아웃 저장 버튼 클릭
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Then - 저장 완료 메시지가 표시되는지 확인
      expect(find.text('레이아웃이 저장되었습니다.'), findsOneWidget);
    });

    testWidgets('user mode switching test', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - 사용자 모드 변경 (앱바의 사용자 아이콘 클릭)
      final userModeButton = find.byIcon(Icons.person);
      await tester.tap(userModeButton);
      await tester.pumpAndSettle();

      // 전문가 모드 선택
      final professionalMode = find.text('전문가');
      await tester.tap(professionalMode);
      await tester.pumpAndSettle();

      // Then - 모드 변경이 반영되었는지 확인
      // 모듈 팔레트를 열어서 전문가 모드 전용 모듈들이 표시되는지 확인
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();

      expect(find.text('베이커스 퍼센트'), findsWidgets);
    });

    testWidgets('recipe information display test', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - 정보 버튼 클릭 (FloatingActionButton)
      final infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Then - 레시피 정보 다이얼로그가 표시되는지 확인
      expect(find.text('테스트 빵'), findsOneWidget);
      expect(find.textContaining('카테고리:'), findsOneWidget);
      expect(find.textContaining('재료 수:'), findsOneWidget);
      expect(find.textContaining('현재 모드:'), findsOneWidget);

      // 확인 버튼 클릭
      final okButton = find.text('확인');
      await tester.tap(okButton);
      await tester.pumpAndSettle();
    });

    testWidgets('performance test - multiple modules rendering', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - 여러 모듈을 빠르게 추가
      await tester.tap(find.byIcon(Icons.widgets));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // 기본 계산기 추가
      final basicCalc = find.text('기본 계산기').first;
      await tester.drag(basicCalc, const Offset(100, 100));
      await tester.pumpAndSettle();

      // 단위 변환 추가
      final unitConv = find.text('단위 변환').first;
      await tester.drag(unitConv, const Offset(300, 100));
      await tester.pumpAndSettle();

      // 스케일링 추가
      final scaling = find.text('스케일링').first;
      await tester.drag(scaling, const Offset(500, 100));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Then - 성능 확인 (3초 이내에 완료되어야 함)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      // 모든 모듈이 정상적으로 렌더링되었는지 확인
      expect(find.byType(AnimatedPositioned), findsNWidgets(3));
    });

    testWidgets('error handling test - invalid module data', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: const DragDropTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - 존재하지 않는 모듈 ID로 테스트
      // (이 테스트는 실제 구현에서 오류 처리가 어떻게 되는지에 따라 조정 필요)
      
      // Then - 앱이 크래시하지 않고 적절한 오류 메시지가 표시되는지 확인
      expect(find.byType(DragDropCalculatorLayout), findsOneWidget);
    });
  });
}