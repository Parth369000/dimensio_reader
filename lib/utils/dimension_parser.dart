import '../models/dimension_item.dart';

class DimensionParser {
  // Regex matches:
  // 1. feet-inch: e.g. 50'-0", 6'-0"
  // 2. inch-only: 12", 24"
  // 3. cm: 30cm, 50.5 cm
  static final RegExp dimensionRegex = RegExp(
    r"(\d+)'\s*-?\s*(\d+)\x22|(\d+(?:\.\d+)?)\x22|(\d+(?:\.\d+)?)\s*cm",
    caseSensitive: false,
  );

  static List<DimensionItem> extractDimensions(String text) {
    final matches = dimensionRegex.allMatches(text);
    final Set<String> uniqueMatches = {};
    final List<DimensionItem> dimensions = [];

    for (var match in matches) {
      final originalText = match.group(0)!;
      // Only add unique texts
      if (!uniqueMatches.contains(originalText)) {
        uniqueMatches.add(originalText);

        double inches = 0.0;
        if (match.group(1) != null && match.group(2) != null) {
          // feet-inch format
          double feet = double.parse(match.group(1)!);
          double ins = double.parse(match.group(2)!);
          inches = (feet * 12.0) + ins;
        } else if (match.group(3) != null) {
          // inch-only format
          inches = double.parse(match.group(3)!);
        } else if (match.group(4) != null) {
          // cm format
          double cm = double.parse(match.group(4)!);
          inches = cm / 2.54; // convert cm to inches
        }

        dimensions.add(
          DimensionItem(originalText: originalText, valueInInches: inches),
        );
      }
    }
    return dimensions;
  }
}
