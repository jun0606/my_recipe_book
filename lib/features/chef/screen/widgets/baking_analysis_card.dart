import 'dart:async'; // Timer import
import 'dart:convert'; // JSON 파싱용 import 복원
import 'dart:convert'; // JSON 파싱용 import 복원
import 'package:flutter/material.dart';
import 'package:my_recipe_book/l10n/app_localizations.dart';
import '../../../../../core/types/environment_types.dart' as env_types;
import '../../../../../core/types/calculation_types.dart' as calc_types;
import '../../../../../core/constants/bread_constants.dart'; // BreadConstants import
import '../types/screen_types.dart' as st;
import '../controllers/baking_analysis_controller.dart'; // 베이킹 컨트롤러 import
import '../../../../services/ingredient_analyzer.dart'; // IngredientAnalyzer import
import '../../../../services/centralized_parsing_service.dart'; // CentralizedParsingService import

class BakingAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final env_types.UserEnvironment environment;
  final Map<String, dynamic>? mixingResult; // 믹싱 결과
  final calc_types.FermentationState? fermentationState; // 발효 상태 추가
  final bool isFermentationComplete; // 발효 분석 완료 여부
  final st.AnalysisSettings settings;
  final BakingAnalysisController? externalController; // 외부 컨트롤러 지원

  const BakingAnalysisCard({
    super.key,
    required this.recipeData,
    required this.environment,
    this.mixingResult,
    this.fermentationState,
    this.isFermentationComplete = false,
    this.settings = const st.AnalysisSettings(),
    this.externalController, // 컨트롤러 공유 지원
  });

  @override
  State<BakingAnalysisCard> createState() => _BakingAnalysisCardState();
}

/// ✅ BakingStepCardEnhanced - 믹싱 카드 디자인 패턴 적용한 베이킹 단계 카드
class BakingStepCardEnhanced extends StatelessWidget {
  final int stepIndex;
  final BakingStepAnalysis analysis;
  final int totalSteps;

