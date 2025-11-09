import 'package:flutter/material.dart';
import '../../../../../models/recipe.dart';
import '../../../../recipe_detail_screen.dart';

class ConnectionPainter extends CustomPainter {
  final List<Map<String, dynamic>> treeRecipes;
  final Recipe initialRecipe;
  final double horizontalOffset;
  final double verticalOffset;

  ConnectionPainter({
    required this.treeRecipes,
    required this.initialRecipe,
    required this.horizontalOffset,
    required this.verticalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade500,
          Colors.blue.shade700,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 최소 깊이 계산
    int minDepth = treeRecipes
        .map((e) => e['depth'] as int)
        .reduce((a, b) => a < b ? a : b);

    // 각 노드의 연결선 그리기
    for (int i = 0; i < treeRecipes.length; i++) {
      final entry = treeRecipes[i];
      final depth = entry['depth'] as int;
      final normalizedDepth = depth - minDepth;

      // 부모 노드 찾기 (현재 노드의 부모)
      if (normalizedDepth > 0) {
        // 같은 레벨의 이전 노드들 중 부모 찾기
        int? parentIndex;
        for (int j = i - 1; j >= 0; j--) {
          final parentEntry = treeRecipes[j];
          final parentDepth = parentEntry['depth'] as int;
          final parentNormalizedDepth = parentDepth - minDepth;

          if (parentNormalizedDepth == normalizedDepth - 1) {
            parentIndex = j;
            break;
          }
        }

        if (parentIndex != null) {
          // 직접 좌표 계산 (Positioned의 left/top 기반)
          final parentX =
              ((treeRecipes[parentIndex]['depth'] as int) - minDepth) * 320.0 +
                  20.0;
          final parentY = parentIndex * 130.0 + 20.0;
          final childX = normalizedDepth * 320.0 + 20.0;
          final childY = i * 130.0 + 20.0;

          // 카드 테두리 좌표 계산 (스크롤 오프셋 고려)
          const cardWidth = 300.0;
          const cardHeight = 100.0;
          const borderOffset = 2.0;

          // 부모 카드 우측 하단 테두리
          final parentEnd = Offset(
            parentX + cardWidth - borderOffset - horizontalOffset,
            parentY + cardHeight - borderOffset - verticalOffset,
          );

          // 자식 카드 좌측 상단 테두리
          final childStart = Offset(
            childX + borderOffset - horizontalOffset,
            childY + borderOffset - verticalOffset,
          );

          // 직선 연결선 그리기
          canvas.drawLine(parentEnd, childStart, linePaint);

          // 화살표 그리기 (자식 카드 좌측 상단에 맞춤)
          final arrowPaint = Paint()
            ..color = Colors.blue.shade600
            ..style = PaintingStyle.fill;

          final arrowPath = Path();
          arrowPath.moveTo(childStart.dx, childStart.dy);
          arrowPath.lineTo(childStart.dx + 8, childStart.dy);
          arrowPath.lineTo(childStart.dx + 4, childStart.dy + 4);
          arrowPath.close();

          canvas.drawPath(arrowPath, arrowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ConnectionPainter) {
      // 스크롤 오프셋 변경 시 무조건 재그리기
      if (oldDelegate.horizontalOffset != horizontalOffset ||
          oldDelegate.verticalOffset != verticalOffset) {
        return true;
      }

      // 데이터 변경 시 재그리기
      return oldDelegate.treeRecipes != treeRecipes ||
          oldDelegate.initialRecipe != initialRecipe;
    }
    return true;
  }
}

class TreeLinePainter extends CustomPainter {
  final int normalizedDepth;
  final bool hasChild;

  TreeLinePainter({
    required this.normalizedDepth,
    required this.hasChild,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 메인 선을 위한 그라데이션 페인트
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade500,
          Colors.blue.shade700,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 점선 효과를 위한 페인트
    final dottedPaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 연결점용 페인트
    final nodePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.shade400,
          Colors.blue.shade600,
        ],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: 6))
      ..style = PaintingStyle.fill;

    // 세로선 (자식이 있을 때만) - 그라데이션 적용
    if (hasChild) {
      final verticalLineX = normalizedDepth * 40.0 - 20.0;

      // 메인 세로선
      canvas.drawLine(
        Offset(verticalLineX, 0.0),
        Offset(verticalLineX, size.height),
        linePaint,
      );

      // 연결점 (상단)
      canvas.drawCircle(Offset(verticalLineX, 6), 4, nodePaint);

      // 연결점 (하단)
      canvas.drawCircle(Offset(verticalLineX, size.height - 6), 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is TreeLinePainter) {
      return oldDelegate.normalizedDepth != normalizedDepth ||
          oldDelegate.hasChild != hasChild;
    }
    return true;
  }
}

class RecipeTreeItem extends StatelessWidget {
  final Recipe recipe;
  final Recipe initialRecipe;

  const RecipeTreeItem({
    super.key,
    required this.recipe,
    required this.initialRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final isInitialRecipe = recipe.id == initialRecipe.id;

    return SizedBox(
      width: 300, // 고정 너비
      height: 100, // 높이 증가 (80 → 100)
      child: Card(
        elevation: isInitialRecipe ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isInitialRecipe
              ? BorderSide(color: Colors.blue.shade300, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            // 레시피 상세 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 레시피 제목
                Row(
                  children: [
                    if (isInitialRecipe) ...[
                      Icon(
                        Icons.star,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isInitialRecipe
                              ? Colors.blue.shade700
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 카테고리
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // 재료 수와 조리법 수
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${recipe.ingredients.length}개',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.list,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${recipe.instructions.length}단계',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
