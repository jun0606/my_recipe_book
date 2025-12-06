// 🎯 발효 분석 카드 컴포넌트 - 컨트롤러 기반 아키텍처 완전 적용
// MixingAnalysisCard와 동일한 패턴으로 FermentationAnalysisController 사용
// ✅ 컨트롤러 기반 상태 관리 및 UI 표시 전문화

import 'dart:async'; // Timer import
import 'dart:convert'; // JSON 파싱용 import 복원
import 'package:flutter/material.dart';
import 'package:my_recipe_book/l10n/app_localizations.dart';
import 'dart:math' as math;
import '../../../../../core/types/environment_types.dart' as env_types;
import '../../../../../core/constants/bread_constants.dart'; // 상수 참조용 import
import '../types/screen_types.dart' as st;
import '../controllers/fermentation_analysis_controller.dart'; // 컨트롤러 import
import 'fermentation_step_card_enhanced.dart'; // 단계별 카드 위젯 import
import '../../../../services/ingredient_analyzer.dart'; // IngredientAnalyzer import
import '../../../../services/centralized_parsing_service.dart'; // CentralizedParsingService import
import '../../../../services/fermentation_calculator.dart'; // FermentationCalculator import 추가

class FermentationAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final env_types.UserEnvironment environment;
  final Map<String, dynamic>? mixingResult; // 믹싱 결과 추가 (컨셉 준수)
  final st.AnalysisSettings settings;
  final FermentationAnalysisController? externalController; // 외부 컨트롤러 지원
  final void Function()? onAnalysisComplete; // 분석 완료 콜백 추가

  const FermentationAnalysisCard({
    super.key,
    required this.recipeData,
    required this.environment,
    this.mixingResult,
    this.settings = const st.AnalysisSettings(),
    this.externalController, // 컨트롤러 공유 지원
    this.onAnalysisComplete,
  });

  @override
  State<FermentationAnalysisCard> createState() =>
      _FermentationAnalysisCardState();
}

class _FermentationAnalysisCardState extends State<FermentationAnalysisCard> {
  /// 컨트롤러 인스턴스
  FermentationAnalysisController? _controller;

  /// ✅ [Fix 무한 루프] 분석 완료 콜백 플래그 추가
  bool _hasCalledCompleteCallback = false;

  /// ✅ [Fix 무한 루프] UI 리빌드 타이머 추가
  Timer? _rebuildTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(FermentationAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalController != oldWidget.externalController ||
        widget.recipeData != oldWidget.recipeData ||
        widget.environment != oldWidget.environment ||
        widget.mixingResult != oldWidget.mixingResult) {
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
    // 외부 컨트롤러 우선 사용, 없으면 내부 생성
    _controller = widget.externalController ?? FermentationAnalysisController();

    // ✅ 단계별 발효 카드 확장 상태 초기화 (기본적으로 모두 펼쳐진 상태)
    _initializeStepExpansionStates();

    // 컨트롤러 데이터 설정 (카드 위젯 파라미터 사용)
    _updateControllerData();

    // 컨트롤러 리스너 설정
    _controller!.addListener(_onControllerChanged);
  }

  /// ✅ 단계별 발효 카드 확장 상태 초기화 (기본적으로 모두 펼쳐진 상태)
  void _initializeStepExpansionStates() {
    // 확장 상태 관리를 위한 초기화 메소드 (향후 확장 가능성 유지)
    debugPrint('🍞 [발효 카드] 단계별 확장 상태 초기화 완료');
  }