  const BakingStepCardEnhanced({
    super.key,
    required this.stepIndex,
    required this.analysis,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isFinalStep = analysis.stepNumber == totalSteps;
    final String stepTitle = isFinalStep
        ? l10n.completedStep(analysis.stepNumber)
        : l10n.stepNumber(analysis.stepNumber);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 단계 헤더
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${analysis.stepNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    Text(
                      l10n.timeMinutes(analysis.time.inMinutes),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFinalStep)
                Icon(
                  Icons.done_rounded,
                  size: 18,
                  color: Colors.green.shade600,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 메트릭 그리드
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '🔥 ${l10n.progress}',
                  '${analysis.bakingProgress.toStringAsFixed(1)}%',
                  analysis.bakingProgress >
                          BreadConstants
                              .bakingProgressExcellent // 빵 과학 연구: 70% = 최적 베이킹 완료율 (녹색)
                      ? Colors.green.shade600
                      : analysis.bakingProgress >
                              BreadConstants
                                  .bakingProgressGood // 빵 과학 연구: 50% = 최소 베이킹 수준 (주황색)
                          ? Colors.orange.shade600
                          : Colors.red.shade600, // 빵 과학 연구: 50% 이하 = 불충분 (빨간색)
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricCard(
                  '🟤 ${l10n.maillardReaction}',
                  '${analysis.maillardReaction.toStringAsFixed(1)}',
                  analysis.maillardReaction >
                          BreadConstants
                              .maillardReactionExcellent // 빵 과학 연구: 20치 이상 = 최적 마이야르 범위 초과 (갈색)
                      ? Colors.brown.shade600
                      : Colors.orange
                          .shade600, // 빵 과학 연구: 20치 이하 = 적정 마이야르 범위 (주황색)
                  Icons.palette_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '🍞 ${l10n.crumb}',
                  '${analysis.crumbBakingProgress.toStringAsFixed(1)}%',
                  analysis.crumbBakingProgress >
                          BreadConstants
                              .crumbBakingProgressExcellent // 빵 과학 연구: 70% = 내부 빵 익음 최적 (보라색)
                      ? Colors.purple.shade600
                      : analysis.crumbBakingProgress >
                              BreadConstants
                                  .crumbBakingProgressGood // 빵 과학 연구: 50% = 내부 빵 익음 양호 (파란색)
                          ? Colors.blue.shade600
                          : Colors
                              .red.shade600, // 빵 과학 연구: 50% 이하 = 낮은 내부 익음 (빨간색)
                  Icons.cake_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricCard(
                  '🌡️ ${l10n.internalTemperature}',
                  '${analysis.internalTemperature.toStringAsFixed(1)}°C',
                  analysis.internalTemperature >
                          BreadConstants
                              .internalTemperatureDanger // 빵 과학 연구: 90°C 이상 = 증기 피킹 위험 경고 (빨간색)
                      ? Colors.red.shade600
                      : Colors
                          .green.shade600, // 빵 과학 연구: 90°C 이하 = 안전온도 범위 (녹색)
                  Icons.thermostat_rounded,
                ),
              ),
            ],
          ),

          // 최종 단계 추가 정보
          if (isFinalStep) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.bakingComplete,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 메트릭 카드 빌더
  Widget _buildMetricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BakingAnalysisCardState extends State<BakingAnalysisCard> {
  /// 컨트롤러 인스턴스
  BakingAnalysisController? _controller;

  /// ✅ [Fix 무한 루프] UI 리빌드 타이머 추가
  Timer? _rebuildTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(BakingAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalController != oldWidget.externalController ||
        widget.recipeData != oldWidget.recipeData ||
        widget.environment != oldWidget.environment ||
        widget.mixingResult != oldWidget.mixingResult ||
        widget.fermentationState != oldWidget.fermentationState) {
      // 컨트롤러가 변경되었으면 다시 초기화
      if (widget.externalController != oldWidget.externalController) {
        _controller?.dispose();
        _initializeController();
      } else {
        _updateControllerData();
        // 단계 분석 데이터가 변경될 수 있으므로 확장 상태 재초기화
        _initializeStepExpansionStates();
        // ❌ 제거: 무한 루프 방지를 위해 스스로 분석 시작하지 않음
        // _triggerAnalysisIfReady(); // externalController를 통해서만 분석 시작
      }
    }
  }

  /// 컨트롤러 초기화
  void _initializeController() {
    debugPrint('🔧 [BakingAnalysisCard._initializeController] 시작');
    debugPrint(
        '   - externalController 제공됨: ${widget.externalController != null}');
    debugPrint(
        '   - externalController 해시: ${widget.externalController?.hashCode}');

    // 외부 컨트롤러 우선 사용, 없으면 내부 생성
    _controller = widget.externalController ?? BakingAnalysisController();

    debugPrint('   - 최종 컨트롤러 해시: ${_controller?.hashCode}');
    debugPrint('   - 컨트롤러 타입: ${_controller?.runtimeType}');

    // ✅ 단계별 오븐 베이킹 카드 확장 상태 초기화 (기본적으로 모두 펼쳐진 상태)
    _initializeStepExpansionStates();

    // 컨트롤러 데이터 설정 (카드 위젯 파라미터 사용)
    _updateControllerData();

    // 컨트롤러 리스너 설정
    debugPrint('   - 리스너 등록 시작');
    _controller!.addListener(_onControllerChanged);
    debugPrint('   - 리스너 등록 완료');

    debugPrint('🔧 [BakingAnalysisCard._initializeController] 완료');
  }

  /// ✅ 단계별 오븐 베이킹 카드 확장 상태 초기화 (기본적으로 모두 펼쳐진 상태)
  void _initializeStepExpansionStates() {
    // 확장 상태 관리를 위한 초기화 메소드 (향후 확장 가능성 유지)
    debugPrint('🔥 [오븐 베이킹 카드] 단계별 확장 상태 초기화 완료');
  }

  /// 컨트롤러 데이터 업데이트 - 상세 오류 로깅 추가
  void _updateControllerData() {
    debugPrint(
        '🔧 [BakingAnalysisCard] _updateControllerData 호출 - 상세 오류 추적 시작');
    debugPrint('   - 호출 시간: ${DateTime.now()}');
    debugPrint('   - 위젯 해시: ${widget.hashCode}');
    debugPrint('   - 카드 인스턴스 해시: ${hashCode}');
    debugPrint(
        '   - fermentationState 존재: ${widget.fermentationState != null}');
    debugPrint(
        '   - fermentationState 해시: ${widget.fermentationState?.hashCode ?? 'null'}');

    if (_controller == null) {
      debugPrint('🚨 [컨트롤러 오류] _controller가 null임 - 초기화 실패 가능성');
      return;
    }

    try {
      debugPrint('🔧 [컨트롤러 데이터 세팅 시작] - ${DateTime.now()}');
      debugPrint('   - 컨트롤러 인스턴스 해시: ${_controller.hashCode}');

      _controller!.setAnalysisData(
        recipeData: widget.recipeData,
        environment: widget.environment,
      );
      debugPrint('✅ [controller] setAnalysisData 완료');

      _controller!.setMixingResult(widget.mixingResult ?? {});
      debugPrint('✅ [controller] setMixingResult 완료');

      // 🔬 [fermentationState 상세 분석 - 오류 추적]
      debugPrint('🔬 [fermentationState 처리 시작]');
      debugPrint(
          '   - widget.fermentationState 타입: ${widget.fermentationState?.runtimeType ?? 'null'}');

      if (widget.fermentationState == null) {
        debugPrint('⚠️ [fermentationState] null 상태 감지 - 빨간 오류 화면 방지');
        debugPrint('   - 분석 준비 상태 유지 (null 허용)');
        debugPrint('   - 이후 발효 데이터 도착시 재실행 예정');
        // null이면 무시하고 이후 발효 데이터가 도착할 때 setFermentationState 호출
      } else {
        debugPrint('✅ [fermentationState] 데이터 존재 - 상세 분석:');
        debugPrint(
            '   - yeastActivity: ${widget.fermentationState!.yeastActivity.toStringAsFixed(2)}');
        debugPrint(
            '   - acidity: ${widget.fermentationState!.acidity.toStringAsFixed(3)}');
        debugPrint(
            '   - fermentationProgress: ${widget.fermentationState!.fermentationProgress.toStringAsFixed(3)}');
        debugPrint(
            '   - volumeIncrease: ${widget.fermentationState!.volumeIncrease.toStringAsFixed(1)}%');
        debugPrint(
            '   - currentStep: ${widget.fermentationState!.currentStep}');
        debugPrint(
            '   - cumulativeCO2: ${widget.fermentationState!.cumulativeCO2.toStringAsFixed(1)}ml');

        _controller!.setFermentationState(widget.fermentationState!);
        debugPrint('✅ [controller] setFermentationState 완료');

        // ✅ fermentationState 설정 후 강제 분석 시작 (디버깅용)
        debugPrint(
            '🔥 [BakingAnalysisCard] fermentationState 설정됨 - 강제 분석 시작 시도');
        debugPrint('   - isReady: ${_controller!.isReadyForAnalysis}');
        debugPrint('   - isAnalyzing: ${_controller!.isAnalyzing}');
        debugPrint('   - hasMixingResult: ${_controller!.hasMixingResult}');
        debugPrint(
            '   - hasFermentationState: ${_controller!.hasFermentationState}');

        // 분석 준비가 되면 즉시 시작
        if (_controller!.isReadyForAnalysis && !_controller!.isAnalyzing) {
          debugPrint('🚀 [BakingAnalysisCard] 분석 조건 충족 - 분석 시작!');
          _controller!.performBakingAnalysis();
        } else {
          debugPrint('⏳ [BakingAnalysisCard] 분석 조건 미충족');
          if (!_controller!.isReadyForAnalysis) {
            debugPrint('   - 이유: isReadyForAnalysis = false');
          }
          if (_controller!.isAnalyzing) {
            debugPrint('   - 이유: isAnalyzing = true (이미 분석 중)');
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🚨 [치명적 오류] _updateControllerData 실행 중 예외 발생!');
      debugPrint('   - 오류 타입: ${e.runtimeType}');
      debugPrint('   - 오류 메시지: $e');
      debugPrint(
          '   - fermentationState 존재: ${widget.fermentationState != null}');
      debugPrint('   - 컨트롤러 존재: ${_controller != null}');
      debugPrint('   - 컨트롤러 해시: ${_controller?.hashCode}');
      debugPrint('   - 스택 트레이스: $stackTrace');
      // 오류가 발생해도 앱이 죽지 않도록 함 - UI에서는 적절한 메시지 표시
      debugPrint('🛡️ [오류 처리] 앱 안정성 유지 - UI에서 오류 상태 표시');
    }

    debugPrint('🔥 [오븐 베이킹 카드] 컨트롤러 데이터 업데이트 완료');

    // 컨트롤러 상태 강제 로깅 (오류 진단용)
    debugPrint('📊 [컨트롤러 상태 상세 분석]:');
    debugPrint('   - 컨트롤러 타입: ${_controller.runtimeType}');
    debugPrint('   - 컨트롤러 해시코드: ${_controller.hashCode}');
    debugPrint('   - 외부 컨트롤러 여부: ${widget.externalController != null}');
    debugPrint('   - 분석중 상태: ${_controller?.isAnalyzing ?? false}');
    debugPrint('   - 에러 상태: "${_controller?.error ?? 'none'}"');
    debugPrint('   - 준비상태: ${_controller?.isReadyForAnalysis ?? false}');
    debugPrint('   - 믹싱결과 존재: ${_controller?.hasMixingResult ?? false}');
    debugPrint('   - 발효상태 존재: ${_controller?.hasFermentationState ?? false}');
    debugPrint('   - 결과 존재: ${_controller?.analysisResult != null}');
    debugPrint('   - 컨트롤러 포인터: $_controller');

    debugPrint(
        '🔧 [BakingAnalysisCard] _updateControllerData 종료 - ${DateTime.now()}');
  }

  /// ✅ 믹싱 결과 변경 시 자동 분석 트리거
  void _triggerAnalysisIfReady() {
    if (_controller != null &&
        _controller!.isReadyForAnalysis &&
        !_controller!.isAnalyzing &&
        widget.externalController == null) {
      debugPrint('🚀 [오븐 베이킹 카드] 믹싱 결과 준비됨 - 자동 분석 시작');
      _controller!.performBakingAnalysis();
    } else {
      if (_controller == null) debugPrint('⚠️ [오븐 베이킹 카드] 컨트롤러 없음');
      if (!_controller!.isReadyForAnalysis)
        debugPrint('⚠️ [오븐 베이킹 카드] 분석 준비 안됨');
      if (_controller!.isAnalyzing) debugPrint('⚠️ [오븐 베이킹 카드] 이미 분석 중');
      if (widget.externalController != null)
        debugPrint('⚠️ [오븐 베이킹 카드] 외부 컨트롤러 사용');
    }
  }

  /// ✅ [Fix 무한 루프] 타이머 기반 디바운싱 적용
  /// 컨트롤러 상태 변화 감지 - 중복 리빌드 방지
  void _onControllerChanged() {
    debugPrint('🎯 [BakingAnalysisCard] _onControllerChanged 호출 트리거 점검');
    debugPrint('   - 호출 시간: ${DateTime.now()}');
    debugPrint('   - 위젯 해시: ${widget.hashCode}');
    debugPrint('   - 카드 인스턴스 해시: $hashCode');
    debugPrint('   - mounted: $mounted');
    debugPrint('   - 컨트롤러 분석중: ${_controller?.isAnalyzing ?? false}');
    debugPrint('   - 컨트롤러 오류 값: "${_controller?.error}"');
    debugPrint('   - 컨트롤러 오류 != null: ${_controller?.error != null}');
    debugPrint('   - 컨트롤러 오류 타입: ${_controller?.error.runtimeType}');
    debugPrint('   - 컨트롤러 오류: ${_controller?.error != null ? '있음' : '없음'}');
    debugPrint(
        '   - 컨트롤러 결과: ${_controller?.analysisResult != null ? '있음' : '없음'}');
    debugPrint(
        '   - externalController 여부: ${widget.externalController != null}');

    if (!mounted) {
      debugPrint('⚠️ [BakingAnalysisCard] mounted=false, 리턴');
      return;
    }

    // ✅ 타이머 중복 취소 후 재설정 (무한 루프 방지)
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _controller != null) {
        debugPrint('🖼️ [디바운드 setState() 호출]');
        setState(() {});
        debugPrint('🔥 [오븐 베이킹 카드] 컨트롤러 상태 변경 감지 - UI 리빌드');
        debugPrint('🔄 [UI 업데이트] 디바운스 완료');
      }
    });

    debugPrint('🎯 [BakingAnalysisCard] _onControllerChanged 종료');
  }

  @override
  void dispose() {
    // ✅ [Fix 무한 루프] 타이머 정리
    _rebuildTimer?.cancel();

    // 외부 컨트롤러인 경우 dispose하지 않음 (외부에서 관리)
    if (widget.externalController == null) {
      _controller?.dispose();
    } else {
      _controller?.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  /// 🛠️ 분 기반 Duration 포맷팅 헬퍼 - 시간/분 분리 포맷팅 제거, 분 단위만 표시
  String _formatDurationFromMinutes(dynamic minutes) {
    final intValue = minutes is num ? minutes.toInt() : 0;
    return '${intValue}분';
  }

  /// ✅ MixingAnalysisCard 패턴 적용 - 헤더 UI 개선
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🔥 ${l10n.bakingAnalysis}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  debugPrint('🔄 [Refresh 버튼 클릭] 시점 추적 - ${DateTime.now()}');
                  debugPrint('   - 클릭 위치: ${StackTrace.current}');
                  setState(() {}); // 리프레쉬 기능
                  debugPrint('🔄 [Refresh 버튼 클릭] setState 완료');
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                ),
                tooltip: l10n.runAnalysis,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.thermostat_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                // 직접 위젯 파라미터에서 환경 값 가져오기 (MixingAnalysisCard 패턴 적용)
                Row(
                  children: [
                    Text(
                      '${widget.environment.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.water_drop_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.environment.humidity.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 항상 표시되는 분석 결과: 메트릭 카드 → 단계별 분석 순서로 배치
  Widget _buildAnalysisResult() {
    final l10n = AppLocalizations.of(context)!;
    // 🎯 분석 준비 상태 추가 확인
    final hasResult = _controller?.analysisResult != null;
    final hasFermentationState = widget.fermentationState != null;

    debugPrint('🎯 [BakingAnalysisCard._buildAnalysisResult] 상태 확인:');
    debugPrint('   - hasResult: $hasResult');
    debugPrint('   - hasFermentationState: $hasFermentationState');
    debugPrint(
        '   - fermentationState.null: ${widget.fermentationState == null}');

    // ✅ fermentationState가 null이면 발효 분석 대기 상태 표시
    if (!hasFermentationState) {
      debugPrint('⏳ [BakingAnalysisCard] 발효 상태가 아직 준비되지 않아 대기 상태 표시');
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.waitingForFermentationAnalysis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (hasResult) {
      // ✨ 분석 완료: 메트릭 카드 + 단계별 분석 순서로 표시
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 오븐 베이킹 분석 완료 메트릭 카드 (총 시간, 마이야르 반응, 겉빛깔 색상, 성공률)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: _buildBakingMetricsGrid(),
          ),
          const SizedBox(height: 12),
          // 2. 오븐 베이킹 단계별 분석 (원래 기능 유지)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _buildAnalysisResultContent(),
          ),
        ],
      );
    } else {
      // ⏳ 아직 분석 중: 기존 대기 상태 표시
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: _buildWaitingAnalysisResult(l10n),
      );
    }
  }

  /// ✅ 분석 결과 컨텐츠: 단계별 분석 카드만 표시 (상위 제목 제거) ✨
  Widget _buildAnalysisResultContent() {
    // ✅ 상위 Row 제목 제거 - ExpansionTile 제목만 사용
    return _buildExpandableBakingSteps();
  }

  /// ✅ 계산 대기 중 표시 컴포넌트
  Widget _buildWaitingAnalysisResult(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.scientificCalculationsInProgress,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.processingAnalysisData,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 오븐 베이킹 분석 완료 카드 - 실데이터 기반 메트릭
  Widget _buildBakingMetricsGrid() {
    final l10n = AppLocalizations.of(context)!;
    final hasControllerResult = _controller?.analysisResult != null;
    final hasStepAnalysis = _controller?.stepAnalyses.isNotEmpty ?? false;

    debugPrint('🟤 [메트릭 그리드 표시 전 상태 확인]');
    debugPrint('   - 컨트롤러 결과 존재: $hasControllerResult');
    debugPrint('   - 단계 분석 존재: $hasStepAnalysis');
    debugPrint('   - 단계 분석 개수: ${_controller?.stepAnalyses.length ?? 0}');
    debugPrint('   - 분석 진행 중: ${_controller?.isAnalyzing ?? false}');

    final totalBakingTime = _getTotalBakingTime();
    final crustColorValue = _getFinalCrustColor();

    debugPrint('🟤 [오븐 베이킹 카드 메트릭] 실데이터 기반 메트릭 표시');
    debugPrint('   - 총 베이킹 시간: ${totalBakingTime}분');
    debugPrint('   - 최종 겉빛깔 색상 값: $crustColorValue');

    return Column(
      children: [
        // 첫 번째 행: 베이킹 총시간 + 마이야르 반응 값
        Row(
          children: [
            Expanded(
              child: _buildBakingMetricCard(
                '⏱️ ${l10n.totalBakingTime}',
                '${totalBakingTime}분',
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildBakingMetricCard(
                '🟤 ${l10n.totalMaillardReaction}',
                _getFinalCumulativeMaillardReaction().toStringAsFixed(1),
                Colors.brown.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 두 번째 행: 겉빛깔 색상 값 + 크럼브 베이킹 진행률
        Row(
          children: [
            Expanded(
              child: _buildBakingMetricCard(
                '🎨 ${l10n.crustColor}',
                _getCrustColorDisplay(crustColorValue),
                Colors.orange.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildBakingMetricCard(
                '🍞 ${l10n.crumbBakingProgress}',
                _getFinalCumulativeCrumbProgress(),
                Colors.red.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 총 베이킹 시간 계산
  int _getTotalBakingTime() {
    final analysisResult = _controller?.analysisResult;
    if (analysisResult != null && analysisResult.totalBakingTime > 0) {
      return analysisResult.totalBakingTime;
    }

    // 오븐 단계 데이터에서 계산
    try {
      final service = CentralizedParsingService();
      final initData = service.initializeBakingAnalysis(
        recipeData: widget.recipeData,
        environment: widget.environment,
      );

      return initData.ovenSteps
          .fold<int>(0, (sum, step) => sum + ((step['time'] as int?) ?? 0));
    } catch (e) {
      debugPrint('⚠️ [총 베이킹 시간 계산] 오류: $e');
      return 0;
    }
  }

  /// 최종 겉빛깔 색상 값
  double _getFinalCrustColor() {
    final analysisResult = _controller?.analysisResult;
    // 마지막 단계의 누적 마이야르 반응 값을 크러스트 색상으로 사용
    return analysisResult?.finalCumulativeMaillardReaction ?? 0.0;
  }

  /// 겉빛깔 색상 표시 문자열
  String _getCrustColorDisplay(double colorValue) {
    final l10n = AppLocalizations.of(context)!;
    if (colorValue >= 90) return l10n.crustColorDarkBrown;
    if (colorValue >= 70) return l10n.crustColorBrown;
    if (colorValue >= 50) return l10n.crustColorLightBrown;
    if (colorValue >= 30) return l10n.crustColorGolden;
    return l10n.crustColorLightIvory;
  }

  /// 최종 누적 마이야르 반응 값
  double _getFinalCumulativeMaillardReaction() {
    final analysisResult = _controller?.analysisResult;
    return analysisResult?.finalCumulativeMaillardReaction ?? 0.0;
  }

  /// 최종 누적 크럼브 베이킹 진행률
  String _getFinalCumulativeCrumbProgress() {
    final analysisResult = _controller?.analysisResult;
    if (analysisResult != null) {
      return '${analysisResult.finalCumulativeCrumbBakingProgress.toStringAsFixed(1)}%';
    }
    return AppLocalizations.of(context)!.noData;
  }

  /// ✅ MixingAnalysisCard 패턴 적용 - 메트릭 카드 헬퍼 (베이킹용으로 수정)
  Widget _buildBakingMetricCard(String label, String value, Color color) {
    final getMetricIcon = () {
      if (label.contains('시간')) return Icons.schedule_rounded;
      if (label.contains('색상') || label.contains('마이야르'))
        return Icons.palette_rounded;
      if (label.contains('크럼브')) return Icons.cake_rounded;
      return Icons.analytics_rounded;
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(getMetricIcon(), size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ✅ 오븐 베이킹 단계별 분석 리스트 표시 - MixingAnalysisCard 패턴 적용 ✨
  Widget _buildExpandableBakingSteps() {
    final l10n = AppLocalizations.of(context)!;
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    final completedSteps = stepAnalyses.length;
    final totalSteps = _getDynamicBakingTotalSteps();

    debugPrint('🔥 [오븐 베이킹 카드] 확장 가능 단계별 분석 섹션 생성 시작');
    debugPrint('   - 컨트롤러에서 가져온 단계별 분석 개수: ${stepAnalyses.length}');
    debugPrint('   - 완료된 단계 개수: $completedSteps');
    debugPrint('   - 예상 총 단계 개수: $totalSteps');

    // 단계별 분석 데이터가 없으면 빈 컨테이너 표시
    if (completedSteps == 0 && !(_controller?.isAnalyzing ?? false)) {
      debugPrint('⚠️ [오븐 베이킹 카드] 단계별 분석 데이터가 없어 빈 컨테이너 표시');
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.preparingBakingStepData,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ExpansionTile 적용
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 20,
              color: Colors.orange.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.bakingStepAnalysis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.stepProgress(completedSteps, totalSteps),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _buildBakingStepWidgets(), // ✅ 베이킹 패턴 적용: 실시간 단계별 위젯 목록
            ),
          ),
        ],
        initiallyExpanded: false, // 기본적으로 접혀있음
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.grey.shade50,
        iconColor: Colors.orange.shade600,
        collapsedIconColor: Colors.orange.shade600,
      ),
    );
  }

  /// ✅ MixingAnalysisCard 패턴 적용: 실시간 단계별 위젯 생성 ✨
  /// BakingStepCardEnhanced를 사용하여 전문화된 카드 표시
  List<Widget> _buildBakingStepWidgets() {
    final l10n = AppLocalizations.of(context)!;
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    final completedSteps = stepAnalyses.length;
    final totalSteps = _getDynamicBakingTotalSteps();

    debugPrint('🔥 [BakingStepWidgets] 위젯 생성 시작: ${stepAnalyses.length}개 단계');
    final stepWidgets = <Widget>[];

    // 완료된 단계들 표시 (BakingStepCardEnhanced 사용)
    for (int i = 0; i < stepAnalyses.length; i++) {
      final stepAnalysis = stepAnalyses[i];
      stepWidgets.add(
        BakingStepCardEnhanced(
          stepIndex: stepAnalysis.stepNumber - 1,
          analysis: stepAnalysis,
          totalSteps: totalSteps,
        ),
      );

      // 단계 사이에 간격 추가 (마지막 단계 제외)
      if (i < stepAnalyses.length - 1) {
        stepWidgets.add(const SizedBox(height: 8));
      }
    }

    // 진행 중인 단계들 표시 (실시간 업데이트 지원)
    if (_controller?.isAnalyzing ?? false) {
      for (int i = completedSteps; i < totalSteps; i++) {
        final stepNumber = i + 1;
        stepWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.stepNumber(stepNumber),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange.shade400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.scientificBakingCalculationsInProgress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return stepWidgets;
  }

  int _getDynamicBakingTotalSteps() {
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    if (stepAnalyses.isNotEmpty) {
      return stepAnalyses.length;
    }

    // 레시피 데이터에서 실제 베이킹 단계 수 파싱 시도
    try {
      var ovenData = widget.recipeData['ovenSteps'];
      if (ovenData == null) {
        ovenData = widget.recipeData['bakingSteps'];
      }
      if (ovenData == null) {
        ovenData = widget.recipeData['baking_steps'];
      }

      if (ovenData != null) {
        if (ovenData is List) {
          return ovenData.length;
        } else if (ovenData is String) {
          try {
            final parsedList = jsonDecode(ovenData) as List;
            return parsedList.length;
          } catch (_) {
            // JSON 파싱 실패 시
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [동적 베이킹 단계 계산] 오류: $e');
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('🏗️ [BakingAnalysisCard.build] 호출 - 시간: ${DateTime.now()}');
    debugPrint('   - 위젯 해시: ${widget.hashCode}');
    debugPrint('   - 카드 인스턴스 해시: $hashCode');
    debugPrint(
        '   - 컨트롤러 상태: isAnalyzing=${_controller?.isAnalyzing}, hasResult=${_controller?.analysisResult != null}');

    return Card(
      elevation: 4, // 🟰 믹싱카드와 동일한 elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // 🟰 믹싱카드와 동일한 패딩 (12)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ MixingAnalysisCard 패턴: 향상된 헤더
            _buildHeader(),
            const SizedBox(height: 12),

            // ✅ 올바른 괄호 구조로 수정된 조건부 구조
            if (_controller == null) ...[
              // 컨트롤러 초기화 중 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.initializingAnalysisEngine,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_controller?.isAnalyzing == true) ...[
              // 분석 중 표시 (MixingAnalysisCard 패턴 적용)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.performingScientificBakingCalculations,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_controller?.error != null) ...[
              // 분석 오류 표시
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _controller!.error!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ✅ "_buildAnalysisResult()" 메소드 사용으로 "베이킹 분석 완료" 제목 항상 표시 보장
              _buildAnalysisResult(), // 제목 + 조건부 메트릭 그리드 표시
            ],
          ],
        ),
      ),
    );
  }
}
