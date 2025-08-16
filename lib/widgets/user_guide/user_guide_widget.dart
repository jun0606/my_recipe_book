/// 사용자 가이드 위젯
/// 통합 가이드 시스템의 메인 UI 컴포넌트

import 'package:flutter/material.dart';
import '../../services/user_guide_system.dart';

class UserGuideWidget extends StatefulWidget {
  final UserGuide guide;
  final VoidCallback? onGuideComplete;
  final Function(String stepId)? onStepComplete;
  final bool showProgress;
  final bool allowSkip;

  const UserGuideWidget({
    Key? key,
    required this.guide,
    this.onGuideComplete,
    this.onStepComplete,
    this.showProgress = true,
    this.allowSkip = false,
  }) : super(key: key);

  @override
  State<UserGuideWidget> createState() => _UserGuideWidgetState();
}

class _UserGuideWidgetState extends State<UserGuideWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  int _currentStepIndex = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // 현재 단계 찾기 (완료되지 않은 첫 번째 단계)
    _currentStepIndex = widget.guide.steps.indexWhere(
      (step) => !step.isCompleted,
    );
    if (_currentStepIndex == -1) {
      _currentStepIndex = widget.guide.steps.length - 1;
    }

    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = widget.guide.progress;
    _progressAnimationController.animateTo(progress);
  }

  Future<void> _completeCurrentStep() async {
    if (_isCompleting) return;
    
    setState(() {
      _isCompleting = true;
    });

    try {
      final currentStep = widget.guide.steps[_currentStepIndex];
      
      // 단계 완료 콜백 호출
      widget.onStepComplete?.call(currentStep.id);

      // 다음 단계로 이동
      if (_currentStepIndex < widget.guide.steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
        
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // 모든 단계 완료
        widget.onGuideComplete?.call();
      }

      _updateProgress();
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  void _goToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < widget.guide.steps.length) {
      setState(() {
        _currentStepIndex = stepIndex;
      });
      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          if (widget.showProgress) _buildProgressIndicator(),
          Expanded(child: _buildStepContent()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getGuideTypeColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getGuideTypeIcon(),
                color: _getGuideTypeColor(),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.guide.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _getGuideTypeColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.allowSkip)
                TextButton(
                  onPressed: () => widget.onGuideComplete?.call(),
                  child: const Text('건너뛰기'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.guide.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '예상 시간: ${_formatDuration(widget.guide.estimatedRemainingTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '${widget.guide.completedStepsCount}/${widget.guide.steps.length} 완료',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getGuideTypeColor(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.guide.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.guide.steps.length,
              itemBuilder: (context, index) {
                final step = widget.guide.steps[index];
                final isCompleted = step.isCompleted;
                final isCurrent = index == _currentStepIndex;
                
                return GestureDetector(
                  onTap: () => _goToStep(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? _getGuideTypeColor()
                          : isCurrent
                              ? _getGuideTypeColor().withOpacity(0.2)
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: isCurrent
                          ? Border.all(color: _getGuideTypeColor(), width: 2)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : isCurrent
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                          size: 16,
                          color: isCompleted
                              ? Colors.white
                              : isCurrent
                                  ? _getGuideTypeColor()
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.white
                                : isCurrent
                                    ? _getGuideTypeColor()
                                    : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentStepIndex = index;
        });
      },
      itemCount: widget.guide.steps.length,
      itemBuilder: (context, index) {
        final step = widget.guide.steps[index];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GuideStepWidget(
            step: step,
            stepNumber: index + 1,
            totalSteps: widget.guide.steps.length,
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    final currentStep = widget.guide.steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == widget.guide.steps.length - 1;
    final canGoBack = _currentStepIndex > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          if (canGoBack)
            OutlinedButton.icon(
              onPressed: () => _goToStep(_currentStepIndex - 1),
              icon: const Icon(Icons.arrow_back),
              label: const Text('이전'),
            ),
          const Spacer(),
          if (!currentStep.isCompleted)
            ElevatedButton.icon(
              onPressed: _isCompleting ? null : _completeCurrentStep,
              icon: _isCompleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
              label: Text(isLastStep ? '완료' : '다음'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getGuideTypeColor(),
                foregroundColor: Colors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: isLastStep ? null : () => _goToStep(_currentStepIndex + 1),
              icon: const Icon(Icons.check_circle),
              label: Text(isLastStep ? '완료됨' : '다음'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Color _getGuideTypeColor() {
    switch (widget.guide.type) {
      case GuideType.setup:
        return Colors.blue;
      case GuideType.fermentation:
        return Colors.green;
      case GuideType.troubleshooting:
        return Colors.orange;
      case GuideType.maintenance:
        return Colors.purple;
      case GuideType.safety:
        return Colors.red;
    }
  }

  IconData _getGuideTypeIcon() {
    switch (widget.guide.type) {
      case GuideType.setup:
        return Icons.settings;
      case GuideType.fermentation:
        return Icons.timeline;
      case GuideType.troubleshooting:
        return Icons.build;
      case GuideType.maintenance:
        return Icons.cleaning_services;
      case GuideType.safety:
        return Icons.security;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}

/// 개별 가이드 단계 위젯
class GuideStepWidget extends StatelessWidget {
  final GuideStep step;
  final int stepNumber;
  final int totalSteps;

  const GuideStepWidget({
    Key? key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),
        const SizedBox(height: 16),
        _buildStepDescription(context),
        const SizedBox(height: 16),
        _buildInstructions(context),
        if (step.tips.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTips(context),
        ],
        if (step.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildWarnings(context),
        ],
        if (step.requiredTools.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRequiredTools(context),
        ],
        if (step.estimatedTime != null) ...[
          const SizedBox(height: 16),
          _buildEstimatedTime(context),
        ],
      ],
    );
  }

  Widget _buildStepHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: step.isCompleted ? Colors.green : _getPriorityColor(),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: step.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '단계 $stepNumber / $totalSteps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPriorityText(),
            style: TextStyle(
              color: _getPriorityColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        step.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실행 방법',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...step.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    instruction,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '유용한 팁',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...step.tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: Colors.green[700])),
                Expanded(
                  child: Text(
                    tip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildWarnings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '주의사항',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...step.warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠ ', style: TextStyle(color: Colors.orange[700])),
                Expanded(
                  child: Text(
                    warning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRequiredTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '필요한 도구',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: step.requiredTools.map((tool) => Chip(
            label: Text(
              tool,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.grey[200],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildEstimatedTime(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: Colors.blue[700], size: 16),
          const SizedBox(width: 4),
          Text(
            '예상 시간: ${_formatDuration(step.estimatedTime!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (step.priority) {
      case GuidePriority.critical:
        return Colors.red;
      case GuidePriority.important:
        return Colors.orange;
      case GuidePriority.helpful:
        return Colors.blue;
      case GuidePriority.optional:
        return Colors.grey;
    }
  }

  String _getPriorityText() {
    switch (step.priority) {
      case GuidePriority.critical:
        return '필수';
      case GuidePriority.important:
        return '중요';
      case GuidePriority.helpful:
        return '도움';
      case GuidePriority.optional:
        return '선택';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}