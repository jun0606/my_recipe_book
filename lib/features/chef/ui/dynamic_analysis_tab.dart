import 'package:flutter/material.dart';

/// 동적 분석 탭 위젯
class DynamicAnalysisTab extends StatefulWidget {
  const DynamicAnalysisTab({super.key});

  @override
  State<DynamicAnalysisTab> createState() => _DynamicAnalysisTabState();
}

class _DynamicAnalysisTabState extends State<DynamicAnalysisTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('동적 분석 탭'),
    );
  }
}
