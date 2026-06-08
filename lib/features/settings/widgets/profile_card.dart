import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_username_dialog.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) return const SizedBox();

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: .all(screenWidth * 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(screenWidth * 0.03),
      ),
      child: Padding(
        padding: .all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: .start,
          spacing: screenWidth * 0.025,
          children: [
            Row(
              spacing: screenWidth * 0.04,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: .new(
                      fontSize: screenWidth * 0.06,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: screenWidth * 0.01,
                    children: [
                      Text(
                        user.displayName ?? 'Unknown',
                        style: .new(
                          fontSize: screenWidth * 0.045,
                          fontWeight: .bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: .new(
                          fontSize: screenWidth * 0.035,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditUsernameDialog(
                    context,
                    ref,
                    user.displayName ?? '',
                  ),
                ),
              ],
            ),
            Text(
              user.emailVerified ? '✓ Verified' : '❌ Not Verified',
              style: .new(
                fontSize: screenWidth * 0.035,
                color: user.emailVerified
                    ? colorScheme.tertiary
                    : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showEditUsernameDialog(
  BuildContext context,
  WidgetRef ref,
  String currentName,
) {
  showDialog(
    context: context,
    builder: (_) => EditUsernameDialog(ref: ref, currentName: currentName),
  );
}
