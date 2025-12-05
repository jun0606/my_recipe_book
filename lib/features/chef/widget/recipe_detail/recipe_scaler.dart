import 'package:flutter/material.dart';
import '../../../../models/recipe.dart';
import '../../../../models/ingredient.dart';
import '../../../../l10n/app_localizations.dart';

/// 파스텔 톤 UI 테마 (부드럽고 따뜻한 색상)
class RecipeScalerTheme {
  // 파스텔 톤 색상 팔레트
  static const Color primaryColor = Color(0xFF81C784); // 민트 그린
  static const Color accentColor = Color(0xFFBA68C8); // 라벤더 퍼플
  static const Color secondaryColor = Color(0xFFFFB74D); // 피치 오렌지
  static const Color backgroundColor = Color(0xFFFFFBF7); // 크림 화이트
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2E2E2E); // 다크 그레이
  static const Color textSecondary = Color(0xFF757575); // 미디엄 그레이
  static const Color borderColor = Color(0xFFE8E8E8); // 라이트 그레이

  // 심플한 그림자 (파스텔 톤에 맞게 부드럽게)
  static BoxShadow subtleShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    spreadRadius: 1,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  // 파스텔 톤 그라데이션
  static LinearGradient softGradient = LinearGradient(
    colors: [
      primaryColor.withOpacity(0.8),
      accentColor.withOpacity(0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 실무형 베이킹 계산기로 BakingCalculator를 대체하는 위젯
/// 베이커스 퍼센트 기반 정확 계산과 직관적인 UI 제공
class RecipeScaler extends StatefulWidget {
  final Recipe recipe;
  final Function(List<Ingredient>)? onIngredientsCalculated;
  final Function(double)? onMultiplierChanged;

  const RecipeScaler({
    Key? key,
    required this.recipe,
    this.onIngredientsCalculated,
    this.onMultiplierChanged,
  }) : super(key: key);

  @override
  State<RecipeScaler> createState() => _RecipeScalerState();
}

class _RecipeScalerState extends State<RecipeScaler> {
  // 계산 모드
  CalculationMode _calculationMode = CalculationMode.percentage;

  // 배율 입력 컨트롤러
  final TextEditingController _multiplierController =
      TextEditingController(text: '1.0');

  // 목표 개수 입력 컨트롤러
  final TextEditingController _targetCountController =
      TextEditingController(text: '1');

  // 기준 재료 선택
  String? _selectedBaseIngredient;

  // 계산 결과
  List<Ingredient> _calculatedIngredients = [];
  double _currentMultiplier = 1.0;

  // 계산 엔진 (직접 구현)

  @override
  void initState() {
    super.initState();
    _calculatedIngredients = List.from(widget.recipe.ingredients);
    _initializeBaseIngredient();
  }

  @override
  void dispose() {
    _multiplierController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  /// 기준 재료 초기화 (밀가루 우선)
  void _initializeBaseIngredient() {
    final flourIngredient = widget.recipe.ingredients.firstWhere(
      (ing) => ing.name.toLowerCase().contains('밀가루'),
      orElse: () => widget.recipe.ingredients.first,
    );
    _selectedBaseIngredient = flourIngredient.name;
  }

  /// 배율 계산 실행 (베이커스 퍼센트 기반)
  void _calculateIngredients() {
    final multiplierText = _multiplierController.text;
    final multiplier = double.tryParse(multiplierText) ?? 1.0;

    // 범위 검증
    if (!ScalerRangeValidator.isValidMultiplier(multiplier)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '배율은 ${ScalerRangeValidator.MIN_MULTIPLIER}배 ~ ${ScalerRangeValidator.MAX_MULTIPLIER}배 사이여야 합니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _currentMultiplier = multiplier;
      _calculatedIngredients = _calculateScaledIngredients(multiplier);
    });

    // 콜백 호출
    widget.onIngredientsCalculated?.call(_calculatedIngredients);
    widget.onMultiplierChanged?.call(multiplier);
  }

  /// 베이커스 퍼센트 기반 재료 계산
  List<Ingredient> _calculateScaledIngredients(double multiplier) {
    // 기준 재료 찾기 (밀가루 우선)
    final baseIngredient = _findBaseIngredient();

    if (baseIngredient == null) {
      // 기준 재료가 없으면 일반 배율 계산
      return widget.recipe.ingredients.map((ingredient) {
        return Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          amount: ingredient.amount * multiplier,
          unit: ingredient.unit,
        );
      }).toList();
    }

    // 베이커스 퍼센트 기반 계산
    final baseAmount = baseIngredient.amount * multiplier;

    return widget.recipe.ingredients.map((ingredient) {
      // 기준 재료는 직접 배율 적용
      if (ingredient.name == baseIngredient.name) {
        return Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          amount: baseAmount,
          unit: ingredient.unit,
        );
      }

      // 다른 재료들은 베이커스 퍼센트 유지
      final bakersPercentage =
          _calculateBakersPercentage(ingredient, baseIngredient);
      final scaledAmount = baseAmount * (bakersPercentage / 100.0);

      return Ingredient(
        id: ingredient.id,
        name: ingredient.name,
        amount: scaledAmount,
        unit: ingredient.unit,
      );
    }).toList();
  }

  /// 기준 재료 찾기
  Ingredient? _findBaseIngredient() {
    // 선택된 기준 재료가 있으면 우선 사용
    if (_selectedBaseIngredient != null) {
      return widget.recipe.ingredients
          .firstWhere((ing) => ing.name == _selectedBaseIngredient);
    }

    // 밀가루 우선 탐색
    try {
      return widget.recipe.ingredients
          .firstWhere((ing) => ing.name.toLowerCase().contains('밀가루'));
    } catch (e) {
      // 밀가루가 없으면 첫 번째 재료 사용
      return widget.recipe.ingredients.isNotEmpty
          ? widget.recipe.ingredients.first
          : null;
    }
  }

  /// 베이커스 퍼센트 계산
  double _calculateBakersPercentage(
      Ingredient ingredient, Ingredient baseIngredient) {
    if (baseIngredient.amount == 0) return 0.0;

    // 기본 베이커스 퍼센트 계산
    return (ingredient.amount / baseIngredient.amount) * 100.0;
  }

  /// 초기화
  void _resetCalculation() {
    setState(() {
      _currentMultiplier = 1.0;
      _multiplierController.text = '1.0';
      _targetCountController.text = '1';
      _calculatedIngredients = List.from(widget.recipe.ingredients);
    });

    widget.onIngredientsCalculated?.call(_calculatedIngredients);
    widget.onMultiplierChanged?.call(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RecipeScalerTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calculate_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.recipeCalculator,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: RecipeScalerTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 계산 컨트롤
            _buildCalculationControls(),

            const SizedBox(height: 20),

            // 전/후 비교 카드
            _buildComparisonCard(),
          ],
        ),
      ),
    );
  }

  /// 계산 컨트롤 UI
  Widget _buildCalculationControls() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecipeScalerTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RecipeScalerTheme.borderColor),
        boxShadow: [RecipeScalerTheme.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: RecipeScalerTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.calculationControl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: RecipeScalerTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 계산 모드 선택
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecipeScalerTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RecipeScalerTheme.borderColor),
            ),
            child: Row(
              children: [
                Text(
                  l10n.calculationMode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RecipeScalerTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: RecipeScalerTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RecipeScalerTheme.borderColor),
                    ),
                    child: DropdownButton<CalculationMode>(
                      value: _calculationMode,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: RecipeScalerTheme.primaryColor,
                      ),
                      items: CalculationMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(
                            mode.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: RecipeScalerTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _calculationMode = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 모드별 입력 필드
          _buildModeSpecificInputField(),
          const SizedBox(height: 12),

          // 기준 재료 선택
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecipeScalerTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RecipeScalerTheme.borderColor),
            ),
            child: Row(
              children: [
                Text(
                  l10n.baseIngredient,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RecipeScalerTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: RecipeScalerTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RecipeScalerTheme.borderColor),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedBaseIngredient,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: RecipeScalerTheme.primaryColor,
                      ),
                      items: widget.recipe.ingredients.map((ingredient) {
                        return DropdownMenuItem(
                          value: ingredient.name,
                          child: Text(
                            ingredient.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: RecipeScalerTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBaseIngredient = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculationMode == CalculationMode.percentage
                      ? _calculateIngredients
                      : _calculateForTargetSplit,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    l10n.runCalculation,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RecipeScalerTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetCalculation,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    l10n.reset,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: RecipeScalerTheme.primaryColor),
                    foregroundColor: RecipeScalerTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 전/후 비교 카드
  Widget _buildComparisonCard() {
    final baseIngredient = _findBaseIngredient();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: RecipeScalerTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RecipeScalerTheme.borderColor),
        boxShadow: [RecipeScalerTheme.subtleShadow],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecipeScalerTheme.primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.originalRecipe,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.calculationResult,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 내용
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RecipeScalerTheme.backgroundColor,
            ),
            child: Column(
              children: [
                // 레시피 비교 정보
                _buildRecipeComparison(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 레시피 비교 정보 (사용자가 원하는 형식)
  Widget _buildRecipeComparison() {
    // 총량 계산
    final originalTotal = widget.recipe.ingredients
        .fold<double>(0, (sum, ing) => sum + ing.amount);
    final calculatedTotal =
        _calculatedIngredients.fold<double>(0, (sum, ing) => sum + ing.amount);

    // 분할개수 계산
    final originalSplitCount = widget.recipe.baseServings;
    final calculatedSplitCount =
        (originalSplitCount * _currentMultiplier).round();

    // 분할 무개 계산 (1인분당 무게)
    final originalWeightPerSplit =
        originalSplitCount > 0 ? originalTotal / originalSplitCount : 0.0;
    final calculatedWeightPerSplit =
        calculatedSplitCount > 0 ? calculatedTotal / calculatedSplitCount : 0.0;

    // 남은재료 무개 (현재는 0으로 가정)
    final remainingWeight = 0.0;

    return Column(
      children: [
        // 총량 비교
        _buildComparisonRow(
          l10n.totalWeight,
          '${originalTotal.toStringAsFixed(1)}g',
          '${calculatedTotal.toStringAsFixed(1)}g',
        ),

        const SizedBox(height: 12),

        // 분할개수 비교
        _buildComparisonRow(
          l10n.splitCount,
          '${originalSplitCount}개',
          '${calculatedSplitCount}개',
        ),

        const SizedBox(height: 12),

        // 분할 무개 비교
        _buildComparisonRow(
          l10n.splitWeight,
          '${originalWeightPerSplit.toStringAsFixed(1)}g',
          '${calculatedWeightPerSplit.toStringAsFixed(1)}g',
        ),

        const SizedBox(height: 12),

        // 남은재료 무개 비교
        _buildComparisonRow(
          l10n.remainingWeight,
          '${remainingWeight.toStringAsFixed(1)}g',
          '${remainingWeight.toStringAsFixed(1)}g',
        ),
      ],
    );
  }

  /// 비교 행 생성 헬퍼 메소드
  Widget _buildComparisonRow(
      String label, String originalValue, String calculatedValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RecipeScalerTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RecipeScalerTheme.borderColor),
        boxShadow: [RecipeScalerTheme.subtleShadow],
      ),
      child: Row(
        children: [
          // 라벨
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: RecipeScalerTheme.textPrimary,
              ),
            ),
          ),

          // 오리지널 레시피 값
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: RecipeScalerTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: RecipeScalerTheme.textSecondary.withOpacity(0.2),
                ),
              ),
              child: Text(
                originalValue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: RecipeScalerTheme.textSecondary,
                ),
              ),
            ),
          ),

          // 화살표
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: RecipeScalerTheme.primaryColor,
            ),
          ),

          // 계산 값
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: RecipeScalerTheme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                calculatedValue,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 베이커스 퍼센트 비교
  Widget _buildBakersPercentageComparison(Ingredient baseIngredient) {
    final l10n = AppLocalizations.of(context)!;
    // 주요 재료들만 표시 (최대 3개)
    final majorIngredients = widget.recipe.ingredients
        .where((ing) {
          return ing.name != baseIngredient.name &&
              ing.amount > 0 &&
              _calculateBakersPercentage(ing, baseIngredient) > 5.0; // 5% 이상만
        })
        .take(3)
        .toList();

    if (majorIngredients.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.bakersPercentageComparison,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...majorIngredients.map((ingredient) {
          final originalPercent =
              _calculateBakersPercentage(ingredient, baseIngredient);
          final calculatedIngredient = _calculatedIngredients.firstWhere(
            (ing) => ing.name == ingredient.name,
            orElse: () => ingredient,
          );
          final calculatedPercent =
              _calculateBakersPercentage(calculatedIngredient, baseIngredient);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildIngredientPercentageRow(
              ingredient.name,
              originalPercent,
              calculatedPercent,
            ),
          );
        }),
      ],
    );
  }

  /// 재료별 퍼센트 행
  Widget _buildIngredientPercentageRow(
      String ingredientName, double originalPercent, double calculatedPercent) {
    final changePercent =
        ((calculatedPercent - originalPercent) / originalPercent * 100);
    final isIncrease = calculatedPercent > originalPercent;
    final hasChange = changePercent.abs() > 0.1;

    return Row(
      children: [
        // 재료명
        Expanded(
          flex: 2,
          child: Text(
            ingredientName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 계산 전 퍼센트
        Expanded(
          child: Text(
            '${originalPercent.toStringAsFixed(1)}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        // 화살표/변화 표시
        Container(
          width: 40,
          alignment: Alignment.center,
          child: hasChange
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIncrease ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isIncrease
                          ? Colors.red.shade400
                          : Colors.blue.shade400,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${changePercent.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isIncrease
                            ? Colors.red.shade600
                            : Colors.blue.shade600,
                      ),
                    ),
                  ],
                )
              : Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green.shade400,
                ),
        ),

        // 계산 후 퍼센트
        Expanded(
          child: Text(
            '${calculatedPercent.toStringAsFixed(1)}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  /// 변화 화살표 표시
  Widget _buildChangeArrow(double multiplier) {
    if (multiplier == 1.0) {
      return Icon(
        Icons.remove,
        size: 12,
        color: Colors.grey.shade400,
      );
    }

    final isIncrease = multiplier > 1.0;
    final changePercent = ((multiplier - 1.0) * 100).round();

    return Row(
      children: [
        Icon(
          isIncrease ? Icons.trending_up : Icons.trending_down,
          size: 12,
          color: isIncrease ? Colors.red.shade600 : Colors.blue.shade600,
        ),
        const SizedBox(width: 2),
        Text(
          '${changePercent.abs()}%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isIncrease ? Colors.red.shade600 : Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  /// 모드별 입력 필드
  Widget _buildModeSpecificInputField() {
    if (_calculationMode == CalculationMode.percentage) {
      // 퍼센트계산 모드: 배율 입력
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RecipeScalerTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RecipeScalerTheme.borderColor),
        ),
        child: Row(
          children: [
            Text(
              '배율:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: RecipeScalerTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: RecipeScalerTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: RecipeScalerTheme.borderColor),
                  boxShadow: [RecipeScalerTheme.subtleShadow],
                ),
                child: TextField(
                  controller: _multiplierController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RecipeScalerTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '1.0',
                    hintStyle: TextStyle(
                      color: RecipeScalerTheme.textSecondary,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: RecipeScalerTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '배',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RecipeScalerTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 목표분할개수 모드: 목표 개수 입력
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RecipeScalerTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RecipeScalerTheme.borderColor),
        ),
        child: Row(
          children: [
            Text(
              '목표 개수:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: RecipeScalerTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: RecipeScalerTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: RecipeScalerTheme.borderColor),
                  boxShadow: [RecipeScalerTheme.subtleShadow],
                ),
                child: TextField(
                  controller: _targetCountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RecipeScalerTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '1',
                    hintStyle: TextStyle(
                      color: RecipeScalerTheme.textSecondary,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: RecipeScalerTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '개',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RecipeScalerTheme.accentColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 목표분할개수 모드 계산 실행
  void _calculateForTargetSplit() {
    final targetCountText = _targetCountController.text;
    final targetCount = int.tryParse(targetCountText) ?? 1;

    if (targetCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('목표 개수는 1개 이상이어야 합니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 레시피의 기본 인분 수를 고려한 배율 계산
    final currentServings = widget.recipe.baseServings.toDouble();
    final multiplier = targetCount / currentServings;

    // 범위 검증
    if (!ScalerRangeValidator.isValidMultiplier(multiplier)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('계산된 배율(${multiplier.toStringAsFixed(2)}배)이 범위를 벗어났습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _currentMultiplier = multiplier;
      _calculatedIngredients = _calculateScaledIngredients(multiplier);
    });

    // 콜백 호출
    widget.onIngredientsCalculated?.call(_calculatedIngredients);
    widget.onMultiplierChanged?.call(multiplier);
  }

  /// 배율 포맷팅
  String _formatMultiplier(double multiplier) {
    if (multiplier == multiplier.roundToDouble()) {
      return multiplier.toInt().toString();
    }
    return multiplier.toStringAsFixed(1);
  }
}

/// 계산 모드 열거형
enum CalculationMode {
  percentage('퍼센트계산'),
  targetSplit('목표분할개수');

  const CalculationMode(this.displayName);
  final String displayName;
}

/// 범위 검증 유틸리티
class ScalerRangeValidator {
  static const double MIN_MULTIPLIER = 0.001;
  static const double MAX_MULTIPLIER = 10000.0;

  static bool isValidMultiplier(double multiplier) {
    return multiplier >= MIN_MULTIPLIER &&
        multiplier <= MAX_MULTIPLIER &&
        multiplier.isFinite;
  }

  static double clampMultiplier(double multiplier) {
    return multiplier.clamp(MIN_MULTIPLIER, MAX_MULTIPLIER);
  }
}
