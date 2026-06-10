import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../auth/providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            spacing: screenWidth * 0.01,
            children: [
              Text(
                'Welcome',
                style: .new(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              userAsync.when(
                data: (user) => Text(
                  user?.username ?? 'User',
                  style: .new(fontSize: screenWidth * 0.06, fontWeight: .w700),
                ),
                loading: () => Text(
                  '...',
                  style: .new(fontSize: screenWidth * 0.06, fontWeight: .w700),
                ),
                error: (_, _) => Text(
                  'User',
                  style: .new(fontSize: screenWidth * 0.06, fontWeight: .w700),
                ),
              ),
            ],
          ),
        ),
        Row(
          spacing: screenWidth * 0.04,
          children: [
            CircleAvatar(
              radius: screenWidth * 0.06,
              child: Text(
                (userAsync.value?.username.isNotEmpty ?? false)
                    ? userAsync.value!.username[0].toUpperCase()
                    : 'U',
                style: .new(fontSize: screenWidth * 0.045),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
