import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/sleep_result.dart';
import '../services/history_service.dart';
import '../widgets/quality_badge.dart';
import '../widgets/stat_chip.dart';
import '../services/route_observer.dart';
import 'assessment_screen.dart';
import 'about_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final HistoryService _historyService = HistoryService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SleepResult> _history = [];
  bool _loading = true;

  String _trendRange = '7d'; // '7d' | '1m'
  bool _showAllRecent = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    if (!mounted) return;
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 5) return Icons.bedtime_rounded;
    if (hour < 12) return Icons.wb_twilight;
    if (hour < 17) return Icons.wb_sunny_rounded;
    if (hour < 20) return Icons.cloud_rounded;
    return Icons.nights_stay_rounded;
  }

  double get _avgDuration {
    if (_history.isEmpty) return 0;
    final recent = _history.length > 7
        ? _history.sublist(_history.length - 7)
        : _history;
    final total = recent.fold<double>(0, (sum, r) => sum + r.input.sleepDuration);
    return total / recent.length;
  }

  int get _streak {
    if (_history.isEmpty) return 0;
    final uniqueDays = _history
        .map((r) =>
            DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    for (int i = 0; i < uniqueDays.length - 1; i++) {
      final diff = uniqueDays[i].difference(uniqueDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get _trendWindow => _trendRange == '7d' ? 7 : 30;

  Future<void> _startAssessment() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssessmentScreen()),
    );
    _loadHistory();
  }

  Future<void> _confirmDeleteResult(SleepResult result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this check-in?'),
        content: Text(
          'Remove the ${result.quality} result from ${_formatDate(result.timestamp)}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.poor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _historyService.deleteResult(result);
      _loadHistory();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bedtime_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SleepWise AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.borderColor(context)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: AppTheme.primary),
              title: Text('Home', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimaryColor(context))),
              trailing: const Icon(Icons.check, color: AppTheme.primary, size: 18),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart_rounded, color: AppTheme.textMutedColor(context).withValues(alpha: 0.6)),
              title: Text('Full history', style: TextStyle(color: AppTheme.textMutedColor(context).withValues(alpha: 0.6))),
              trailing: Text('Coming soon', style: TextStyle(fontSize: 11, color: AppTheme.textMutedColor(context))),
              enabled: false,
            ),
            ListTile(
              leading: Icon(Icons.settings_rounded, color: AppTheme.textSecondaryColor(context)),
              title: Text('Settings', style: TextStyle(color: AppTheme.textPrimaryColor(context))),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Spacer(),
            Divider(height: 1, color: AppTheme.borderColor(context)),
            ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.textSecondaryColor(context)),
              title: Text('About', style: TextStyle(color: AppTheme.textPrimaryColor(context))),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(context),
            if (!_loading) _buildStatsCard(context),
            if (!_loading && _history.isNotEmpty) _buildTrendChart(context),
            if (!_loading && _history.isNotEmpty) _buildRecentList(context),
            if (!_loading && _history.isEmpty) _buildEmptyState(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 40,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                    tooltip: 'Menu',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _greetingIcon,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Ready for tonight's check?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                ),
                child: const Text('Start sleep assessment'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppTheme.isDark(context) ? 0.25 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatChip(
                label: 'Avg duration',
                value: _history.isEmpty ? '—' : '${_avgDuration.toStringAsFixed(1)}h',
              ),
              StatChip(
                label: 'Streak',
                value: _history.isEmpty ? '—' : '$_streak day${_streak == 1 ? '' : 's'}',
              ),
              StatChip(
                label: 'Last quality',
                value: _history.isEmpty ? '—' : _history.last.quality,
                valueColor: _history.isEmpty
                    ? null
                    : AppTheme.qualityColor(_history.last.quality),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeToggle(BuildContext context) {
    Widget rangeButton(String key, String label) {
      final selected = _trendRange == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _trendRange = key),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textMutedColor(context),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMutedColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          rangeButton('7d', '7 Days'),
          rangeButton('1m', '1 Month'),
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    final window = _trendWindow;
    final recent = _history.length > window
        ? _history.sublist(_history.length - window)
        : _history;
    final isMonthView = _trendRange == '1m';
    final mutedColor = AppTheme.textMutedColor(context);
    final borderColor = AppTheme.borderColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sleep trend", style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor(context),
              )),
              SizedBox(width: 140, child: _buildRangeToggle(context)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: borderColor.withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: mutedColor),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: isMonthView
                          ? (recent.length / 5).ceilToDouble().clamp(1, 999)
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= recent.length) {
                          return const SizedBox.shrink();
                        }
                        String label;
                        if (isMonthView) {
                          final d = recent[index].timestamp;
                          label = '${d.day}/${d.month}';
                        } else {
                          const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          label = weekdays[recent[index].timestamp.weekday - 1];
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label, style: TextStyle(
                            fontSize: 10,
                            color: mutedColor,
                          )),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(show: !isMonthView || recent.length <= 10),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                    ),
                    spots: [
                      for (int i = 0; i < recent.length; i++)
                        FlSpot(i.toDouble(), recent[i].displayScore.toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList(BuildContext context) {
    final visibleCount = _showAllRecent ? 30 : 7;
    final recent = _history.reversed.take(visibleCount).toList();
    final hasMore = !_showAllRecent && _history.length > 7;
    final borderColor = AppTheme.borderColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent check-ins', style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor(context),
          )),
          const SizedBox(height: 8),
          for (final r in recent)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ResultScreen(result: r)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(r.timestamp),
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor(context)),
                              ),
                            ),
                            QualityBadge(quality: r.quality),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: AppTheme.textMutedColor(context)),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeleteResult(r);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete_outline, size: 18, color: AppTheme.poor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.poor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAllRecent = true),
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: const Text('Show more'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ),
            ),
          if (_showAllRecent && _history.length > 7)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAllRecent = false),
                  icon: const Icon(Icons.expand_less_rounded, size: 18),
                  label: Text('Show less', style: TextStyle(color: AppTheme.textMutedColor(context))),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceMutedColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.bedtime_outlined, color: AppTheme.textMutedColor(context), size: 32),
            const SizedBox(height: 8),
            Text(
              'No check-ins yet',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimaryColor(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Start your first sleep assessment to see your trend here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMutedColor(context)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
