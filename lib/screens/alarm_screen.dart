import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// หน้าตั้งนาฬิกาปลุกแบบ Sleep Cycle
/// TODO: ยังไม่ implement ฟีเจอร์จริง — ตอนนี้เป็นแค่หน้า placeholder
class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Sleep Cycle Alarm'),
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
                child: const Icon(Icons.alarm_rounded, color: AppTheme.primary, size: 40),
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
                'Set alarms based on your sleep cycles so you wake up at the lightest sleep stage, feeling more refreshed.',
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
