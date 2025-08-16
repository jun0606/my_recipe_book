import 'package:flutter/material.dart';
import 'package:my_recipe_book/models/enhanced_recipe.dart';
import 'package:my_recipe_book/models/baking_calculation_result.dart';
import 'package:my_recipe_book/models/user_configuration.dart';

/// 계산기 모듈의 기본 인터페이스
abstract class CalculatorModule extends StatefulWidget {
  final String id;
  final String title;
  final ModuleType type;
  final Size preferredSize;
  final bool isResizable;
  final EnhancedRecipe? recipe;
  final Function(BakingCalculationResult)? onCalculationChanged;

  const CalculatorModule({
    Key? key,
    required this.id,
    required this.title,
    required this.type,
    this.preferredSize = const Size(300, 200),
    this.isResizable = true,
    this.recipe,
    this.onCalculationChanged,
  }) : super(key: key);

  /// 모듈의 설정 가능한 옵션들
  Map<String, dynamic> get configurableOptions => {};

  /// 모듈이 현재 레시피와 호환되는지 확인
  bool isCompatibleWith(EnhancedRecipe recipe) => true;

  /// 모듈의 도움말 텍스트
  String get helpText => '';

  /// 모듈의 아이콘
  IconData get icon => Icons.calculate;
}

/// 모듈 타입 열거형
enum ModuleType {
  basicCalculator,
  bakersPercentage,
  scaling,
  unitConversion,
  environmentalAdjustment,
  costAnalysis,
  substitution,
  fermentationTiming,
  yieldPrediction,
}

/// 모듈 정보를 담는 클래스
class ModuleInfo {
  final String id;
  final String title;
  final String description;
  final ModuleType type;
  final IconData icon;
  final Size preferredSize;
  final bool isResizable;
  final List<String> requiredFeatures;
  final UserMode minimumMode;

  const ModuleInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    this.preferredSize = const Size(300, 200),
    this.isResizable = true,
    this.requiredFeatures = const [],
    this.minimumMode = UserMode.homeBaker,
  });

  /// defaultSize는 preferredSize의 별칭
  Size get defaultSize => preferredSize;
}

/// 모듈 레지스트리 - 사용 가능한 모든 모듈 관리
class ModuleRegistry {
  static const List<ModuleInfo> _availableModules = [
    ModuleInfo(
      id: 'basic_calculator',
      title: '기본 계산기',
      description: '레시피의 기본적인 스케일링과 계산을 수행합니다',
      type: ModuleType.basicCalculator,
      icon: Icons.calculate,
      preferredSize: Size(350, 250),
    ),
    ModuleInfo(
      id: 'bakers_percentage',
      title: '베이커스 퍼센트',
      description: '베이커스 퍼센트를 계산하고 표시합니다',
      type: ModuleType.bakersPercentage,
      icon: Icons.percent,
      preferredSize: Size(300, 300),
      minimumMode: UserMode.professional,
    ),
    ModuleInfo(
      id: 'scaling',
      title: '스케일링',
      description: '레시피 양을 조절하고 스케일링합니다',
      type: ModuleType.scaling,
      icon: Icons.straighten,
      preferredSize: Size(280, 200),
    ),
    ModuleInfo(
      id: 'unit_conversion',
      title: '단위 변환',
      description: '다양한 단위 간 변환을 수행합니다',
      type: ModuleType.unitConversion,
      icon: Icons.swap_horiz,
      preferredSize: Size(320, 220), // 높이를 약간 늘림
    ),
    ModuleInfo(
      id: 'environmental_adjustment',
      title: '환경 보정',
      description: '고도, 습도, 온도에 따른 레시피 보정을 수행합니다',
      type: ModuleType.environmentalAdjustment,
      icon: Icons.thermostat,
      preferredSize: Size(360, 280),
      minimumMode: UserMode.professional,
    ),
    ModuleInfo(
      id: 'cost_analysis',
      title: '원가 분석',
      description: '재료비와 원가를 분석합니다',
      type: ModuleType.costAnalysis,
      icon: Icons.attach_money,
      preferredSize: Size(340, 220),
      minimumMode: UserMode.professional,
    ),
    ModuleInfo(
      id: 'substitution',
      title: '재료 대체',
      description: '재료 대체 옵션을 제안합니다',
      type: ModuleType.substitution,
      icon: Icons.swap_vert,
      preferredSize: Size(300, 250),
      minimumMode: UserMode.professional,
    ),
    ModuleInfo(
      id: 'fermentation_timing',
      title: '발효 타이밍',
      description: '발효 시간과 온도를 계산합니다',
      type: ModuleType.fermentationTiming,
      icon: Icons.timer,
      preferredSize: Size(320, 240),
      minimumMode: UserMode.research,
    ),
    ModuleInfo(
      id: 'yield_prediction',
      title: '수율 예측',
      description: '완성품 수율과 손실률을 예측합니다',
      type: ModuleType.yieldPrediction,
      icon: Icons.trending_up,
      preferredSize: Size(300, 200),
      minimumMode: UserMode.research,
    ),
  ];

