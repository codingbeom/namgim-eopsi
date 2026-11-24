import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../providers/providers.dart';
import '../../services/notification_actions.dart';
import '../../services/notification_service.dart';

/// Keeps scheduled alerts aligned with Drift and opens /recipes from a tap.
class NotificationHost extends ConsumerStatefulWidget {
  const NotificationHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends ConsumerState<NotificationHost>
    with WidgetsBindingObserver {
  late final NotificationService _service;
  StreamSubscription<String>? _routes;
  Timer? _debounce;
  var _askedPermission = false;

  @override
  void initState() {
    super.initState();
    _service = ref.read(notificationServiceProvider);
    _service.onAction = _handleAction;
    _routes = _service.routes.listen((route) {
      _service.pendingRoute = null;
      _open(route);
    });
    final pending = _service.takePendingRoute();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pending != null) _open(pending);
      unawaited(_prepare());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_service.onAction == _handleAction) _service.onAction = null;
    _routes?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    ref.invalidate(ingredientsProvider);
    unawaited(_service.refreshStatus());
    _scheduleSync();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(ingredientsProvider, (previous, next) => _scheduleSync());
    ref.listen(settingsProvider, (previous, next) => _scheduleSync());
    return widget.child;
  }

  Future<void> _prepare() async {
    await _service.refreshStatus();
    if (!_askedPermission &&
        _service.supported &&
        _service.access != NotificationAccess.granted) {
      _askedPermission = true;
      await _service.requestPermission();
    }
    _scheduleSync();
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final items = ref.read(ingredientsProvider).value;
      final prefs = ref.read(settingsProvider).value;
      if (items == null || prefs == null) return;
      unawaited(_service.sync(items: items, prefs: prefs));
    });
  }

  Future<void> _handleAction(NotificationActionPlan plan) async {
    if (!mounted) return;
    if (plan.updatesStorage) {
      await applyNotificationAction(
        repository: ref.read(ingredientRepositoryProvider),
        plan: plan,
      );
      if (!mounted) return;
    }
    if (plan.kind == NotificationActionKind.openRecipes) {
      _open('/recipes');
    }
  }

  void _open(String route) {
    if (!mounted) return;
    ref.read(routerProvider).go(route);
  }
}
