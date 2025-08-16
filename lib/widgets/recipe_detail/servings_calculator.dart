import 'package:flutter/material.dart';
import '../../utils/recipe_calculator.dart';
import '../../utils/validation_utils.dart';

class ServingsCalculator extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final int baseServings;
  final Function(List<Map<String, dynamic>>) onIngredientsCalculated;
  final Function(double) onMultiplierChanged;

  const ServingsCalculator({
    Key? key,
    required this.ingredients,
    required this.baseServings,
    required this.onIngredientsCalculated,
    required this.onMultiplierChanged,
  }) : super(key: key);

  @override
  _ServingsCalculatorState createState() => _ServingsCalculatorState();
}

class _ServingsCalculatorState extends State<ServingsCalculator> {
  late TextEditingController _desiredServingsController;
  double _currentMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _desiredServingsController = TextEditingController(text: widget.baseServings.toString());
  }

  @override
  void dispose() {
    _desiredServingsController.dispose();
    super.dispose();
  }

  void _calculateServings() {
    final double? desiredServings = double.tryParse(_desiredServingsController.text);
    if (desiredServings == null || desiredServings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 인분 수를 입력하세요.')),
      );
      return;
    }
    
    setState(() {
      _currentMultiplier = desiredServings / widget.baseServings;
    });
    
    final calculatedIngredients = RecipeCalculator.calculateIngredients(
      widget.ingredients, 
      _currentMultiplier
    );
    
    widget.onIngredientsCalculated(calculatedIngredients);
    widget.onMultiplierChanged(_currentMultiplier);
  }

  void _resetServings() {
    setState(() {
      _desiredServingsController.text = widget.baseServings.toString();
      _currentMultiplier = 1.0;
    });
    
    widget.onIngredientsCalculated(List<Map<String, dynamic>>.from(widget.ingredients));
    widget.onMultiplierChanged(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인분 수 조정 (${widget.baseServings}인분 기준)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _desiredServingsController,
                  decoration: InputDecoration(
                    labelText: '필요한 인분 수',
                    border: OutlineInputBorder(),
                    helperText: _currentMultiplier != 1.0 ? '현재 배율: ${_currentMultiplier.toStringAsFixed(2)}배' : null,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => ValidationUtils.validatePositiveNumber(value, '인분 수'),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _calculateServings,
                child: Text('계산'),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.refresh),
                tooltip: '초기화',
                onPressed: _resetServings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}