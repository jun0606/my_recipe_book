import 'package:flutter/material.dart';
import '../../models/user_configuration.dart';

/// 사용자가 드래그 앤 드롭으로 기능을 커스터마이징할 수 있는 위젯
class FeatureCustomizer extends StatefulWidget {
  final RecipeSettings settings;
  final Function(RecipeSettings) onSettingsChanged;

  const FeatureCustomizer({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<FeatureCustomizer> createState() => _FeatureCustomizerState();
}

class _FeatureCustomizerState extends State<FeatureCustomizer> {
  late List<FeatureItem> availableFeatures;
  late List<FeatureItem> enabledFeatures;

  @override
  void initState() {
    super.initState();
    _initializeFeatures();
  }

  void _initializeFeatures() {
    // 사용 가능한 모든 기능들
    final allFeatures = [
      const FeatureItem(
        id: 'baking_calculator',
        title: '베이킹 계산기',
        description: '베이커스 퍼센트, 하이드레이션 등 계산',
        icon: Icons.calculate,
        category: FeatureCategory.calculation,
      ),
      const FeatureItem(
        id: 'nutrition_info',
        title: '영양 정보',
        description: '칼로리, 단백질, 탄수화물 등',
        icon: Icons.health_and_safety,
        category: FeatureCategory.health,
      ),
      const FeatureItem(
        id: 'video_guides',
        title: '비디오 가이드',
        description: '유튜브 영상 및 로컬 비디오',
        icon: Icons.video_library,
        category: FeatureCategory.media,
      ),
      const FeatureItem(
        id: 'scaling',
        title: '레시피 스케일링',
        description: '인분 수 조정 및 팬 크기 변환',
        icon: Icons.straighten,
        category: FeatureCategory.calculation,
      ),
      const FeatureItem(
        id: 'substitutions',
        title: '재료 대체',
        description: '재료 대체 제안 및 계산',
        icon: Icons.swap_horiz,
        category: FeatureCategory.calculation,
      ),
      const FeatureItem(
        id: 'timer',
        title: '타이머',
        description: '단계별 타이머 기능',
        icon: Icons.timer,
        category: FeatureCategory.utility,
      ),
      const FeatureItem(
        id: 'notes',
        title: '개인 노트',
        description: '레시피에 개인 메모 추가',
        icon: Icons.note_add,
        category: FeatureCategory.utility,
      ),
      const FeatureItem(
        id: 'shopping_list',
        title: '쇼핑 리스트',
        description: '재료 쇼핑 리스트 생성',
        icon: Icons.shopping_cart,
        category: FeatureCategory.utility,
      ),
      const FeatureItem(
        id: 'cost_calculator',
        title: '원가 계산',
        description: '재료비 및 총 원가 계산',
        icon: Icons.attach_money,
        category: FeatureCategory.calculation,
      ),
      const FeatureItem(
        id: 'difficulty_indicator',
        title: '난이도 표시',
        description: '베이킹 난이도 및 소요 시간',
        icon: Icons.star_rate,
        category: FeatureCategory.info,
      ),
      const FeatureItem(
        id: 'weather_adjustment',
        title: '날씨 조정',
        description: '습도, 온도에 따른 레시피 조정',
        icon: Icons.wb_sunny,
        category: FeatureCategory.calculation,
      ),
      const FeatureItem(
        id: 'altitude_adjustment',
        title: '고도 조정',
        description: '고도에 따른 베이킹 조정',
        icon: Icons.terrain,
        category: FeatureCategory.calculation,
      ),
    ];

    // 현재 설정에 따라 활성화된 기능과 비활성화된 기능 분리
    enabledFeatures = allFeatures.where((feature) {
      switch (feature.id) {
        case 'baking_calculator':
          return widget.settings.showBakingCalculator;
        case 'nutrition_info':
          return widget.settings.showNutritionInfo;
        case 'video_guides':
          return widget.settings.showVideoGuides;
        case 'scaling':
          return widget.settings.enableScaling;
        case 'substitutions':
          return widget.settings.enableSubstitutions;
        default:
          return widget.settings.enabledFeatures.contains(feature.id);
      }
    }).toList();

    availableFeatures = allFeatures
        .where((feature) =>
            !enabledFeatures.any((enabled) => enabled.id == feature.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기능 커스터마이징'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '드래그 앤 드롭으로 원하는 기능을 활성화하세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // 활성화된 기능들
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '활성화된 기능',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: DragTarget<FeatureItem>(
                      onAcceptWithDetails: (details) {
                        setState(() {
                          availableFeatures.remove(details.data);
                          enabledFeatures.add(details.data);
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: candidateData.isNotEmpty
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                          ),
                          child: enabledFeatures.isEmpty
                              ? const Center(
                                  child: Text(
                                    '여기로 기능을 드래그하세요',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ReorderableListView(
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (newIndex > oldIndex) {
                                        newIndex -= 1;
                                      }
                                      final item =
                                          enabledFeatures.removeAt(oldIndex);
                                      enabledFeatures.insert(newIndex, item);
                                    });
                                  },
                                  children: enabledFeatures.map((feature) {
                                    return Dismissible(
                                      key: Key(feature.id),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        setState(() {
                                          enabledFeatures.remove(feature);
                                          availableFeatures.add(feature);
                                        });
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: FeatureTile(
                                        key: Key(feature.id),
                                        feature: feature,
                                        isEnabled: true,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 사용 가능한 기능들
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '사용 가능한 기능',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: availableFeatures.length,
                      itemBuilder: (context, index) {
                        final feature = availableFeatures[index];
                        return Draggable<FeatureItem>(
                          data: feature,
                          feedback: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 200,
                              height: 60,
                              child: FeatureTile(
                                feature: feature,
                                isEnabled: false,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: FeatureTile(
                              feature: feature,
                              isEnabled: false,
                            ),
                          ),
                          child: FeatureTile(
                            feature: feature,
                            isEnabled: false,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final newSettings = widget.settings.copyWith(
      showBakingCalculator:
          enabledFeatures.any((f) => f.id == 'baking_calculator'),
      showNutritionInfo: enabledFeatures.any((f) => f.id == 'nutrition_info'),
      showVideoGuides: enabledFeatures.any((f) => f.id == 'video_guides'),
      enableScaling: enabledFeatures.any((f) => f.id == 'scaling'),
      enableSubstitutions: enabledFeatures.any((f) => f.id == 'substitutions'),
      enabledFeatures: enabledFeatures
          .where((f) => ![
                'baking_calculator',
                'nutrition_info',
                'video_guides',
                'scaling',
                'substitutions'
              ].contains(f.id))
          .map((f) => f.id)
          .toList(),
    );

    widget.onSettingsChanged(newSettings);
    Navigator.of(context).pop();
  }
}

/// 기능 아이템 모델
class FeatureItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final FeatureCategory category;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}

enum FeatureCategory {
  calculation, // 계산
  health, // 건강
  media, // 미디어
  utility, // 유틸리티
  info, // 정보
}

/// 기능 타일 위젯
class FeatureTile extends StatelessWidget {
  final FeatureItem feature;
  final bool isEnabled;

  const FeatureTile({
    super.key,
    required this.feature,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isEnabled ? 2 : 1,
      color: isEnabled ? Colors.blue.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              feature.icon,
              color: _getCategoryColor(feature.category),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    feature.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isEnabled ? Colors.blue.shade800 : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isEnabled
                          ? Colors.blue.shade600
                          : Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(FeatureCategory category) {
    switch (category) {
      case FeatureCategory.calculation:
        return Colors.blue;
      case FeatureCategory.health:
        return Colors.green;
      case FeatureCategory.media:
        return Colors.purple;
      case FeatureCategory.utility:
        return Colors.orange;
      case FeatureCategory.info:
        return Colors.teal;
    }
  }
}
