import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF8D4F23);

    return AppBar(
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBrown),
            onPressed: () {},
          ),
        ),
      ),
      title: Column(
        children: [
          Text(
            'CONSTRUCTION AI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'VIEW STRUCTURE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: primaryBrown,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
          child: Container(
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: primaryBrown),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
