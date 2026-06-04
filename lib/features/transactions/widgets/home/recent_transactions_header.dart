import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

class RecentTransactionsHeader extends StatelessWidget {
  const RecentTransactionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    // final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Recent Transactions',
          style: .new(fontSize: screenWidth * 0.05, fontWeight: .w700),
        ),
        // const Spacer(),
        // TextButton(
        //   onPressed: () {},
        //   child: Text(
        //     'See All',
        //     style: .new(color: colorScheme.primary, fontWeight: .bold),
        //   ),
        // ),
      ],
    );
  }
}
