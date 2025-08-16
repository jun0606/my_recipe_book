import 'package:flutter/material.dart';

/// 발효 전문가 시트 (더 이상 사용하지 않음)
/// 
/// 이 기능은 Sous Chef 시스템에 통합되었습니다.
/// 대신 SousChefOptionsSheet를 사용하세요.
class FermentationAdvisorSheet extends StatefulWidget {
  final Function(dynamic) onSettingsApplied;

  const FermentationAdvisorSheet({
    super.key,
    required this.onSettingsApplied,
  });

  @override
  State<FermentationAdvisorSheet> createState() => _FermentationAdvisorSheetState();
}

class _FermentationAdvisorSheetState extends State<FermentationAdvisorSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            '발효 전문가 기능이 이동되었습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '발효 전문가 기능이 Sous Chef 시스템에 통합되었습니다.\n'
            '더 강력하고 종합적인 베이킹 조언을 위해\n'
            'Sous Chef 버튼을 사용해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}