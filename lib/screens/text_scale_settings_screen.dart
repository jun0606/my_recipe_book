import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/text_scale_provider.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.textScaleSettings),
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
                    title: Text(l10n.useSystemTextScale),
                    subtitle: Text(l10n.followDeviceAccessibility),
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
                          l10n.textScaleAdjustment,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.currentSize(
                              (textScaleProvider.textScaleFactor * 100)
                                  .round()
                                  .toString()),
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
                                l10n.preview,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.previewBodyText,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.previewSmallText,
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
                              l10n.sizeSmall,
                              0.9,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              l10n.sizeNormal,
                              1.0,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              l10n.sizeLarge,
                              1.2,
                              textScaleProvider,
                            ),
                            _buildQuickButton(
                              context,
                              l10n.sizeVeryLarge,
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
                              l10n.helpTitle,
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
                        Text(
                          l10n.textScaleHelp,
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
