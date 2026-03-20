import 'package:flutter/material.dart';

class TextFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final String currentUnit;
  final Function(String?) onUnitChanged;

  const TextFieldRow({
    super.key,
    required this.label,
    required this.textController,
    required this.currentUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF8D4F23);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryBrown,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryBrown, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                value: currentUnit,
                iconDisabledColor: primaryBrown,
                iconEnabledColor: primaryBrown,
                style: const TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                items: const [
                  DropdownMenuItem(value: 'in', child: Text('in')),
                  DropdownMenuItem(value: 'cm', child: Text('cm')),
                ],
                onChanged: onUnitChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
