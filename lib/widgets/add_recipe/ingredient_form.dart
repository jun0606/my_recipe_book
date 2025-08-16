import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/unit_converter.dart';
import '../../utils/validation_utils.dart';

class IngredientForm extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final Function(List<Map<String, dynamic>>) onIngredientsChanged;
  final Function() onIngredientsUpdated;

  const IngredientForm({
    Key? key,
    required this.ingredients,
    required this.onIngredientsChanged,
    required this.onIngredientsUpdated,
  }) : super(key: key);

  @override
  _IngredientFormState createState() => _IngredientFormState();
}

class _IngredientFormState extends State<IngredientForm> {
  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  String? _unit = 'g';

  @override
  void dispose() {
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientNameController.text.isNotEmpty && _ingredientAmountController.text.isNotEmpty) {
      final amount = double.tryParse(_ingredientAmountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 재료 양을 입력하세요.')),
        );
        return;
      }
      
      final newIngredients = List<Map<String, dynamic>>.from(widget.ingredients);
      newIngredients.add({
        'name': _ingredientNameController.text,
        'amount': amount,
        'unit': _unit,
      });
      
      widget.onIngredientsChanged(newIngredients);
      widget.onIngredientsUpdated();
      
      _ingredientNameController.clear();
      _ingredientAmountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('재료 이름과 양을 모두 입력하세요.')),
      );
    }
  }

  void _editIngredient(int index) {
    final ingredient = widget.ingredients[index];
    final nameController = TextEditingController(text: ingredient['name'] as String?);
    final amountController = TextEditingController(text: ingredient['amount']?.toString());
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
                      items: UnitConverter.getUnits(Provider.of<RecipeProvider>(context, listen: false).unitSystem)
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
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
                    if (nameController.text.isNotEmpty && amount != null && amount > 0) {
                      final newIngredients = List<Map<String, dynamic>>.from(widget.ingredients);
                      newIngredients[index] = {
                        'name': nameController.text,
                        'amount': amount,
                        'unit': selectedUnit,
                      };
                      
                      widget.onIngredientsChanged(newIngredients);
                      widget.onIngredientsUpdated();
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

  void _deleteIngredient(int index) {
    final newIngredients = List<Map<String, dynamic>>.from(widget.ingredients);
    newIngredients.removeAt(index);
    widget.onIngredientsChanged(newIngredients);
    widget.onIngredientsUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('재료', style: Theme.of(context).textTheme.titleLarge),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ingredientNameController,
                decoration: InputDecoration(labelText: '재료 이름'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _ingredientAmountController,
                decoration: InputDecoration(labelText: '양'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: _unit,
              items: UnitConverter.getUnits(provider.unitSystem)
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: (value) => setState(() => _unit = value),
            ),
            IconButton(icon: Icon(Icons.add), onPressed: _addIngredient),
          ],
        ),
        SizedBox(height: 10),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.ingredients.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final newIngredients = List<Map<String, dynamic>>.from(widget.ingredients);
            final item = newIngredients.removeAt(oldIndex);
            newIngredients.insert(newIndex, item);
            widget.onIngredientsChanged(newIngredients);
          },
          itemBuilder: (context, index) {
            final ingredient = widget.ingredients[index];
            return Card(
              key: ValueKey(ingredient),
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.brown[700]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${ingredient['amount']} ${ingredient['unit']}',
                            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
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
                      onPressed: () => _deleteIngredient(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}