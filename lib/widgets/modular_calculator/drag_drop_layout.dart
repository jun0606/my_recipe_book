import 'package:flutter/material.dart';
import 'package:my_recipe_book/models/enhanced_recipe.dart';
import 'package:my_recipe_book/models/user_configuration.dart';
import 'package:my_recipe_book/widgets/modular_calculator/calculator_module.dart';
import 'package:my_recipe_book/services/user_settings_service.dart';

/// 드래그 앤 드롭 가능한 모듈형 계산기 레이아웃
class DragDropCalculatorLayout extends StatefulWidget {
  final EnhancedRecipe? recipe;
  final UserConfiguration userConfig;
  final UserSettingsService userSettingsService;
  final Function(Map<String, dynamic>)? onCalculationChanged;

  const DragDropCalculatorLayout({
    Key? key,
    this.recipe,
    required this.userConfig,
    required this.userSettingsService,
    this.onCalculationChanged,
  }) : super(key: key);

  @override
  State<DragDropCalculatorLayout> createState() => _DragDropCalculatorLayoutState();
}

class _DragDropCalculatorLayoutState extends State<DragDropCalculatorLayout> {
  final Map<String, Offset> _modulePositions = {};
  final Map<String, Size> _moduleSizes = {};
  final List<String> _activeModules = [];
  final GlobalKey _layoutKey = GlobalKey();
  
  bool _showModulePalette = false;
  Size _layoutSize = Size.zero;
  final double _gridSize = 20.0;

  @override
  void initState() {
    super.initState();
    _initializeLayout();
  }

  void _initializeLayout() {
    // 사용자 설정에서 활성 모듈과 위치 로드
    _activeModules.clear();
    _activeModules.addAll(widget.userConfig.activeModules);
    
    _modulePositions.clear();
    _modulePositions.addAll(widget.userConfig.moduleLayout);
    
    // 기본 위치 설정 (저장된 위치가 없는 경우)
    _setDefaultPositions();
  }

