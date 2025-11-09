// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:my_recipe_book/models/dashboard_data.dart';
import 'package:my_recipe_book/screens/dessert_list_screen.dart';
import 'package:my_recipe_book/services/visualization_dashboard_service.dart';
import 'package:my_recipe_book/widgets/dashboard/crust_color_indicator.dart';
import 'package:my_recipe_book/widgets/dashboard/crumb_score_histogram.dart';
import 'package:my_recipe_book/widgets/dashboard/environment_monitor.dart';
import 'package:my_recipe_book/widgets/dashboard/volume_index_graph.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VisualizationDashboardService _dashboardService =
      VisualizationDashboardService();

  @override
  void initState() {
    super.initState();
    _dashboardService.startDataStream();
  }

  @override
  void dispose() {
    _dashboardService.stopDataStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualization Dashboard'),
      ),
      body: StreamBuilder<DashboardData>(
        stream: _dashboardService.dashboardDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return GridView.count(
              crossAxisCount: 2,
              children: [
                VolumeIndexGraph(),
                CrustColorIndicator(),
                CrumbScoreHistogram(),
                EnvironmentMonitor(),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DessertListScreen()),
          );
        },
        child: const Icon(Icons.food_bank),
      ),
    );
  }
}
