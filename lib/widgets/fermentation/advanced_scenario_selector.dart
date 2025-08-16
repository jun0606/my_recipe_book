/// 고급 발효 시나리오 선택 위젯
/// 환경별 세분화된 시나리오, AI 추천, 커스텀 시나리오 관리

import 'package:flutter/material.dart';
import '../../models/fermentation_scenario.dart';
import '../../models/sous_chef_models.dart';
import '../../services/advanced_fermentation_scenarios.dart';
import 'custom_scenario_builder.dart';

class AdvancedScenarioSelector extends StatefulWidget {
  final Function(FermentationScenario) onScenarioSelected;
  final List<Map<String, dynamic>> ingredients;
  final double environmentTemperature;
  final double environmentHumidity;
  final double altitude;
  final String? recipeTitle;

  const AdvancedScenarioSelector({
    super.key,
    required this.onScenarioSelected,
    required this.ingredients,
    this.environmentTemperature = 26.0,
    this.environmentHumidity = 60.0,
    this.altitude = 0.0,
    this.recipeTitle,
  });

  @override
  State<AdvancedScenarioSelector> createState() => _AdvancedScenarioSelectorState();
}

class _AdvancedScenarioSelectorState extends State<AdvancedScenarioSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  Map<String, Map<String, dynamic>> _customScenarios = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2개 탭으로 단순화
    _loadScenarios();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadScenarios() async {
    // 커스텀 시나리오만 로드 (단순화)
    _customScenarios = await AdvancedFermentationScenarios.getCustomScenarios();
    
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발효 시나리오 선택'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: '내 시나리오'),
            Tab(icon: Icon(Icons.add), text: '새로 만들기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCustomScenariosTab(),
          _buildCreateScenarioTab(),
        ],
      ),
    );
  }





  Widget _buildCustomScenariosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '내가 만든 시나리오',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _loadScenarios,
                icon: const Icon(Icons.refresh),
                label: const Text('새로고침'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_customScenarios.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '저장된 커스텀 시나리오가 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"새로 만들기" 탭에서 나만의 시나리오를 만들어보세요',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ..._customScenarios.entries.map((entry) {
              final name = entry.key;
              final data = entry.value;
              final scenario = FermentationScenario.fromJson(data['scenario']);
              
              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(
                    '${scenario.selectedStages.length}단계 • ${scenario.totalEstimatedTime.toStringAsFixed(0)}분',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        onPressed: () => _deleteCustomScenario(name),
                        icon: const Icon(Icons.delete),
                        tooltip: '삭제',
                      ),
                    ],
                  ),
                  onTap: () => widget.onScenarioSelected(scenario),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCreateScenarioTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '나만의 발효 시나리오 만들기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '원하는 발효 단계와 시간을 직접 설정해보세요',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCustomScenarioBuilder,
            icon: const Icon(Icons.create),
            label: const Text('시나리오 만들기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomScenarioBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomScenarioBuilder(
          onScenarioCreated: (scenario) {
            widget.onScenarioSelected(scenario);
            Navigator.pop(context); // 시나리오 선택 화면으로 돌아가기
            Navigator.pop(context); // 메인 화면으로 돌아가기
          },
          ingredients: widget.ingredients,
          environmentTemperature: widget.environmentTemperature,
          environmentHumidity: widget.environmentHumidity,
          altitude: widget.altitude,
          recipeTitle: widget.recipeTitle,
        ),
      ),
    );
  }





  Future<void> _deleteCustomScenario(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시나리오 삭제'),
        content: Text('$name 시나리오를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await AdvancedFermentationScenarios.deleteCustomScenario(name);
      _loadScenarios();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name 시나리오가 삭제되었습니다')),
      );
    }
  }


}