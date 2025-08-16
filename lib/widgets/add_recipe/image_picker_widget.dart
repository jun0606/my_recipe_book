import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/image_utils.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? image;
  final Function(File) onImageSelected;

  const ImagePickerWidget({
    Key? key,
    this.image,
    required this.onImageSelected,
  }) : super(key: key);

  Future<void> _showImageSourceSelectionSheet(BuildContext context) async {
    final picker = ImagePicker();
    
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
                      onImageSelected(compressedImage);
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
                      onImageSelected(compressedImage);
                    }
                  }
                },
              ),
              if (image != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('이미지 삭제', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    // 이미지 삭제 로직은 상위 위젯에서 처리하도록 null을 전달
                    onImageSelected(File(''));
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
    return GestureDetector(
      onTap: () => _showImageSourceSelectionSheet(context),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: image != null && image!.path.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    color: Colors.pink[100],
                    size: 80,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.pink[100],
                    size: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '이미지 추가하기',
                    style: TextStyle(
                      color: Colors.pink[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}