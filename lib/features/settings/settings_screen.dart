import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/notification_prefs.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final note = ref.watch(notificationServiceProvider).initNote;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: AsyncBody<NotificationPrefs>(
        value: settings,
        data: (prefs) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text(
              '알림 시각과 시점만 저장해요. 실제 예약은 5주차에 workmanager와 함께 연결합니다.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(note, style: const TextStyle(color: AppColors.olive)),
            ],
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('알림 시각'),
              subtitle: Text(formatClock(prefs.hour, prefs.minute)),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: prefs.hour,
                    minute: prefs.minute,
                  ),
                );
                if (picked == null) return;
                await ref
                    .read(settingsRepositoryProvider)
                    .save(
                      prefs.copyWith(hour: picked.hour, minute: picked.minute),
                    );
              },
            ),
            const Divider(),
            _LeadSection(
              title: '냉장',
              body: '기본은 3일 전과 당일 아침이에요.',
              lead: prefs.fridgeLeadDays,
              onLead: (value) => ref
                  .read(settingsRepositoryProvider)
                  .save(prefs.copyWith(fridgeLeadDays: value)),
              dayOf: prefs.fridgeOnTheDay,
              onDayOf: (value) => ref
                  .read(settingsRepositoryProvider)
                  .save(prefs.copyWith(fridgeOnTheDay: value)),
            ),
            _LeadSection(
              title: '냉동',
              body: '냉동도 3일 전과 당일을 기본으로 해요.',
              lead: prefs.freezerLeadDays,
              onLead: (value) => ref
                  .read(settingsRepositoryProvider)
                  .save(prefs.copyWith(freezerLeadDays: value)),
              dayOf: prefs.freezerOnTheDay,
              onDayOf: (value) => ref
                  .read(settingsRepositoryProvider)
                  .save(prefs.copyWith(freezerOnTheDay: value)),
            ),
            _PantrySection(prefs: prefs),
            const SizedBox(height: 12),
            const Text(
              '홈의 임박 표시는 이 날짜를 바로 따라가요. 냉장·냉동은 앞선 일수, 상온은 두 번째 알림 일수를 기준으로 해요.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            const Text(
              '남김없이',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.olive,
              ),
            ),
            const SizedBox(height: 4),
            const Text('입력은 간편하게, 식재료는 남김없이'),
            const SizedBox(height: 8),
            const Text(
              '1단계 개인 관리. 재료는 이 기기에만 저장되고, 계정이나 서버는 쓰지 않아요.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadSection extends StatelessWidget {
  const _LeadSection({
    required this.title,
    required this.body,
    required this.lead,
    required this.onLead,
    required this.dayOf,
    required this.onDayOf,
  });

  final String title;
  final String body;
  final int lead;
  final ValueChanged<int> onLead;
  final bool dayOf;
  final ValueChanged<bool> onDayOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        Text(body, style: const TextStyle(color: AppColors.muted)),
        Row(
          children: [
            const Expanded(child: Text('며칠 전')),
            IconButton(
              onPressed: lead > 0 ? () => onLead(lead - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$lead일'),
            IconButton(
              onPressed: lead < 14 ? () => onLead(lead + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('당일에도 알림'),
          value: dayOf,
          onChanged: onDayOf,
        ),
      ],
    );
  }
}

class _PantrySection extends ConsumerWidget {
  const _PantrySection({required this.prefs});

  final NotificationPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> save(NotificationPrefs next) {
      return ref.read(settingsRepositoryProvider).save(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상온',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const Text(
          '기한이 긴 찬장 식품은 2주 전, 다시 1주 전에 알려요.',
          style: TextStyle(color: AppColors.muted),
        ),
        _StepperRow(
          label: '첫 알림',
          value: prefs.pantryEarlyDays,
          onChanged: (value) {
            final late = prefs.pantryLateDays >= value
                ? value - 1
                : prefs.pantryLateDays;
            save(
              prefs.copyWith(
                pantryEarlyDays: value,
                pantryLateDays: late < 1 ? 1 : late,
              ),
            );
          },
          min: 2,
          max: 60,
        ),
        _StepperRow(
          label: '두 번째 알림',
          value: prefs.pantryLateDays,
          onChanged: (value) => save(prefs.copyWith(pantryLateDays: value)),
          min: 1,
          max: prefs.pantryEarlyDays - 1,
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$value일'),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