  /// 모든 사용 가능한 모듈 정보 반환
  static List<ModuleInfo> get availableModules => _availableModules;

  /// ID로 모듈 정보 찾기
  static ModuleInfo? getModuleInfo(String id) {
    try {
      return _availableModules.firstWhere((module) => module.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 사용자 모드에 따른 사용 가능한 모듈 필터링
  static List<ModuleInfo> getModulesForUserMode(UserMode userMode) {
    return _availableModules.where((module) {
      switch (userMode) {
        case UserMode.homeBaker:
          return module.minimumMode == UserMode.homeBaker;
        case UserMode.professional:
          return module.minimumMode == UserMode.homeBaker ||
                 module.minimumMode == UserMode.professional;
        case UserMode.research:
          return true; // 모든 모듈 사용 가능
      }
    }).toList();
  }

  /// 모듈 타입으로 모듈 정보 찾기
  static ModuleInfo? getModuleInfoByType(ModuleType type) {
    try {
      return _availableModules.firstWhere((module) => module.type == type);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리별 모듈 그룹화
  static Map<String, List<ModuleInfo>> getModulesByCategory() {
    return {
      '기본 계산': _availableModules.where((m) => 
        [ModuleType.basicCalculator, ModuleType.scaling, ModuleType.unitConversion]
        .contains(m.type)).toList(),
      '고급 분석': _availableModules.where((m) => 
        [ModuleType.bakersPercentage, ModuleType.environmentalAdjustment, ModuleType.costAnalysis]
        .contains(m.type)).toList(),
      '전문 도구': _availableModules.where((m) => 
        [ModuleType.substitution, ModuleType.fermentationTiming, ModuleType.yieldPrediction]
        .contains(m.type)).toList(),
    };
  }
}

/// 모듈 팩토리 - 모듈 인스턴스 생성
class ModuleFactory {
  /// 사용 가능한 모든 모듈 정보 반환 (ModuleRegistry의 래퍼)
  static List<ModuleInfo> getAvailableModules() {
    return ModuleRegistry.availableModules;
  }

  static CalculatorModule? createModule({
    required String moduleId,
    EnhancedRecipe? recipe,
    Function(BakingCalculationResult)? onCalculationChanged,
  }) {
    final moduleInfo = ModuleRegistry.getModuleInfo(moduleId);
    if (moduleInfo == null) return null;

    switch (moduleInfo.type) {
      case ModuleType.basicCalculator:
        return BasicCalculatorModule(
          id: moduleId,
          title: moduleInfo.title,
          type: moduleInfo.type,
          preferredSize: moduleInfo.preferredSize,
          recipe: recipe,
          onCalculationChanged: onCalculationChanged,
        );
      case ModuleType.bakersPercentage:
        return BakersPercentageModule(
          id: moduleId,
          title: moduleInfo.title,
          type: moduleInfo.type,
          preferredSize: moduleInfo.preferredSize,
          recipe: recipe,
          onCalculationChanged: onCalculationChanged,
        );
      case ModuleType.scaling:
        return ScalingModule(
          id: moduleId,
          title: moduleInfo.title,
          type: moduleInfo.type,
          preferredSize: moduleInfo.preferredSize,
          recipe: recipe,
          onCalculationChanged: onCalculationChanged,
        );
      case ModuleType.unitConversion:
        return UnitConversionModule(
          id: moduleId,
          title: moduleInfo.title,
          type: moduleInfo.type,
          preferredSize: moduleInfo.preferredSize,
          recipe: recipe,
          onCalculationChanged: onCalculationChanged,
        );
      default:
        return null; // 아직 구현되지 않은 모듈
    }
  }
}

/// 기본 계산기 모듈 (예시 구현)
class BasicCalculatorModule extends CalculatorModule {
  const BasicCalculatorModule({
    Key? key,
    required String id,
    required String title,
    required ModuleType type,
    Size preferredSize = const Size(350, 250),
    EnhancedRecipe? recipe,
    Function(BakingCalculationResult)? onCalculationChanged,
  }) : super(
    key: key,
    id: id,
    title: title,
    type: type,
    preferredSize: preferredSize,
    recipe: recipe,
    onCalculationChanged: onCalculationChanged,
  );

  @override
  IconData get icon => Icons.calculate;

  @override
  String get helpText => '레시피의 기본적인 스케일링과 계산을 수행합니다.';

  @override
  State<BasicCalculatorModule> createState() => _BasicCalculatorModuleState();
}

class _BasicCalculatorModuleState extends State<BasicCalculatorModule> {
  double _scaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.preferredSize.width,
          height: widget.preferredSize.height,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 행 - 고정 높이
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Icon(widget.icon, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline, size: 14),
                        onPressed: () => _showHelpDialog(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // 나머지 내용을 Expanded로 감싸서 남은 공간 활용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('스케일링 팩터', style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Slider(
                        value: _scaleFactor,
                        min: 0.1,
                        max: 5.0,
                        divisions: 49,
                        label: '${_scaleFactor.toStringAsFixed(1)}x',
                        onChanged: (value) {
                          setState(() {
                            _scaleFactor = value;
                          });
                          _performCalculation();
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPresetButton('1/2', 0.5),
                          _buildPresetButton('1x', 1.0),
                          _buildPresetButton('2x', 2.0),
                          _buildPresetButton('3x', 3.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, double value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _scaleFactor = value;
            });
            _performCalculation();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4),
            minimumSize: const Size(0, 28),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }

  void _performCalculation() {
    if (widget.recipe != null && widget.onCalculationChanged != null) {
      // 실제 계산 로직은 여기에 구현
      // 지금은 더미 결과 생성
      final result = BakingCalculationResult(
        originalRecipe: widget.recipe!,
        calculatedRecipe: widget.recipe!,
        calculationMode: BakingCalculationMode.scaleAdjustment,
        calculations: {'scaleFactor': _scaleFactor},
        scale: _scaleFactor,
      );
      widget.onCalculationChanged!(result);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Text(widget.helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 다른 모듈들의 기본 구현 (실제로는 별도 파일에 구현)
class BakersPercentageModule extends CalculatorModule {
  const BakersPercentageModule({
    Key? key,
    required String id,
    required String title,
    required ModuleType type,
    Size preferredSize = const Size(300, 300),
    EnhancedRecipe? recipe,
    Function(BakingCalculationResult)? onCalculationChanged,
  }) : super(
    key: key,
    id: id,
    title: title,
    type: type,
    preferredSize: preferredSize,
    recipe: recipe,
    onCalculationChanged: onCalculationChanged,
  );

  @override
  State<BakersPercentageModule> createState() => _BakersPercentageModuleState();
}

class _BakersPercentageModuleState extends State<BakersPercentageModule> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.preferredSize.width,
          height: widget.preferredSize.height,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 행 - 고정 높이
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Icon(Icons.percent, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // 나머지 내용을 Expanded로 감싸서 남은 공간 활용
              const Expanded(
                child: Center(
                  child: Text(
                    '베이커스 퍼센트 계산 모듈\n(구현 예정)',
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScalingModule extends CalculatorModule {
  const ScalingModule({
    Key? key,
    required String id,
    required String title,
    required ModuleType type,
    Size preferredSize = const Size(320, 240),
    EnhancedRecipe? recipe,
    Function(BakingCalculationResult)? onCalculationChanged,
  }) : super(
    key: key,
    id: id,
    title: title,
    type: type,
    preferredSize: preferredSize,
    recipe: recipe,
    onCalculationChanged: onCalculationChanged,
  );

  @override
  IconData get icon => Icons.straighten;

  @override
  String get helpText => '레시피 양을 목표 무게나 인분 수에 맞춰 조절합니다.';

  @override
  State<ScalingModule> createState() => _ScalingModuleState();
}

class _ScalingModuleState extends State<ScalingModule> {
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  double _currentTotalWeight = 0.0;
  bool _useWeight = true;

  @override
  void initState() {
    super.initState();
    _calculateCurrentWeight();
  }

  void _calculateCurrentWeight() {
    if (widget.recipe != null) {
      double total = 0.0;
      for (final ingredient in widget.recipe!.ingredients) {
        final amount = ingredient.amount;
        total += amount;
      }
      setState(() {
        _currentTotalWeight = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.preferredSize.width,
          height: widget.preferredSize.height,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 행 - 고정 높이
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Icon(widget.icon, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline, size: 14),
                        onPressed: () => _showHelpDialog(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // 나머지 내용을 Expanded로 감싸서 남은 공간 활용
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '현재 총 무게: ${_currentTotalWeight.toStringAsFixed(0)}g',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      
                      // 스케일링 방법 선택
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('무게로', style: TextStyle(fontSize: 10)),
                                value: true,
                                groupValue: _useWeight,
                                onChanged: (value) {
                                  setState(() {
                                    _useWeight = value ?? true;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('인분으로', style: TextStyle(fontSize: 10)),
                                value: false,
                                groupValue: _useWeight,
                                onChanged: (value) {
                                  setState(() {
                                    _useWeight = value ?? true;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // 입력 필드
                      SizedBox(
                        height: 40,
                        child: _useWeight 
                          ? TextField(
                              controller: _targetWeightController,
                              decoration: const InputDecoration(
                                labelText: '목표 무게 (g)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                labelStyle: TextStyle(fontSize: 10),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 11),
                              onChanged: (_) => _performScaling(),
                            )
                          : TextField(
                              controller: _servingsController,
                              decoration: const InputDecoration(
                                labelText: '목표 인분 수',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                labelStyle: TextStyle(fontSize: 10),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 11),
                              onChanged: (_) => _performScaling(),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performScaling() {
    if (widget.recipe == null || widget.onCalculationChanged == null) return;

    double scaleFactor = 1.0;
    
    if (_useWeight) {
      final targetWeight = double.tryParse(_targetWeightController.text) ?? 0.0;
      if (targetWeight > 0 && _currentTotalWeight > 0) {
        scaleFactor = targetWeight / _currentTotalWeight;
      }
    } else {
      final targetServings = double.tryParse(_servingsController.text) ?? 0.0;
      final currentServings = widget.recipe!.baseServings.toDouble();
      if (targetServings > 0 && currentServings > 0) {
        scaleFactor = targetServings / currentServings;
      }
    }

    final result = BakingCalculationResult(
      originalRecipe: widget.recipe!,
      calculatedRecipe: widget.recipe!,
      calculationMode: BakingCalculationMode.scaleAdjustment,
      calculations: {
        'scaleFactor': scaleFactor,
        'method': _useWeight ? 'weight' : 'servings',
        'targetWeight': _useWeight ? double.tryParse(_targetWeightController.text) : null,
        'targetServings': !_useWeight ? double.tryParse(_servingsController.text) : null,
      },
      scale: scaleFactor,
    );
    
    widget.onCalculationChanged!(result);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Text(widget.helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _servingsController.dispose();
    super.dispose();
  }
}

class UnitConversionModule extends CalculatorModule {
  const UnitConversionModule({
    Key? key,
    required String id,
    required String title,
    required ModuleType type,
    Size preferredSize = const Size(360, 280),
    EnhancedRecipe? recipe,
    Function(BakingCalculationResult)? onCalculationChanged,
  }) : super(
    key: key,
    id: id,
    title: title,
    type: type,
    preferredSize: preferredSize,
    recipe: recipe,
    onCalculationChanged: onCalculationChanged,
  );

  @override
  IconData get icon => Icons.swap_horiz;

  @override
  String get helpText => '다양한 단위 간 변환을 수행합니다. 무게, 부피, 온도 변환을 지원합니다.';

  @override
  State<UnitConversionModule> createState() => _UnitConversionModuleState();
}

class _UnitConversionModuleState extends State<UnitConversionModule> {
  final TextEditingController _inputController = TextEditingController();
  String _fromUnit = 'g';
  String _toUnit = 'kg';
  String _conversionType = 'weight';
  double _result = 0.0;

  final Map<String, Map<String, dynamic>> _units = {
    'weight': {
      'name': '무게',
      'units': ['g', 'kg', 'oz', 'lb', 'cup(flour)', 'cup(sugar)'],
    },
    'volume': {
      'name': '부피',
      'units': ['ml', 'l', 'cup', 'tbsp', 'tsp', 'fl oz'],
    },
    'temperature': {
      'name': '온도',
      'units': ['°C', '°F', 'K'],
    },
  };

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_performConversion);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.preferredSize.width,
          height: widget.preferredSize.height,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 행 - 고정 높이
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Icon(widget.icon, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline, size: 14),
                        onPressed: () => _showHelpDialog(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // 나머지 내용을 Expanded로 감싸서 남은 공간 활용
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 변환 타입 선택
                      SizedBox(
                        height: 28,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _units.keys.length,
                          itemBuilder: (context, index) {
                            final type = _units.keys.elementAt(index);
                            final isSelected = _conversionType == type;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              child: GestureDetector(
                                onTap: () => _changeConversionType(type),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _units[type]!['name']! as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontSize: 9,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // 입력 필드
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            labelText: '변환할 값',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            suffixText: _fromUnit,
                            labelStyle: const TextStyle(fontSize: 10),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // 단위 선택
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _fromUnit,
                                decoration: const InputDecoration(
                                  labelText: '변환 전',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  labelStyle: TextStyle(fontSize: 9),
                                ),
                                style: const TextStyle(fontSize: 10, color: Colors.black),
                                items: _getCurrentUnits().map((unit) {
                                  return DropdownMenuItem(
                                    value: unit, 
                                    child: Text(
                                      unit,
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _fromUnit = value!;
                                  });
                                  _performConversion();
                                },
                              ),
                            ),
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                onPressed: _swapUnits,
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: Theme.of(context).primaryColor,
                                  size: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _toUnit,
                                decoration: const InputDecoration(
                                  labelText: '변환 후',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  labelStyle: TextStyle(fontSize: 9),
                                ),
                                style: const TextStyle(fontSize: 10, color: Colors.black),
                                items: _getCurrentUnits().map((unit) {
                                  return DropdownMenuItem(
                                    value: unit, 
                                    child: Text(
                                      unit,
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _toUnit = value!;
                                  });
                                  _performConversion();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // 결과 표시
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '결과: ${_result.toStringAsFixed(2)} $_toUnit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getCurrentUnits() {
    return _units[_conversionType]!['units']!;
  }

  void _changeConversionType(String type) {
    setState(() {
      _conversionType = type;
      final units = _getCurrentUnits();
      _fromUnit = units.first;
      _toUnit = units.length > 1 ? units[1] : units.first;
    });
    _performConversion();
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _performConversion();
  }

  void _performConversion() {
    final inputValue = double.tryParse(_inputController.text) ?? 0.0;
    
    setState(() {
      _result = _convertValue(inputValue, _fromUnit, _toUnit, _conversionType);
    });

    if (widget.onCalculationChanged != null && widget.recipe != null) {
      final result = BakingCalculationResult(
        originalRecipe: widget.recipe!,
        calculatedRecipe: widget.recipe!,
        calculationMode: BakingCalculationMode.scaleAdjustment,
        calculations: {
          'conversionType': _conversionType,
          'fromUnit': _fromUnit,
          'toUnit': _toUnit,
          'inputValue': inputValue,
          'result': _result,
        },
      );
      widget.onCalculationChanged!(result);
    }
  }

  double _convertValue(double value, String from, String to, String type) {
    if (from == to) return value;

    switch (type) {
      case 'weight':
        return _convertWeight(value, from, to);
      case 'volume':
        return _convertVolume(value, from, to);
      case 'temperature':
        return _convertTemperature(value, from, to);
      default:
        return value;
    }
  }

  double _convertWeight(double value, String from, String to) {
    // 모든 값을 그램으로 변환 후 목표 단위로 변환
    double grams = value;
    
    // from 단위를 그램으로 변환
    switch (from) {
      case 'kg':
        grams = value * 1000;
        break;
      case 'oz':
        grams = value * 28.3495;
        break;
      case 'lb':
        grams = value * 453.592;
        break;
      case 'cup(flour)':
        grams = value * 120; // 밀가루 1컵 ≈ 120g
        break;
      case 'cup(sugar)':
        grams = value * 200; // 설탕 1컵 ≈ 200g
        break;
    }
    
    // 그램에서 to 단위로 변환
    switch (to) {
      case 'g':
        return grams;
      case 'kg':
        return grams / 1000;
      case 'oz':
        return grams / 28.3495;
      case 'lb':
        return grams / 453.592;
      case 'cup(flour)':
        return grams / 120;
      case 'cup(sugar)':
        return grams / 200;
      default:
        return grams;
    }
  }

  double _convertVolume(double value, String from, String to) {
    // 모든 값을 ml로 변환 후 목표 단위로 변환
    double ml = value;
    
    switch (from) {
      case 'l':
        ml = value * 1000;
        break;
      case 'cup':
        ml = value * 240; // 1컵 = 240ml
        break;
      case 'tbsp':
        ml = value * 15; // 1큰술 = 15ml
        break;
      case 'tsp':
        ml = value * 5; // 1작은술 = 5ml
        break;
      case 'fl oz':
        ml = value * 29.5735;
        break;
    }
    
    switch (to) {
      case 'ml':
        return ml;
      case 'l':
        return ml / 1000;
      case 'cup':
        return ml / 240;
      case 'tbsp':
        return ml / 15;
      case 'tsp':
        return ml / 5;
      case 'fl oz':
        return ml / 29.5735;
      default:
        return ml;
    }
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;
    
    // 모든 값을 섭씨로 변환
    double celsius = value;
    switch (from) {
      case '°F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsius = value - 273.15;
        break;
    }
    
    // 섭씨에서 목표 단위로 변환
    switch (to) {
      case '°C':
        return celsius;
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Text(widget.helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}