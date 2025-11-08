class NutritionAnalysisException implements Exception {
  final String message;
  final String? technicalDetails;

  NutritionAnalysisException(this.message, [this.technicalDetails]);

  @override
  String toString() => 'NutritionAnalysisException: $message';
}
