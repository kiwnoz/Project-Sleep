import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kDisplayName = 'settings_display_name';
  static const _kAge = 'settings_age';
  static const _kDurationUnit = 'settings_duration_unit';
  static const _kRememberLast = 'settings_remember_last_assessment';
  static const _kSleepReminder = 'settings_sleep_reminder';
  static const _kDailyReminder = 'settings_daily_reminder';
  static const _kAppearance = 'settings_appearance';
  static const _kLanguage = 'settings_language';
  static const _kLastAssessmentDraft = 'last_assessment_draft';

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _loading = true;
  String _durationUnit = 'hours';
  bool _rememberLast = true;
  bool _sleepReminder = false;
  bool _dailyReminder = false;
  String _appearance = 'light';
  String _language = 'en';

  static const String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString(_kDisplayName) ?? '';
      _ageController.text = prefs.getString(_kAge) ?? '';
      _durationUnit = prefs.getString(_kDurationUnit) ?? 'hours';
      _rememberLast = prefs.getBool(_kRememberLast) ?? true;
      _sleepReminder = prefs.getBool(_kSleepReminder) ?? false;
      _dailyReminder = prefs.getBool(_kDailyReminder) ?? false;
      _appearance = prefs.getString(_kAppearance) ?? 'light';
      _language = prefs.getString(_kLanguage) ?? 'en';
      _loading = false;
    });
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _resetAssessmentDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastAssessmentDraft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Last assessment memory cleared')),
    );
  }

  Future<void> _confirmResetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'คุณต้องการลบข้อมูลการตั้งค่าและข้อมูลการประเมินทั้งหมดหรือไม่? '
          'การกระทำนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.poor),
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _ageController.clear();
        _durationUnit = 'hours';
        _rememberLast = true;
        _sleepReminder = false;
        _dailyReminder = false;
        _appearance = 'light';
        _language = 'en';
      });
      AppTheme.themeNotifier.value = ThemeMode.light;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All app data has been reset')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final textPrimary = AppTheme.textPrimaryColor(context);
    final textSecondary = AppTheme.textSecondaryColor(context);
    final textMuted = AppTheme.textMutedColor(context);
    final border = AppTheme.borderColor(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceMutedColor(context),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _sectionTitle(context, 'Profile'),
          _card(
            context,
            child: Column(
              children: [
                _iconRow(
                  context,
                  icon: Icons.person_outline,
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Display name',
                      labelStyle: TextStyle(color: textMuted),
                      hintText: 'e.g. Alex',
                      hintStyle: TextStyle(color: textMuted),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => _saveString(_kDisplayName, v),
                  ),
                ),
                Divider(height: 1, color: border),
                _iconRow(
                  context,
                  icon: Icons.cake_outlined,
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Age (optional)',
                      labelStyle: TextStyle(color: textMuted),
                      hintText: 'Only used if a future model needs it',
                      hintStyle: TextStyle(color: textMuted),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => _saveString(_kAge, v),
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Sleep Assessment Preferences'),
          _card(
            context,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_outlined, size: 20, color: textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Sleep duration unit', style: TextStyle(fontSize: 13, color: textPrimary)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 4, 16, 14),
                  child: _segmentedToggle(
                    context,
                    value: _durationUnit,
                    options: const {'hours': 'Hours', 'minutes': 'Minutes'},
                    onChanged: (v) {
                      setState(() => _durationUnit = v);
                      _saveString(_kDurationUnit, v);
                    },
                  ),
                ),
                Divider(height: 1, color: border),
                SwitchListTile(
                  secondary: Icon(Icons.history_rounded, color: textSecondary),
                  title: Text('Remember last assessment', style: TextStyle(fontSize: 13, color: textPrimary)),
                  subtitle: Text(
                    'Pre-fill the form with your last answers',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                  value: _rememberLast,
                  activeColor: AppTheme.primary,
                  onChanged: (v) {
                    setState(() => _rememberLast = v);
                    _saveBool(_kRememberLast, v);
                  },
                ),
                Divider(height: 1, color: border),
                ListTile(
                  leading: Icon(Icons.restart_alt_rounded, color: textSecondary),
                  title: Text('Reset assessment memory', style: TextStyle(fontSize: 13, color: textPrimary)),
                  subtitle: Text(
                    'Clear the remembered last assessment answers',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                  trailing: Icon(Icons.chevron_right, size: 18, color: textMuted),
                  onTap: _resetAssessmentDraft,
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Notifications'),
          _placeholderNote(context, 'Not connected to a real notification system yet'),
          _card(
            context,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.bedtime_outlined, color: textSecondary),
                  title: Text('Sleep reminder', style: TextStyle(fontSize: 13, color: textPrimary)),
                  value: _sleepReminder,
                  activeColor: AppTheme.primary,
                  onChanged: (v) {
                    setState(() => _sleepReminder = v);
                    _saveBool(_kSleepReminder, v);
                  },
                ),
                Divider(height: 1, color: border),
                SwitchListTile(
                  secondary: Icon(Icons.notifications_outlined, color: textSecondary),
                  title: Text('Daily reminder', style: TextStyle(fontSize: 13, color: textPrimary)),
                  value: _dailyReminder,
                  activeColor: AppTheme.primary,
                  onChanged: (v) {
                    setState(() => _dailyReminder = v);
                    _saveBool(_kDailyReminder, v);
                  },
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Appearance'),
          _card(
            context,
            child: Column(
              children: [
                _radioRow(
                  context,
                  icon: Icons.light_mode_outlined,
                  label: 'Light',
                  value: 'light',
                  groupValue: _appearance,
                  onChanged: (v) {
                    setState(() => _appearance = v);
                    _saveString(_kAppearance, v);
                    AppTheme.themeNotifier.value = ThemeMode.light;
                  },
                ),
                Divider(height: 1, color: border),
                _radioRow(
                  context,
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark',
                  value: 'dark',
                  groupValue: _appearance,
                  onChanged: (v) {
                    setState(() => _appearance = v);
                    _saveString(_kAppearance, v);
                    AppTheme.themeNotifier.value = ThemeMode.dark;
                  },
                ),
                Divider(height: 1, color: border),
                _radioRow(
                  context,
                  icon: Icons.settings_suggest_outlined,
                  label: 'System default',
                  value: 'system',
                  groupValue: _appearance,
                  onChanged: (v) {
                    setState(() => _appearance = v);
                    _saveString(_kAppearance, v);
                    AppTheme.themeNotifier.value = ThemeMode.system;
                  },
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Language'),
          _placeholderNote(context, 'App text stays in English for now — this choice is saved for later'),
          _card(
            context,
            child: Column(
              children: [
                _radioRow(
                  context,
                  icon: Icons.language_rounded,
                  label: 'ภาษาไทย',
                  value: 'th',
                  groupValue: _language,
                  onChanged: (v) {
                    setState(() => _language = v);
                    _saveString(_kLanguage, v);
                  },
                ),
                Divider(height: 1, color: border),
                _radioRow(
                  context,
                  icon: Icons.language_rounded,
                  label: 'English',
                  value: 'en',
                  groupValue: _language,
                  onChanged: (v) {
                    setState(() => _language = v);
                    _saveString(_kLanguage, v);
                  },
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Privacy'),
          _card(
            context,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrivacyLine(text: 'Data you enter is used only to run the sleep assessment.', color: textSecondary),
                  const SizedBox(height: 8),
                  _PrivacyLine(text: 'This app is an educational prototype.', color: textSecondary),
                  const SizedBox(height: 8),
                  _PrivacyLine(text: 'It is not a medical diagnostic system.', color: textSecondary),
                ],
              ),
            ),
          ),

          _sectionTitle(context, 'About'),
          _card(
            context,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bedtime_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SleepWise AI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary)),
                            const SizedBox(height: 2),
                            Text('Version $_appVersion', style: TextStyle(fontSize: 11, color: textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'CPE310 — Healthcare AI Project',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A prototype mobile app that estimates sleep quality from a short '
                    'daily check-in, built as a class project to explore how a simple '
                    'ML model can be paired with a friendly, easy-to-use interface.',
                    style: TextStyle(fontSize: 12, color: textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          _sectionTitle(context, 'Medical Disclaimer'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warningBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.warningText),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'SleepWise AI เป็นต้นแบบเพื่อการศึกษา ผลการประเมินจาก AI '
                    'ไม่ใช่การวินิจฉัยทางการแพทย์ และไม่สามารถใช้แทนคำแนะนำจาก'
                    'บุคลากรทางการแพทย์ได้',
                    style: TextStyle(fontSize: 12, color: AppTheme.warningText, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle(context, 'Reset App Data'),
          _card(
            context,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: AppTheme.poor),
              title: const Text(
                'Reset All Data',
                style: TextStyle(color: AppTheme.poor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                'Deletes settings and all saved check-ins from this device',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
              onTap: _confirmResetAllData,
            ),
          ),

          _sectionTitle(context, 'App Information'),
          _card(
            context,
            child: Column(
              children: [
                _infoRow(context, 'App name', 'SleepWise AI'),
                Divider(height: 1, color: border),
                _infoRow(context, 'Version', _appVersion),
                Divider(height: 1, color: border),
                _infoRow(context, 'Developer / Team', 'SleepWise AI Team'),
                Divider(height: 1, color: border),
                _infoRow(context, 'Course', 'CPE310'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondaryColor(context),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _placeholderNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: AppTheme.textMutedColor(context), fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppTheme.isDark(context) ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _iconRow(BuildContext context, {required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondaryColor(context)),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _radioRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      activeColor: AppTheme.primary,
      onChanged: (v) => onChanged(v!),
      secondary: Icon(icon, color: AppTheme.textSecondaryColor(context)),
      title: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textPrimaryColor(context))),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor(context))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryColor(context))),
        ],
      ),
    );
  }

  Widget _segmentedToggle(
    BuildContext context, {
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMutedColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: options.entries.map((e) {
          final selected = value == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.textMutedColor(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  final String text;
  final Color color;
  const _PrivacyLine({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(Icons.check_circle_outline, size: 14, color: AppTheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color, height: 1.4)),
        ),
      ],
    );
  }
}