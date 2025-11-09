class History {
  final int? id;
  final int recipeId;
  final String modifiedDate;
  final String changes;
  final String? recipeState;

  History(
      {this.id,
      required this.recipeId,
      required this.modifiedDate,
      required this.changes,
      this.recipeState});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': recipeId,
      'modifiedDate': modifiedDate,
      'changes': changes,
      'recipeState': recipeState
    };
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      recipeId: json['recipeId'] ?? 0,
      modifiedDate: json['modifiedDate'] ?? '',
      changes: json['changes'] ?? '',
      recipeState: json['recipeState'],
    );
  }
}
