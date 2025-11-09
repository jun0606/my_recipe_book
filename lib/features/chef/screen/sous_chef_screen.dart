// Sous Chef 메인 화면 - 최소화 버전
// 분리된 컴포넌트들을 조합하여 사용하는 최소한의 코드만 유지

import 'package:flutter/material.dart';

// 분리된 컴포넌트들 import
import 'widgets/environment_input_card.dart';
import 'widgets/mixing_analysis_card.dart';
import 'widgets/improvement_suggestions.dart';
import 'widgets/real_time_recipe_tab.dart';
import 'services/recipe_analyzer.dart';
import 'types/screen_types.dart';

// 필수 모듈들
import '../../../core/types/environment_types.dart';
import '../../../data/module_keywords.dart';

/// Sous Chef 메인 화면 - 완전 최소화 버전
class SousChefModeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const SousChefModeScreen({
    super.key,
    required this.recipeData,
  });

  @override
  State<SousChefModeScreen> createState() => _SousChefModeScreenState();
}

class _SousChefModeScreenState extends State<SousChefModeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SousChefScreenState _screenState;
  late AnalysisSettings _analysisSettings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeState() {
    final defaultEnvironment = UserEnvironment(
      temperature: 25.0,
      humidity: 60.0,
      pressure: 1013.25,
      altitude: 0.0,
      season: Season.spring,
      ovenType: OvenType.convection,
      fermentationMethod: FermentationMethod.roomTemperature,
      mixerType: MixerType.home,
      lastUpdated: DateTime.now(),
    );

    final selectedModule =
        RecipeAnalyzer.analyzeRecipeModule(widget.recipeData);

    _screenState = SousChefScreenState(
      environment: defaultEnvironment,
      selectedModule: selectedModule,
      analysisResults: {},
    );

    _analysisSettings = const AnalysisSettings();
  }

  void _onEnvironmentChanged(UserEnvironment newEnvironment) {
    setState(() =>
        _screenState = _screenState.copyWith(environment: newEnvironment));
  }

  void _onAnalysisComplete(Map<String, dynamic> results) {
    setState(
        () => _screenState = _screenState.copyWith(analysisResults: results));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sous Chef Mode'),
        backgroundColor: Colors.pink[400],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '분석', icon: Icon(Icons.analytics)),
            Tab(text: '개선방법', icon: Icon(Icons.tune)),
            Tab(text: '실시간 레시피', icon: Icon(Icons.restaurant_menu)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalysisTab(),
          _buildImprovementTab(),
          _buildRealTimeRecipeTab(),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleSelector(),
          const SizedBox(height: 16),
          EnvironmentInputCard(
            initialEnvironment: _screenState.environment,
            onEnvironmentChanged: _onEnvironmentChanged,
            showMixerType: _screenState.selectedModule == 'bread',
          ),
          const SizedBox(height: 16),
          MixingAnalysisCard(
            recipeData: widget.recipeData,
            environment: _screenState.environment,
            settings: _analysisSettings,
            onAnalysisComplete: _onAnalysisComplete,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('분석 모듈 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ModuleKeywords.moduleInfo.entries.map((entry) {
                final moduleKey = entry.key;
                final moduleData = entry.value;
                final isSelected = _screenState.selectedModule == moduleKey;

                return GestureDetector(
                  onTap: () => setState(() => _screenState =
                      _screenState.copyWith(selectedModule: moduleKey)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIcon(moduleKey),
                            size: 16,
                            color: isSelected ? Colors.blue : Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          moduleData['name'] ?? '모듈',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTab() {
    return ImprovementSuggestions(
      environment: _screenState.environment,
      mixingData: widget.recipeData,
    );
  }

  Widget _buildRealTimeRecipeTab() {
    return const RealTimeRecipeTab();
  }

  IconData _getIcon(String moduleKey) {
    switch (moduleKey) {
      case 'bread':
        return Icons.bakery_dining;
      case 'cake':
        return Icons.cake;
      case 'cookie':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}
