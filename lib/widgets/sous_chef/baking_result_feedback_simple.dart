/// 간단한 베이킹 결과 피드백 위젯
import 'package:flutter/material.dart';
import '../../models/favorite_preset.dart';

class BakingResultFeedbackSimple extends StatefulWidget {
  final FavoritePreset preset;
  final Map<String, dynamic> recipeContext;
  final VoidCallback? onFeedbackSubmitted;

  const BakingResultFeedbackSimple({
    super.key,
    required this.preset,
    required this.recipeContext,
    this.onFeedbackSubmitted,
  });

  @override
  State<BakingResultFeedbackSimple> createState() => _BakingResultFeedbackSimpleState();
}

class _BakingResultFeedbackSimpleState extends State<BakingResultFeedbackSimple> {
  double _overallScore = 3.0;
  bool _hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _hasSubmitted ? _buildThankYouMessage() : _buildFeedbackForm(),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.preset.name} 프리셋 사용 결과',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        const Text('전체적인 만족도를 평가해주세요:'),
        const SizedBox(height: 8),
        
        Slider(
          value: _overallScore,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          label: '${_overallScore.toStringAsFixed(1)}점',
          onChanged: (value) => setState(() => _overallScore = value),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitFeedback,
            child: const Text('피드백 제출'),
          ),
        ),
      ],
    );
  }

  Widget _buildThankYouMessage() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          '피드백 감사합니다!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.onFeedbackSubmitted?.call(),
          child: const Text('완료'),
        ),
      ],
    );
  }

  void _submitFeedback() {
    setState(() {
      _hasSubmitted = true;
    });
    
    // 간단한 피드백 로깅
    print('Feedback for ${widget.preset.name}: $_overallScore/5.0');
  }
}