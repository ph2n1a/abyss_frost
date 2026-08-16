import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class MonthStats {
  final String monthYear;
  final int pingCount;
  final double sizeMb;

  MonthStats({
    required this.monthYear,
    required this.pingCount,
    required this.sizeMb,
  });
}

class DayStats {
  final int totalPings;
  final double avgPingMs;
  final int? minPingMs;
  final int? maxPingMs;
  final List<PingLog> logs;

  DayStats({
    required this.totalPings,
    required this.avgPingMs,
    this.minPingMs,
    this.maxPingMs,
    required this.logs,
  });
}

enum StatsPeriod { day, week, month }

class PeriodStats {
  final int totalPings;
  final double avgPingMs;
  final int? minPingMs;
  final int? maxPingMs;
  final List<PingLog> logs;
  final DateTime startDate;
  final DateTime endDate;
  final StatsPeriod period;

  PeriodStats({
    required this.totalPings,
    required this.avgPingMs,
    this.minPingMs,
    this.maxPingMs,
    required this.logs,
    required this.startDate,
    required this.endDate,
    required this.period,
  });
}

@DataClassName('PingLog')
class PingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dataTime => dateTime().withDefault(currentDateAndTime)();
  TextColumn get targetUrl => text().withLength(min: 1, max: 255)();
  IntColumn get statusCode => integer().nullable()();
  IntColumn get latencyMs => integer().nullable()();
  TextColumn get pingMethod => text()();

  TextColumn get networkDetails => text().nullable()();
}


