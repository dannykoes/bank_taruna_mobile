import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/responsive_container.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

// 340 x 669 px
  static const _assetPath = 'assets/images/a_Premium.png';

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    _assetPath,
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
