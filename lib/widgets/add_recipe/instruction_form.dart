import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/image_utils.dart';

class InstructionForm extends StatefulWidget {
  final List<Map<String, dynamic>> instructions;
  final Function(List<Map<String, dynamic>>) onInstructionsChanged;

  const InstructionForm({
    Key? key,
    required this.instructions,
    required this.onInstructionsChanged,
  }) : super(key: key);

  @override
  _InstructionFormState createState() => _InstructionFormState();
}

class _InstructionFormState extends State<InstructionForm> {
  final picker = ImagePicker();

  void _addInstruction() {
    final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
    newInstructions.add({'text': '', 'imagePath': null});
    widget.onInstructionsChanged(newInstructions);
  }

  void _updateInstructionText(int index, String text) {
    final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
    newInstructions[index] = {
      ...newInstructions[index],
      'text': text,
    };
    widget.onInstructionsChanged(newInstructions);
  }

  void _deleteInstruction(int index) {
    final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
    newInstructions.removeAt(index);
    widget.onInstructionsChanged(newInstructions);
  }

  Future<void> _showImageSourceSelectionSheet(BuildContext context, int instructionIndex) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final compressedImage = await ImageUtils.compressImage(File(pickedFile.path));
                    if (compressedImage != null) {
                      final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
                      newInstructions[instructionIndex] = {
                        ...newInstructions[instructionIndex],
                        'imagePath': compressedImage.path,
                      };
                      widget.onInstructionsChanged(newInstructions);
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
                  if (pickedFile != null) {
                    final compressedImage = await ImageUtils.compressImage(File(pickedFile.path));
                    if (compressedImage != null) {
                      final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
                      newInstructions[instructionIndex] = {
                        ...newInstructions[instructionIndex],
                        'imagePath': compressedImage.path,
                      };
                      widget.onInstructionsChanged(newInstructions);
                    }
                  }
                },
              ),
              if (widget.instructions[instructionIndex]['imagePath'] != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('이미지 삭제', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
                    newInstructions[instructionIndex] = {
                      ...newInstructions[instructionIndex],
                      'imagePath': null,
                    };
                    widget.onInstructionsChanged(newInstructions);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('조리법', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('단계 추가'),
              onPressed: _addInstruction,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.instructions.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.instructions[index]['text'],
                        decoration: InputDecoration(labelText: '단계 ${index + 1}'),
                        onChanged: (value) => _updateInstructionText(index, value),
                        validator: (value) => value!.isEmpty ? '조리법을 입력하세요' : null,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () => _showImageSourceSelectionSheet(context, index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteInstruction(index),
                    ),
                  ],
                ),
                if (widget.instructions[index]['imagePath'] != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        File(widget.instructions[index]['imagePath']!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          final newInstructions = List<Map<String, dynamic>>.from(widget.instructions);
                          newInstructions[index] = {
                            ...newInstructions[index],
                            'imagePath': null,
                          };
                          widget.onInstructionsChanged(newInstructions);
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 10),
              ],
            );
          },
        ),
      ],
    );
  }
}