  /// 컨트롤러 데이터 업데이트
  void _updateControllerData() {
    if (_controller != null) {
      _controller!.setAnalysisData(
        recipeData: widget.recipeData,
        environment: widget.environment,
      );
      _controller!.setMixingResult(widget.mixingResult ?? {});
      debugPrint('🍞 [발효 카드] 컨트롤러 데이터 업데이트 완료');

      // 컨트롤러 상태 강제 로깅 (문제 진단용)
      debugPrint('🚨 [발효 카드] 컨트롤러 상태 세부 정보:');
      debugPrint('   - 컨트롤러 타입: ${_controller.runtimeType}');
      debugPrint('   - 컨트롤러 해시코드: ${_controller.hashCode}');
      debugPrint('   - 외부 컨트롤러 여부: ${widget.externalController != null}');
      debugPrint('   - 분석중 상태: ${_controller?.isAnalyzing}');
      debugPrint('   - 에러 상태: ${_controller?.error}');
      debugPrint('   - 준비상태: ${_controller?.isReadyForAnalysis}');
      debugPrint('   - 믹싱결과 존재: ${_controller?.hasMixingResult}');
      debugPrint('   - 결과 존재: ${_controller?.analysisResult != null}');

      // 컨트롤러 포인터 로깅 추가
      debugPrint('🔵 _controller 포인터: ${_controller}');
    }
  }

  /// ✅ 믹싱 결과 변경 시 자동 분석 트리거 (외부 컨트롤러 지원 개선)
  void _triggerAnalysisIfReady() {
    if (_controller != null &&
        _controller!.isReadyForAnalysis &&
        !_controller!.isAnalyzing) {
      // ✅ 개선: 외부 컨트롤러가 있어도 분석 데이터가 없다면 자동 분석 시작
      if (widget.externalController != null) {
        if (_controller!.analysisResult == null) {
          debugPrint('🚀 [발효 카드] 외부 컨트롤러 데이터 없음 - 분석 자동 시작');
          _controller!.performAnalysis();
        } else {
          debugPrint('ℹ️ [발효 카드] 외부 컨트롤러에서 이미 분석 완료됨');
        }
      } else {
        debugPrint('🚀 [발효 카드] 내부 컨트롤러 - 자동 분석 시작');
        _controller!.performAnalysis();
      }
    } else {
      if (_controller == null) debugPrint('⚠️ [발효 카드] 컨트롤러 없음');
      if (!_controller!.isReadyForAnalysis) {
        debugPrint('⚠️ [발효 카드] 분석 준비 안됨');
        debugPrint('   - 레시피 데이터: ${widget.recipeData != null ? '있음' : '없음'}');
        debugPrint('   - 환경 데이터: ${widget.environment != null ? '있음' : '없음'}');
        debugPrint(
            '   - 믹싱 결과: ${_controller != null && _controller!.hasMixingResult ? '있음' : '없음'}');
        debugPrint('   - 분석 중: ${_controller?.isAnalyzing ?? false}');
      }
      if (_controller!.isAnalyzing) debugPrint('⚠️ [발효 카드] 이미 분석 중');
    }
  }

