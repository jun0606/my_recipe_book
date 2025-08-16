// Sous Chef 옵션 선택 BottomSheet

import 'package:flutter/material.dart';
import '../../models/sous_chef_models.dart';
import '../../services/sous_chef_engine.dart';
import '../../services/sous_chef_database.dart';
import 'preset_management_dialog.dart';
import 'comparison_card.dart';

class SousChefOptionsSheet extends StatefulWidget {
  final BakingType bakingType;
  final SousChefRecipeState? currentState;
  final Function(Map<String, dynamic>) onOptionsSelected;
  final Map<String, dynamic>? recipeData; // 레시피 정보 추가

  const SousChefOptionsSheet({
    Key? key,
    required this.bakingType,
    this.currentState,
    required this.onOptionsSelected,
    this.recipeData, // 레시피 정보 매개변수 추가
  }) : super(key: key);

  @override
  State<SousChefOptionsSheet> createState() => _SousChefOptionsSheetState();
}

class _SousChefOptionsSheetState extends State<SousChefOptionsSheet> {
  final Map<String, dynamic> _selectedOptions = {};
  final Map<String, TextEditingController> _controllers = {};
  
  // 환경 변수
  double _roomTemperature = 22.0;
  double _humidity = 55.0;
  double _altitude = 0.0;
  
  // 오븐 설정
  OvenType _ovenType = OvenType.convection;
  bool _useFan = true;  // 팬 사용 여부
  String _fanSpeed = 'medium';
  double? _topHeat;
  double? _bottomHeat;
  String _steamAmount = 'none';
  String _combiMode = 'dry';
  
  // 레시피 설정 (사용자 입력)
  double _recipeTemperature = 180.0;
  double _recipeTime = 30.0;
  
  // 발효 설정 (시나리오 기반)
  Set<FermentationStage> _selectedFermentationStages = {FermentationStage.bulk};
  FermentationMethod _fermentationMethod = FermentationMethod.roomTemp;
  String? _selectedPresetScenario;
  
  // 각 단계별 세부 설정
  final Map<FermentationStage, double> _stageTemperatures = {};
  final Map<FermentationStage, double> _stageHumidities = {};
  final Map<FermentationStage, double> _stageDurations = {};
  
