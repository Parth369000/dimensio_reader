import 'package:flutter/material.dart';

class BlockModel {
  String name;
  TextEditingController lengthController = TextEditingController();
  TextEditingController breadthController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  String lengthUnit = 'in';
  String breadthUnit = 'in';
  String heightUnit = 'in';

  double parsedL = 0.0;
  double parsedB = 0.0;
  double parsedH = 0.0;

  BlockModel({required this.name});
}
