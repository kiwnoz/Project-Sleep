import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// หน้าเปิดเสียงช่วยให้นอนหลับง่ายขึ้น (เช่น เสียงฝน)
/// TODO: ยังไม่ implement ฟีเจอร์จริง — ตอนนี้เป็นแค่หน้า placeholder
class SoundsScreen extends StatelessWidget {
  const SoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Sleep Sounds'),
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Play calming sounds like rain to help you fall asleep faster.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMutedColor(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
