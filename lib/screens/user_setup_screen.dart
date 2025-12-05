import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/recipe_provider.dart';
import '../../providers/locale_provider.dart';
import '../screens/recipe_list_screen.dart';
import '../../utils/navigation.dart';
import '../../l10n/app_localizations.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  _UserSetupScreenState createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _title; // 초기값을 null로 변경
  String _selectedLanguageCode = 'ko'; // 추가: 기본 언어 설정
  bool _showWelcome = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 추가: 저장된 언어 설정 로드
    _controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().then((_) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) setState(() => _showWelcome = false);
      });
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguageCode = prefs.getString('language_code') ?? 'ko';
      _title = prefs.getString('user_title'); // 키를 로드
    });
  }

  Future<void> _showLanguageSelectionDialog() async {
    final List<Map<String, String>> supportedLanguages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'ko', 'name': '한국어'},
      {'code': 'ja', 'name': '日本語'},
    ];

    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final l10nDialog = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10nDialog.languageSelection),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: supportedLanguages.map((lang) {
                return ListTile(
                  title: Text(lang['name']!),
                  onTap: () {
                    Navigator.pop(context, lang['code']);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _selectedLanguageCode) {
      setState(() {
        _selectedLanguageCode = selected;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', _selectedLanguageCode);
      if (mounted) {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(selected);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.pink[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _showWelcome
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dinner_dining, size: 100, color: Colors.white),
                      SizedBox(height: 20),
                      Text('My Recipe Book',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.w)),
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              // 추가: 언어 선택 아이콘
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(Icons.language, color: Colors.pink),
                                onPressed: _showLanguageSelectionDialog,
                                tooltip: l10n.languageSelectionLabel,
                              ),
                            ),
                            Text(l10n.setupScreenTitle,
                                style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink)),
                            SizedBox(height: 20.h),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: l10n.nameLabel,
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.pink)),
                              onChanged: (value) => _name = value,
                              validator: (value) =>
                                  value!.isEmpty ? l10n.nameRequired : null,
                            ),
                            SizedBox(height: 16.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.titleSelection,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey[700])),
                                SizedBox(height: 8.h),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    {'key': 'chef', 'text': '셰프'},
                                    {'key': 'pastryChef', 'text': '파티시에'},
                                    {'key': 'cook', 'text': '요리사'},
                                    {'key': 'baker', 'text': '베이커'},
                                    {'key': 'kitchenMaster', 'text': '주방장'},
                                    {'key': 'gourmet', 'text': '미식가'},
                                    {'key': 'foodie', 'text': '푸디'},
                                    {
                                      'key': 'culinaryResearcher',
                                      'text': '요리연구가'
                                    },
                                    {'key': 'honorificNim', 'text': '님'},
                                    {'key': 'honorificSsi', 'text': '씨'},
                                  ].map((Map<String, String> item) {
                                    return ChoiceChip(
                                      label: Text(item['text']!),
                                      selected: _title == item['key'], // 키로 비교
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _title = item['key']; // 키 저장
                                        });
                                      },
                                      selectedColor: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.2),
                                      labelStyle: TextStyle(
                                          color: _title == item['key']
                                              ? Theme.of(context).primaryColor
                                              : Colors.black87),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.5)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('user_name', _name);
                                  await prefs.setString(
                                      'user_title',
                                      _title ??
                                          'chef'); // _title이 null일 경우 기본값 'chef' 저장
                                  await prefs.setString('language_code',
                                      _selectedLanguageCode); // 추가: 언어 코드 저장
                                  await Provider.of<RecipeProvider>(context,
                                          listen: false)
                                      .loadCategories();
                                  if (mounted) {
                                    Navigator.pushReplacement(context,
                                        buildPageRoute(RecipeListScreen()));
                                  }
                                }
                              },
                              child: Text(l10n.startCooking,
                                  style: TextStyle(fontSize: 18.sp)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
