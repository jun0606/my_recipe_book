
class ProcessGuide {
  final String mixingGuide;
  final String fermentationGuide;
  final String bakingGuide;
  final String overallProcessSummary;

  ProcessGuide({
    required this.mixingGuide,
    required this.fermentationGuide,
    required this.bakingGuide,
    required this.overallProcessSummary,
  });

  // Optional: Add toJson/fromJson for persistence if needed later
  Map<String, dynamic> toJson() {
    return {
      'mixingGuide': mixingGuide,
      'fermentationGuide': fermentationGuide,
      'bakingGuide': bakingGuide,
      'overallProcessSummary': overallProcessSummary,
    };
  }

  factory ProcessGuide.fromJson(Map<String, dynamic> json) {
    return ProcessGuide(
      mixingGuide: json['mixingGuide'],
      fermentationGuide: json['fermentationGuide'],
      bakingGuide: json['bakingGuide'],
      overallProcessSummary: json['overallProcessSummary'],
    );
  }
}
