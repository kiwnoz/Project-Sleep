import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// แสดงตัวเลขสถิติสั้นๆ พร้อม label เช่น "Avg duration: 6.8h"
/// ใช้ในแถบสถิติของหน้า Home
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textMutedColor(context)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimaryColor(context),
          ),
        ),
      ],
    );
  }
}