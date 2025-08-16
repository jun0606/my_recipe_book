import 'package:flutter/material.dart';
import '../../../models/history.dart';

/// 히스토리 항목 카드 위젯
class HistoryEntryCard extends StatelessWidget {
  /// 히스토리 항목
  final History history;
  
  /// 복원 콜백
  final VoidCallback onRestore;
  
  /// 생성자
  const HistoryEntryCard({
    Key? key,
    required this.history,
    required this.onRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷팅
    final dateTime = DateTime.parse(history.modifiedDate);
    final formattedDate = '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.restore),
                  tooltip: '이 버전으로 복원',
                  onPressed: onRestore,
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8.0),
            Text(
              '변경 사항:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              history.changes,
              style: TextStyle(fontSize: 14.0),
            ),
            if (history.recipeState != null) ...[
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.visibility),
                  label: Text('상세 보기'),
                  onPressed: () {
                    _showHistoryDetails(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showHistoryDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('변경 사항 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이 기능은 아직 구현되지 않았습니다.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16.0),
              Text(
                '향후 업데이트에서 이전 버전과 현재 버전의 상세 비교 기능이 추가될 예정입니다.',
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }
}