  /// ✅ [Fix 무한 루프] 타이머 기반 디바운싱 + 콜백 중복 방지 적용
  /// 컨트롤러 상태 변화 감지 - 중복 리빌드 및 콜백 방지
  void _onControllerChanged() {
    debugPrint('🎯 [발효 카드] _onControllerChanged 호출 트리거 점검');
    debugPrint('   - mounted: $mounted');
    debugPrint('   - _hasCalledCompleteCallback: $_hasCalledCompleteCallback');

    if (!mounted) {
      debugPrint('⚠️ [발효 카드] mounted=false, 리턴');
      return;
    }

    // ✅ 타이머 중복 취소 후 재설정 (무한 루프 방지)
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _controller != null) {
        debugPrint('🖼️ [디바운드 setState() 호출]');
        setState(() {});
        debugPrint('🍞 [발효 카드] 컨트롤러 상태 변경 감지 - UI 리빌드');

        // ✅ 콜백 중복 방지 플래그 확인 후 단 1회 호출
        final hasResult = _controller?.analysisResult != null;
        final wasAnalyzing = _controller?.isAnalyzing == false;

        if (hasResult &&
            wasAnalyzing &&
            widget.onAnalysisComplete != null &&
            !_hasCalledCompleteCallback) {
          _hasCalledCompleteCallback = true; // ✅ 2회 이상 호출 방지
          debugPrint('🚀 [발효 카드] 분석 완료 - 콜백 호출 (최초 1회만)');
          widget.onAnalysisComplete!();
        }
        debugPrint('🔄 [UI 업데이트] 디바운드 완료');
      }
    });

    debugPrint('🎯 [발효 카드] _onControllerChanged 종료');
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade400, Colors.brown.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
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
                Icons.bakery_dining,
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🍞 ${AppLocalizations.of(context)!.fermentationAnalysis}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {}); // 리프레쉬 기능
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                ),
                tooltip: AppLocalizations.of(context)!.runAnalysis,
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
    // 🎯 분석 결과 존재 여부 확인
    final hasResult = _controller?.analysisResult != null;

    if (hasResult) {
      // ✨ 분석 완료: 메트릭 카드 + 단계별 분석 순서로 표시
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 발효 분석 완료 메트릭 카드 (레시피 시간, 글루텐, 수분, 성공률)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: _buildFermentationMetricsGrid(),
          ),
          const SizedBox(height: 12),
          // 2. 발효 단계별 분석 (원래 기능 유지)
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
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: _buildWaitingAnalysisResult(),
      );
    }
  }

  /// ✅ 분석 결과 컨텐츠: 단계별 분석 카드만 표시 (상위 제목 제거) ✨
  Widget _buildAnalysisResultContent() {
    // ✅ 상위 Row 제목 제거 - ExpansionTile 제목만 사용
    return _buildExpandableFermentationSteps();
  }

  /// ✅ 계산 대기 중 표시 컴포넌트
  Widget _buildWaitingAnalysisResult() {
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
                  AppLocalizations.of(context)!
                      .scientificCalculationsInProgress,
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
            AppLocalizations.of(context)!.processingAnalysisData,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 발효 분석 완료 카드 - 실데이터 기반 메트릭
  Widget _buildFermentationMetricsGrid() {
    final hasControllerResult = _controller?.analysisResult != null;
    final hasStepAnalysis = _controller?.stepAnalyses.isNotEmpty ?? false;

    debugPrint('🧪 [메트릭 그리드 표시 전 상태 확인]');
    debugPrint('   - 컨트롤러 결과 존재: $hasControllerResult');
    debugPrint('   - 단계 분석 존재: $hasStepAnalysis');
    debugPrint('   - 단계 분석 개수: ${_controller?.stepAnalyses.length ?? 0}');
    debugPrint('   - 분석 진행 중: ${_controller?.isAnalyzing ?? false}');

    final totalFermentationTime = _getRecipeTotalFermentationTime();
    final completionLevel = _calculateFermentationCompletionLevel();

    debugPrint('🧪 [발효 카드 메트릭] 실데이터 기반 메트릭 표시');
    debugPrint('   - 총 발효시간: ${totalFermentationTime}분 (레시피 합산)');
    debugPrint('   - 발효 완료 레벨: $completionLevel');
    debugPrint('   - 이스트양: 실재료 데이터에서 추출');
    debugPrint('   - 밀가루양: 실재료 데이터에서 추출');
    debugPrint('   - 단계수: 실레시피 데이터에서 계산');

    debugPrint('🐛 [시간 값 계산 과정]');
    debugPrint(
        '   - 컨트롤러 stepAnalyses 길이: ${_controller?.stepAnalyses.length ?? 0}');
    if (_controller?.stepAnalyses.isNotEmpty ?? false) {
      for (int i = 0; i < _controller!.stepAnalyses.length; i++) {
        final step = _controller!.stepAnalyses[i];
        debugPrint('   - 단계 ${i + 1}: ${step.duration.inMinutes}분');
      }
    }
    debugPrint('   - 최종 계산된 총 시간: ${totalFermentationTime}분');

    return Column(
      children: [
        // 첫 번째 행: 발효 총시간 + CO₂ 생성량 (순수 계산 데이터만)
        Row(
          children: [
            Expanded(
              child: _buildFermentationMetricCard(
                '⏱️ ${AppLocalizations.of(context)!.totalFermentationTime}',
                '${totalFermentationTime}분',
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildFermentationMetricCard(
                '🫧 ${AppLocalizations.of(context)!.totalCO2Generation}',
                _getTotalCO2Generation(),
                Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 두 번째 행: 평균 발효 진행률 + 발효 단계수
        Row(
          children: [
            Expanded(
              child: _buildFermentationMetricCard(
                '📊 ${AppLocalizations.of(context)!.totalFermentationProgress}',
                _getTotalFermentationProgress(),
                Colors.green.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildFermentationMetricCard(
                '📋 ${AppLocalizations.of(context)!.fermentationStepCount}',
                _getFermentationStepsCount(),
                Colors.teal.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getYeastAmountFromIngredients() {
    final l10n = AppLocalizations.of(context)!;
    // ✅ 컨트롤러 단계 분석(계산 결과)이 아닌 레시피 재료(원본 데이터)에서 직접 추출
    var ingredients = widget.recipeData['ingredients'];
    if (ingredients is! List) return l10n.noData;

    double totalYeast = 0.0;
    for (var ingredient in ingredients.where((ing) => ing is Map)) {
      final name = (ingredient['name'] as String?)?.toLowerCase() ?? '';
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = (ingredient['unit'] as String?)?.toLowerCase() ?? 'g';

      if (amount <= 0) continue;

      // 이스트 관련 재료 필터링: yeast, 이스트, 드라이이스트 등
      if (name.contains('이스트') ||
          name.contains('yeast') ||
          name.contains('인스턴트이스트') ||
          name.contains('드라이이스트') ||
          name.contains('액티브이스트') ||
          name.contains('생이스트')) {
        // ✅ IngredientAnalyzer 활용 (표준화된 단위 변환)
        double weightInGrams = amount;
        if (unit != 'g' && unit != 'gram') {
          // IngredientAnalyzer.convertToGrams 사용 (표준화된 변환)
          weightInGrams = IngredientAnalyzer.convertToGrams(amount, unit, name);
        }
        totalYeast += weightInGrams;
      }
    }

    return totalYeast > 0 ? '${totalYeast.toStringAsFixed(1)}g' : l10n.noData;
  }

  String _getFlourAmountFromIngredients() {
    final l10n = AppLocalizations.of(context)!;
    // 레시피 재료에서 밀가루 함량 추출
    var ingredients = widget.recipeData['ingredients'];
    if (ingredients is! List) return l10n.noData;

    double totalFlour = 0.0;
    for (var ingredient in ingredients.where((ing) => ing is Map)) {
      final name = (ingredient['name'] as String?)?.toLowerCase() ?? '';
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;

      // 밀가루 관련 재료 필터링: flour, 밀가루, 강력분 등
      if (name.contains('밀가루') ||
          name.contains('flour') ||
          name.contains('강력분') ||
          name.contains('박력분') ||
          name.contains('중력분') ||
          name.contains('전립분')) {
        totalFlour += amount;
      }
    }

    return totalFlour > 0 ? '${totalFlour.toStringAsFixed(1)}g' : l10n.noData;
  }

  String _getFermentationStepsCount() {
    final l10n = AppLocalizations.of(context)!;
    if (_controller?.stepAnalyses != null &&
        _controller!.stepAnalyses.isNotEmpty) {
      return l10n.stepCount(_controller!.stepAnalyses.length);
    }

    return l10n.actualDataUnavailable;
  }

  /// 완료 레벨 제거 (단순 텍스트 표시) - BreadConstants 상수 참조
  String _calculateFermentationCompletionLevel() {
    final l10n = AppLocalizations.of(context)!;
    if (_controller == null || !_controller!.hasStepAnalysis) {
      return l10n.analysisIncomplete;
    }

    final analyses = _controller!.stepAnalyses;
    if (analyses.isEmpty) return l10n.noData;

    // CO₂ 생성량 기반 평가 - 빅데이터 준수 상수 사용
    final totalCo2 = analyses.fold<double>(
        0.0, (sum, analysis) => sum + analysis.gasProduction);
    final avgCo2PerStep =
        analyses.length > 0 ? totalCo2 / analyses.length : 0.0;

    // 빵 과학 연구 기반 상수 적용 (하드코딩 제거):
    if (totalCo2 >= BreadConstants.fermentationCO2ThresholdExcellent &&
        avgCo2PerStep >=
            BreadConstants.fermentationCO2AverageThresholdExcellent) {
      return l10n.fermentationPerfect;
    } else if (totalCo2 >= BreadConstants.fermentationCO2ThresholdGood &&
        avgCo2PerStep >= BreadConstants.fermentationCO2AverageThresholdGood) {
      return l10n.fermentationExcellent;
    } else if (totalCo2 >= BreadConstants.fermentationCO2ThresholdModerate &&
        avgCo2PerStep >=
            BreadConstants.fermentationCO2AverageThresholdModerate) {
      return l10n.fermentationGood;
    } else if (totalCo2 >= BreadConstants.fermentationCO2ThresholdMinimum &&
        avgCo2PerStep >=
            BreadConstants.fermentationCO2AverageThresholdMinimum) {
      return l10n.fermentationAverage;
    } else {
      return l10n.fermentationPoor;
    }
  }

  /// 완료 레벨 색상 결정
  Color _getCompletionLevelColor(String level) {
    final l10n = AppLocalizations.of(context)!;
    if (level == l10n.fermentationPerfect) {
      return Colors.green.shade700;
    } else if (level == l10n.fermentationExcellent) {
      return Colors.blue.shade700;
    } else if (level == l10n.fermentationGood) {
      return Colors.orange.shade700;
    } else if (level == l10n.fermentationAverage) {
      return Colors.amber.shade700;
    } else if (level == l10n.fermentationPoor) {
      return Colors.red.shade700;
    } else {
      return Colors.grey.shade600;
    }
  }

  /// 총 CO₂ 생성량 계산 - 마지막 단계의 누적 값 직접 사용 (빵 과학적 L 단위 표시)
  String _getTotalCO2Generation() {
    final l10n = AppLocalizations.of(context)!;
    if (_controller == null || !_controller!.hasStepAnalysis) {
      debugPrint('🧪 [메트릭 총 CO2] 컨트롤러 없음 또는 단계 분석 없음');
      return AppLocalizations.of(context)!.noData;
    }

    final analyses = _controller!.stepAnalyses;
    debugPrint('🧪 [메트릭 총 CO2] stepAnalyses 길이: ${analyses.length}');
    if (analyses.isEmpty) {
      debugPrint('🧪 [메트릭 총 CO2] stepAnalyses가 비어있음');
      return '0.0L';
    }

    // 마지막 단계의 누적 CO₂를 직접 사용 (별도 계산 불필요)
    final totalCO2 = analyses.last.cumulativeCO2;
    debugPrint('🧪 [메트릭 총 CO2] 마지막 단계 cumulativeCO2: $totalCO2');
    debugPrint(
        '🧪 [메트릭 총 CO2] 마지막 단계 누적 값 사용: ${totalCO2.toStringAsFixed(4)}ml');

    // NaN 또는 Infinity 방지
    if (totalCO2.isNaN || totalCO2.isInfinite) {
      debugPrint('🚨 [메트릭 총 CO2] NaN/Infinite 감지: $totalCO2');
      return '0.0L';
    }

    // 빵 과학적 표시: ml를 L로 변환하여 현실적인 값 표시
    final totalCO2InLiters = totalCO2 / 1000.0;
    debugPrint(
        '🧪 [메트릭 총 CO2] L 단위 변환: ${totalCO2InLiters.toStringAsFixed(3)}L');

    return '${totalCO2InLiters.toStringAsFixed(2)}L';
  }

  /// 총 발효 진행률 합산 - 컨트롤러에서 통일된 총 진행률 사용
  String _getTotalFermentationProgress() {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('🔍 [총 진행률 비교 디버깅 시작]');

    // 컨트롤러의 통합된 총 진행률
    final controllerTotalProgress =
        _controller?.analysisResult?.data?['totalFermentationProgress'];
    debugPrint(
        '   - 컨트롤러 총 진행률: $controllerTotalProgress (${controllerTotalProgress?.runtimeType})');

    // 단계 분석의 마지막 단계 진행률
    final lastStepProgress = _controller?.stepAnalyses.isNotEmpty ?? false
        ? _controller!.stepAnalyses.last.fermentationProgress
        : null;
    debugPrint(
        '   - 마지막 단계 진행률: $lastStepProgress (${lastStepProgress?.runtimeType})');

    // 값 비교
    if (controllerTotalProgress is num && lastStepProgress is num) {
      final diff =
          controllerTotalProgress.toDouble() - (lastStepProgress ?? 0.0);
      debugPrint('   - 차이: $diff (컨트롤러 - 마지막단계)');
    }

    if (_controller?.analysisResult?.data != null) {
      // 컨트롤러에서 통일된 총 진행률 사용 (빅데이터 준수 - clamp 제거)
      final totalProgress =
          _controller!.analysisResult!.data['totalFermentationProgress'];
      if (totalProgress is num) {
        // 빅데이터 준수: 계산 그대로 사용, clamp 제거
        final progress = totalProgress.toDouble();
        debugPrint(
            '✅ [결과] 컨트롤러 총 진행률 사용: ${(progress * 100).toStringAsFixed(1)}%');
        return '${(progress * 100).toStringAsFixed(1)}%';
      }
    }

    // Fallback: 기존 방식 사용
    if (_controller?.stepAnalyses.isNotEmpty ?? false) {
      final finalProgress = _controller!.stepAnalyses.last.fermentationProgress;
      debugPrint(
          '✅ [결과] Fallback 마지막 단계 진행률 사용: ${(finalProgress * 100).toStringAsFixed(1)}%');
      return '${(finalProgress * 100).toStringAsFixed(1)}%';
    }

    return l10n.noData;
  }

  /// ✅ MixingAnalysisCard 패턴 적용 - 메트릭 카드 헬퍼
  Widget _buildFermentationMetricCard(String label, String value, Color color) {
    final getMetricIcon = () {
      if (label.contains('시간')) return Icons.schedule_rounded;
      if (label.contains('부피'))
        return Icons.monitor_weight_rounded; // 📊 부피 확장률
      if (label.contains('산 생성')) return Icons.science_rounded; // 🧪 산 생성
      if (label.contains('발효 진행률'))
        return Icons.rotate_right_rounded; // 🔄 발효 진행률
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
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
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

  /// ✅ 발효 단계별 분석 리스트 표시 - MixingAnalysisCard 패턴 적용 ✨
  /// 믹싱 카드처럼 단계별 실시간 업데이트 지원
  Widget _buildExpandableFermentationSteps() {
    final l10n = AppLocalizations.of(context)!;
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    final completedSteps = stepAnalyses.length;
    final totalSteps = _getDynamicFermentationTotalSteps(); // ✅ 하드코딩 제거!

    debugPrint('🍞 [발효 카드] 확장 가능 단계별 분석 섹션 생성 시작');
    debugPrint('   - 컨트롤러에서 가져온 단계별 분석 개수: ${stepAnalyses.length}');
    debugPrint('   - 완료된 단계 개수: $completedSteps');
    debugPrint('   - 예상 총 단계 개수: $totalSteps');

    // 단계별 분석 데이터가 없으면 빈 컨테이너 표시
    if (completedSteps == 0 && !(_controller?.isAnalyzing ?? false)) {
      debugPrint('⚠️ [발효 카드] 단계별 분석 데이터가 없어 빈 컨테이너 표시');
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
                l10n.preparingAnalysisData,
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
              Icons.layers_rounded,
              size: 20,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.fermentationAnalysisTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${completedSteps}/${totalSteps}단계',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.6, // 화면의 60%로 제한하여 overflow 방지
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children:
                      _buildFermentationStepWidgets(), // ✅ 믹싱 패턴 적용: 실시간 단계별 위젯 목록
                ),
              ),
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
        iconColor: Colors.blue.shade600,
        collapsedIconColor: Colors.blue.shade600,
      ),
    );
  }

  /// ✅ 믹싱 카드 패턴 적용: 실시간 단계별 FermentationStepCardEnhanced 위젯 생성 ✨
  /// 컨트롤러의 stepAnalyses 데이터를 기반으로 위젯 목록 생성
  List<Widget> _buildFermentationStepWidgets() {
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    final totalSteps = _getDynamicFermentationTotalSteps();

    debugPrint(
        '🍞 [FermentationStepWidgets] 위젯 생성 시작: ${stepAnalyses.length}개 단계');

    if (stepAnalyses.isEmpty) {
      debugPrint('⚠️ [FermentationStepWidgets] stepAnalyses가 비어있음 - UI에 미표시');
      return []; // 빈 리스트 반환
    }

    final stepWidgets = <Widget>[];

    for (int i = 0; i < stepAnalyses.length; i++) {
      final stepAnalysis = stepAnalyses[i];
      debugPrint('🧪 [FermentationStepWidgets] 단계 ${i + 1} 위젯 생성 시작');
      debugPrint(
          '   - stepAnalysis.cumulativeCO2: ${stepAnalysis.cumulativeCO2}');

      final stepCard = FermentationStepCardEnhanced(
        stepIndex: i,
        stepAnalysis: stepAnalysis,
        totalSteps: totalSteps,
      );

      stepWidgets.add(stepCard);
      debugPrint('✅ [FermentationStepWidgets] 단계 ${i + 1} 위젯 생성 완료 - 카드 추가됨');

      // 단계 사이에 간격 추가 (마지막 단계 제외)
      if (i < stepAnalyses.length - 1) {
        stepWidgets.add(const SizedBox(height: 8));
      }
    }

    debugPrint(
        '🎯 [FermentationStepWidgets] 위젯 목록 생성 완료: ${stepWidgets.length}개 항목');
    return stepWidgets;
  }

  int _getDynamicFermentationTotalSteps() {
    final stepAnalyses = _controller?.stepAnalyses ?? [];
    if (stepAnalyses.isNotEmpty) {
      return stepAnalyses.length;
    }

    // 레시피 데이터에서 실제 발효 단계 수 파싱 시도
    try {
      var fermentationData = widget.recipeData['fermentationSteps'];
      if (fermentationData == null) {
        fermentationData = widget.recipeData['fermentation_steps'];
      }
      if (fermentationData == null) {
        fermentationData = widget.recipeData['fermentationStages'];
      }
      if (fermentationData == null) {
        fermentationData = widget.recipeData['fermentation'];
      }

      if (fermentationData != null) {
        if (fermentationData is List) {
          return fermentationData.length;
        } else if (fermentationData is String) {
          try {
            final parsedList = jsonDecode(fermentationData) as List;
            return parsedList.length;
          } catch (_) {
            // JSON 파싱 실패 시
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [동적 단계 계산] 레시피 데이터에서 단계 수 추출 실패: $e');
    }

    return 0;
  }

  /// 컨셉 준수: 중앙화된 발효 총시간을 직접 사용 - 분산 계산 제거
  int _getRecipeTotalFermentationTime() {
    // 컨트롤러의 중앙화된 발효 결과에서 총 시간 직접 추출
    final analysisResult = _controller?.analysisResult;
    if (analysisResult != null &&
        analysisResult.success &&
        analysisResult.data != null) {
      final totalTime = analysisResult.data['fermentationTotalElapsedTime'];
      if (totalTime is int) {
        return totalTime;
      }
    }

    // 계산되지 않은 경우 0분 반환
    debugPrint('⚠️ [UI 시간 계산] 중앙화된 총 시간 데이터 없음 - 기본값 0분');
    return 0;
  }

  /// 컨셉 준수: UI 위젯에서도 직접 계산 시 최단 경로만 유지
  /// 복잡한 계산 로직은 컨트롤러에게 위임
  int _calculateTotalFermentationTimeFromRecipe() {
    try {
      // CentralizedParsingService 활용 - 실제 데이터 기반 시간 계산
      final service = CentralizedParsingService();
      final initData = service.initializeFermentationAnalysis(
        recipeData: widget.recipeData,
        environment: widget.environment,
      );

      // 발효 단계 추출
      final fermentationSteps =
          service.extractFermentationSteps(widget.recipeData);
      debugPrint('🍞 [서비스 기반 시간 계산] 단계 전체 데이터: ${fermentationSteps.length}개');

      if (fermentationSteps.isEmpty) {
        debugPrint('⚠️ [서비스 기반 시간 계산] 발효 단계 데이터 없음 - 빅데이터 제거: 사용자 입력 데이터만 사용');
        return 0; // 빅데이터 제거: 사용자 입력 데이터만 사용
      }

      // 각 단계의 duration 합산 (단순 계산만)
      int totalMinutes = 0;
      for (int i = 0; i < fermentationSteps.length; i++) {
        final step = fermentationSteps[i];
        if (step is Map<String, dynamic>) {
          // 시간 키 우선순위 검색
          final durationHours = step['durationHours'] as num?;
          final durationMinutes = step['duration'] as num?;
          final timeValue = step['time'] as num?;

          num? finalTimeMinutes;

          if (durationHours != null && durationHours > 0) {
            // 이미 시간 단위로 저장된 경우
            finalTimeMinutes = (durationHours * 60).toInt();
            debugPrint(
                '   단계 $i: durationHours ${durationHours}h → ${finalTimeMinutes}분');
          } else if (durationMinutes != null && durationMinutes > 0) {
            // 분 단위로 저장된 경우
            finalTimeMinutes = durationMinutes.toInt();
            debugPrint('   단계 $i: duration ${durationMinutes}분');
          } else if (timeValue != null && timeValue > 0) {
            // 일반 time 값일 경우 단위 판별
            if (timeValue > 50) {
              // 50보다 크면 시간 단위
              finalTimeMinutes = (timeValue * 60).toInt();
              debugPrint('   단계 $i: time ${timeValue}h → ${finalTimeMinutes}분');
            } else {
              // 50이하면 분 단위
              finalTimeMinutes = timeValue.toInt();
              debugPrint('   단계 $i: time ${timeValue}분');
            }
          } else {
            debugPrint('   단계 $i: 유효한 시간 값 없음');
            continue;
          }

          totalMinutes += finalTimeMinutes.toInt();
        }
      }

      final result = totalMinutes; // 빅데이터 제거: 사용자 입력 데이터만 계산
      debugPrint('✅ [서비스 기반 시간 계산] 총 발효 시간: ${result}분 (빅데이터 제거 - 순수 실데이터)');

      return result;
    } catch (e) {
      debugPrint('❌ [서비스 기반 시간 계산] 서비스 호출 실패: $e - 빅데이터 제거: 계산 불가');
      return 0; // 빅데이터 제거: 계산 불가 시 0분
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        '분석 엔진 초기화 중...',
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '빵 제조 과학적 발효 계산 수행 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
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
              // ✅ "_buildAnalysisResult()" 메소드 사용으로 "발효 분석 완료" 제목 항상 표시 보장
              _buildAnalysisResult(), // 제목 + 조건부 메트릭 그리드 표시
            ],
          ],
        ),
      ),
    );
  }
}