  // 전역 발효 설정 (기존 호환성 유지)
  FermentationStage _fermentationStage = FermentationStage.bulk;
  double _fermentationTemp = 26.0;
  double _fermentationHumidityValue = 75.0;
  double _fermentationTime = 120.0;
  double? _fermentationHumidity = 75.0;
  double _yeastAmount = 5.0;
  String _yeastType = 'instant';
  double _doughWeight = 1000.0;
  double _hydration = 65.0;
  double _saltPercentage = 2.0;
  bool _usePreferment = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCurrentSettings();
  }

  void _initializeControllers() {
    _controllers['roomTemperature'] = TextEditingController(text: _roomTemperature.toString());
    _controllers['humidity'] = TextEditingController(text: _humidity.toString());
    _controllers['altitude'] = TextEditingController(text: _altitude.toString());
    _controllers['topHeat'] = TextEditingController();
    _controllers['bottomHeat'] = TextEditingController();
    _controllers['fermentationTemp'] = TextEditingController(text: _fermentationTemp.toString());
    _controllers['fermentationHumidity'] = TextEditingController(text: _fermentationHumidityValue.toString());
    _controllers['doughWeight'] = TextEditingController(text: _doughWeight.toString());
    _controllers['yeastAmount'] = TextEditingController(text: _yeastAmount.toString());
    _controllers['recipeTemperature'] = TextEditingController(text: _recipeTemperature.toString());
    _controllers['recipeTime'] = TextEditingController(text: _recipeTime.toString());
    
    // 레시피 데이터 기반 초기값 설정
    _initializeFromRecipeData();
  }

  /// 레시피 데이터를 분석하여 초기값 설정
  void _initializeFromRecipeData() {
    if (widget.recipeData == null) return;
    
    final ingredients = widget.recipeData!['ingredients'] as List<Map<String, dynamic>>? ?? [];
    if (ingredients.isEmpty) return;
    
    // IngredientAnalyzer를 사용하여 레시피 분석
    try {
      // 실제 반죽 무게 계산
      final totalWeight = widget.recipeData!['totalWeight'] as double? ?? 
                         _calculateTotalDoughWeightFromIngredients(ingredients);
      if (totalWeight > 0) {
        _doughWeight = totalWeight;
        _controllers['doughWeight']?.text = _doughWeight.toString();
      }
      
      // 실제 이스트량 계산
      final yeastIngredients = _findYeastIngredients(ingredients);
      if (yeastIngredients.isNotEmpty) {
        double totalYeast = 0.0;
        for (final yeast in yeastIngredients) {
          final amount = yeast['amount'] as double? ?? 0.0;
          final unit = yeast['unit'] as String? ?? 'g';
          totalYeast += _convertToGrams(amount, unit, yeast['name'] as String? ?? '');
        }
        if (totalYeast > 0) {
          _yeastAmount = totalYeast;
          _controllers['yeastAmount']?.text = _yeastAmount.toString();
        }
      }
      
      // 실제 수분율 계산
      final hydration = _calculateHydrationFromIngredients(ingredients);
      if (hydration > 0) {
        _hydration = hydration;
      }
      
      // 실제 소금 비율 계산
      final saltPercentage = _calculateSaltPercentageFromIngredients(ingredients);
      if (saltPercentage > 0) {
        _saltPercentage = saltPercentage;
      }
      
      // 실제 레시피 온도와 시간 설정
      final bakingTemperature = widget.recipeData!['bakingTemperature'] as double?;
      if (bakingTemperature != null && bakingTemperature > 0) {
        _recipeTemperature = bakingTemperature;
        _controllers['recipeTemperature']?.text = _recipeTemperature.toString();
      }
      
      final bakingTime = widget.recipeData!['bakingTime'] as double?;
      if (bakingTime != null && bakingTime > 0) {
        _recipeTime = bakingTime;
        _controllers['recipeTime']?.text = _recipeTime.toString();
      }
      
      print('레시피 분석 결과:');
      print('- 반죽 무게: ${_doughWeight}g');
      print('- 이스트량: ${_yeastAmount}g');
      print('- 수분율: ${_hydration.toStringAsFixed(1)}%');
      print('- 소금 비율: ${_saltPercentage.toStringAsFixed(1)}%');
      print('- 굽기 온도: ${_recipeTemperature}°C');
      print('- 굽기 시간: ${_recipeTime}분');
      
    } catch (e) {
      print('레시피 데이터 분석 중 오류: $e');
    }
  }

  void _loadCurrentSettings() {
    if (widget.currentState?.activePresetId != null) {
      final preset = widget.currentState!.presets
          .where((p) => p.id == widget.currentState!.activePresetId)
          .firstOrNull;
      
      if (preset != null) {
        // 기존 설정 로드
        _loadPresetOptions(preset.options);
      }
    }
  }

  void _loadPresetOptions(Map<String, dynamic> options) {
    setState(() {
      if (options['environment'] != null) {
        _roomTemperature = options['environment']['temperature'] ?? 22.0;
        _humidity = options['environment']['humidity'] ?? 55.0;
        _altitude = options['environment']['altitude'] ?? 0.0;
      }
      
      if (options['oven'] != null) {
        final ovenData = options['oven'];
        _ovenType = OvenType.values.firstWhere(
          (type) => type.name == ovenData['type'],
          orElse: () => OvenType.convection,
        );
        _fanSpeed = ovenData['fanSpeed'] ?? 'medium';
        _topHeat = ovenData['topHeat'];
        _bottomHeat = ovenData['bottomHeat'];
      }
      
      if (options['fermentation'] != null) {
        final fermentData = options['fermentation'];
        _fermentationMethod = FermentationMethod.values.firstWhere(
          (method) => method.name == fermentData['method'],
          orElse: () => FermentationMethod.roomTemp,
        );
        _fermentationTemp = fermentData['temperature'];
        _fermentationHumidity = fermentData['humidity'];
      }
    });
    
    _updateControllers();
  }

  void _updateControllers() {
    _controllers['roomTemperature']!.text = _roomTemperature.toString();
    _controllers['humidity']!.text = _humidity.toString();
    _controllers['altitude']!.text = _altitude.toString();
    _controllers['topHeat']!.text = _topHeat?.toString() ?? '';
    _controllers['bottomHeat']!.text = _bottomHeat?.toString() ?? '';
    _controllers['fermentationTemp']!.text = _fermentationTemp?.toString() ?? '';
    _controllers['fermentationHumidity']!.text = _fermentationHumidity?.toString() ?? '';
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnvironmentSection(),
                  const SizedBox(height: 24),
                  ..._buildBakingTypeSpecificSections(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final typeNames = {
      BakingType.bread: '빵 설정',
      BakingType.cake: '케이크 설정',
      BakingType.cookie: '쿠키 설정',
      BakingType.fried: '튀김 설정',
      BakingType.dessertHot: '온 디저트 설정',
      BakingType.dessertCold: '냉 디저트 설정',
      BakingType.frozenDessert: '냉동 디저트 설정',
      BakingType.iceCream: '아이스크림 설정',
      BakingType.gelato: '젤라토 설정',
      BakingType.candy: '사탕 설정',
      BakingType.etc: '기타 설정',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.tune, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeNames[widget.bakingType] ?? '설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                Text(
                  'Sous Chef 모드',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return _buildSection(
      title: '환경 설정',
      icon: Icons.thermostat,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                label: '실내 온도 (°C)',
                controller: _controllers['roomTemperature']!,
                onChanged: (value) {
                  _roomTemperature = double.tryParse(value) ?? 22.0;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                label: '습도 (%)',
                controller: _controllers['humidity']!,
                onChanged: (value) {
                  _humidity = double.tryParse(value) ?? 55.0;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNumberField(
          label: '해발 고도 (m)',
          controller: _controllers['altitude']!,
          onChanged: (value) {
            _altitude = double.tryParse(value) ?? 0.0;
          },
        ),
      ],
    );
  }

  List<Widget> _buildBakingTypeSpecificSections() {
    final sections = <Widget>[];

    // 베이킹 타입별 섹션 추가
    switch (widget.bakingType) {
      case BakingType.bread:
        sections.addAll([
          _buildOvenSection(),
          const SizedBox(height: 24),
          _buildFermentationSection(),
        ]);
        break;
      case BakingType.cake:
        sections.addAll([
          _buildOvenSection(),
          const SizedBox(height: 24),
          _buildMixingSection(),
        ]);
        break;
      case BakingType.cookie:
        sections.addAll([
          _buildOvenSection(),
          const SizedBox(height: 24),
          _buildDoughSection(),
        ]);
        break;
      case BakingType.fried:
        sections.add(_buildFryingSection());
        break;
      case BakingType.iceCream:
      case BakingType.gelato:
        sections.add(_buildFreezingSection());
        break;
      case BakingType.candy:
        sections.add(_buildCandySection());
        break;
      default:
        sections.add(_buildOvenSection());
    }

    return sections;
  }

  Widget _buildOvenSection() {
    return _buildSection(
      title: '오븐 설정',
      icon: Icons.local_fire_department,
      children: [
        // 레시피 기본 정보 입력
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '레시피 기본 정보',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: '레시피 온도 (°C)',
                      controller: _controllers['recipeTemperature']!,
                      onChanged: (value) {
                        final temp = double.tryParse(value);
                        if (temp != null) {
                          setState(() {
                            _recipeTemperature = temp;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      label: '굽는 시간 (분)',
                      controller: _controllers['recipeTime']!,
                      onChanged: (value) {
                        final time = double.tryParse(value);
                        if (time != null) {
                          setState(() {
                            _recipeTime = time;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField<OvenType>(
          label: '오븐 종류',
          value: _ovenType,
          items: [
            DropdownMenuItem(value: OvenType.convection, child: Text('컨벡션 오븐')),
            DropdownMenuItem(value: OvenType.deck, child: Text('데크 오븐')),
            DropdownMenuItem(value: OvenType.steam, child: Text('스팀 오븐')),
            DropdownMenuItem(value: OvenType.gas, child: Text('가스 오븐')),
            DropdownMenuItem(value: OvenType.electricHome, child: Text('가정용 전기 오븐')),
            DropdownMenuItem(value: OvenType.combi, child: Text('콤비 오븐')),
          ],
          onChanged: (value) {
            setState(() {
              _ovenType = value!;
            });
          },
        ),
        const SizedBox(height: 12),
        
        // 모든 오븐 타입에서 상단열/하단열 설정 가능
        _buildHeatControlSection(),
        
        // 오븐 타입별 추가 설정
        ..._buildOvenTypeSpecificSettings(),
      ],
    );
  }

  Widget _buildHeatControlSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.whatshot, size: 16, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                '열 제어 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오븐의 상단열과 하단열을 개별적으로 설정할 수 있습니다. 빈 칸으로 두면 해당 열이 없는 것으로 처리됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: '상단 열 (°C)',
                  controller: _controllers['topHeat']!,
                  onChanged: (value) {
                    _topHeat = value.isEmpty ? null : double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  label: '하단 열 (°C)',
                  controller: _controllers['bottomHeat']!,
                  onChanged: (value) {
                    _bottomHeat = value.isEmpty ? null : double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHeatControlInfo(),
        ],
      ),
    );
  }

  Widget _buildHeatControlInfo() {
    String infoText = '';
    Color infoColor = Colors.blue.shade700;
    IconData infoIcon = Icons.info_outline;

    if (_topHeat != null && _bottomHeat != null) {
      infoText = '상하 모든 열 사용 - 균등한 열 분포로 고른 굽기';
      infoColor = Colors.green.shade700;
      infoIcon = Icons.check_circle_outline;
    } else if (_topHeat != null && _bottomHeat == null) {
      infoText = '상단열만 사용 - 표면 브라우닝에 적합';
      infoColor = Colors.orange.shade700;
      infoIcon = Icons.keyboard_arrow_up;
    } else if (_topHeat == null && _bottomHeat != null) {
      infoText = '하단열만 사용 - 바닥 굽기에 적합 (피자, 빵 등)';
      infoColor = Colors.orange.shade700;
      infoIcon = Icons.keyboard_arrow_down;
    } else {
      infoText = '열 설정이 필요합니다';
      infoColor = Colors.red.shade700;
      infoIcon = Icons.warning_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(infoIcon, size: 16, color: infoColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              infoText,
              style: TextStyle(
                fontSize: 12,
                color: infoColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOvenTypeSpecificSettings() {
    final widgets = <Widget>[];

    switch (_ovenType) {
      case OvenType.convection:
        widgets.addAll([
          const SizedBox(height: 12),
          _buildFanControlSection(),
          const SizedBox(height: 8),
          _buildInfoCard(
            '컨벡션 오븐은 팬으로 열을 순환시켜 균등한 온도를 유지합니다. 일반적으로 기존 온도보다 15-20°C 낮춰서 사용합니다.',
            Colors.blue,
          ),
        ]);
        break;

      case OvenType.deck:
        widgets.addAll([
          const SizedBox(height: 8),
          _buildInfoCard(
            '데크 오븐은 상하 열을 독립적으로 조절할 수 있어 정밀한 굽기가 가능합니다. 빵류에 특히 적합합니다.',
            Colors.brown,
          ),
        ]);
        break;

      case OvenType.steam:
        widgets.addAll([
          const SizedBox(height: 12),
          _buildDropdownField<String>(
            label: '스팀 사용량',
            value: _steamAmount,
            items: [
              DropdownMenuItem(value: 'none', child: Text('스팀 없음')),
              DropdownMenuItem(value: 'low', child: Text('약간')),
              DropdownMenuItem(value: 'medium', child: Text('보통')),
              DropdownMenuItem(value: 'high', child: Text('많이')),
            ],
            onChanged: (value) {
              setState(() {
                _steamAmount = value!;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            '스팀 오븐은 수분을 공급하여 빵의 크러스트 형성과 부피 증가에 도움을 줍니다.',
            Colors.cyan,
          ),
        ]);
        break;

      case OvenType.gas:
        widgets.addAll([
          const SizedBox(height: 12),
          _buildFanControlSection(),
          const SizedBox(height: 8),
          _buildInfoCard(
            '가스 오븐은 직화로 인해 빠른 가열과 높은 온도가 특징입니다. 팬이 있는 경우 더 균등한 열분포를 얻을 수 있습니다.',
            Colors.orange,
          ),
        ]);
        break;

      case OvenType.electricHome:
        widgets.addAll([
          const SizedBox(height: 12),
          _buildFanControlSection(),
          const SizedBox(height: 8),
          _buildInfoCard(
            '가정용 전기 오븐은 안정적인 온도 유지가 장점입니다. 컨벡션 기능이 있다면 팬을 사용하여 더 균등한 굽기가 가능합니다.',
            Colors.green,
          ),
        ]);
        break;

      case OvenType.combi:
        widgets.addAll([
          const SizedBox(height: 12),
          _buildDropdownField<String>(
            label: '운전 모드',
            value: _combiMode,
            items: [
              DropdownMenuItem(value: 'dry', child: Text('드라이 모드')),
              DropdownMenuItem(value: 'steam', child: Text('스팀 모드')),
              DropdownMenuItem(value: 'combi', child: Text('콤비 모드')),
            ],
            onChanged: (value) {
              setState(() {
                _combiMode = value!;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            '콤비 오븐은 건열과 습열을 조합하여 다양한 조리가 가능합니다. 모드에 따라 결과가 크게 달라집니다.',
            Colors.purple,
          ),
        ]);
        break;
    }

    return widgets;
  }

  Widget _buildFanControlSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '팬 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _useFan,
                      onChanged: (value) {
                        setState(() {
                          _useFan = value!;
                        });
                      },
                    ),
                    const Text('팬 사용'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _useFan,
                      onChanged: (value) {
                        setState(() {
                          _useFan = value!;
                        });
                      },
                    ),
                    const Text('팬 사용 안함'),
                  ],
                ),
              ),
            ],
          ),
          if (_useFan) ...[
            const SizedBox(height: 8),
            _buildDropdownField<String>(
              label: '팬 속도',
              value: _fanSpeed,
              items: [
                DropdownMenuItem(value: 'low', child: Text('저속')),
                DropdownMenuItem(value: 'medium', child: Text('중속')),
                DropdownMenuItem(value: 'high', child: Text('고속')),
              ],
              onChanged: (value) {
                setState(() {
                  _fanSpeed = value!;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: color.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFermentationSection() {
    return _buildSection(
      title: '발효 전문가',
      icon: Icons.science,
      children: [
        // 발효 단계 다중 선택
        Text(
          '발효 단계 선택 (중복 선택 가능)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '베이킹 공정에 맞는 발효 단계들을 선택하세요. 예: 1차발효 → 분할 → 성형 → 최종발효',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        
        // 발효 단계 체크박스 목록
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FermentationStage.values.map((stage) {
            final isSelected = _selectedFermentationStages.contains(stage);
            return FilterChip(
              label: Text(_getFermentationStageDisplayName(stage)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFermentationStages.add(stage);
                  } else {
                    _selectedFermentationStages.remove(stage);
                  }
                  // 선택이 변경되면 프리셋 해제
                  _selectedPresetScenario = null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green.shade700,
              labelStyle: TextStyle(
                color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        
        // 선택된 단계들의 분석 정보
        if (_selectedFermentationStages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '선택된 발효 시나리오 분석',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '총 예상 시간: ${_formatDuration(_getTotalEstimatedTime())}',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
                Text(
                  '시나리오 타입: ${_getScenarioTypeDescription()}',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
                Text(
                  '선택된 단계: ${_selectedFermentationStages.length}개',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // 빠른 프리셋 선택
        Text(
          '빠른 프리셋 선택',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip('빠른 식빵', '1차발효 → 최종발효', 'quick'),
            _buildPresetChip('표준 식빵', '1차 → 2차 → 분할 → 성형 → 최종', 'standard'),
            _buildPresetChip('오버나이트', '1차 → 오버나이트 → 최종', 'overnight'),
            _buildPresetChip('사워도우', '1차 → 냉장숙성 → 최종', 'sourdough'),
          ],
        ),
        const SizedBox(height: 12),
        
        // 발효 방식 선택
        _buildDropdownField<FermentationMethod>(
          label: '발효 방식',
          value: _fermentationMethod,
          items: [
            DropdownMenuItem(value: FermentationMethod.roomTemp, child: Text('실온 발효')),
            DropdownMenuItem(value: FermentationMethod.proofer, child: Text('발효기 사용')),
            DropdownMenuItem(value: FermentationMethod.cold, child: Text('냉장 발효')),
            DropdownMenuItem(value: FermentationMethod.warmPlace, child: Text('따뜻한 곳')),
            DropdownMenuItem(value: FermentationMethod.controlled, child: Text('온습도 조절')),
          ],
          onChanged: (value) {
            setState(() {
              _fermentationMethod = value!;
            });
          },
        ),
        const SizedBox(height: 12),
        
        // 환경 설정
        Row(
          children: [
            Expanded(
              child: _buildSliderField(
                label: '온도 (°C)',
                value: _fermentationTemp,
                min: 4.0,
                max: 40.0,
                divisions: 36,
                onChanged: (value) {
                  setState(() {
                    _fermentationTemp = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSliderField(
                label: '습도 (%)',
                value: _fermentationHumidityValue,
                min: 50.0,
                max: 95.0,
                divisions: 45,
                onChanged: (value) {
                  setState(() {
                    _fermentationHumidityValue = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 시간 설정
        _buildSliderField(
          label: '목표 시간 (${_formatTime(_fermentationTime)})',
          value: _fermentationTime,
          min: 30.0,
          max: 1440.0,
          divisions: 94,
          onChanged: (value) {
            setState(() {
              _fermentationTime = value;
            });
          },
        ),
        const SizedBox(height: 12),
        
        // 반죽 정보
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                label: '반죽 무게 (g)',
                controller: _controllers['doughWeight']!,
                onChanged: (value) {
                  _doughWeight = double.tryParse(value) ?? 1000.0;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                label: '이스트 양 (g)',
                controller: _controllers['yeastAmount']!,
                onChanged: (value) {
                  _yeastAmount = double.tryParse(value) ?? 5.0;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 수분율과 소금
        Row(
          children: [
            Expanded(
              child: _buildSliderField(
                label: '수분율 (${_hydration.toStringAsFixed(1)}%)',
                value: _hydration,
                min: 50.0,
                max: 95.0,
                divisions: 45,
                onChanged: (value) {
                  setState(() {
                    _hydration = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSliderField(
                label: '소금 비율 (${_saltPercentage.toStringAsFixed(1)}%)',
                value: _saltPercentage,
                min: 1.0,
                max: 4.0,
                divisions: 30,
                onChanged: (value) {
                  setState(() {
                    _saltPercentage = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 이스트 종류와 프리퍼먼트
        Row(
          children: [
            Expanded(
              child: _buildDropdownField<String>(
                label: '이스트 종류',
                value: _yeastType,
                items: [
                  DropdownMenuItem(value: 'instant', child: Text('인스턴트 이스트')),
                  DropdownMenuItem(value: 'active_dry', child: Text('액티브 드라이 이스트')),
                  DropdownMenuItem(value: 'fresh', child: Text('생이스트')),
                  DropdownMenuItem(value: 'sourdough', child: Text('사워도우 스타터')),
                ],
                onChanged: (value) {
                  setState(() {
                    _yeastType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SwitchListTile(
                title: Text('프리퍼먼트 사용'),
                subtitle: Text('폴리쉬, 비가 등'),
                value: _usePreferment,
                onChanged: (value) {
                  setState(() {
                    _usePreferment = value;
                  });
                },
                activeColor: Colors.purple.shade600,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMixingSection() {
    return _buildSection(
      title: '믹싱 설정',
      icon: Icons.blender,
      children: [
        Text(
          '케이크 믹싱 옵션 (추후 구현)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDoughSection() {
    return _buildSection(
      title: '반죽 설정',
      icon: Icons.cookie,
      children: [
        Text(
          '쿠키 반죽 옵션 (추후 구현)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildFryingSection() {
    return _buildSection(
      title: '튀김 설정',
      icon: Icons.local_dining,
      children: [
        Text(
          '튀김 옵션 (추후 구현)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildFreezingSection() {
    return _buildSection(
      title: '냉동 설정',
      icon: Icons.ac_unit,
      children: [
        Text(
          '냉동 디저트 옵션 (추후 구현)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCandySection() {
    return _buildSection(
      title: '사탕 설정',
      icon: Icons.cake,
      children: [
        Text(
          '사탕 제조 옵션 (추후 구현)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _showPresetDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade600,
                side: BorderSide(color: Colors.orange.shade600),
              ),
              child: const Text('프리셋 관리'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applySettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('설정 적용'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPresetDialog() {
    final currentOptions = {
      'environment': {
        'temperature': _roomTemperature,
        'humidity': _humidity,
        'altitude': _altitude,
      },
      'oven': {
        'type': _ovenType.name,
        'fanSpeed': _fanSpeed,
        'topHeat': _topHeat,
        'bottomHeat': _bottomHeat,
      },
      'fermentation': {
        'method': _fermentationMethod.name,
        'temperature': _fermentationTemp,
        'humidity': _fermentationHumidity,
      },
    };

    showDialog(
      context: context,
      builder: (context) => PresetManagementDialog(
        bakingType: widget.bakingType,
        currentOptions: currentOptions,
        onPresetSelected: (preset) => _loadPresetOptions(preset.options),
      ),
    );
  }

  void _applySettings() async {
    final options = {
      'environment': {
        'temperature': _roomTemperature,
        'humidity': _humidity,
        'altitude': _altitude,
      },
      'oven': {
        'type': _ovenType.name,
        'useFan': _useFan,
        'fanSpeed': _useFan ? _fanSpeed : null,
        'topHeat': _topHeat,
        'bottomHeat': _bottomHeat,
      },
      'fermentation': {
        'method': _fermentationMethod.name,
        'temperature': _fermentationTemp,
        'humidity': _fermentationHumidity,
      },
      'recipe': {
        'temperature': _recipeTemperature,
        'time': _recipeTime,
      },
    };

    // SousChefEngine을 사용하여 보정값 계산
    final engine = SousChefEngine();
    
    final userInputs = {
      'ovenType': _ovenType.name,
      'recipeTemperature': _recipeTemperature,
      'recipeTime': _recipeTime,
      'useFan': _useFan,
      'fanSpeed': _useFan ? _fanSpeed : null,
      'topHeat': _topHeat,
      'bottomHeat': _bottomHeat,
      // 발효 관련 데이터
      'fermentation_stage': _fermentationStage.name,
      'fermentation_method': _fermentationMethod.name,
      'fermentation_temperature': _fermentationTemp,
      'fermentation_humidity': _fermentationHumidityValue,
      'fermentation_time': _fermentationTime,
      'yeast_amount': _yeastAmount,
      'yeast_type': _yeastType,
      'dough_weight': _doughWeight,
      'hydration': _hydration,
      'salt_percentage': _saltPercentage,
      'use_preferment': _usePreferment,
    };

    final environmentData = {
      'roomTemperature': _roomTemperature,
      'humidity': _humidity,
      'altitude': _altitude,
    };

    final recipeData = {
      'bakingType': widget.bakingType,
    };

    try {
      final result = engine.calculateAdjustments(
        bakingType: widget.bakingType,
        userInputs: userInputs,
        environmentData: environmentData,
        recipeData: recipeData,
      );

      // 비교 카드 표시
      if (mounted) {
        await _showComparisonCard(options, result);
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('계산 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showComparisonCard(
    Map<String, dynamic> options, 
    AdjustmentResult result
  ) async {
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (context) => ComparisonCard(
        originalValues: {
          'temperature': 180.0,
          'time': 30.0,
          'moisture': 65.0,
        },
        adjustmentResult: result,
        onApply: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    if (shouldApply == true) {
      widget.onOptionsSelected({
        ...options,
        'adjustments': result.adjustments,
        'explanations': result.explanations,
        'warnings': result.warnings,
      });
      Navigator.of(context).pop();
    }
  }

  // 슬라이더 필드 위젯
  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Colors.purple.shade600,
        ),
      ],
    );
  }

  // 시간 포맷 헬퍼
  String _formatTime(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}분';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).round();
      return remainingMinutes > 0 ? '${hours}시간 ${remainingMinutes}분' : '${hours}시간';
    }
  }

  /// 시나리오 타입 설명
  String _getScenarioTypeDescription() {
    if (_selectedFermentationStages.isEmpty) return '선택 없음';
    
    if (_selectedFermentationStages.contains(FermentationStage.bulk) && 
        _selectedFermentationStages.contains(FermentationStage.finalProof) &&
        _selectedFermentationStages.length == 2) {
      return '빠른 발효 (1차 + 최종)';
    }
    
    if (_selectedFermentationStages.contains(FermentationStage.bulk) && 
        _selectedFermentationStages.contains(FermentationStage.secondary) &&
        _selectedFermentationStages.contains(FermentationStage.divided) &&
        _selectedFermentationStages.contains(FermentationStage.shaped) &&
        _selectedFermentationStages.contains(FermentationStage.finalProof)) {
      return '완전한 표준 식빵 공정';
    }
    
    if (_selectedFermentationStages.contains(FermentationStage.bulk) && 
        _selectedFermentationStages.contains(FermentationStage.divided) &&
        _selectedFermentationStages.contains(FermentationStage.shaped) &&
        _selectedFermentationStages.contains(FermentationStage.finalProof)) {
      return '표준 식빵 공정';
    }
    
    if (_selectedFermentationStages.contains(FermentationStage.overnight) ||
        _selectedFermentationStages.contains(FermentationStage.coldRetard)) {
      return '장시간 발효';
    }
    
    if (_selectedFermentationStages.length == 1) {
      return '단일 단계 발효';
    }
    
    return '사용자 정의 발효';
  }

  /// 프리셋 칩 위젯 생성
  Widget _buildPresetChip(String title, String description, String presetKey) {
    final isSelected = _selectedPresetScenario == presetKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPresetScenario = null;
          } else {
            _selectedPresetScenario = presetKey;
            _applyPresetScenario(presetKey);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.orange.shade800 : Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 발효 단계 표시명 반환
  String _getFermentationStageDisplayName(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return '1차 발효';
      case FermentationStage.secondary:
        return '2차 발효';
      case FermentationStage.divided:
        return '분할 후 휴지';
      case FermentationStage.shaped:
        return '성형 후 발효';
      case FermentationStage.finalProof:
        return '최종 발효';
      case FermentationStage.overnight:
        return '오버나이트';
      case FermentationStage.coldRetard:
        return '냉장 숙성';
    }
  }

  /// 프리셋 시나리오 적용
  void _applyPresetScenario(String preset) {
    switch (preset) {
      case 'quick':
        _selectedFermentationStages = {FermentationStage.bulk, FermentationStage.finalProof};
        break;
      case 'standard':
        _selectedFermentationStages = {
          FermentationStage.bulk,
          FermentationStage.secondary,
          FermentationStage.divided,
          FermentationStage.shaped,
          FermentationStage.finalProof
        };
        break;
      case 'overnight':
        _selectedFermentationStages = {
          FermentationStage.bulk,
          FermentationStage.secondary,
          FermentationStage.overnight,
          FermentationStage.finalProof
        };
        break;
      case 'sourdough':
        _selectedFermentationStages = {
          FermentationStage.bulk,
          FermentationStage.secondary,
          FermentationStage.coldRetard,
          FermentationStage.finalProof
        };
        break;
    }
  }

  /// 총 예상 시간 계산
  double _getTotalEstimatedTime() {
    double total = 0.0;
    for (final stage in _selectedFermentationStages) {
      total += _stageDurations[stage] ?? _getDefaultDuration(stage);
    }
    return total;
  }

  /// 발효 단계별 기본 시간 (분)
  double _getDefaultDuration(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return 120.0; // 2시간
      case FermentationStage.secondary:
        return 90.0;  // 1시간 30분
      case FermentationStage.divided:
        return 20.0;  // 20분
      case FermentationStage.shaped:
        return 15.0;  // 15분
      case FermentationStage.finalProof:
        return 60.0;  // 1시간
      case FermentationStage.overnight:
        return 720.0; // 12시간
      case FermentationStage.coldRetard:
        return 1440.0; // 24시간
    }
  }

  /// 시간을 읽기 쉬운 형태로 포맷
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()}분';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).toInt();
      if (remainingMinutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${remainingMinutes}분';
      }
    } else {
      final days = (minutes / 1440).floor();
      final remainingHours = ((minutes % 1440) / 60).floor();
      if (remainingHours == 0) {
        return '${days}일';
      } else {
        return '${days}일 ${remainingHours}시간';
      }
    }
  }

  // === 레시피 분석 헬퍼 메서드들 ===

  /// 재료에서 총 반죽 무게 계산
  double _calculateTotalDoughWeightFromIngredients(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';
      totalWeight += _convertToGrams(amount, unit, name);
    }
    return totalWeight;
  }

  /// 재료에서 이스트 재료들 찾기
  List<Map<String, dynamic>> _findYeastIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final yeastKeywords = [
        '이스트', '드라이이스트', '인스턴트이스트', '액티브드라이이스트',
        '생이스트', '천연효모', 'yeast', 'dry yeast', 'instant yeast',
        'active dry yeast', 'fresh yeast', 'sourdough starter'
      ];
      return yeastKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 재료에서 수분율 계산
  double _calculateHydrationFromIngredients(List<Map<String, dynamic>> ingredients) {
    final flourIngredients = _findFlourIngredients(ingredients);
    final liquidIngredients = _findLiquidIngredients(ingredients);

    if (flourIngredients.isEmpty) return 0.0;

    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += _convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    double totalLiquid = 0.0;
    for (final liquid in liquidIngredients) {
      final amount = liquid['amount'] as double? ?? 0.0;
      final unit = liquid['unit'] as String? ?? 'g';
      totalLiquid += _convertToGrams(amount, unit, liquid['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalLiquid / totalFlour) * 100;
  }

  /// 재료에서 소금 비율 계산
  double _calculateSaltPercentageFromIngredients(List<Map<String, dynamic>> ingredients) {
    final flourIngredients = _findFlourIngredients(ingredients);
    final saltIngredients = _findSaltIngredients(ingredients);

    if (flourIngredients.isEmpty || saltIngredients.isEmpty) return 0.0;

    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += _convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    double totalSalt = 0.0;
    for (final salt in saltIngredients) {
      final amount = salt['amount'] as double? ?? 0.0;
      final unit = salt['unit'] as String? ?? 'g';
      totalSalt += _convertToGrams(amount, unit, salt['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalSalt / totalFlour) * 100;
  }

  /// 밀가루 재료들 찾기
  List<Map<String, dynamic>> _findFlourIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final flourKeywords = [
        '밀가루', '강력분', '중력분', '박력분', '통밀가루', '호밀가루',
        'flour', 'bread flour', 'all-purpose flour', 'cake flour',
        'whole wheat flour', 'rye flour', '가루'
      ];
      return flourKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 액체 재료들 찾기
  List<Map<String, dynamic>> _findLiquidIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final liquidKeywords = [
        '물', '우유', '생크림', '버터밀크', '요구르트', '기름', '올리브오일',
        'water', 'milk', 'cream', 'buttermilk', 'yogurt', 'oil', 'butter'
      ];
      return liquidKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 소금 재료들 찾기
  List<Map<String, dynamic>> _findSaltIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final saltKeywords = ['소금', '천일염', '바다소금', 'salt', 'sea salt'];
      return saltKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 단위를 그램으로 변환
  double _convertToGrams(double amount, String unit, String ingredientName) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return amount * 1000;
      case 'ml':
        return amount; // 대부분의 액체는 1:1 비율로 근사
      case 'cup':
        return amount * 240;
      case 'tbsp':
        return amount * 15;
      case 'tsp':
        return amount * 5;
      default:
        return amount; // 이미 그램이거나 알 수 없는 단위
    }
  }
}