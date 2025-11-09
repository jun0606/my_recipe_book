
class RecipeAnalysisResult {
  final List<String> extractedKeywords;
  final String determinedCategory; // e.g., 'bread', 'cake', 'cookie', 'dessert'

  RecipeAnalysisResult({
    required this.extractedKeywords,
    required this.determinedCategory,
  });

  // Optional: Add toJson/fromJson for persistence if needed later
  Map<String, dynamic> toJson() {
    return {
      'extractedKeywords': extractedKeywords,
      'determinedCategory': determinedCategory,
    };
  }

  factory RecipeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return RecipeAnalysisResult(
      extractedKeywords: List<String>.from(json['extractedKeywords']),
      determinedCategory: json['determinedCategory'],
    );
  }
}
