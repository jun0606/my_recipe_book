import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/image_utils.dart';
import '../l10n/app_localizations.dart';

import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../utils/unit_converter.dart';
import '../services/recipe_derivation_service.dart';
import '../services/recipe_data_parser.dart';
import '../services/environment_defaults_calculator.dart';
import '../services/centralized_parsing_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  final String? initialCategory;
  final bool isCopy;
  final bool isDerivedCopy;

  AddRecipeScreen({
    this.recipe,
    this.initialCategory,
    this.isCopy = false,
    this.isDerivedCopy = false,
  });

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '한식';
  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _instructions = [];
  File? _image;
  final picker = ImagePicker();
  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  final _servingsController = TextEditingController();
  bool _isBakingMode = false;
  final _splitAmountController = TextEditingController();
  final _splitCountController = TextEditingController();
  String? _unit = 'g';
  String? _splitAmountUnit = 'g';
  bool _isProgrammaticChange = false; // 자동 채움 플래그
  bool _isKeyboardVisible = false;

  // 오븐 설정
  List<Map<String, dynamic>> _ovenSteps = [];

  // 믹싱 설정
  List<Map<String, dynamic>> _mixingSteps = [];

  // 발효 설정
  List<Map<String, dynamic>> _fermentationSteps = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      print(
          'AddRecipeScreen: initState - 레시피 정보 - ID: ${widget.recipe!.id}, 제목: ${widget.recipe!.title}, 부모 ID: ${widget.recipe!.parentId}, isCopy: ${widget.isCopy}, isDerivedCopy: ${widget.isDerivedCopy}');
      _title = widget.recipe!.title;
      _category = widget.recipe!.category;
      _ingredients = widget.recipe!.ingredients
          .map((ingredient) => ingredient.toJson())
          .toList();
      _instructions = widget.recipe!.instructions
          .map((instruction) => <String, dynamic>{
                'text': instruction['description'],
                'imagePath': instruction['imagePath'],
              })
          .toList();
      _servingsController.text = widget.recipe!.baseServings.toString();
      _isBakingMode = widget.recipe!.isBaking;
      _splitAmountController.text =
          widget.recipe!.targetSplitAmount?.toString() ?? '';
      _splitCountController.text =
          widget.recipe!.targetSplitCount?.toString() ?? '';
      _splitAmountUnit = 'g'; // 기존 레시피 로드 시 기본값 설정

      // 믹싱 설정, 발효 설정과 오븐 설정 불러오기
      if (widget.recipe!.mixingSteps != null) {
        _mixingSteps =
            List<Map<String, dynamic>>.from(widget.recipe!.mixingSteps!);
      }
      if (widget.recipe!.fermentationSteps != null) {
        // 저장된 데이터를 UI 표시용 키로 변환하여 불러오기
        _fermentationSteps = widget.recipe!.fermentationSteps!.map((step) {
          return {
            'temperature':
                step['targetTemperature'] ?? step['temperature'] ?? 25,
            'humidity': step['targetHumidity'] ?? step['humidity'] ?? 75,
            'time': step['time'] ?? 90,
            'comment': step['description'] ?? step['comment'] ?? '',
          };
        }).toList();
      }
      if (widget.recipe!.ovenSteps != null) {
        _ovenSteps = List<Map<String, dynamic>>.from(widget.recipe!.ovenSteps!);
      }

      if (widget.isCopy || widget.isDerivedCopy) {
        // isCopy 또는 isDerivedCopy일 때 이미지 복사
        _image = null; // 초기에는 이미지 없음으로 설정
        if (widget.recipe!.imagePath != null) {
          _copyImageFile(widget.recipe!.imagePath!).then((newPath) {
            if (mounted) {
              setState(() {
                _image = newPath != null ? File(newPath) : null;
              });
            }
          });
        }
        // 복사본은 제목에 (복사본) 추가 (단순 복사일 경우에만)
        if (widget.isCopy && !widget.isDerivedCopy) {
          // 단순 복사일 경우에만 제목에 (복사본) 추가
          _title = '${_title} (복사본)';
        }
        // 파생 레시피의 경우 제목에 (파생) 추가 (선택 사항)
        if (widget.isDerivedCopy) {
          _title = '${_title} (파생)'; // 파생 레시피임을 명확히 하기 위해 제목에 추가
        }
      } else {
        _image = widget.recipe!.imagePath != null
            ? File(widget.recipe!.imagePath!)
            : null;
      }
    } else {
      _category = widget.initialCategory ??
          Provider.of<RecipeProvider>(context, listen: false).categories[0];
      _instructions = [
        <String, dynamic>{'text': '', 'imagePath': null}
      ];
      _servingsController.text = '1';
    }

    // 리스너 추가
    _splitAmountController.addListener(_onSplitAmountChanged);
    _splitCountController.addListener(_onSplitCountChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (mounted) {
        setState(() {
          _isKeyboardVisible = bottomInset > 0;
        });
      }
    });
  }

  Future<String?> _copyImageFile(String originalPath) async {
    // ImageUtils를 사용하여 이미지 복사
    return await ImageUtils.copyImageFile(originalPath);
  }

  Future<File?> _compressImage(File file) async {
    // ImageUtils를 사용하여 이미지 압축
    return await ImageUtils.compressImage(file);
  }

  Future<void> _pickImageFromGallery() async {
    // 사진 라이브러리 권한 확인
    final status = await Permission.photos.status;

    if (status.isGranted) {
      // 권한 있음: 사진 선택 진행
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final compressedImage = await _compressImage(File(pickedFile.path));
        if (compressedImage != null) {
          setState(() => _image = compressedImage);
        }
      }
    } else if (status.isDenied) {
      // 권한 거부: 재요청
      final result = await Permission.photos.request();
      if (result.isGranted) {
        _pickImageFromGallery(); // 재귀 호출로 다시 시도
      } else {
        _showPermissionRequiredDialog(l10n.galleryAccessFeature);
      }
    } else if (status.isPermanentlyDenied) {
      // 영구 거부: 설정 유도
      _showPermissionRequiredDialog(l10n.galleryAccessFeature, permanent: true);
    }
  }

  Future<void> _takeImageFromCamera() async {
    // 카메라 권한 확인
    final status = await Permission.camera.status;

    if (status.isGranted) {
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        final compressedImage = await _compressImage(File(pickedFile.path));
        if (compressedImage != null) {
          setState(() => _image = compressedImage);
        }
      }
    } else {
      // 권한 없음: 사용자 안내
      _showPermissionRequiredDialog(l10n.cameraFeature);
    }
  }

  void _showPermissionRequiredDialog(String feature, {bool permanent = false}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired(feature)),
        content: Text(permanent
            ? l10n.permissionPermanentlyDenied(feature)
            : l10n.permissionRequiredMessage(feature)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (!permanent)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (feature == l10n.galleryAccessFeature) {
                  Permission.photos.request();
                } else {
                  Permission.camera.request();
                }
              },
              child: Text(l10n.requestPermission),
            ),
          if (permanent)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text(l10n.goToSettings),
            ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceSelectionSheet(BuildContext context,
      {bool isInstructionImage = false, int? instructionIndex}) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        final l10nSheet = AppLocalizations.of(context)!;
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(l10nSheet.selectFromGallery),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (isInstructionImage) {
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final compressedImage =
                          await _compressImage(File(pickedFile.path));
                      if (compressedImage != null) {
                        setState(() {
                          _instructions[instructionIndex!]['imagePath'] =
                              compressedImage.path;
                        });
                      }
                    }
                  } else {
                    _pickImageFromGallery();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(l10nSheet.takeWithCamera),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (isInstructionImage) {
                    final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                        preferredCameraDevice: CameraDevice.rear);
                    if (pickedFile != null) {
                      final compressedImage =
                          await _compressImage(File(pickedFile.path));
                      if (compressedImage != null) {
                        setState(() {
                          _instructions[instructionIndex!]['imagePath'] =
                              compressedImage.path;
                        });
                      }
                    }
                  } else {
                    _takeImageFromCamera();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addIngredient() {
    if (_ingredientNameController.text.isNotEmpty &&
        _ingredientAmountController.text.isNotEmpty) {
      final amount = double.tryParse(_ingredientAmountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 재료 양을 입력하세요.')),
        );
        return;
      }

      // 단위 체계에 따라 입력된 값을 그램으로 변환하여 저장
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      final gramsAmount =
          UnitConverter.convertToGrams(amount, _unit!, provider.unitSystem);

      setState(() {
        _ingredients.add({
          'name': _ingredientNameController.text,
          'amount': gramsAmount, // 그램으로 변환하여 저장
          'unit': 'g', // 저장 단위는 항상 그램
        });
        _ingredientNameController.clear();
        _ingredientAmountController.clear();
        _updateBakingCalculations(); // 재료 추가 후 베이킹 계산 업데이트
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('재료 이름과 양을 모두 입력하세요.')),
      );
    }
  }

  void _editIngredient(int index) {
    final ingredient = _ingredients[index];
    final nameController =
        TextEditingController(text: ingredient['name'] as String?);
    final amountController =
        TextEditingController(text: ingredient['amount']?.toString());
    String? selectedUnit = ingredient['unit'] as String?;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('재료 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: '재료 이름'),
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: '양'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<String>(
                      value: selectedUnit,
                      items: UnitConverter.getUnits(Provider.of<RecipeProvider>(
                                  context,
                                  listen: false)
                              .unitSystem)
                          .map((unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUnit = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (nameController.text.isNotEmpty &&
                        amount != null &&
                        amount > 0) {
                      setState(() {
                        _ingredients[index] = {
                          'name': nameController.text,
                          'amount': amount,
                          'unit': selectedUnit,
                        };
                        _updateBakingCalculations(); // 재료 수정 후 베이킹 계산 업데이트
                      });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('유효한 재료 이름과 양을 입력하세요.')),
                      );
                    }
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateTotalIngredientWeight() {
    try {
      // 중앙 집중화된 서비스 사용
      final recipeData = {
        'ingredients': _ingredients,
      };
      return RecipeDataParser().calculateTotalIngredientWeight(recipeData);
    } catch (e) {
      print('❌ [재료 총량 계산 오류] $e');
      // fallback: 기존 로직 사용
      double totalWeight = 0.0;
      for (var ingredient in _ingredients) {
        final amount = double.tryParse(ingredient['amount'].toString()) ?? 0.0;
        final unit = ingredient['unit'] ?? 'g';
        if (amount > 0) {
          totalWeight += UnitConverter.convert(amount, unit, 'g');
        }
      }
      return totalWeight;
    }
  }

  String? _getSplitAmountHintText() {
    final totalWeight = _calculateTotalIngredientWeight();
    if (_splitCountController.text.isNotEmpty) {
      final splitCount = int.tryParse(_splitCountController.text) ?? 0;
      if (splitCount > 0) {
        final weightPerSplit = totalWeight / splitCount;
        return '각 ${UnitConverter.convert(weightPerSplit, 'g', _splitAmountUnit!).toStringAsFixed(2)}${_splitAmountUnit} 씩';
      }
    }
    return null;
  }

  String? _getSplitCountHintText() {
    final totalWeight = _calculateTotalIngredientWeight();
    if (_splitAmountController.text.isNotEmpty) {
      final splitAmount = double.tryParse(_splitAmountController.text) ?? 0.0;
      final convertedSplitAmount =
          UnitConverter.convert(splitAmount, _splitAmountUnit!, 'g');
      if (convertedSplitAmount > 0 && convertedSplitAmount <= totalWeight) {
        final numSplits = (totalWeight / convertedSplitAmount).floor();
        final remainingWeight =
            totalWeight - (numSplits * convertedSplitAmount);
        return '총 ${numSplits}개로 분할 가능 (남는 양: ${UnitConverter.convert(remainingWeight, 'g', _splitAmountUnit!).toStringAsFixed(2)}${_splitAmountUnit})';
      }
    }
    return null;
  }

  void _updateBakingCalculations() {
    if (!_isBakingMode) return;

    final splitAmountText = _splitAmountController.text;
    final splitCountText = _splitCountController.text;

    // 사용자가 분할량과 분할 개수 중 무엇을 기준으로 계산하고 싶어하는지 확인합니다.
    // 여기서는 간단하게 분할량이 입력되어 있으면 분할량을 기준으로, 그렇지 않으면 분할 개수를 기준으로 계산합니다.
    if (splitAmountText.isNotEmpty) {
      _onSplitAmountChanged();
    } else if (splitCountText.isNotEmpty) {
      _onSplitCountChanged();
    }
  }

  void _onSplitAmountChanged() {
    if (_isProgrammaticChange) return;

    final totalWeight = _calculateTotalIngredientWeight();
    final splitAmount = double.tryParse(_splitAmountController.text) ?? 0.0;
    final convertedSplitAmount =
        UnitConverter.convert(splitAmount, _splitAmountUnit!, 'g');

    if (convertedSplitAmount > 0 && totalWeight > 0) {
      if (convertedSplitAmount <= totalWeight) {
        final numSplits = (totalWeight / convertedSplitAmount).floor();
        final remainingWeight =
            totalWeight - (numSplits * convertedSplitAmount);

        _isProgrammaticChange = true;
        _splitCountController.text = numSplits.toString();
        _isProgrammaticChange = false;

        print(
            '분할 무게 기준 계산: 총 무게 ${totalWeight.toStringAsFixed(1)}g, 분할 무게 ${convertedSplitAmount.toStringAsFixed(1)}g, 분할 개수 $numSplits개, 남은 무게 ${remainingWeight.toStringAsFixed(1)}g');
      } else {
        // 분할량이 총 무게보다 큰 경우
        _isProgrammaticChange = true;
        _splitCountController.text = '1';
        _isProgrammaticChange = false;

        print('분할 무게가 총 무게보다 큼: 1개로 설정');
      }
    } else if (splitAmount == 0.0 && _splitCountController.text.isNotEmpty) {
      // 분할량이 0이 되고 분할 개수가 입력되어 있으면 분할 개수 필드를 비우지 않음
    } else {
      _isProgrammaticChange = true;
      _splitCountController.clear();
      _isProgrammaticChange = false;
    }
    setState(() {});
  }

  void _onSplitCountChanged() {
    if (_isProgrammaticChange) return;

    final totalWeight = _calculateTotalIngredientWeight();
    final splitCount = int.tryParse(_splitCountController.text) ?? 0;

    if (splitCount > 0 && totalWeight > 0) {
      final weightPerSplit = totalWeight / splitCount;
      final remainingWeight = totalWeight % weightPerSplit;

      _isProgrammaticChange = true;
      _splitAmountController.text =
          UnitConverter.convert(weightPerSplit, 'g', _splitAmountUnit!)
              .toStringAsFixed(2);
      _isProgrammaticChange = false;

      print(
          '분할 개수 기준 계산: 총 무게 ${totalWeight.toStringAsFixed(1)}g, 분할 개수 $splitCount개, 각 분할 무게 ${weightPerSplit.toStringAsFixed(1)}g, 남은 무게 ${remainingWeight.toStringAsFixed(1)}g');
    } else if (splitCount == 0 && _splitAmountController.text.isNotEmpty) {
      // 분할 개수가 0이 되고 분할량이 입력되어 있으면 분할량 필드를 비우지 않음
    } else {
      _isProgrammaticChange = true;
      _splitAmountController.clear();
      _isProgrammaticChange = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    _servingsController.dispose();
    _splitAmountController.removeListener(_onSplitAmountChanged);
    _splitAmountController.dispose();
    _splitCountController.removeListener(_onSplitCountChanged);
    _splitCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isCopy
              ? (widget.isDerivedCopy ? '파생 레시피 저장' : '레시피 복사')
              : (widget.recipe == null ? '레시피 추가' : '레시피 수정'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백을 100으로 늘림
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImageSourceSelectionSheet(context),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.pink[100]),
                        )
                      : Icon(Icons.camera_alt, color: Colors.pink[100]),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: '레시피 제목'),
                onChanged: (value) => _title = value,
                validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                items: provider.categories
                    .map((String category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: InputDecoration(labelText: '카테고리'),
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('베이킹 모드 활성화'),
                value: _isBakingMode,
                onChanged: (bool value) {
                  setState(() {
                    _isBakingMode = value;
                    _servingsController.clear();
                    _splitAmountController.clear();
                    _splitCountController.clear();
                  });
                },
              ),
              if (!_isBakingMode)
                TextFormField(
                  controller: _servingsController,
                  decoration: InputDecoration(labelText: '인분'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return '인분을 입력하세요';
                    final servings = int.tryParse(value);
                    if (servings == null || servings <= 0)
                      return '유효한 인분 수를 입력하세요';
                    return null;
                  },
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _splitAmountController,
                            decoration: InputDecoration(
                              labelText: '분할 무게',
                              helperText: _getSplitAmountHintText(),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _onSplitAmountChanged();
                            },
                            validator: (value) {
                              if (value!.isEmpty &&
                                  _splitCountController.text.isEmpty)
                                return '분할량 또는 분할 개수를 입력하세요';
                              if (value.isNotEmpty) {
                                final splitAmount = double.tryParse(value);
                                if (splitAmount == null || splitAmount <= 0)
                                  return '유효한 분할량을 입력하세요';
                                final totalWeight =
                                    _calculateTotalIngredientWeight();
                                final convertedSplitAmount =
                                    UnitConverter.convert(
                                        splitAmount, _splitAmountUnit!, 'g');
                                if (convertedSplitAmount > totalWeight) {
                                  return '분할량은 총 재료 무게를 초과할 수 없습니다. (총: ${totalWeight.toStringAsFixed(2)}g)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _splitAmountUnit,
                            decoration: InputDecoration(
                              labelText: '단위',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: UnitConverter.getUnits(provider.unitSystem)
                                .map((unit) => DropdownMenuItem(
                                    value: unit, child: Text(unit)))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              final oldUnit = _splitAmountUnit!;
                              final newUnit = value;
                              final splitAmountText =
                                  _splitAmountController.text;

                              if (splitAmountText.isNotEmpty) {
                                final originalAmount =
                                    double.tryParse(splitAmountText) ?? 0.0;
                                final convertedAmount = UnitConverter.convert(
                                    originalAmount, oldUnit, newUnit);

                                _isProgrammaticChange = true;
                                _splitAmountController.text =
                                    convertedAmount.toStringAsFixed(2);
                                _isProgrammaticChange = false;
                              }

                              setState(() {
                                _splitAmountUnit = newUnit;
                              });

                              // 분할 개수도 다시 계산합니다.
                              _onSplitAmountChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _splitCountController,
                            decoration: InputDecoration(
                              labelText: '분할 개수',
                              helperText: _getSplitCountHintText(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _onSplitCountChanged();
                            },
                            validator: (value) {
                              if (value!.isEmpty &&
                                  _splitAmountController.text.isEmpty)
                                return '분할량 또는 분할 개수를 입력하세요';
                              if (value.isNotEmpty) {
                                final splitCount = int.tryParse(value);
                                if (splitCount == null || splitCount <= 0)
                                  return '유효한 분할 개수를 입력하세요';
                              }
                              return null;
                            },
                          ),
                        ),
                        Tooltip(
                          message: '입력값 초기화',
                          child: IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              setState(() {
                                _splitAmountController.clear();
                                _splitCountController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              SizedBox(height: 20),

              // 믹싱 설정 (베이킹 모드일 때만)
              if (_isBakingMode) ...[
                _buildMixingSettings(),
                SizedBox(height: 16),
              ],

              // 발효 설정 (베이킹 모드일 때만)
              if (_isBakingMode) ...[
                _buildFermentationSettings(),
                SizedBox(height: 16),
              ],

              // 오븐 설정 (베이킹 모드일 때만)
              if (_isBakingMode) ...[
                _buildOvenSettings(),
                SizedBox(height: 16),
              ],

              Text('재료', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _ingredientNameController,
                          decoration: InputDecoration(labelText: '재료 이름'))),
                  SizedBox(width: 10),
                  Expanded(
                      child: TextFormField(
                          controller: _ingredientAmountController,
                          decoration: InputDecoration(labelText: '양'),
                          keyboardType: TextInputType.number)),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _unit,
                    items: UnitConverter.getUnits(provider.unitSystem)
                        .map((unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) => setState(() => _unit = value),
                  ),
                  IconButton(icon: Icon(Icons.add), onPressed: _addIngredient),
                ],
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _ingredients.removeAt(oldIndex);
                    _ingredients.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return Card(
                    key: ValueKey(ingredient),
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.drag_handle, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ingredient['name']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown[700]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${ingredient['amount']} ${ingredient['unit']}',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editIngredient(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => setState(() {
                              _ingredients.removeAt(index);
                              _updateBakingCalculations(); // 재료 삭제 후 베이킹 계산 업데이트
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text('조리법', style: Theme.of(context).textTheme.titleLarge),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _instructions.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _instructions[index]['text'],
                              decoration:
                                  InputDecoration(labelText: '단계 ${index + 1}'),
                              onChanged: (value) =>
                                  _instructions[index]['text'] = value,
                              validator: (value) =>
                                  value!.isEmpty ? '조리법을 입력하세요' : null,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () async {
                              _showImageSourceSelectionSheet(context,
                                  isInstructionImage: true,
                                  instructionIndex: index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                setState(() => _instructions.removeAt(index)),
                          ),
                        ],
                      ),
                      if (_instructions[index]['imagePath'] != null)
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(
                              File(_instructions[index]['imagePath']!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _instructions[index]['imagePath'] = null;
                                });
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text('단계 추가'),
                onPressed: () => setState(() => _instructions
                    .add(<String, dynamic>{'text': '', 'imagePath': null})),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton(
              heroTag: 'add_recipe_fab',
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_instructions.any((instr) => instr['text'].isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('모든 조리법 단계를 작성하세요.')),
                    );
                    return;
                  }
                  if (_ingredients.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('최소 하나의 재료를 추가하세요.')),
                    );
                    return;
                  }
                  final double? targetSplitAmount = _splitAmountController
                          .text.isNotEmpty
                      ? UnitConverter.convert(
                          double.tryParse(_splitAmountController.text) ?? 0.0,
                          _splitAmountUnit!,
                          'g')
                      : null;
                  final int? targetSplitCount =
                      int.tryParse(_splitCountController.text);
                  final double totalIngredientWeight =
                      _calculateTotalIngredientWeight();
                  double? calculatedRemainingWeight;

                  print(
                      'AddRecipeScreen: _instructions content before Recipe creation: $_instructions');

                  if (_isBakingMode) {
                    if (targetSplitAmount != null && targetSplitAmount > 0) {
                      final numSplits =
                          (totalIngredientWeight / targetSplitAmount).floor();
                      calculatedRemainingWeight = totalIngredientWeight -
                          (numSplits * targetSplitAmount);
                    } else if (targetSplitCount != null &&
                        targetSplitCount > 0) {
                      calculatedRemainingWeight =
                          totalIngredientWeight % targetSplitCount;
                    }
                  }

                  // parentId 처리 로직 개선
                  int? finalParentId;
                  if (widget.isDerivedCopy) {
                    // 파생 레시피 생성 모드
                    finalParentId = widget.recipe?.id;
                    print(
                        'AddRecipeScreen: 파생 레시피 생성 모드 - 부모 ID: $finalParentId');
                  } else if (widget.recipe != null && !widget.isCopy) {
                    // 레시피 수정 모드 - 기존 parentId 유지
                    finalParentId = widget.recipe!.parentId;
                    print(
                        'AddRecipeScreen: 레시피 수정 모드 - 기존 부모 ID 유지: $finalParentId');
                  } else {
                    // 일반 레시피 생성 모드
                    finalParentId = null;
                    print('AddRecipeScreen: 일반 레시피 생성 모드 - 부모 ID 없음');
                  }

                  // 레시피 ID 처리 로직 개선
                  int? recipeId = null;
                  if (widget.recipe != null) {
                    if (widget.isCopy || widget.isDerivedCopy) {
                      // 복사 모드 또는 파생 레시피 생성 모드는 새 ID 생성 (null)
                      print('AddRecipeScreen: 복사 또는 파생 레시피 생성 모드 - 새 ID 생성');
                    } else {
                      // 기존 레시피 수정 시 ID 유지
                      recipeId = widget.recipe!.id;
                      print('AddRecipeScreen: 레시피 수정 모드 - ID 유지: $recipeId');
                    }
                  }

                  debugPrint('🚀 [레시피 저장 전 디버깅] 발효 단계 데이터 검증 시작');
                  debugPrint(
                      '🚀 [레시피 저장 전 디버깅] _fermentationSteps.length: ${_fermentationSteps.length}');
                  for (int i = 0; i < _fermentationSteps.length; i++) {
                    final step = _fermentationSteps[i];
                    debugPrint(
                        '🚀 [레시피 저장 전 디버깅] 단계 $i: humidity=${step['humidity']}, time=${step['time']}, temperature=${step['temperature']}, comment=${step['comment']}');
                  }

                  // 🚀 [파싱 로깅] 발효 단계 데이터 정규화 시작 로그
                  debugPrint(
                      '🚀 [발효 단계 정규화 시작] AddRecipeScreen에서 CentralizedParsingService.normalizeUserFermentationSteps 호출');
                  debugPrint(
                      '🚀 [발효 단계 원본 데이터] _fermentationSteps.length: ${_fermentationSteps.length}');

                  // 각 단계의 원본 데이터를 로깅
                  for (int i = 0; i < _fermentationSteps.length; i++) {
                    final originalStep = _fermentationSteps[i];
                    debugPrint(
                        '🚀 [원본 단계 $i 입력] humidity=${originalStep['humidity']}, time=${originalStep['time']}, temperature=${originalStep['temperature']}, comment=${originalStep['comment']}');
                  }

                  // 발효 단계 데이터 정규화 (AddRecipeScreen UI 형식 → 발효 분석 표준 형식)
                  List<Map<String, dynamic>>? normalizedFermentationSteps;
                  if (_isBakingMode && _fermentationSteps.isNotEmpty) {
                    normalizedFermentationSteps = CentralizedParsingService()
                        .normalizeUserFermentationSteps(_fermentationSteps);
                    debugPrint(
                        '🚀 [레시피 저장 후 디버깅] 정규화된 발효 단계 수: ${normalizedFermentationSteps?.length ?? 0}');

                    // 🚀 [파싱 로깅] 정규화 결과 상세 로깅
                    if (normalizedFermentationSteps != null) {
                      for (int i = 0;
                          i < normalizedFermentationSteps.length;
                          i++) {
                        final step = normalizedFermentationSteps[i];
                        debugPrint(
                            '🚀 [레시피 저장 후 디버깅] 정규화된 단계 $i: time=${step['time']}, durationHours=${step['durationHours']}, temperature=${step['temperature']}, targetTemperature=${step['targetTemperature']}, targetHumidity=${step['targetHumidity']}, description=${step['description']}');
                      }

                      // 🚀 [파싱 로깅] 데이터 타입 확인
                      debugPrint(
                          '🚀 [정규화 결과 타입 확인] normalizedFermentationSteps 타입: ${normalizedFermentationSteps.runtimeType}');
                      debugPrint(
                          '🚀 [정규화 결과 구조] 각 단계 키 구조: ${normalizedFermentationSteps.first.keys.toList()}');
                    }
                  }

                  final recipe = Recipe(
                    id: recipeId,
                    title: _title,
                    category: _category,
                    ingredients: _ingredients
                        .map((ing) => Ingredient.fromJson(ing))
                        .toList(),
                    instructions: _instructions
                        .map((inst) => {
                              'description': inst['text'],
                              'imagePath': inst['imagePath']
                            })
                        .toList(),
                    imagePath: _image?.path,
                    baseServings: _isBakingMode
                        ? 1
                        : (int.tryParse(_servingsController.text) ?? 1),
                    isBaking: _isBakingMode,
                    targetSplitAmount: targetSplitAmount,
                    targetSplitCount: targetSplitCount,
                    calculatedRemainingWeight: calculatedRemainingWeight,
                    totalIngredientWeight: totalIngredientWeight,
                    parentId: finalParentId,
                    mixingSteps: _isBakingMode && _mixingSteps.isNotEmpty
                        ? _mixingSteps
                        : null,
                    fermentationSteps:
                        normalizedFermentationSteps, // 정규화된 데이터 사용
                    ovenSteps: _isBakingMode && _ovenSteps.isNotEmpty
                        ? _ovenSteps
                        : null,
                  );
                  try {
                    // 저장 조건 로깅
                    print(
                        'AddRecipeScreen: 저장 조건 - recipe == null: ${widget.recipe == null}, isCopy: ${widget.isCopy}, isDerivedCopy: ${widget.isDerivedCopy}, recipe.id: ${recipe.id}, parentId: ${recipe.parentId}');

                    // 저장 로직 개선
                    // 1. 새 레시피 생성 또는 복사인 경우 addRecipe 호출
                    // 2. 기존 레시피 수정인 경우 updateRecipe 호출
                    if (recipe.id == null) {
                      // ID가 없는 경우 (새 레시피 또는 복사)
                      print('AddRecipeScreen: 새 레시피 저장 - addRecipe 호출');
                      await provider.addRecipe(recipe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(widget.isCopy
                                ? (widget.isDerivedCopy
                                    ? '파생 레시피가 저장되었습니다.'
                                    : '레시피가 복사되어 저장되었습니다.')
                                : '레시피가 추가되었습니다.')),
                      );
                    } else {
                      // ID가 있는 경우 (기존 레시피 수정)
                      print(
                          'AddRecipeScreen: 기존 레시피 수정 - updateRecipe 호출 - ID: ${recipe.id}, 부모 ID: ${recipe.parentId}');
                      try {
                        await provider.updateRecipe(recipe, '레시피 수정');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('레시피가 수정되었습니다.')),
                        );
                      } catch (e) {
                        print('AddRecipeScreen: 레시피 수정 중 오류 발생 - $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('레시피 수정 중 오류가 발생했습니다: $e')),
                        );
                        // 오류 발생 시 처리
                        return; // Navigator.pop 호출하지 않고 함수 종료
                      }
                    }
                    Navigator.pop(context, recipe);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('레시피 저장 중 오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
              child: Icon(Icons.save),
            ),
    );
  }

  Widget _buildOvenSettings() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade50,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.local_fire_department,
                      color: Colors.orange.shade700, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  '오븐 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                Spacer(),
                Container(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _ovenSteps.add(<String, dynamic>{
                          'temperature': 180,
                          'time': 30,
                          'comment': '',
                        });
                      });
                    },
                    icon: Icon(Icons.add, size: 16),
                    label: Text('추가', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_ovenSteps.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '''오븐 단계를 추가해주세요
예: 180°C 40분 → 200°C 20분''',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_ovenSteps.length, (index) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: _ovenSteps[index]
                                              ['temperature']
                                          .toString(),
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        labelText: '온도 (°C)',
                                        labelStyle: TextStyle(fontSize: 12),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _ovenSteps[index]['temperature'] =
                                            int.tryParse(value) ?? 180;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue:
                                          _ovenSteps[index]['time'].toString(),
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        labelText: '시간 (분)',
                                        labelStyle: TextStyle(fontSize: 12),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _ovenSteps[index]['time'] =
                                            int.tryParse(value) ?? 30;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ovenSteps.removeAt(index);
                                });
                              },
                              icon: Icon(Icons.delete,
                                  color: Colors.red.shade600, size: 18),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 코멘트 입력 필드 추가
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        initialValue:
                            _ovenSteps[index]['comment']?.toString() ?? '',
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: '${index + 1}단계 코멘트 (선택사항)',
                          labelStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          hintText: '예: 윗면이 갈색이 될 때까지',
                          hintStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(color: Colors.orange.shade400),
                          ),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          _ovenSteps[index]['comment'] = value;
                        },
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFermentationSettings() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.bubble_chart,
                      color: Colors.blue.shade700, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  '발효 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                Spacer(),
                Container(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _fermentationSteps.add(<String, dynamic>{
                          'humidity': 80, // 합리적인 초기값 사용
                          'time': 40, // 기본값 대신 합리적인 초기값
                          'temperature': 26, // 합리적인 초기값 사용
                          'comment': '',
                        });
                      });
                    },
                    icon: Icon(Icons.add, size: 16),
                    label: Text('추가', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_fermentationSteps.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '''발효 단계를 추가해주세요
예: 1차 발효 80% 240분 → 2차 발효 85% 120분''',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_fermentationSteps.length, (index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${index + 1}차 발효',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _fermentationSteps.removeAt(index);
                                });
                              },
                              icon: Icon(Icons.delete,
                                  color: Colors.red.shade600, size: 18),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                initialValue: _fermentationSteps[index]
                                        ['humidity']
                                    .toString(),
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: '습도 (%)',
                                  labelStyle: TextStyle(fontSize: 12),
                                  hintText: '75-85',
                                  hintStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _fermentationSteps[index]['humidity'] =
                                      int.tryParse(value) ?? 80;
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                initialValue: _fermentationSteps[index]['time']
                                    .toString(),
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: _fermentationSteps[index]
                                                  ['time'] ==
                                              0 ||
                                          _fermentationSteps[index]['time'] ==
                                              null
                                      ? '시간을 분단위로 입력하세요'
                                      : '시간 (${_formatMinutesToHours(_fermentationSteps[index]['time'])})',
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    _fermentationSteps[index]['time'] =
                                        _parseTimeInput(value);
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                initialValue: _fermentationSteps[index]
                                        ['temperature']
                                    .toString(),
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: '온도 (°C)',
                                  labelStyle: TextStyle(fontSize: 12),
                                  hintText: '25-30',
                                  hintStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _fermentationSteps[index]['temperature'] =
                                      int.tryParse(value) ?? 28;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // 코멘트 입력 필드 추가
                      TextFormField(
                        initialValue:
                            _fermentationSteps[index]['comment']?.toString() ??
                                '',
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: '${index + 1}차 발효 코멘트 (선택사항)',
                          labelStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          hintText: '예: 반죽이 2배로 부풀 때까지',
                          hintStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.blue.shade400),
                          ),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          _fermentationSteps[index]['comment'] = value;
                        },
                      ),
                    ],
                  ),
                );
              }),
            if (_fermentationSteps.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '발효 조건은 반죽 종류와 실내 온도에 따라 달라집니다',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatMinutesToHours(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours시간';
      } else {
        return '$hours시간 $remainingMinutes분';
      }
    }
  }

  int _parseTimeInput(String input) {
    if (input.isEmpty) return 0; // 기본값

    // 숫자만 있는 경우 (분으로 간주)
    final numericOnly = int.tryParse(input);
    if (numericOnly != null) {
      return numericOnly;
    }

    int totalMinutes = 0;

    // "4시간 30분", "4시간", "30분" 형태 파싱
    final hourMatch = RegExp(r'(\d+)시간?').firstMatch(input);
    final minuteMatch = RegExp(r'(\d+)분').firstMatch(input);

    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1) ?? '0') ?? 0;
      totalMinutes += hours * 60;
    }

    if (minuteMatch != null) {
      final minutes = int.tryParse(minuteMatch.group(1) ?? '0') ?? 0;
      totalMinutes += minutes;
    }

    // 아무것도 파싱되지 않은 경우 기본값 반환
    return totalMinutes > 0 ? totalMinutes : 0;
  }

  Widget _buildMixingSettings() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade50,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.blender,
                      color: Colors.green.shade700, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  '믹싱 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
                Spacer(),
                Container(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _mixingSteps.add(<String, dynamic>{
                          'speed': '중속', // 기본값: 중속
                          'time': 0, // 분 단위 (초기값 0분)
                          'comment': '',
                        });
                      });
                    },
                    icon: Icon(Icons.add, size: 16),
                    label: Text('추가', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_mixingSteps.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '''믹싱 단계를 추가해주세요
예: 중속 15분 → 저속 10분''',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_mixingSteps.length, (index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${index + 1}차 믹싱',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _mixingSteps.removeAt(index);
                                });
                              },
                              icon: Icon(Icons.delete,
                                  color: Colors.red.shade600, size: 18),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                value: _mixingSteps[index]['speed'] ?? '중속',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: '속도',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                dropdownColor: Colors.white,
                                items: ['저속', '중속', '고속']
                                    .map((speed) => DropdownMenuItem(
                                          value: speed,
                                          child: Text(speed,
                                              style: TextStyle(
                                                  color: Colors.black87)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _mixingSteps[index]['speed'] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                initialValue:
                                    _mixingSteps[index]['time'].toString(),
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: _mixingSteps[index]['time'] == 0 ||
                                          _mixingSteps[index]['time'] == null
                                      ? '시간을 분단위로 입력하세요'
                                      : '시간 (${_formatMinutesToHours(_mixingSteps[index]['time'])})',
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    _mixingSteps[index]['time'] =
                                        _parseTimeInput(value);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // 코멘트 입력 필드 추가
                      TextFormField(
                        initialValue:
                            _mixingSteps[index]['comment']?.toString() ?? '',
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: '${index + 1}차 믹싱 코멘트 (선택사항)',
                          labelStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          hintText: '예: 반죽이 매끈해질 때까지',
                          hintStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(color: Colors.green.shade400),
                          ),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          _mixingSteps[index]['comment'] = value;
                        },
                      ),
                    ],
                  ),
                );
              }),
            if (_mixingSteps.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.green.shade600, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '믹싱 속도와 시간은 반죽 종류와 재료 상태에 따라 조절하세요',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
