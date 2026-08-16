// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PingLogsTable extends PingLogs with TableInfo<$PingLogsTable, PingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PingLogsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumn<DateTime> dataTime = GeneratedColumn<DateTime>(
    'data_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumn<String> targetUrl = GeneratedColumn<String>(
    'target_url',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumn<String> pingMethod = GeneratedColumn<String>(
    'ping_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumn<String> networkDetails = GeneratedColumn<String>(
    'network_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dataTime,
    targetUrl,
    statusCode,
    latencyMs,
    pingMethod,
    networkDetails,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ping_logs';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dataTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_time'],
      )!,
      targetUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_url'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      pingMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ping_method'],
      )!,
      networkDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_details'],
      ),
    );
  }

  @override
  $PingLogsTable createAlias(String alias) {
    return $PingLogsTable(attachedDatabase, alias);
  }
}

class PingLog extends DataClass implements Insertable<PingLog> {
  final int id;
  final DateTime dataTime;
  final String targetUrl;
  final int? statusCode;
  final int? latencyMs;
  final String pingMethod;
  final String? networkDetails;
  const PingLog({
    required this.id,
    required this.dataTime,
    required this.targetUrl,
    this.statusCode,
    this.latencyMs,
    required this.pingMethod,
    this.networkDetails,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data_time'] = Variable<DateTime>(dataTime);
    map['target_url'] = Variable<String>(targetUrl);
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    map['ping_method'] = Variable<String>(pingMethod);
    if (!nullToAbsent || networkDetails != null) {
      map['network_details'] = Variable<String>(networkDetails);
    }
    return map;
  }

  PingLogsCompanion toCompanion(bool nullToAbsent) {
    return PingLogsCompanion(
      id: Value(id),
      dataTime: Value(dataTime),
      targetUrl: Value(targetUrl),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      pingMethod: Value(pingMethod),
      networkDetails: networkDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(networkDetails),
    );
  }

  factory PingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PingLog(
      id: serializer.fromJson<int>(json['id']),
      dataTime: serializer.fromJson<DateTime>(json['dataTime']),
      targetUrl: serializer.fromJson<String>(json['targetUrl']),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      pingMethod: serializer.fromJson<String>(json['pingMethod']),
      networkDetails: serializer.fromJson<String?>(json['networkDetails']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dataTime': serializer.toJson<DateTime>(dataTime),
      'targetUrl': serializer.toJson<String>(targetUrl),
      'statusCode': serializer.toJson<int?>(statusCode),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'pingMethod': serializer.toJson<String>(pingMethod),
      'networkDetails': serializer.toJson<String?>(networkDetails),
    };
  }

  PingLog copyWith({
    int? id,
    DateTime? dataTime,
    String? targetUrl,
    Value<int?> statusCode = const Value.absent(),
    Value<int?> latencyMs = const Value.absent(),
    String? pingMethod,
    Value<String?> networkDetails = const Value.absent(),
  }) => PingLog(
    id: id ?? this.id,
    dataTime: dataTime ?? this.dataTime,
    targetUrl: targetUrl ?? this.targetUrl,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    pingMethod: pingMethod ?? this.pingMethod,
    networkDetails: networkDetails.present
        ? networkDetails.value
        : this.networkDetails,
  );
  PingLog copyWithCompanion(PingLogsCompanion data) {
    return PingLog(
      id: data.id.present ? data.id.value : this.id,
      dataTime: data.dataTime.present ? data.dataTime.value : this.dataTime,
      targetUrl: data.targetUrl.present ? data.targetUrl.value : this.targetUrl,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      pingMethod: data.pingMethod.present
          ? data.pingMethod.value
          : this.pingMethod,
      networkDetails: data.networkDetails.present
          ? data.networkDetails.value
          : this.networkDetails,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PingLog(')
          ..write('id: $id, ')
          ..write('dataTime: $dataTime, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('statusCode: $statusCode, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('pingMethod: $pingMethod, ')
          ..write('networkDetails: $networkDetails')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dataTime,
    targetUrl,
    statusCode,
    latencyMs,
    pingMethod,
    networkDetails,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PingLog &&
          other.id == this.id &&
          other.dataTime == this.dataTime &&
          other.targetUrl == this.targetUrl &&
          other.statusCode == this.statusCode &&
          other.latencyMs == this.latencyMs &&
          other.pingMethod == this.pingMethod &&
          other.networkDetails == this.networkDetails);
}

class PingLogsCompanion extends UpdateCompanion<PingLog> {
  final Value<int> id;
  final Value<DateTime> dataTime;
  final Value<String> targetUrl;
  final Value<int?> statusCode;
  final Value<int?> latencyMs;
  final Value<String> pingMethod;
  final Value<String?> networkDetails;
  const PingLogsCompanion({
    this.id = const Value.absent(),
    this.dataTime = const Value.absent(),
    this.targetUrl = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.pingMethod = const Value.absent(),
    this.networkDetails = const Value.absent(),
  });
  PingLogsCompanion.insert({
    this.id = const Value.absent(),
    this.dataTime = const Value.absent(),
    required String targetUrl,
    this.statusCode = const Value.absent(),
    this.latencyMs = const Value.absent(),
    required String pingMethod,
    this.networkDetails = const Value.absent(),
  }) : targetUrl = Value(targetUrl),
       pingMethod = Value(pingMethod);
  static Insertable<PingLog> custom({
    Expression<int>? id,
    Expression<DateTime>? dataTime,
    Expression<String>? targetUrl,
    Expression<int>? statusCode,
    Expression<int>? latencyMs,
    Expression<String>? pingMethod,
    Expression<String>? networkDetails,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dataTime != null) 'data_time': dataTime,
      if (targetUrl != null) 'target_url': targetUrl,
      if (statusCode != null) 'status_code': statusCode,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (pingMethod != null) 'ping_method': pingMethod,
      if (networkDetails != null) 'network_details': networkDetails,
    });
  }

  PingLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? dataTime,
    Value<String>? targetUrl,
    Value<int?>? statusCode,
    Value<int?>? latencyMs,
    Value<String>? pingMethod,
    Value<String?>? networkDetails,
  }) {
    return PingLogsCompanion(
      id: id ?? this.id,
      dataTime: dataTime ?? this.dataTime,
      targetUrl: targetUrl ?? this.targetUrl,
      statusCode: statusCode ?? this.statusCode,
      latencyMs: latencyMs ?? this.latencyMs,
      pingMethod: pingMethod ?? this.pingMethod,
      networkDetails: networkDetails ?? this.networkDetails,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dataTime.present) {
      map['data_time'] = Variable<DateTime>(dataTime.value);
    }
    if (targetUrl.present) {
      map['target_url'] = Variable<String>(targetUrl.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (pingMethod.present) {
      map['ping_method'] = Variable<String>(pingMethod.value);
    }
    if (networkDetails.present) {
      map['network_details'] = Variable<String>(networkDetails.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PingLogsCompanion(')
          ..write('id: $id, ')
          ..write('dataTime: $dataTime, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('statusCode: $statusCode, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('pingMethod: $pingMethod, ')
          ..write('networkDetails: $networkDetails')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PingLogsTable pingLogs = $PingLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pingLogs];
}

typedef $$PingLogsTableCreateCompanionBuilder =
    PingLogsCompanion Function({
      Value<int> id,
      Value<DateTime> dataTime,
      required String targetUrl,
      Value<int?> statusCode,
      Value<int?> latencyMs,
      required String pingMethod,
      Value<String?> networkDetails,
    });
typedef $$PingLogsTableUpdateCompanionBuilder =
    PingLogsCompanion Function({
      Value<int> id,
      Value<DateTime> dataTime,
      Value<String> targetUrl,
      Value<int?> statusCode,
      Value<int?> latencyMs,
      Value<String> pingMethod,
      Value<String?> networkDetails,
    });

class $$PingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PingLogsTable> {
  $$PingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataTime => $composableBuilder(
    column: $table.dataTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pingMethod => $composableBuilder(
    column: $table.pingMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get networkDetails => $composableBuilder(
    column: $table.networkDetails,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PingLogsTable> {
  $$PingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataTime => $composableBuilder(
    column: $table.dataTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pingMethod => $composableBuilder(
    column: $table.pingMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get networkDetails => $composableBuilder(
    column: $table.networkDetails,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PingLogsTable> {
  $$PingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dataTime =>
      $composableBuilder(column: $table.dataTime, builder: (column) => column);

  GeneratedColumn<String> get targetUrl =>
      $composableBuilder(column: $table.targetUrl, builder: (column) => column);

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<String> get pingMethod => $composableBuilder(
    column: $table.pingMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get networkDetails => $composableBuilder(
    column: $table.networkDetails,
    builder: (column) => column,
  );
}

class $$PingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PingLogsTable,
          PingLog,
          $$PingLogsTableFilterComposer,
          $$PingLogsTableOrderingComposer,
          $$PingLogsTableAnnotationComposer,
          $$PingLogsTableCreateCompanionBuilder,
          $$PingLogsTableUpdateCompanionBuilder,
          (PingLog, BaseReferences<_$AppDatabase, $PingLogsTable, PingLog>),
          PingLog,
          PrefetchHooks Function()
        > {
  $$PingLogsTableTableManager(_$AppDatabase db, $PingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> dataTime = const Value.absent(),
                Value<String> targetUrl = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<String> pingMethod = const Value.absent(),
                Value<String?> networkDetails = const Value.absent(),
              }) => PingLogsCompanion(
                id: id,
                dataTime: dataTime,
                targetUrl: targetUrl,
                statusCode: statusCode,
                latencyMs: latencyMs,
                pingMethod: pingMethod,
                networkDetails: networkDetails,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> dataTime = const Value.absent(),
                required String targetUrl,
                Value<int?> statusCode = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                required String pingMethod,
                Value<String?> networkDetails = const Value.absent(),
              }) => PingLogsCompanion.insert(
                id: id,
                dataTime: dataTime,
                targetUrl: targetUrl,
                statusCode: statusCode,
                latencyMs: latencyMs,
                pingMethod: pingMethod,
                networkDetails: networkDetails,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PingLogsTable,
      PingLog,
      $$PingLogsTableFilterComposer,
      $$PingLogsTableOrderingComposer,
      $$PingLogsTableAnnotationComposer,
      $$PingLogsTableCreateCompanionBuilder,
      $$PingLogsTableUpdateCompanionBuilder,
      (PingLog, BaseReferences<_$AppDatabase, $PingLogsTable, PingLog>),
      PingLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PingLogsTableTableManager get pingLogs =>
      $$PingLogsTableTableManager(_db, _db.pingLogs);
}
