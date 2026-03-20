import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';

class AddBlockDialog extends StatelessWidget {
  final AppController controller;
  final TextEditingController blockNameController;

  const AddBlockDialog({
    super.key,
    required this.controller,
    required this.blockNameController,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF8D4F23);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add Dimension Block',
        style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: blockNameController,
        decoration: InputDecoration(
          labelText: 'Block Name (e.g. r1, r2)',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryBrown, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            controller.addBlock(blockNameController.text);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
