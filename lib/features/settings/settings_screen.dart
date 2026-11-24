import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/app_toast.dart';
import '../../core/format.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/notification_prefs.dart';
import '../../providers/providers.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: AsyncBody<NotificationPrefs>(
        value: settings,
        data: (prefs) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text(
              '냉장·냉동·상온 기한을 이 휴대폰 알림으로 알려요. 알림의 먹음·버림은 앱을 열지 않아도 정리되고, 메뉴 보기는 추천으로 이어져요.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 12),
            const _NotificationPanel(),
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

class _NotificationPanel extends ConsumerStatefulWidget {
  const _NotificationPanel();

  @override
  ConsumerState<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends ConsumerState<_NotificationPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationServiceProvider).refreshStatus();
    });
  }

  Future<void> _sync() async {
    if (!mounted) return;
    final items = ref.read(ingredientsProvider).value;
    final prefs = ref.read(settingsProvider).value;
    if (items == null || prefs == null) return;
    await ref
        .read(notificationServiceProvider)
        .sync(items: items, prefs: prefs);
  }

  Future<void> _toast(Future<String> message) async {
    final text = await message;
    if (!mounted) return;
    AppToast.show(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(notificationServiceProvider);
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final access = service.access;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_accessLabel(access), style: const TextStyle(height: 1.4)),
            if (service.initNote != null) ...[
              const SizedBox(height: 6),
              Text(
                service.initNote!,
                style: const TextStyle(color: AppColors.olive, height: 1.4),
              ),
            ],
            if (access == NotificationAccess.denied ||
                access == NotificationAccess.unknown) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('notification-permission'),
                onPressed: () async {
                  final text = await ref
                      .read(notificationServiceProvider)
                      .requestPermission();
                  await _sync();
                  if (!context.mounted) return;
                  AppToast.show(context, text);
                },
                child: const Text('알림 허용하기'),
              ),
            ],
            if (service.exactAlarmsApplicable &&
                !service.exactAlarmsGranted) ...[
              const SizedBox(height: 8),
              const Text(
                '정확한 알람 권한이 없으면 알림이 몇 분 늦게 올 수 있어요.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('notification-exact-alarm'),
                onPressed: () async {
                  final text = await ref
                      .read(notificationServiceProvider)
                      .requestExactAlarms();
                  await _sync();
                  if (!context.mounted) return;
                  AppToast.show(context, text);
                },
                child: const Text('정확한 시각 허용'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('send-test-notification'),
              onPressed: () => _toast(
                ref.read(notificationServiceProvider).showTestNotification(),
              ),
              child: const Text('테스트 알림 보내기'),
            ),
          ],
        );
      },
    );
  }
}

String _accessLabel(NotificationAccess access) {
  return switch (access) {
    NotificationAccess.granted => '알림이 켜져 있어요.',
    NotificationAccess.denied => '알림이 꺼져 있어요. 허용하면 기한 전에 알려 드릴게요.',
    NotificationAccess.unsupported =>
      '웹이나 컴퓨터에서는 알림을 예약하지 않아요. 휴대폰 앱에서 같은 설정으로 알려요.',
    NotificationAccess.unknown => '알림 상태를 확인하고 있어요.',
  };
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