@DriftDatabase(tables: [PingLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(pingLogs, pingLogs.networkDetails);
        }
      },
    );
  }

  Future<int> insertPingLog(PingLogsCompanion entry) {
    int? cappedLatency = entry.latencyMs.present ? entry.latencyMs.value : null;

    if (cappedLatency != null && cappedLatency > 999) {
      cappedLatency = 999;
    }

    final cappedEntry = entry.copyWith(latencyMs: Value(cappedLatency));

    return into(pingLogs).insert(cappedEntry);
  }

  Stream<List<PingLog>> getLogs(
    DateTime date, {
    TimeOfDay? timeFrom,
    TimeOfDay? timeTo,
    Map<String, bool>? statusFilters, // {'2xx': true, 'Timeout': false, ...}
    int? latencyFrom,
    int? latencyTo,
    List<String>? targetUrls,
    List<String>? pingMethods,
  }) {
    DateTime start;
    if (timeFrom == null || (timeFrom.hour == 0 && timeFrom.minute == 0)) {
      start = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    } else {
      start = DateTime(
        date.year,
        date.month,
        date.day,
        timeFrom.hour,
        timeFrom.minute,
        0,
        0,
      );
    }

    DateTime end;
    if (timeTo == null || (timeTo.hour == 23 && timeTo.minute == 59)) {
      end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    } else {
      end = DateTime(
        date.year,
        date.month,
        date.day,
        timeTo.hour,
        timeTo.minute,
        59,
        999,
      );
    }

    final query = select(pingLogs)
      ..where((tbl) => tbl.dataTime.isBetweenValues(start, end));

    final activeStatuses =
        statusFilters?.entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .toList() ??
        [];

    if (activeStatuses.isNotEmpty) {
      query.where((tbl) {
        final conditions = <Expression<bool>>[];

        if (activeStatuses.contains('1xx')) {
          conditions.add(tbl.statusCode.isBetweenValues(100, 199));
        }
        if (activeStatuses.contains('2xx')) {
          conditions.add(tbl.statusCode.isBetweenValues(200, 299));
        }
        if (activeStatuses.contains('3xx')) {
          conditions.add(tbl.statusCode.isBetweenValues(300, 399));
        }
        if (activeStatuses.contains('4xx')) {
          conditions.add(tbl.statusCode.isBetweenValues(400, 499));
        }
        if (activeStatuses.contains('5xx')) {
          conditions.add(tbl.statusCode.isBetweenValues(500, 599));
        }
        if (activeStatuses.contains('Timeout')) {
          conditions.add(tbl.statusCode.isNull());
        }

        Expression<bool> combinedCondition = conditions.first;
        for (int i = 1; i < conditions.length; i++) {
          combinedCondition = combinedCondition | conditions[i];
        }

        return combinedCondition;
      });
    }

    if (latencyFrom != null && latencyTo != null) {
      query.where(
        (tbl) =>
            tbl.latencyMs.isBetweenValues(latencyFrom, latencyTo) |
            tbl.latencyMs.isNull(),
      );
    } else if (latencyFrom != null) {
      query.where(
        (tbl) =>
            tbl.latencyMs.isBiggerOrEqualValue(latencyFrom) |
            tbl.latencyMs.isNull(),
      );
    } else if (latencyTo != null) {
      query.where(
        (tbl) =>
            tbl.latencyMs.isSmallerOrEqualValue(latencyTo) |
            tbl.latencyMs.isNull(),
      );
    }

    if (targetUrls != null && targetUrls.isNotEmpty) {
      query.where((tbl) => tbl.targetUrl.isIn(targetUrls));
    }

    if (pingMethods != null && pingMethods.isNotEmpty) {
      query.where((tbl) => tbl.pingMethod.isIn(pingMethods));
    }

    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.dataTime)])).watch();
  }

  Future<void> cleanupLogs(List<DateTime> monthsToDelete) async {
    if (monthsToDelete.isEmpty) return;

    final monthStrings = monthsToDelete.map((d) {
      final m = d.month.toString().padLeft(2, '0');
      return '${d.year}-$m';
    }).toList();

    final yearMonthExpr = CustomExpression<String>(
      "strftime('%Y-%m', data_time, 'unixepoch', 'localtime')",
    );

    await (delete(pingLogs)..where((tbl) => yearMonthExpr.isIn(monthStrings))).go();
  }

  Future<List<MonthStats>> getUsedMonths() async {
    final query = customSelect(
      '''
    SELECT
      strftime('%m.%Y', data_time, 'unixepoch', 'localtime') as monthYear,
      COUNT(id) as pingCount,
      SUM(LENGTH(target_url) + LENGTH(ping_method) + COALESCE(LENGTH(network_details), 0) + 24) as approxBytes
    FROM ping_logs
    GROUP BY strftime('%Y-%m', data_time, 'unixepoch', 'localtime')
    ORDER BY strftime('%Y-%m', data_time, 'unixepoch', 'localtime') DESC
    ''',
      readsFrom: {pingLogs},
    );

    final rows = await query.get();
    return rows.map((row) {
      final bytes = row.read<int>('approxBytes');
      final mb = bytes / (1024 * 1024);
      return MonthStats(
        monthYear: row.read<String>('monthYear'),
        pingCount: row.read<int>('pingCount'),
        sizeMb: double.parse(mb.toStringAsFixed(2)),
      );
    }).toList();
  }

  Future<DayStats> getDayStats(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final logs =
        await (select(pingLogs)
              ..where((tbl) => tbl.dataTime.isBetweenValues(start, end))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.dataTime)]))
            .get();

    final totalPings = logs.length;

    final validPings = logs.where((log) => log.latencyMs != null).toList();

    if (validPings.isEmpty) {
      return DayStats(
        totalPings: totalPings,
        avgPingMs: 0,
        minPingMs: null,
        maxPingMs: null,
        logs: logs,
      );
    }

    final latencies = validPings.map((l) => l.latencyMs!).toList();
    final avgPing = latencies.reduce((a, b) => a + b) / latencies.length;
    final minPing = latencies.reduce((a, b) => a < b ? a : b);
    final maxPing = latencies.reduce((a, b) => a > b ? a : b);

    return DayStats(
      totalPings: totalPings,
      avgPingMs: double.parse(avgPing.toStringAsFixed(2)),
      minPingMs: minPing,
      maxPingMs: maxPing,
      logs: logs,
    );
  }

  Future<PeriodStats> getDayStatsGeneric(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return _getPeriodStats(start, end, StatsPeriod.day);
  }

  Future<PeriodStats> getWeekStats(DateTime weekStart) async {
    final start = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
      0,
      0,
      0,
      0,
    );
    final end = start.add(
      const Duration(
        days: 6,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
      ),
    );
    return _getPeriodStats(start, end, StatsPeriod.week);
  }

  Future<PeriodStats> getMonthStats(DateTime monthDate) async {
    final start = DateTime(monthDate.year, monthDate.month, 1, 0, 0, 0, 0);
    final end = DateTime(
      monthDate.year,
      monthDate.month + 1,
      0,
      23,
      59,
      59,
      999,
    );
    return _getPeriodStats(start, end, StatsPeriod.month);
  }

  Future<PeriodStats> _getPeriodStats(
    DateTime start,
    DateTime end,
    StatsPeriod period,
  ) async {
    final logs =
        await (select(pingLogs)
              ..where((tbl) => tbl.dataTime.isBetweenValues(start, end))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.dataTime)]))
            .get();

    final totalPings = logs.length;
    final validPings = logs.where((log) => log.latencyMs != null).toList();

    if (validPings.isEmpty) {
      return PeriodStats(
        totalPings: totalPings,
        avgPingMs: 0,
        minPingMs: null,
        maxPingMs: null,
        logs: logs,
        startDate: start,
        endDate: end,
        period: period,
      );
    }

    final latencies = validPings.map((l) => l.latencyMs!).toList();
    final avgPing = latencies.reduce((a, b) => a + b) / latencies.length;
    final minPing = latencies.reduce((a, b) => a < b ? a : b);
    final maxPing = latencies.reduce((a, b) => a > b ? a : b);

    return PeriodStats(
      totalPings: totalPings,
      avgPingMs: double.parse(avgPing.toStringAsFixed(2)),
      minPingMs: minPing,
      maxPingMs: maxPing,
      logs: logs,
      startDate: start,
      endDate: end,
      period: period,
    );
  }
}

Future<AppDatabase> getDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'ping_logs.sqlite'));
  return AppDatabase(NativeDatabase(file));
}
