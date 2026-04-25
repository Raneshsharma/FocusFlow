import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BodyDoublePill extends StatelessWidget {
  final int partnerCount;
  final bool isFocusing;

  const BodyDoublePill({
    super.key,
    this.partnerCount = 3,
    this.isFocusing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFocusing ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$partnerCount others focusing',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}