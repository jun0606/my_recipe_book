import 'package:flutter/material.dart';
import 'package:my_recipe_book/models/user_configuration.dart';

/// 사용자 모드 선택 위젯
class UserModeSelector extends StatelessWidget {
  final UserMode currentMode;
  final Function(UserMode) onModeChanged;
  final bool showDescription;

  const UserModeSelector({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
    this.showDescription = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용자 모드',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...UserMode.values.map((mode) => _buildModeOption(context, mode)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(BuildContext context, UserMode mode) {
    final isSelected = currentMode == mode;
    final modeInfo = _getModeInfo(mode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                modeInfo.icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeInfo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                    ),
                    if (showDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        modeInfo.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: modeInfo.features
                            .map(
                              (feature) => Chip(
                                label: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: isSelected
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2)
                                    : Colors.grey.shade100,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ModeInfo _getModeInfo(UserMode mode) {
    switch (mode) {
      case UserMode.homeBaker:
        return ModeInfo(
          title: '홈베이커',
          description: '가정에서 베이킹을 즐기는 분들을 위한 간단하고 직관적인 모드',
          icon: Icons.home,
          features: ['간단한 계산', '단위 변환', '기본 스케일링', '도움말'],
        );
      case UserMode.professional:
        return ModeInfo(
          title: '전문베이커',
          description: '베이킹 전문가를 위한 고급 기능과 정밀한 계산 도구',
          icon: Icons.business,
          features: ['베이커스 퍼센트', '배치 스케일링', '원가 분석', '환경 보정'],
        );
      case UserMode.research:
        return ModeInfo(
          title: '연구개발',
          description: '연구 및 개발을 위한 과학적 정밀도와 실험적 기능',
          icon: Icons.science,
          features: ['고정밀 계산', '실험 기능', '데이터 분석', '공식 표시'],
        );
    }
  }
}

class ModeInfo {
  final String title;
  final String description;
  final IconData icon;
  final List<String> features;

  ModeInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
  });
}

/// 간단한 모드 전환 버튼
class QuickModeToggle extends StatelessWidget {
  final UserMode currentMode;
  final Function(UserMode) onModeChanged;

  const QuickModeToggle({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: UserMode.values.map((mode) {
          final isSelected = currentMode == mode;
          return GestureDetector(
            onTap: () => onModeChanged(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getShortModeTitle(mode),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getShortModeTitle(UserMode mode) {
    switch (mode) {
      case UserMode.homeBaker:
        return '홈';
      case UserMode.professional:
        return '전문';
      case UserMode.research:
        return '연구';
    }
  }
}

/// 모드별 기능 설명 다이얼로그
class ModeInfoDialog extends StatelessWidget {
  final UserMode mode;

  const ModeInfoDialog({Key? key, required this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modeDetails = _getModeDetails(mode);

    return AlertDialog(
      title: Row(
        children: [
          Icon(modeDetails.icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(modeDetails.title),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(modeDetails.description),
            const SizedBox(height: 16),
            Text(
              '주요 기능:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...modeDetails.detailedFeatures.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '적합한 사용자:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(modeDetails.targetUsers),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    );
  }

  ModeDetails _getModeDetails(UserMode mode) {
    switch (mode) {
      case UserMode.homeBaker:
        return ModeDetails(
          title: '홈베이커 모드',
          description: '가정에서 베이킹을 즐기는 분들을 위해 설계된 사용하기 쉬운 모드입니다.',
          icon: Icons.home,
          detailedFeatures: [
            '간단한 레시피 스케일링 (2배, 3배, 절반)',
            '일반적인 단위 변환 (컵 ↔ 그램)',
            '기본적인 재료 대체 제안',
            '단계별 도움말과 팁',
            '시각적 피드백과 아이콘',
            '일반적인 베이킹 실수 방지 알림',
          ],
          targetUsers: '베이킹 초보자, 가정용 베이킹을 즐기는 분, 간단한 계산만 필요한 분',
        );
      case UserMode.professional:
        return ModeDetails(
          title: '전문베이커 모드',
          description: '베이킹 전문가와 상업적 베이킹을 위한 고급 기능을 제공합니다.',
          icon: Icons.business,
          detailedFeatures: [
            '베이커스 퍼센트 계산 및 표시',
            '대량 생산을 위한 배치 스케일링',
            '재료비 및 원가 분석',
            '환경 조건에 따른 레시피 보정',
            '발효 시간 및 온도 계산',
            '수율 예측 및 손실률 계산',
            '정밀한 단위 변환',
          ],
          targetUsers: '전문 베이커, 베이커리 운영자, 요리학교 학생, 상업적 베이킹 종사자',
        );
      case UserMode.research:
        return ModeDetails(
          title: '연구개발 모드',
          description: '과학적 정밀도와 실험적 기능을 제공하는 고급 연구 도구입니다.',
          icon: Icons.science,
          detailedFeatures: [
            '0.1g 정밀도의 고정밀 계산',
            '과학적 공식 및 계산 과정 표시',
            '실험적 기능 및 베타 도구',
            '통계 분석 및 데이터 시각화',
            'A/B 테스트 프레임워크',
            '데이터 내보내기 및 분석 도구',
            '레시피 최적화 알고리즘',
          ],
          targetUsers: '식품 연구원, 제품 개발자, 베이킹 과학 연구자, 고급 베이킹 전문가',
        );
    }
  }
}

class ModeDetails {
  final String title;
  final String description;
  final IconData icon;
  final List<String> detailedFeatures;
  final String targetUsers;

  ModeDetails({
    required this.title,
    required this.description,
    required this.icon,
    required this.detailedFeatures,
    required this.targetUsers,
  });
}
