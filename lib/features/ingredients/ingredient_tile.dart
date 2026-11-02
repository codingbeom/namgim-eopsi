import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/notification_prefs.dart';
import '../../domain/urgency.dart';
import '../shell/app_shell.dart';

class IngredientTile extends StatelessWidget {
  const IngredientTile({
    super.key,
    required this.item,
    required this.prefs,
    required this.now,
    this.onEat,
    this.onDiscard,
    this.onOpen,
    this.onEdit,
  });

  final IngredientItem item;
  final NotificationPrefs prefs;
  final DateTime now;
  final VoidCallback? onEat;
  final VoidCallback? onDiscard;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final urgency = urgencyFor(
      expiry: item.expiryDate,
      location: item.storageLocation,
      now: now,
      prefs: prefs,
    );
    final color = urgencyColor(urgency);
    final stored = item.status == IngredientStatus.stored;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 72,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(6),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusChip(
                          label: item.storageLocation.label,
                          color: storageColor(item.storageLocation.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatExpiry(item.expiryDate, now)} · ${formatQuantity(item.quantity)}개'
                      '${item.isOpened ? ' · 개봉' : ''}',
                      style: TextStyle(
                        color: urgency == Urgency.later
                            ? AppColors.muted
                            : color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (stored)
                      Row(
                        children: [
                          if (!item.isOpened)
                            TextButton(
                              onPressed: onOpen,
                              child: const Text('개봉'),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '개봉됨',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            tooltip: '먹음',
                            onPressed: onEat,
                            icon: const Icon(Icons.check_circle_outline),
                            color: AppColors.olive,
                          ),
                          IconButton(
                            tooltip: '버림',
                            onPressed: onDiscard,
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
