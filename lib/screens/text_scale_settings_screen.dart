import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/text_scale_provider.dart';

/// 텍스트 크기 설정 화면
class TextScaleSettingsScreen extends StatefulWidget {
  const TextScaleSettingsScreen({super.key});

  @override
  State<TextScaleSettingsScreen> createState() =>
      _TextScaleSettingsScreenState();
}

class _TextScaleSettingsScreenState extends State<TextScaleSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textScaleProvider =
          Provider.of<TextScaleProvider>(context, listen: false);
      textScaleProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('텍스트 크기 설정'),
      ),
      body: Consumer<TextScaleProvider>(
        builder: (context, textScaleProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시스템 설정 사용 여부
                Card(
                  child: SwitchListTile(
                    title: const Text('시스템 텍스트 크기 설정 사용'),
                    subtitle: const Text('기기의 접근성 설정을 따릅니다'),
                    value: textScaleProvider.useSystemTextScale,
                    onChanged: (value) {
                      textScaleProvider.updateUseSystemTextScale(value);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 커스텀 텍스트 크기 설정
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '텍스트 크기 조절',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '현재 크기: ${(textScaleProvider.textScaleFactor * 100).round()}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),

                        // 슬라이더
                        Slider(
                          value: textScaleProvider.textScaleFactor,
                          min: 0.8,
                          max: 2.0,
                          divisions: 12,
                          label:
                              '${(textScaleProvider.textScaleFactor * 100).round()}%',
                          onChanged: (value) {
                            textScaleProvider.updateTextScaleFactor(value);
                          },
                        ),

                        // 미리보기 텍스트
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '미리보기',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '이것은 본문 텍스트의 예시입니다. 레시피 내용이나 설명이 이런 크기로 표시됩니다.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '작은 텍스트 예시입니다.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // 빠른 설정 버튼들
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildQuickButton(
                              context,
                              '작게',
                              0.9,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              '보통',
                              1.0,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              '크게',
                              1.2,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              '매우 크게',
                              1.5,
                              textScaleProvider,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 도움말
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '도움말',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.blue[600],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 시스템 설정을 사용하면 기기의 접근성 설정이 적용됩니다.\n'
                          '• 커스텀 설정을 사용하면 앱 내에서만 텍스트 크기가 조절됩니다.\n'
                          '• 두 설정을 함께 사용할 수도 있습니다.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    double scale,
    TextScaleProvider provider,
  ) {
    final isSelected = (provider.textScaleFactor - scale).abs() < 0.01;

    return ElevatedButton(
      onPressed: () => provider.updateTextScaleFactor(scale),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }
}
