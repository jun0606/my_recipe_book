import 'package:flutter/material.dart';

class InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const InstructionStep({
    Key? key,
    required this.stepNumber,
    required this.instruction,
  }) : super(key: key);

  String _cleanInstructionText(String text) {
    // HTML 태그 제거
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // 마크다운 코드 블록 제거 (```로 감싸진 부분)
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // 인라인 코드 제거 (`로 감싸진 부분)
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]*`'), '');
    
    // 특수 문자 정리
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1'); // **bold** -> bold
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1'); // *italic* -> italic
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'$1'); // __bold__ -> bold
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'$1'); // _italic_ -> italic
    
    // 여러 줄바꿈을 하나로 정리
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
    
    // 앞뒤 공백 제거
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 단계 번호
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 조리법 내용
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                _cleanInstructionText(instruction),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}