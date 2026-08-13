import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/responsive_container.dart';
import '../home/home_repository.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  static const _fallbackImageUrl =
      'https://banktaruna.com/frontend/bprtaruna/assets/img/banner/banner%20mobile%20coming%20soon.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    final imageUrl = homeData?.transactionImageUrl ?? _fallbackImageUrl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxHeight * 0.72;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ResponsiveContainer(
              maxWidth: 520,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    height: imageHeight.clamp(320.0, 680.0),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
