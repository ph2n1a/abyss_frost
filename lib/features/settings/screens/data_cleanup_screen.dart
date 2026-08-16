import 'package:flutter/material.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:abyss_frost/features/settings/widgets/data_cleanup_widgets/month_cleanup_card.dart';
import 'package:abyss_frost/features/settings/widgets/data_cleanup_widgets/storage_donut_chart.dart';

class DataCleanupScreen extends StatefulWidget {
  final AppDatabase db;

  const DataCleanupScreen({
    super.key,
    required this.db,
  });

  @override
  State<DataCleanupScreen> createState() => _DataCleanupScreenState();
}

class _DataCleanupScreenState extends State<DataCleanupScreen> {

  List<MonthStats> _months = [];
  bool _loading = true;
  String? _error;

  final Set<String> _deletingMonths = {};

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    if (mounted) {
      setState(() {
        _loading = _months.isEmpty;
        _error = null;
      });
    }

    try {
      final months = await widget.db.getUsedMonths();

      if (!mounted) return;

      setState(() {
        _months = months;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      if (_months.isNotEmpty) {
        setState(() => _loading = false);
        _showSnackBar('Failed to refresh months', isError: true);
      } else {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  DateTime? _parseMonth(String monthYear) {
    final parts = monthYear.split('.');

    if (parts.length != 2) return null;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return null;
    if (month < 1 || month > 12) return null;

    return DateTime(year, month, 1);
  }

  Future<bool> _confirmDelete(MonthStats month) async {
    if (_deletingMonths.contains(month.monthYear)) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF191921),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delete ${month.monthYear}?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '${month.pingCount} records will be deleted permanently.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _deleteMonth(MonthStats month) async {
    if (_deletingMonths.contains(month.monthYear)) return;

    final date = _parseMonth(month.monthYear);

    if (date == null) {
      _showSnackBar('Invalid month format: ${month.monthYear}', isError: true);
      return;
    }

    if (!mounted) return;

    setState(() {
      _deletingMonths.add(month.monthYear);
      _months.removeWhere((element) => element.monthYear == month.monthYear);
    });

    try {
      await widget.db.cleanupLogs([date]);

      if (!mounted) return;

      _showSnackBar('${month.monthYear} deleted');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Failed to delete ${month.monthYear}', isError: true);

      await _loadMonths();
    } finally {
      if (mounted) {
        setState(() {
          _deletingMonths.remove(month.monthYear);
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: appColors.backgroundColor,
        surfaceTintColor: appColors.backgroundColor,
        iconTheme: IconThemeData(color: appColors.backColor),
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Data cleanup',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadMonths,
            icon: Icon(
              Icons.refresh_rounded,
              color: appColors.backColor,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _months.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _months.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load months',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadMonths,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_months.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 46,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'There are no saved months.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMonths,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        itemCount: _months.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return StorageDonutChart(months: _months);
          }

          final month = _months[index - 1];

          return MonthCleanupCard(
            month: month,
            isDeleting: _deletingMonths.contains(month.monthYear),
            onConfirmDelete: () => _confirmDelete(month),
            onDelete: () => _deleteMonth(month),
          );
        },
      ),
    );
  }
}