class DimensionItem {
  final String originalText;
  final double valueInInches;

  DimensionItem({required this.originalText, required this.valueInInches});

  @override
  String toString() => '$originalText (${valueInInches.toStringAsFixed(2)} in)';
}
