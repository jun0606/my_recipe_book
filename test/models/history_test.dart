import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/history.dart';

void main() {
  group('History Model Tests', () {
    test('should serialize and deserialize correctly', () {
      // Arrange
      final history = History(
        id: 1,
        recipeId: 5,
        modifiedDate: '2024-01-15 10:30:00',
        changes: 'Updated ingredients',
        recipeState: '{"title": "Old Recipe"}',
      );

      // Act
      final json = history.toJson();
      final deserializedHistory = History.fromJson(json);

      // Assert
      expect(deserializedHistory.id, history.id);
      expect(deserializedHistory.recipeId, history.recipeId);
      expect(deserializedHistory.modifiedDate, history.modifiedDate);
      expect(deserializedHistory.changes, history.changes);
      expect(deserializedHistory.recipeState, history.recipeState);
    });

    test('should handle null values correctly', () {
      // Arrange
      final history = History(
        recipeId: 5,
        modifiedDate: '2024-01-15 10:30:00',
        changes: 'Updated ingredients',
      );

      // Act
      final json = history.toJson();
      final deserializedHistory = History.fromJson(json);

      // Assert
      expect(deserializedHistory.id, isNull);
      expect(deserializedHistory.recipeState, isNull);
      expect(deserializedHistory.recipeId, 5);
      expect(deserializedHistory.modifiedDate, '2024-01-15 10:30:00');
      expect(deserializedHistory.changes, 'Updated ingredients');
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final jsonWithMissingFields = {
        'id': 1,
        // recipeId missing
        // modifiedDate missing
        // changes missing
      };

      // Act
      final history = History.fromJson(jsonWithMissingFields);

      // Assert
      expect(history.id, 1);
      expect(history.recipeId, 0); // default value
      expect(history.modifiedDate, ''); // default value
      expect(history.changes, ''); // default value
      expect(history.recipeState, isNull);
    });

    test('should maintain data integrity through serialization cycle', () {
      // Arrange
      final originalHistory = History(
        id: 42,
        recipeId: 123,
        modifiedDate: '2024-12-25 15:45:30',
        changes: 'Added new step in instructions',
        recipeState: '{"id": 123, "title": "Christmas Cake"}',
      );

      // Act
      final json = originalHistory.toJson();
      final roundTripHistory = History.fromJson(json);
      final secondJson = roundTripHistory.toJson();

      // Assert - JSON should be identical after round trip
      expect(secondJson, equals(json));

      // Assert - All fields should match
      expect(roundTripHistory.id, originalHistory.id);
      expect(roundTripHistory.recipeId, originalHistory.recipeId);
      expect(roundTripHistory.modifiedDate, originalHistory.modifiedDate);
      expect(roundTripHistory.changes, originalHistory.changes);
      expect(roundTripHistory.recipeState, originalHistory.recipeState);
    });
  });
}
