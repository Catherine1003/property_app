import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../data/repository/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsService _analyticsService;
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analyticsService = context.read<AnalyticsService>();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final data = await _analyticsService.getAllAnalytics();
      setState(() => _analyticsData = data);
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearDialog,
            tooltip: 'Clear Analytics',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildMostViewedSection(context),
              const SizedBox(height: AppTheme.spacing24),

              _buildInteractionsSection(context),
              const SizedBox(height: AppTheme.spacing24),

              _buildTimeSpentSection(context),
              const SizedBox(height: AppTheme.spacing24),

              _buildSummaryStats(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMostViewedSection(BuildContext context) {
    final views = _analyticsData['views'] as Map<String, dynamic>? ?? {};

    if (views.isEmpty) {
      return _buildEmptyCard('No Views Yet', 'Properties you view will appear here');
    }

    final sortedViews = views.values.toList();
    sortedViews.sort((a, b) =>
        (b['count'] as int).compareTo(a['count'] as int)
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Most Viewed Properties',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedViews.length,
              separatorBuilder: (_, __) =>
              const Divider(height: AppTheme.spacing16),
              itemBuilder: (_, index) {
                final view = sortedViews[index] as Map<String, dynamic>;
                return _ViewItem(
                  rank: index + 1,
                  title: view['title'] ?? 'Unknown',
                  views: view['count'] ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsSection(BuildContext context) {
    final interactions = _analyticsData['interactions'] as Map<String, dynamic>? ?? {};

    if (interactions.isEmpty) {
      return _buildEmptyCard('No Interactions', 'Your interactions will appear here');
    }

    Map<String, int> actionCounts = {};
    interactions.forEach((key, count) {
      final parts = key.split('_');
      if (parts.length > 1) {
        final action = parts.sublist(1).join('_');
        actionCounts[action] = (actionCounts[action] ?? 0) + (count as int);
      }
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Interactions Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: AppTheme.spacing12,
              runSpacing: AppTheme.spacing12,
              children: actionCounts.entries
                  .map((e) => _InteractionChip(
                action: e.key,
                count: e.value,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSpentSection(BuildContext context) {
    final timeSpent = _analyticsData['timeSpent'] as Map<String, dynamic>? ?? {};

    if (timeSpent.isEmpty) {
      return _buildEmptyCard('No Time Data', 'Time spent will be tracked here');
    }

    final totalSeconds = timeSpent.values.fold<int>(
      0,
          (sum, val) => sum + (val as int),
    );

    final totalMinutes = totalSeconds / 60;
    final totalHours = totalMinutes / 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Time Spent Analysis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TimeStatCard(
                  label: 'Total Hours',
                  value: totalHours.toStringAsFixed(1),
                  unit: 'h',
                ),
                _TimeStatCard(
                  label: 'Total Minutes',
                  value: totalMinutes.toStringAsFixed(0),
                  unit: 'm',
                ),
                _TimeStatCard(
                  label: 'Total Seconds',
                  value: totalSeconds.toString(),
                  unit: 's',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    final views = _analyticsData['views'] as Map<String, dynamic>? ?? {};
    final interactions = _analyticsData['interactions'] as Map<String, dynamic>? ?? {};
    final timeSpent = _analyticsData['timeSpent'] as Map<String, dynamic>? ?? {};

    final totalViews = views.values.fold<int>(
      0,
          (sum, view) => sum + (view['count'] as int? ?? 0),
    );

    final totalInteractions = interactions.values.fold<int>(
      0,
          (sum, count) => sum + (count as int),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatTile(
                  icon: Icons.visibility,
                  label: 'Total Views',
                  value: totalViews.toString(),
                  color: AppColors.info,
                ),
                _StatTile(
                  icon: Icons.touch_app,
                  label: 'Total Interactions',
                  value: totalInteractions.toString(),
                  color: AppColors.secondary,
                ),
                _StatTile(
                  icon: Icons.home_work,
                  label: 'Properties Viewed',
                  value: views.length.toString(),
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Analytics'),
        content: const Text('Are you sure you want to clear all analytics data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _analyticsService.clearAnalytics();
              Navigator.pop(context);
              _loadAnalytics();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewItem extends StatelessWidget {
  final int rank;
  final String title;
  final int views;

  const _ViewItem({
    required this.rank,
    required this.title,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '$views views',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing12,
            vertical: AppTheme.spacing4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Text(
            views.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _InteractionChip extends StatelessWidget {
  final String action;
  final int count;

  const _InteractionChip({
    required this.action,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$action: $count'),
      backgroundColor: AppColors.secondaryLight,
      labelStyle: const TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TimeStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _TimeStatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value $unit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}