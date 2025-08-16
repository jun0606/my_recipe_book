import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

/// 언어 선택 위젯
class LanguageSelector extends StatelessWidget {
  /// 드롭다운 형태로 표시할지 여부
  final bool isDropdown;
  
  /// 생성자
  const LanguageSelector({
    Key? key,
    this.isDropdown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    if (isDropdown) {
      return _buildDropdown(context, localeProvider);
    } else {
      return _buildIconButton(context, localeProvider);
    }
  }
  
  Widget _buildDropdown(BuildContext context, LocaleProvider localeProvider) {
    return DropdownButton<String>(
      value: localeProvider.locale.languageCode,
      items: [
        DropdownMenuItem(
          value: 'ko',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇰🇷'),
              SizedBox(width: 8),
              Text('한국어'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇺🇸'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'ja',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇯🇵'),
              SizedBox(width: 8),
              Text('日本語'),
            ],
          ),
        ),
      ],
      onChanged: (String? languageCode) {
        if (languageCode != null) {
          localeProvider.setLocale(languageCode);
        }
      },
      underline: Container(), // 밑줄 제거
    );
  }
  
  Widget _buildIconButton(BuildContext context, LocaleProvider localeProvider) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.language),
      tooltip: '언어 선택',
      onSelected: (String languageCode) {
        localeProvider.setLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'ko',
          child: Row(
            children: [
              Text('🇰🇷'),
              SizedBox(width: 8),
              Text('한국어'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text('🇺🇸'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ja',
          child: Row(
            children: [
              Text('🇯🇵'),
              SizedBox(width: 8),
              Text('日本語'),
            ],
          ),
        ),
      ],
    );
  }
}