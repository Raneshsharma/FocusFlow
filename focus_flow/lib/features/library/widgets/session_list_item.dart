import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon.dart';

class SessionListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: leading,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? AppIcon(AppIcons.chevronRight),
        onTap: onTap,
      ),
    );
  }
}
