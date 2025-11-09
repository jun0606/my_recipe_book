// lib/screens/dessert_list_screen.dart

import 'package:flutter/material.dart';
import 'package:my_recipe_book/database/traditional_dessert_database.dart';
import 'package:my_recipe_book/models/traditional_dessert.dart';

class DessertListScreen extends StatefulWidget {
  const DessertListScreen({super.key});

  @override
  State<DessertListScreen> createState() => _DessertListScreenState();
}

class _DessertListScreenState extends State<DessertListScreen> {
  final TraditionalDessertDatabase _dessertDatabase = TraditionalDessertDatabase();
  late Future<List<TraditionalDessert>> _desserts;

  @override
  void initState() {
    super.initState();
    _desserts = _dessertDatabase.getAllDesserts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traditional Desserts'),
      ),
      body: FutureBuilder<List<TraditionalDessert>>(
        future: _desserts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final desserts = snapshot.data!;
            return ListView.builder(
              itemCount: desserts.length,
              itemBuilder: (context, index) {
                final dessert = desserts[index];
                return ListTile(
                  title: Text(dessert.name),
                  subtitle: Text(dessert.country),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
