import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/namgim_app.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.initialize();
  runApp(
    ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(notifications)],
      child: const NamgimApp(),
    ),
  );
}
