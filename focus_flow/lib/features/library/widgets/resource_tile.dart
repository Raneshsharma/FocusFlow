import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/resource.dart';

class ResourceTile extends StatelessWidget {
  final String title;
  final String url;
  final ResourceCategory? category;
  final bool isReadLater;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onOpen;

  const ResourceTile({
    super.key,
    required this.title,
    required this.url,
    this.category,
    this.isReadLater = false,
    this.onTap,
    this.onDelete,
    this.onOpen,
  });

  Color _getCategoryColor(ResourceCategory? cat) {
    switch (cat) {
      case ResourceCategory.article:
        return AppColors.teal;
      case ResourceCategory.tool:
        return AppColors.energyQuick;
      case ResourceCategory.video:
        return const Color(0xFFE91E63);
      case ResourceCategory.course:
        return AppColors.energyDeep;
      default:
        return AppColors.teal;
    }
  }

  String _getCategoryIcon(ResourceCategory? cat) {
    switch (cat) {
      case ResourceCategory.article:
        return '📄';
      case ResourceCategory.tool:
        return '🛠️';
      case ResourceCategory.video:
        return '🎥';
      case ResourceCategory.course:
        return '📚';
      default:
        return '🔗';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getCategoryIcon(category),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(title),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            if (isReadLater) ...[
              const SizedBox(width: 4),
              AppIcon(AppIcons.bookmarkFilled, color: AppColors.energyLow, size: 14),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onOpen != null)
              IconButton(
                icon: AppIcon(AppIcons.externalLink, size: 18),
                onPressed: onOpen,
              ),
            if (onDelete != null)
              IconButton(
                icon: AppIcon(AppIcons.delete, color: Colors.red, size: 18),
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
