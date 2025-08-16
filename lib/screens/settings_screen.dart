import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/recipe_provider.dart';
import '../providers/locale_provider.dart';
import 'user_setup_screen.dart';

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
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      final filePath = await provider.exportAllRecipes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipesBackedUp(filePath))),
      );
      await Share.shareXFiles([XFile(filePath)], text: l10n.shareBackupFile);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.userInfo, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.nameLabel),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTitle,
              items: [
                {'key': 'chef', 'text': AppLocalizations.of(context)!.chef},
                {
                  'key': 'pastryChef',
                  'text': AppLocalizations.of(context)!.pastryChef
                },
                {'key': 'cook', 'text': AppLocalizations.of(context)!.cook},
                {'key': 'baker', 'text': AppLocalizations.of(context)!.baker},
                {
                  'key': 'kitchenMaster',
                  'text': AppLocalizations.of(context)!.kitchenMaster
                },
                {
                  'key': 'gourmet',
                  'text': AppLocalizations.of(context)!.gourmet
                },
                {'key': 'foodie', 'text': AppLocalizations.of(context)!.foodie},
                {
                  'key': 'culinaryResearcher',
                  'text': AppLocalizations.of(context)!.culinaryResearcher
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetUserNameAndTitle,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(l10n.resetUserNameAndTitle,
                  style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Text(l10n.languageSelectionLabel,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: Provider.of<LocaleProvider>(context).locale.languageCode,
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
              decoration:
                  InputDecoration(labelText: l10n.languageSelectionLabel),
            ),
            SizedBox(height: 20),
            Text(l10n.unitSystemLabel,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedUnitSystem,
              items: ['Korea', 'SI', 'US', 'Japan', 'Europe']
                  .map((String system) =>
                      DropdownMenuItem(value: system, child: Text(system)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitSystem = value!;
                });
              },
              decoration:
                  InputDecoration(labelText: l10n.unitSystemSelectionLabel),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text(l10n.saveSettings),
            ),
            SizedBox(height: 30),
            Text(l10n.categoryManagement,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration:
                        InputDecoration(labelText: l10n.newCategoryNameLabel),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: Text(l10n.add),
                ),
              ],
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeCategory(category),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            Text(l10n.dataManagement,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _exportAllRecipes,
              child: Text(l10n.backupAllRecipes),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _importAllRecipes,
              child: Text(l10n.restoreRecipes),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteAllRecipes,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.deleteAllRecipes,
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
