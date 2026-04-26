import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String label;
  final Widget? action;
  final bool spacing;

  const SettingsSection({
    super.key,
    required this.label,
    this.action,
    this.spacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: spacing ? 20 : 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
                letterSpacing: 1.4,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}