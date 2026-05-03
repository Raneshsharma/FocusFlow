import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class SettingsActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconEmoji;
  final Color? iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;
  final Color? textColor;
  final bool enabled;

  const SettingsActionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconEmoji,
    this.iconColor,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
    this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? (isDark ? Colors.white : AppColors.textPrimary);
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        children: [
          InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.teal).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: effectiveTextColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing ??
                      AppIcon(
                        AppIcons.chevronRight,
                        color: AppColors.grey400,
                        size: 20,
                      ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 66,
              color: AppColors.settingsDivider,
            ),
        ],
      ),
    );
  }
}