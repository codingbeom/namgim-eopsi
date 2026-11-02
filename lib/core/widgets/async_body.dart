import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.data});

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: data,
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.olive),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '불러오지 못했어요\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.danger, height: 1.4),
          ),
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      child: Column(
        children: [
          const Icon(Icons.spa_outlined, color: AppColors.leaf, size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
