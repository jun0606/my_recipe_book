import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/recipe_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/image_utils.dart';
import 'user_setup_screen.dart';
import 'text_scale_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  String? _selectedTitle;
  String _selectedUnitSystem = 'Korea';
  final _categoryController = TextEditingController();
  late AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      final validKeys = [
        'chef',
        'pastryChef',
        'cook',
        'baker',
        'kitchenMaster',
        'gourmet',
        'foodie',
        'culinaryResearcher',
        'honorificNim',
        'honorificSsi'
      ];
      final userTitle = prefs.getString('user_title');
      if (userTitle != null && validKeys.contains(userTitle)) {
        _selectedTitle = userTitle;
      } else {
        _selectedTitle = 'chef'; // Default to 'chef' if invalid or null
      }
      _selectedUnitSystem = prefs.getString('unit_system') ?? 'Korea';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_title', _selectedTitle ?? 'chef');
    await prefs.setString('unit_system', _selectedUnitSystem);

    await Provider.of<RecipeProvider>(context, listen: false)
        .setUnitSystem(_selectedUnitSystem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSaved)),
      );
    }
  }

  Future<void> _addCategory() async {
    if (_categoryController.text.isNotEmpty) {
      await Provider.of<RecipeProvider>(context, listen: false)
          .addCategory(_categoryController.text);
      _categoryController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryAdded)),
      );
    }
  }

  Future<void> _removeCategory(String category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.confirmDeleteCategory(category)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await Provider.of<RecipeProvider>(context, listen: false)
            .removeCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryDeleted(category))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryDeletionFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _exportAllRecipes() async {
    try {
      // 저장 위치 선택 대화상자 표시
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '백업 파일을 저장할 위치를 선택하세요',
      );

      if (selectedDirectory == null) {
        // 사용자가 취소한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupCancelled)),
        );
        return;
      }

      // 파일명 생성
      final fileName =
          'my_recipe_book_backup_${DateTime.now().toIso8601String().substring(0, 10)}.zip';
      final fullPath = '${selectedDirectory}/$fileName';

      // 선택된 경로에 백업 파일 생성
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      final savedPath = await provider.exportAllRecipesToPath(fullPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('백업이 완료되었습니다: $savedPath'),
          duration: const Duration(seconds: 5),
        ),
      );

      // 백업 파일 공유 옵션 제공
      final shareResult = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupFileShare),
          content: Text('백업 파일을 다른 앱으로 공유하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('네'),
            ),
          ],
        ),
      );

      if (shareResult == true) {
        await Share.shareXFiles([XFile(savedPath)], text: l10n.shareBackupFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeBackupFailed(e.toString()))),
      );
    }
  }

  Future<void> _importAllRecipes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final provider = Provider.of<RecipeProvider>(context, listen: false);
        await provider.importAllRecipes(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recipesRestored)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileSelectionCancelled)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeRestoreFailed(e.toString()))),
      );
    }
  }

  Future<void> _deleteAllRecipes() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllRecipesTitle),
        content: Text(l10n.confirmDeleteAllRecipes),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<RecipeProvider>(context, listen: false)
          .deleteAllRecipes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allRecipesDeleted)),
      );
    }
  }

  Future<void> _resetUserNameAndTitle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetUserNameAndTitleTitle),
        content: Text(l10n.confirmResetUserNameAndTitle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.reset)),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_title');
      setState(() {
        _selectedTitle = null; // 초기화 시 키를 null로 설정
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userNameAndTitleReset)),
        );
        // 앱 재시작 또는 UserSetupScreen으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserSetupScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!; // 멤버 변수 초기화
    final provider = Provider.of<RecipeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextScaleSettingsScreen(),
                ),
              );
            },
            tooltip: '텍스트 크기 설정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사용자 정보 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(l10n.userInfo,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l10n.nameLabel),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTitle,
                      items: [
                        {
                          'key': 'chef',
                          'text': AppLocalizations.of(context)!.chef
                        },
                        {
                          'key': 'pastryChef',
                          'text': AppLocalizations.of(context)!.pastryChef
                        },
                        {
                          'key': 'cook',
                          'text': AppLocalizations.of(context)!.cook
                        },
                        {
                          'key': 'baker',
                          'text': AppLocalizations.of(context)!.baker
                        },
                        {
                          'key': 'kitchenMaster',
                          'text': AppLocalizations.of(context)!.kitchenMaster
                        },
                        {
                          'key': 'gourmet',
                          'text': AppLocalizations.of(context)!.gourmet
                        },
                        {
                          'key': 'foodie',
                          'text': AppLocalizations.of(context)!.foodie
                        },
                        {
                          'key': 'culinaryResearcher',
                          'text':
                              AppLocalizations.of(context)!.culinaryResearcher
                        },
                        {
                          'key': 'honorificNim',
                          'text': AppLocalizations.of(context)!.honorificNim
                        },
                        {
                          'key': 'honorificSsi',
                          'text': AppLocalizations.of(context)!.honorificSsi
                        },
                      ].map((Map<String, String> item) {
                        return DropdownMenuItem(
                            value: item['key'], child: Text(item['text']!));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTitle = value!;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.titleLabel),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            child: Text(l10n.saveSettings),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _resetUserNameAndTitle,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange),
                          ),
                          child: Text(
                            l10n.resetUserNameAndTitle,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 언어 설정 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(l10n.languageSelectionLabel,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('자동 저장', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: Provider.of<LocaleProvider>(context)
                          .locale
                          .languageCode,
                      items: [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ko', child: Text('한국어')),
                        DropdownMenuItem(value: 'ja', child: Text('日本語')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale(value);
                        }
                      },
                      decoration: InputDecoration(
                          labelText: l10n.languageSelectionLabel),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 단위 시스템 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.scale,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(l10n.unitSystemLabel,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedUnitSystem,
                      items: ['Korea', 'SI', 'US', 'Japan', 'Europe']
                          .map((String system) => DropdownMenuItem(
                              value: system, child: Text(system)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnitSystem = value!;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: l10n.unitSystemSelectionLabel),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        child: Text(l10n.saveSettings),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 관리 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(l10n.categoryManagement,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('자동 저장', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                                labelText: l10n.newCategoryNameLabel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addCategory,
                          child: Text(l10n.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (provider.categories.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(category),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeCategory(category),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('카테고리가 없습니다'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 데이터 관리 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(l10n.dataManagement,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 저장소 정보 표시
                    FutureBuilder<StorageStats>(
                      future: ImageUtils.getStorageStats(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData) {
                          return Text('저장소 정보를 불러올 수 없습니다');
                        }

                        final stats = snapshot.data!;
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.photo_library,
                                      color: Colors.pink[400]),
                                  SizedBox(width: 8),
                                  Text('레시피 사진 저장소',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              _buildStorageStat(
                                  '총 사진 수', '${stats.totalFiles}장'),
                              _buildStorageStat('총 용량',
                                  '${stats.totalSizeMB.toStringAsFixed(1)} MB'),
                              _buildStorageStat('평균 크기',
                                  '${stats.averageSizeKB.toStringAsFixed(0)} KB'),
                              if (stats.largeFilesCount > 0)
                                _buildStorageStat(
                                  '대용량 파일',
                                  '${stats.largeFilesCount}개 (1MB 이상)',
                                  color: Colors.orange,
                                ),
                              SizedBox(height: 8),
                              Text(
                                '💡 사진은 자동으로 최적화되어 저장됩니다',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _exportAllRecipes,
                        icon: const Icon(Icons.backup),
                        label: Text(l10n.backupAllRecipes),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _importAllRecipes,
                        icon: const Icon(Icons.restore),
                        label: Text(l10n.restoreRecipes),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deleteAllRecipes,
                        icon: const Icon(Icons.delete_forever),
                        label: Text(l10n.deleteAllRecipes),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 저장소 통계 표시 헬퍼 메서드
  Widget _buildStorageStat(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
