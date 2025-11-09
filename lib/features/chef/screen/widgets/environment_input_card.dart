// 환경 입력 카드 위젯
// 베이킹 환경 조건 입력을 위한 UI 컴포넌트

import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';

class EnvironmentInputCard extends StatefulWidget {
  final UserEnvironment initialEnvironment;
  final Function(UserEnvironment) onEnvironmentChanged;
  final bool showMixerType;

  const EnvironmentInputCard({
    super.key,
    required this.initialEnvironment,
    required this.onEnvironmentChanged,
    this.showMixerType = true,
  });

  @override
  State<EnvironmentInputCard> createState() => _EnvironmentInputCardState();
}

class _EnvironmentInputCardState extends State<EnvironmentInputCard> {
  late TextEditingController _temperatureController;
  late TextEditingController _humidityController;
  late TextEditingController _altitudeController;

  late String _season;
  late String _ovenType;
  late String _fermentationType;
  late String _mixerType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final env = widget.initialEnvironment;
    _temperatureController =
        TextEditingController(text: env.temperature.toString());
    _humidityController = TextEditingController(text: env.humidity.toString());
    _altitudeController = TextEditingController(text: env.altitude.toString());

    _season = env.season.name;
    _ovenType = env.ovenType.name;
    _fermentationType = env.fermentationMethod.name;
    _mixerType = env.mixerType.name;
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '베이킹 환경 조건',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // 온도, 습도 입력
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: '온도 (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateEnvironment(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _humidityController,
                    decoration: const InputDecoration(
                      labelText: '습도 (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateEnvironment(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 고도, 계절 입력
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _altitudeController,
                    decoration: const InputDecoration(
                      labelText: '고도 (m)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateEnvironment(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _season,
                    decoration: const InputDecoration(
                      labelText: '계절',
                      border: OutlineInputBorder(),
                    ),
                    items: Season.values
                        .map((season) => DropdownMenuItem(
                              value: season.name,
                              child: Text(season.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _season = value);
                        _updateEnvironment();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 오븐 타입
            DropdownButtonFormField<String>(
              value: _ovenType,
              decoration: const InputDecoration(
                labelText: '오븐 타입',
                border: OutlineInputBorder(),
              ),
              items: OvenType.values
                  .map((oven) => DropdownMenuItem(
                        value: oven.name,
                        child: Text(oven.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _ovenType = value);
                  _updateEnvironment();
                }
              },
            ),
            const SizedBox(height: 12),

            // 발효 방식
            DropdownButtonFormField<String>(
              value: _fermentationType,
              decoration: const InputDecoration(
                labelText: '발효 방식',
                border: OutlineInputBorder(),
              ),
              items: FermentationMethod.values
                  .map((method) => DropdownMenuItem(
                        value: method.name,
                        child: Text(method.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _fermentationType = value);
                  _updateEnvironment();
                }
              },
            ),

            // 믹서 타입 (선택적 표시)
            if (widget.showMixerType) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _mixerType,
                decoration: const InputDecoration(
                  labelText: '믹서 타입',
                  border: OutlineInputBorder(),
                ),
                items: MixerType.values
                    .map((mixer) => DropdownMenuItem(
                          value: mixer.name,
                          child: Text(mixer.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mixerType = value);
                    _updateEnvironment();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateEnvironment() {
    final newEnvironment = widget.initialEnvironment.copyWith(
      temperature: double.tryParse(_temperatureController.text) ??
          widget.initialEnvironment.temperature,
      humidity: double.tryParse(_humidityController.text) ??
          widget.initialEnvironment.humidity,
      altitude: double.tryParse(_altitudeController.text) ??
          widget.initialEnvironment.altitude,
      season: Season.values.firstWhere((s) => s.name == _season,
          orElse: () => widget.initialEnvironment.season),
      ovenType: OvenType.values.firstWhere((o) => o.name == _ovenType,
          orElse: () => widget.initialEnvironment.ovenType),
      fermentationMethod: FermentationMethod.values.firstWhere(
        (f) => f.name == _fermentationType,
        orElse: () => widget.initialEnvironment.fermentationMethod,
      ),
      mixerType: MixerType.values.firstWhere((m) => m.name == _mixerType,
          orElse: () => widget.initialEnvironment.mixerType),
    );

    widget.onEnvironmentChanged(newEnvironment);
  }
}
