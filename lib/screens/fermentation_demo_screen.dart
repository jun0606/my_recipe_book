/// 발효 시스템 데모 화면
/// 실제 레시피 없이도 발효 시스템을 테스트할 수 있는 데모

import 'package:flutter/material.dart';
import '../screens/enhanced_fermentation_screen.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';

class FermentationDemoScreen extends StatelessWidget {
  const FermentationDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발효 시스템 데모'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '발효 시스템 테스트',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '다양한 레시피 타입으로 발효 시스템을 테스트해보세요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // 데모 레시피 버튼들
            _buildDemoButton(
              context,
              '기본 식빵',
              '일반적인 식빵 레시피로 테스트',
              Icons.bakery_dining,
              Colors.blue,
              () => _launchDemo(context, _createBasicBreadRecipe()),
            ),
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              '리치 브리오슈',
              '버터와 설탕이 많은 리치 도우',
              Icons.cake,
              Colors.orange,
              () => _launchDemo(context, _createRichBriocheRecipe()),
            ),
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              '통밀 빵',
              '통밀가루를 사용한 건강한 빵',
              Icons.eco,
              Colors.green,
              () => _launchDemo(context, _createWholeWheatRecipe()),
            ),
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              '사워도우',
              '천연 발효종을 사용한 사워도우',
              Icons.science,
              Colors.purple,
              () => _launchDemo(context, _createSourdoughRecipe()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.shade50,
          foregroundColor: color.shade700,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.shade400),
          ],
        ),
      ),
    );
  }

  void _launchDemo(BuildContext context, RecipeAnalysis recipe) {
    final environment = EnvironmentalConditions(
      temperature: 23.0,
      humidity: 60.0,
      altitude: 0,
      season: _getCurrentSeason(),
      timestamp: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedFermentationScreen(
          recipe: recipe,
          environment: environment,
        ),
      ),
    );
  }

  Season _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  // 데모 레시피들
  RecipeAnalysis _createBasicBreadRecipe() {
    return RecipeAnalysis(
      recipeId: 'demo_basic_bread',
      recipeName: '기본 식빵',
      flourAmount: 500,
      yeastAmount: 7,
      sugarAmount: 30,
      liquidAmount: 320,
      fatAmount: 30,
      yeastType: YeastType.dry,
      breadType: BreadType.white,
      analysisTimestamp: DateTime.now(),
    );
  }

  RecipeAnalysis _createRichBriocheRecipe() {
    return RecipeAnalysis(
      recipeId: 'demo_brioche',
      recipeName: '리치 브리오슈',
      flourAmount: 500,
      yeastAmount: 10,
      sugarAmount: 80,
      liquidAmount: 200,
      fatAmount: 150, // 버터 많음
      yeastType: YeastType.fresh,
      breadType: BreadType.enriched,
      analysisTimestamp: DateTime.now(),
    );
  }

  RecipeAnalysis _createWholeWheatRecipe() {
    return RecipeAnalysis(
      recipeId: 'demo_whole_wheat',
      recipeName: '통밀 빵',
      flourAmount: 500,
      yeastAmount: 8,
      sugarAmount: 20,
      liquidAmount: 350, // 수분 많음
      fatAmount: 20,
      yeastType: YeastType.dry,
      breadType: BreadType.whole_wheat,
      analysisTimestamp: DateTime.now(),
    );
  }

  RecipeAnalysis _createSourdoughRecipe() {
    return RecipeAnalysis(
      recipeId: 'demo_sourdough',
      recipeName: '사워도우',
      flourAmount: 500,
      yeastAmount: 0, // 천연 발효종 사용
      sugarAmount: 0,
      liquidAmount: 375,
      fatAmount: 0,
      yeastType: YeastType.sourdough,
      breadType: BreadType.sourdough,
      analysisTimestamp: DateTime.now(),
    );
  }
}