  void _setDefaultPositions() {
    final availableModules = ModuleFactory.getAvailableModules();
    double x = 20.0;
    double y = 20.0;
    
    for (int i = 0; i < _activeModules.length; i++) {
      final moduleId = _activeModules[i];
      
      if (!_modulePositions.containsKey(moduleId)) {
        _modulePositions[moduleId] = Offset(x, y);
        
        // 다음 모듈 위치 계산
        x += 420.0; // 모듈 너비 + 여백
        if (x > 800) {
          x = 20.0;
          y += 320.0; // 모듈 높이 + 여백
        }
      }
      
      // 기본 크기 설정
      if (!_moduleSizes.containsKey(moduleId)) {
        final moduleInfo = availableModules.firstWhere(
          (m) => m.id == moduleId,
          orElse: () => availableModules.first,
        );
        _moduleSizes[moduleId] = moduleInfo.defaultSize;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _layoutSize = Size(constraints.maxWidth, constraints.maxHeight);
          
          return DragTarget<String>(
            onAccept: (moduleId) {
              // 팔레트에서 드래그한 모듈을 중앙에 배치
              final centerPosition = Offset(
                (_layoutSize.width - 400) / 2,
                (_layoutSize.height - 300) / 2,
              );
              _handleModuleDrop(moduleId, DraggableDetails(
                offset: centerPosition,
                velocity: Velocity.zero,
                wasAccepted: true,
              ));
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                key: _layoutKey,
                children: [
                  // 그리드 배경
                  _buildGridBackground(),
                  
                  // 드롭 영역 표시 (드래그 중일 때)
                  if (candidateData.isNotEmpty) _buildDropIndicator(),
                  
                  // 활성 모듈들
                  ..._buildActiveModules(),
                  
                  // 모듈 팔레트
                  if (_showModulePalette) _buildModulePalette(),
                  
                  // 컨트롤 버튼들
                  _buildControlButtons(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      size: _layoutSize,
      painter: GridPainter(gridSize: _gridSize),
    );
  }

  Widget _buildDropIndicator() {
    return Container(
      width: _layoutSize.width,
      height: _layoutSize.height,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '여기에 모듈을 놓으세요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActiveModules() {
    return _activeModules.map((moduleId) {
      final position = _modulePositions[moduleId] ?? Offset.zero;
      final size = _moduleSizes[moduleId] ?? const Size(400, 300);
      
      final maxLeft = (_layoutSize.width - size.width).clamp(0.0, _layoutSize.width);
      final maxTop = (_layoutSize.height - size.height).clamp(0.0, _layoutSize.height);
      
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        left: position.dx.clamp(0.0, maxLeft),
        top: position.dy.clamp(0.0, maxTop),
        width: size.width,
        height: size.height,
        child: _buildDraggableModule(moduleId, size),
      );
    }).toList();
  }

  Widget _buildDraggableModule(String moduleId, Size size) {
    final moduleInfo = ModuleFactory.getAvailableModules()
        .firstWhere((m) => m.id == moduleId);
    
    return Draggable<String>(
      data: moduleId,
      feedback: _buildModuleFeedback(moduleId, size),
      childWhenDragging: _buildModulePlaceholder(size),
      onDragStarted: () {
        setState(() {
          // 드래그 시작 시 상태 업데이트
        });
      },
      onDragEnd: (details) {
        _handleModuleDrop(moduleId, details);
        setState(() {
          // 드래그 종료 시 상태 업데이트
        });
      },
      onDragCompleted: () {
        // 드래그 성공 시 피드백
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${moduleInfo.title} 모듈이 이동되었습니다'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: _buildModuleContent(moduleId, size),
    );
  }

  Widget _buildModuleContent(String moduleId, Size size) {
    final module = ModuleFactory.createModule(
      moduleId: moduleId,
      recipe: widget.recipe,
      onCalculationChanged: (result) {
        if (widget.onCalculationChanged != null) {
          widget.onCalculationChanged!(result.toJson());
        }
      },
    );
    
    if (module == null) {
      return Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('모듈을 로드할 수 없습니다: $moduleId'),
        ),
      );
    }
    
    return Stack(
      clipBehavior: Clip.none, // 클리핑 동작 명시적 설정
      children: [
        Container(
          width: size.width,
          height: size.height,
          clipBehavior: Clip.hardEdge, // 하드 클리핑으로 오버플로우 방지
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: module,
        ),
        // 제거 버튼
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              onPressed: () => _removeModule(moduleId),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleFeedback(String moduleId, Size size) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            _getModuleTitle(moduleId),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModulePlaceholder(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withOpacity(0.3),
        border: Border.all(
          color: Colors.grey,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
    );
  }

  Widget _buildModulePalette() {
    return Positioned(
      right: 20,
      top: 80,
      child: Container(
        width: 250,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.widgets,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '모듈 팔레트',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showModulePalette = false;
                      });
                    },
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: _buildPaletteItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaletteItems() {
    final availableModules = ModuleFactory.getAvailableModules()
        .where((module) => !_activeModules.contains(module.id))
        .where((module) => _isModuleAvailableForCurrentMode(module.id))
        .toList();

    if (availableModules.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                '모든 모듈이 활성화되었습니다',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    return availableModules.map((module) {
      return Draggable<String>(
        data: module.id,
        feedback: _buildPaletteFeedback(module),
        childWhenDragging: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              Icon(module.icon, size: 20, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      '드래그 중...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  module.icon, 
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      module.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.drag_indicator,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPaletteFeedback(ModuleInfo module) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: module.defaultSize.width,
        height: module.defaultSize.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                module.icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 레이아웃 저장 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _saveLayout,
                child: Container(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.save,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // 레이아웃 초기화 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showResetDialog,
                child: Container(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.refresh,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // 모듈 팔레트 토글 버튼
          Container(
            decoration: BoxDecoration(
              color: _showModulePalette 
                  ? Theme.of(context).primaryColor 
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _showModulePalette = !_showModulePalette;
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  child: Icon(
                    _showModulePalette ? Icons.close : Icons.widgets,
                    color: _showModulePalette ? Colors.white : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleModuleDrop(String moduleId, DraggableDetails details) {
    final RenderBox? renderBox = _layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = renderBox.globalToLocal(details.offset);
    
    // 레이아웃 경계 확인
    if (localPosition.dx < 0 || localPosition.dy < 0 ||
        localPosition.dx > _layoutSize.width || localPosition.dy > _layoutSize.height) {
      // 경계 밖으로 드래그한 경우 모듈 제거
      if (_activeModules.contains(moduleId)) {
        _removeModule(moduleId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getModuleTitle(moduleId)} 모듈이 제거되었습니다'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // 개선된 그리드 스냅 - 모듈 크기 고려
    final moduleSize = _moduleSizes[moduleId] ?? const Size(400, 300);
    final snappedX = (localPosition.dx / _gridSize).round() * _gridSize;
    final snappedY = (localPosition.dy / _gridSize).round() * _gridSize;
    
    // 경계 내에서 조정
    final maxX = (_layoutSize.width - moduleSize.width).clamp(0.0, _layoutSize.width);
    final maxY = (_layoutSize.height - moduleSize.height).clamp(0.0, _layoutSize.height);
    
    final finalPosition = Offset(
      snappedX.clamp(0.0, maxX),
      snappedY.clamp(0.0, maxY),
    );
    
    // 다른 모듈과의 겹침 확인
    final adjustedPosition = _findNonOverlappingPosition(moduleId, finalPosition, moduleSize);
    
    setState(() {
      _modulePositions[moduleId] = adjustedPosition;
      
      // 팔레트에서 드래그한 경우 활성 모듈에 추가
      if (!_activeModules.contains(moduleId)) {
        _activeModules.add(moduleId);
        _moduleSizes[moduleId] = ModuleFactory.getAvailableModules()
            .firstWhere((m) => m.id == moduleId)
            .defaultSize;
      }
    });
    
    _saveLayout();
  }

  Offset _findNonOverlappingPosition(String moduleId, Offset targetPosition, Size moduleSize) {
    // 간단한 겹침 방지 로직
    for (final otherModuleId in _activeModules) {
      if (otherModuleId == moduleId) continue;
      
      final otherPosition = _modulePositions[otherModuleId] ?? Offset.zero;
      final otherSize = _moduleSizes[otherModuleId] ?? const Size(400, 300);
      
      // 겹침 확인
      if (_isOverlapping(targetPosition, moduleSize, otherPosition, otherSize)) {
        // 겹치는 경우 오른쪽으로 이동
        final newX = otherPosition.dx + otherSize.width + _gridSize;
        if (newX + moduleSize.width <= _layoutSize.width) {
          return Offset(newX, targetPosition.dy);
        } else {
          // 오른쪽에 공간이 없으면 아래로 이동
          final newY = otherPosition.dy + otherSize.height + _gridSize;
          if (newY + moduleSize.height <= _layoutSize.height) {
            return Offset(targetPosition.dx, newY);
          }
        }
      }
    }
    
    return targetPosition;
  }

  bool _isOverlapping(Offset pos1, Size size1, Offset pos2, Size size2) {
    return !(pos1.dx + size1.width <= pos2.dx ||
             pos2.dx + size2.width <= pos1.dx ||
             pos1.dy + size1.height <= pos2.dy ||
             pos2.dy + size2.height <= pos1.dy);
  }

  void _removeModule(String moduleId) {
    setState(() {
      _activeModules.remove(moduleId);
      _modulePositions.remove(moduleId);
      _moduleSizes.remove(moduleId);
    });
    _saveLayout();
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레이아웃 초기화'),
        content: const Text('모든 모듈을 기본 위치로 재배치하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetLayout();
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _resetLayout() {
    setState(() {
      _modulePositions.clear();
      _setDefaultPositions();
    });
    _saveLayout();
  }

  Future<void> _saveLayout() async {
    try {
      await widget.userSettingsService.saveModuleLayout(_modulePositions);
      await widget.userSettingsService.updateActiveModules(_activeModules);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('레이아웃이 저장되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('레이아웃 저장에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isModuleAvailableForCurrentMode(String moduleId) {
    switch (widget.userConfig.preferredMode) {
      case UserMode.homeBaker:
        return ['basic_calculator', 'scaling', 'unit_conversion'].contains(moduleId);
      case UserMode.professional:
        return ![].contains(moduleId); // 대부분 사용 가능
      case UserMode.research:
        return true; // 모든 모듈 사용 가능
    }
  }



  String _getModuleTitle(String moduleId) {
    final module = ModuleFactory.getAvailableModules()
        .firstWhere((m) => m.id == moduleId);
    return module.title;
  }
}

/// 그리드 배경을 그리는 커스텀 페인터
class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // 세로선 그리기
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 가로선 그리기
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}