// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatExtMeta =
      const VerificationMeta('formatExt');
  @override
  late final GeneratedColumn<String> formatExt = GeneratedColumn<String>(
      'format_ext', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mp4'));
  static const VerificationMeta _targetFolderMeta =
      const VerificationMeta('targetFolder');
  @override
  late final GeneratedColumn<String> targetFolder = GeneratedColumn<String>(
      'target_folder', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch ~/ 1000);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, url, type, formatExt, targetFolder, downloadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_table';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('format_ext')) {
      context.handle(_formatExtMeta,
          formatExt.isAcceptableOrUnknown(data['format_ext']!, _formatExtMeta));
    }
    if (data.containsKey('target_folder')) {
      context.handle(
          _targetFolderMeta,
          targetFolder.isAcceptableOrUnknown(
              data['target_folder']!, _targetFolderMeta));
    } else if (isInserting) {
      context.missing(_targetFolderMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      formatExt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_ext'])!,
      targetFolder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_folder'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downloaded_at'])!,
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }
}

class HistoryTableData extends DataClass
    implements Insertable<HistoryTableData> {
  final int id;
  final String title;
  final String url;
  final String type;
  final String formatExt;
  final String targetFolder;
  final int downloadedAt;
  const HistoryTableData(
      {required this.id,
      required this.title,
      required this.url,
      required this.type,
      required this.formatExt,
      required this.targetFolder,
      required this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['type'] = Variable<String>(type);
    map['format_ext'] = Variable<String>(formatExt);
    map['target_folder'] = Variable<String>(targetFolder);
    map['downloaded_at'] = Variable<int>(downloadedAt);
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      type: Value(type),
      formatExt: Value(formatExt),
      targetFolder: Value(targetFolder),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory HistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      type: serializer.fromJson<String>(json['type']),
      formatExt: serializer.fromJson<String>(json['formatExt']),
      targetFolder: serializer.fromJson<String>(json['targetFolder']),
      downloadedAt: serializer.fromJson<int>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'type': serializer.toJson<String>(type),
      'formatExt': serializer.toJson<String>(formatExt),
      'targetFolder': serializer.toJson<String>(targetFolder),
      'downloadedAt': serializer.toJson<int>(downloadedAt),
    };
  }

  HistoryTableData copyWith(
          {int? id,
          String? title,
          String? url,
          String? type,
          String? formatExt,
          String? targetFolder,
          int? downloadedAt}) =>
      HistoryTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
        type: type ?? this.type,
        formatExt: formatExt ?? this.formatExt,
        targetFolder: targetFolder ?? this.targetFolder,
        downloadedAt: downloadedAt ?? this.downloadedAt,
      );
  HistoryTableData copyWithCompanion(HistoryTableCompanion data) {
    return HistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      type: data.type.present ? data.type.value : this.type,
      formatExt: data.formatExt.present ? data.formatExt.value : this.formatExt,
      targetFolder: data.targetFolder.present
          ? data.targetFolder.value
          : this.targetFolder,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('formatExt: $formatExt, ')
          ..write('targetFolder: $targetFolder, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, url, type, formatExt, targetFolder, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.type == this.type &&
          other.formatExt == this.formatExt &&
          other.targetFolder == this.targetFolder &&
          other.downloadedAt == this.downloadedAt);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String> type;
  final Value<String> formatExt;
  final Value<String> targetFolder;
  final Value<int> downloadedAt;
  const HistoryTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
    this.formatExt = const Value.absent(),
    this.targetFolder = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String url,
    required String type,
    this.formatExt = const Value.absent(),
    required String targetFolder,
    this.downloadedAt = const Value.absent(),
  })  : title = Value(title),
        url = Value(url),
        type = Value(type),
        targetFolder = Value(targetFolder);
  static Insertable<HistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? type,
    Expression<String>? formatExt,
    Expression<String>? targetFolder,
    Expression<int>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (formatExt != null) 'format_ext': formatExt,
      if (targetFolder != null) 'target_folder': targetFolder,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  HistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? url,
      Value<String>? type,
      Value<String>? formatExt,
      Value<String>? targetFolder,
      Value<int>? downloadedAt}) {
    return HistoryTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
      formatExt: formatExt ?? this.formatExt,
      targetFolder: targetFolder ?? this.targetFolder,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (formatExt.present) {
      map['format_ext'] = Variable<String>(formatExt.value);
    }
    if (targetFolder.present) {
      map['target_folder'] = Variable<String>(targetFolder.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('formatExt: $formatExt, ')
          ..write('targetFolder: $targetFolder, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $CacheTableTable extends CacheTable
    with TableInfo<$CacheTableTable, CacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch ~/ 1000);
  @override
  List<GeneratedColumn> get $columns => [url, metadataJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_table';
  @override
  VerificationContext validateIntegrity(Insertable<CacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  CacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheTableData(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CacheTableTable createAlias(String alias) {
    return $CacheTableTable(attachedDatabase, alias);
  }
}

class CacheTableData extends DataClass implements Insertable<CacheTableData> {
  final String url;
  final String metadataJson;
  final int cachedAt;
  const CacheTableData(
      {required this.url, required this.metadataJson, required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  CacheTableCompanion toCompanion(bool nullToAbsent) {
    return CacheTableCompanion(
      url: Value(url),
      metadataJson: Value(metadataJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheTableData(
      url: serializer.fromJson<String>(json['url']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  CacheTableData copyWith({String? url, String? metadataJson, int? cachedAt}) =>
      CacheTableData(
        url: url ?? this.url,
        metadataJson: metadataJson ?? this.metadataJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CacheTableData copyWithCompanion(CacheTableCompanion data) {
    return CacheTableData(
      url: data.url.present ? data.url.value : this.url,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheTableData(')
          ..write('url: $url, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, metadataJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheTableData &&
          other.url == this.url &&
          other.metadataJson == this.metadataJson &&
          other.cachedAt == this.cachedAt);
}

class CacheTableCompanion extends UpdateCompanion<CacheTableData> {
  final Value<String> url;
  final Value<String> metadataJson;
  final Value<int> cachedAt;
  final Value<int> rowid;
  const CacheTableCompanion({
    this.url = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheTableCompanion.insert({
    required String url,
    required String metadataJson,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : url = Value(url),
        metadataJson = Value(metadataJson);
  static Insertable<CacheTableData> custom({
    Expression<String>? url,
    Expression<String>? metadataJson,
    Expression<int>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheTableCompanion copyWith(
      {Value<String>? url,
      Value<String>? metadataJson,
      Value<int>? cachedAt,
      Value<int>? rowid}) {
    return CacheTableCompanion(
      url: url ?? this.url,
      metadataJson: metadataJson ?? this.metadataJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheTableCompanion(')
          ..write('url: $url, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadQueueTableTable extends DownloadQueueTable
    with TableInfo<$DownloadQueueTableTable, DownloadQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailMeta =
      const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
      'thumbnail', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetFolderMeta =
      const VerificationMeta('targetFolder');
  @override
  late final GeneratedColumn<String> targetFolder = GeneratedColumn<String>(
      'target_folder', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatIdMeta =
      const VerificationMeta('formatId');
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
      'format_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatExtMeta =
      const VerificationMeta('formatExt');
  @override
  late final GeneratedColumn<String> formatExt = GeneratedColumn<String>(
      'format_ext', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mp4'));
  static const VerificationMeta _displayLabelMeta =
      const VerificationMeta('displayLabel');
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
      'display_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  @override
  List<GeneratedColumn> get $columns => [
        taskId,
        url,
        title,
        thumbnail,
        targetFolder,
        formatId,
        formatExt,
        displayLabel,
        progress,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_queue_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DownloadQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    } else if (isInserting) {
      context.missing(_thumbnailMeta);
    }
    if (data.containsKey('target_folder')) {
      context.handle(
          _targetFolderMeta,
          targetFolder.isAcceptableOrUnknown(
              data['target_folder']!, _targetFolderMeta));
    } else if (isInserting) {
      context.missing(_targetFolderMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(_formatIdMeta,
          formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta));
    }
    if (data.containsKey('format_ext')) {
      context.handle(_formatExtMeta,
          formatExt.isAcceptableOrUnknown(data['format_ext']!, _formatExtMeta));
    }
    if (data.containsKey('display_label')) {
      context.handle(
          _displayLabelMeta,
          displayLabel.isAcceptableOrUnknown(
              data['display_label']!, _displayLabelMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  DownloadQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadQueueTableData(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      thumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail'])!,
      targetFolder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_folder'])!,
      formatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_id']),
      formatExt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_ext'])!,
      displayLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_label']),
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $DownloadQueueTableTable createAlias(String alias) {
    return $DownloadQueueTableTable(attachedDatabase, alias);
  }
}

class DownloadQueueTableData extends DataClass
    implements Insertable<DownloadQueueTableData> {
  final String taskId;
  final String url;
  final String title;
  final String thumbnail;
  final String targetFolder;
  final String? formatId;
  final String formatExt;
  final String? displayLabel;
  final double progress;
  final String status;
  const DownloadQueueTableData(
      {required this.taskId,
      required this.url,
      required this.title,
      required this.thumbnail,
      required this.targetFolder,
      this.formatId,
      required this.formatExt,
      this.displayLabel,
      required this.progress,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['thumbnail'] = Variable<String>(thumbnail);
    map['target_folder'] = Variable<String>(targetFolder);
    if (!nullToAbsent || formatId != null) {
      map['format_id'] = Variable<String>(formatId);
    }
    map['format_ext'] = Variable<String>(formatExt);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    map['progress'] = Variable<double>(progress);
    map['status'] = Variable<String>(status);
    return map;
  }

  DownloadQueueTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadQueueTableCompanion(
      taskId: Value(taskId),
      url: Value(url),
      title: Value(title),
      thumbnail: Value(thumbnail),
      targetFolder: Value(targetFolder),
      formatId: formatId == null && nullToAbsent
          ? const Value.absent()
          : Value(formatId),
      formatExt: Value(formatExt),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
      progress: Value(progress),
      status: Value(status),
    );
  }

  factory DownloadQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadQueueTableData(
      taskId: serializer.fromJson<String>(json['taskId']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      thumbnail: serializer.fromJson<String>(json['thumbnail']),
      targetFolder: serializer.fromJson<String>(json['targetFolder']),
      formatId: serializer.fromJson<String?>(json['formatId']),
      formatExt: serializer.fromJson<String>(json['formatExt']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
      progress: serializer.fromJson<double>(json['progress']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'thumbnail': serializer.toJson<String>(thumbnail),
      'targetFolder': serializer.toJson<String>(targetFolder),
      'formatId': serializer.toJson<String?>(formatId),
      'formatExt': serializer.toJson<String>(formatExt),
      'displayLabel': serializer.toJson<String?>(displayLabel),
      'progress': serializer.toJson<double>(progress),
      'status': serializer.toJson<String>(status),
    };
  }

  DownloadQueueTableData copyWith(
          {String? taskId,
          String? url,
          String? title,
          String? thumbnail,
          String? targetFolder,
          Value<String?> formatId = const Value.absent(),
          String? formatExt,
          Value<String?> displayLabel = const Value.absent(),
          double? progress,
          String? status}) =>
      DownloadQueueTableData(
        taskId: taskId ?? this.taskId,
        url: url ?? this.url,
        title: title ?? this.title,
        thumbnail: thumbnail ?? this.thumbnail,
        targetFolder: targetFolder ?? this.targetFolder,
        formatId: formatId.present ? formatId.value : this.formatId,
        formatExt: formatExt ?? this.formatExt,
        displayLabel:
            displayLabel.present ? displayLabel.value : this.displayLabel,
        progress: progress ?? this.progress,
        status: status ?? this.status,
      );
  DownloadQueueTableData copyWithCompanion(DownloadQueueTableCompanion data) {
    return DownloadQueueTableData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      targetFolder: data.targetFolder.present
          ? data.targetFolder.value
          : this.targetFolder,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      formatExt: data.formatExt.present ? data.formatExt.value : this.formatExt,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      progress: data.progress.present ? data.progress.value : this.progress,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueueTableData(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('targetFolder: $targetFolder, ')
          ..write('formatId: $formatId, ')
          ..write('formatExt: $formatExt, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('progress: $progress, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, url, title, thumbnail, targetFolder,
      formatId, formatExt, displayLabel, progress, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadQueueTableData &&
          other.taskId == this.taskId &&
          other.url == this.url &&
          other.title == this.title &&
          other.thumbnail == this.thumbnail &&
          other.targetFolder == this.targetFolder &&
          other.formatId == this.formatId &&
          other.formatExt == this.formatExt &&
          other.displayLabel == this.displayLabel &&
          other.progress == this.progress &&
          other.status == this.status);
}

class DownloadQueueTableCompanion
    extends UpdateCompanion<DownloadQueueTableData> {
  final Value<String> taskId;
  final Value<String> url;
  final Value<String> title;
  final Value<String> thumbnail;
  final Value<String> targetFolder;
  final Value<String?> formatId;
  final Value<String> formatExt;
  final Value<String?> displayLabel;
  final Value<double> progress;
  final Value<String> status;
  final Value<int> rowid;
  const DownloadQueueTableCompanion({
    this.taskId = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.targetFolder = const Value.absent(),
    this.formatId = const Value.absent(),
    this.formatExt = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadQueueTableCompanion.insert({
    required String taskId,
    required String url,
    required String title,
    required String thumbnail,
    required String targetFolder,
    this.formatId = const Value.absent(),
    this.formatExt = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        url = Value(url),
        title = Value(title),
        thumbnail = Value(thumbnail),
        targetFolder = Value(targetFolder);
  static Insertable<DownloadQueueTableData> custom({
    Expression<String>? taskId,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? thumbnail,
    Expression<String>? targetFolder,
    Expression<String>? formatId,
    Expression<String>? formatExt,
    Expression<String>? displayLabel,
    Expression<double>? progress,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (targetFolder != null) 'target_folder': targetFolder,
      if (formatId != null) 'format_id': formatId,
      if (formatExt != null) 'format_ext': formatExt,
      if (displayLabel != null) 'display_label': displayLabel,
      if (progress != null) 'progress': progress,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadQueueTableCompanion copyWith(
      {Value<String>? taskId,
      Value<String>? url,
      Value<String>? title,
      Value<String>? thumbnail,
      Value<String>? targetFolder,
      Value<String?>? formatId,
      Value<String>? formatExt,
      Value<String?>? displayLabel,
      Value<double>? progress,
      Value<String>? status,
      Value<int>? rowid}) {
    return DownloadQueueTableCompanion(
      taskId: taskId ?? this.taskId,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      targetFolder: targetFolder ?? this.targetFolder,
      formatId: formatId ?? this.formatId,
      formatExt: formatExt ?? this.formatExt,
      displayLabel: displayLabel ?? this.displayLabel,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (targetFolder.present) {
      map['target_folder'] = Variable<String>(targetFolder.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (formatExt.present) {
      map['format_ext'] = Variable<String>(formatExt.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueueTableCompanion(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('targetFolder: $targetFolder, ')
          ..write('formatId: $formatId, ')
          ..write('formatExt: $formatExt, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('progress: $progress, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  late final $CacheTableTable cacheTable = $CacheTableTable(this);
  late final $DownloadQueueTableTable downloadQueueTable =
      $DownloadQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [historyTable, cacheTable, downloadQueueTable];
}

typedef $$HistoryTableTableCreateCompanionBuilder = HistoryTableCompanion
    Function({
  Value<int> id,
  required String title,
  required String url,
  required String type,
  Value<String> formatExt,
  required String targetFolder,
  Value<int> downloadedAt,
});
typedef $$HistoryTableTableUpdateCompanionBuilder = HistoryTableCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> url,
  Value<String> type,
  Value<String> formatExt,
  Value<String> targetFolder,
  Value<int> downloadedAt,
});

class $$HistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get formatExt =>
      $composableBuilder(column: $table.formatExt, builder: (column) => column);

  GeneratedColumn<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => column);

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$HistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryTableTable,
    HistoryTableData,
    $$HistoryTableTableFilterComposer,
    $$HistoryTableTableOrderingComposer,
    $$HistoryTableTableAnnotationComposer,
    $$HistoryTableTableCreateCompanionBuilder,
    $$HistoryTableTableUpdateCompanionBuilder,
    (
      HistoryTableData,
      BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>
    ),
    HistoryTableData,
    PrefetchHooks Function()> {
  $$HistoryTableTableTableManager(_$AppDatabase db, $HistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> formatExt = const Value.absent(),
            Value<String> targetFolder = const Value.absent(),
            Value<int> downloadedAt = const Value.absent(),
          }) =>
              HistoryTableCompanion(
            id: id,
            title: title,
            url: url,
            type: type,
            formatExt: formatExt,
            targetFolder: targetFolder,
            downloadedAt: downloadedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String url,
            required String type,
            Value<String> formatExt = const Value.absent(),
            required String targetFolder,
            Value<int> downloadedAt = const Value.absent(),
          }) =>
              HistoryTableCompanion.insert(
            id: id,
            title: title,
            url: url,
            type: type,
            formatExt: formatExt,
            targetFolder: targetFolder,
            downloadedAt: downloadedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryTableTable,
    HistoryTableData,
    $$HistoryTableTableFilterComposer,
    $$HistoryTableTableOrderingComposer,
    $$HistoryTableTableAnnotationComposer,
    $$HistoryTableTableCreateCompanionBuilder,
    $$HistoryTableTableUpdateCompanionBuilder,
    (
      HistoryTableData,
      BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>
    ),
    HistoryTableData,
    PrefetchHooks Function()>;
typedef $$CacheTableTableCreateCompanionBuilder = CacheTableCompanion Function({
  required String url,
  required String metadataJson,
  Value<int> cachedAt,
  Value<int> rowid,
});
typedef $$CacheTableTableUpdateCompanionBuilder = CacheTableCompanion Function({
  Value<String> url,
  Value<String> metadataJson,
  Value<int> cachedAt,
  Value<int> rowid,
});

class $$CacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $CacheTableTable> {
  $$CacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTableTable> {
  $$CacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTableTable> {
  $$CacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CacheTableTable,
    CacheTableData,
    $$CacheTableTableFilterComposer,
    $$CacheTableTableOrderingComposer,
    $$CacheTableTableAnnotationComposer,
    $$CacheTableTableCreateCompanionBuilder,
    $$CacheTableTableUpdateCompanionBuilder,
    (
      CacheTableData,
      BaseReferences<_$AppDatabase, $CacheTableTable, CacheTableData>
    ),
    CacheTableData,
    PrefetchHooks Function()> {
  $$CacheTableTableTableManager(_$AppDatabase db, $CacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<int> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheTableCompanion(
            url: url,
            metadataJson: metadataJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            required String metadataJson,
            Value<int> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheTableCompanion.insert(
            url: url,
            metadataJson: metadataJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CacheTableTable,
    CacheTableData,
    $$CacheTableTableFilterComposer,
    $$CacheTableTableOrderingComposer,
    $$CacheTableTableAnnotationComposer,
    $$CacheTableTableCreateCompanionBuilder,
    $$CacheTableTableUpdateCompanionBuilder,
    (
      CacheTableData,
      BaseReferences<_$AppDatabase, $CacheTableTable, CacheTableData>
    ),
    CacheTableData,
    PrefetchHooks Function()>;
typedef $$DownloadQueueTableTableCreateCompanionBuilder
    = DownloadQueueTableCompanion Function({
  required String taskId,
  required String url,
  required String title,
  required String thumbnail,
  required String targetFolder,
  Value<String?> formatId,
  Value<String> formatExt,
  Value<String?> displayLabel,
  Value<double> progress,
  Value<String> status,
  Value<int> rowid,
});
typedef $$DownloadQueueTableTableUpdateCompanionBuilder
    = DownloadQueueTableCompanion Function({
  Value<String> taskId,
  Value<String> url,
  Value<String> title,
  Value<String> thumbnail,
  Value<String> targetFolder,
  Value<String?> formatId,
  Value<String> formatExt,
  Value<String?> displayLabel,
  Value<double> progress,
  Value<String> status,
  Value<int> rowid,
});

class $$DownloadQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadQueueTableTable> {
  $$DownloadQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatId => $composableBuilder(
      column: $table.formatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayLabel => $composableBuilder(
      column: $table.displayLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$DownloadQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadQueueTableTable> {
  $$DownloadQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatId => $composableBuilder(
      column: $table.formatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayLabel => $composableBuilder(
      column: $table.displayLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$DownloadQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadQueueTableTable> {
  $$DownloadQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => column);

  GeneratedColumn<String> get formatId =>
      $composableBuilder(column: $table.formatId, builder: (column) => column);

  GeneratedColumn<String> get formatExt =>
      $composableBuilder(column: $table.formatExt, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
      column: $table.displayLabel, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$DownloadQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadQueueTableTable,
    DownloadQueueTableData,
    $$DownloadQueueTableTableFilterComposer,
    $$DownloadQueueTableTableOrderingComposer,
    $$DownloadQueueTableTableAnnotationComposer,
    $$DownloadQueueTableTableCreateCompanionBuilder,
    $$DownloadQueueTableTableUpdateCompanionBuilder,
    (
      DownloadQueueTableData,
      BaseReferences<_$AppDatabase, $DownloadQueueTableTable,
          DownloadQueueTableData>
    ),
    DownloadQueueTableData,
    PrefetchHooks Function()> {
  $$DownloadQueueTableTableTableManager(
      _$AppDatabase db, $DownloadQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadQueueTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> thumbnail = const Value.absent(),
            Value<String> targetFolder = const Value.absent(),
            Value<String?> formatId = const Value.absent(),
            Value<String> formatExt = const Value.absent(),
            Value<String?> displayLabel = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadQueueTableCompanion(
            taskId: taskId,
            url: url,
            title: title,
            thumbnail: thumbnail,
            targetFolder: targetFolder,
            formatId: formatId,
            formatExt: formatExt,
            displayLabel: displayLabel,
            progress: progress,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String url,
            required String title,
            required String thumbnail,
            required String targetFolder,
            Value<String?> formatId = const Value.absent(),
            Value<String> formatExt = const Value.absent(),
            Value<String?> displayLabel = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadQueueTableCompanion.insert(
            taskId: taskId,
            url: url,
            title: title,
            thumbnail: thumbnail,
            targetFolder: targetFolder,
            formatId: formatId,
            formatExt: formatExt,
            displayLabel: displayLabel,
            progress: progress,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadQueueTableTable,
    DownloadQueueTableData,
    $$DownloadQueueTableTableFilterComposer,
    $$DownloadQueueTableTableOrderingComposer,
    $$DownloadQueueTableTableAnnotationComposer,
    $$DownloadQueueTableTableCreateCompanionBuilder,
    $$DownloadQueueTableTableUpdateCompanionBuilder,
    (
      DownloadQueueTableData,
      BaseReferences<_$AppDatabase, $DownloadQueueTableTable,
          DownloadQueueTableData>
    ),
    DownloadQueueTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
  $$CacheTableTableTableManager get cacheTable =>
      $$CacheTableTableTableManager(_db, _db.cacheTable);
  $$DownloadQueueTableTableTableManager get downloadQueueTable =>
      $$DownloadQueueTableTableTableManager(_db, _db.downloadQueueTable);
}
