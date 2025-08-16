import 'dart:io';
import 'package:flutter/material.dart';

class InstructionStep extends StatelessWidget {
  final Map<String, dynamic> instruction;
  final int index;
  final bool isHighlighted;
  final Key? itemKey;

  const InstructionStep({
    Key? key,
    required this.instruction,
    required this.index,
    this.isHighlighted = false,
    this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String text = instruction['text'] ?? '';
    final String? imagePath = instruction['imagePath'];

    Widget stepCard = Card(
      key: itemKey,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.pink[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.brown[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(imagePath),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isHighlighted) {
      return Transform.scale(
        scale: 1.05,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.pink, width: 3),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)],
          ),
          child: stepCard,
        ),
      );
    }

    return stepCard;
  }
}